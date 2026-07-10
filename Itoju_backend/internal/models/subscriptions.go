package models

import (
	"context"
	"database/sql"
	"time"
)

// Subscription mirrors a row of the subscriptions table: one per (user,
// entitlement), kept current by the RevenueCat webhook.
type Subscription struct {
	UserID      string
	RCAppUserID string
	Entitlement string
	Status      string
	Platform    string
	ProductID   string
	Environment string
	ExpiresAt   *time.Time
	LastEventID string
	LastEventAt time.Time
}

type SubscriptionModel struct {
	DB *sql.DB
}

// HasActiveEntitlement reports whether the user currently holds the entitlement.
// It keys on expiry (expires_at > now) rather than status, so a missed
// EXPIRATION webhook fails CLOSED — access lapses on its own when the paid period
// ends. A cancelled-but-not-yet-expired subscription stays entitled until expiry.
func (m SubscriptionModel) HasActiveEntitlement(ctx context.Context, userID, entitlement string) (bool, error) {
	query := `
	SELECT EXISTS(
		SELECT 1 FROM subscriptions
		WHERE user_id = $1 AND entitlement = $2 AND expires_at IS NOT NULL AND expires_at > now()
	)`
	ctx, cancel := context.WithTimeout(ctx, 3*time.Second)
	defer cancel()
	var ok bool
	if err := m.DB.QueryRowContext(ctx, query, userID, entitlement).Scan(&ok); err != nil {
		return false, err
	}
	return ok, nil
}

// UpsertFromWebhook applies a RevenueCat webhook event to the user's entitlement
// row. It is guarded by last_event_at so a duplicated or out-of-order webhook
// (RevenueCat retries and does not guarantee ordering) can never regress a newer
// state. A 0-row result (older event ignored) is not an error.
func (m SubscriptionModel) UpsertFromWebhook(ctx context.Context, s Subscription) error {
	query := `
	INSERT INTO subscriptions (
		user_id, rc_app_user_id, entitlement, status, platform, product_id,
		environment, expires_at, last_event_id, last_event_at, updated_at)
	VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10, now())
	ON CONFLICT (user_id, entitlement) DO UPDATE SET
		rc_app_user_id = EXCLUDED.rc_app_user_id,
		status = EXCLUDED.status,
		platform = EXCLUDED.platform,
		product_id = EXCLUDED.product_id,
		environment = EXCLUDED.environment,
		expires_at = EXCLUDED.expires_at,
		last_event_id = EXCLUDED.last_event_id,
		last_event_at = EXCLUDED.last_event_at,
		updated_at = now()
	WHERE subscriptions.last_event_at IS NULL
	   OR EXCLUDED.last_event_at > subscriptions.last_event_at`

	args := []any{
		s.UserID, s.RCAppUserID, s.Entitlement, s.Status, s.Platform, s.ProductID,
		s.Environment, s.ExpiresAt, s.LastEventID, s.LastEventAt,
	}
	ctx, cancel := context.WithTimeout(ctx, 3*time.Second)
	defer cancel()
	_, err := m.DB.ExecContext(ctx, query, args...)
	return err
}
