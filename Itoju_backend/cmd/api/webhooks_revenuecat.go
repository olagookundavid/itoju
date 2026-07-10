package api

import (
	"crypto/subtle"
	"net/http"
	"strings"
	"time"

	"github.com/olagookundavid/itoju/internal/models"
)

// rcWebhookEnvelope is the subset of a RevenueCat webhook we consume. RC posts
// {"event": {...}} with an Authorization header carrying the shared secret we
// configured in the RC dashboard.
type rcWebhookEnvelope struct {
	Event struct {
		ID               string   `json:"id"`
		Type             string   `json:"type"`
		AppUserID        string   `json:"app_user_id"`
		EntitlementIDs   []string `json:"entitlement_ids"`
		ProductID        string   `json:"product_id"`
		Store            string   `json:"store"`
		Environment      string   `json:"environment"`
		ExpirationAtMs   int64    `json:"expiration_at_ms"`
		EventTimestampMs int64    `json:"event_timestamp_ms"`
	} `json:"event"`
}

// HandleRevenueCatWebhook keeps a user's "sync" entitlement in step with
// RevenueCat. Auth is a constant-time comparison against the configured shared
// secret. Because RC retries on any non-2xx and may deliver events out of order
// or before an anonymous purchase is bound to an account, unknown users and
// stale events are acknowledged with 200 rather than retried forever; the model
// layer's last_event_at guard drops out-of-order updates.
func (app *Application) HandleRevenueCatWebhook(w http.ResponseWriter, r *http.Request) {
	if app.Config.RevenueCat.WebhookToken == "" {
		app.errorResponse(w, r, http.StatusServiceUnavailable, "revenuecat webhook not configured")
		return
	}
	// Authorization header, tolerant of an optional "Bearer " prefix.
	provided := strings.TrimSpace(strings.TrimPrefix(r.Header.Get("Authorization"), "Bearer "))
	if subtle.ConstantTimeCompare([]byte(provided), []byte(app.Config.RevenueCat.WebhookToken)) != 1 {
		app.invalidAuthenticationTokenResponse(w, r)
		return
	}

	var env rcWebhookEnvelope
	if err := app.readJSON(w, r, &env); err != nil {
		app.badRequestResponse(w, r, err)
		return
	}

	ev := env.Event
	status, expiresAt := rcStatusAndExpiry(ev.Type, ev.ExpirationAtMs)

	sub := models.Subscription{
		UserID:      ev.AppUserID,
		RCAppUserID: ev.AppUserID,
		Entitlement: "sync",
		Status:      status,
		Platform:    ev.Store,
		ProductID:   ev.ProductID,
		Environment: ev.Environment,
		ExpiresAt:   expiresAt,
		LastEventID: ev.ID,
		LastEventAt: msToTime(ev.EventTimestampMs),
	}

	err := app.Models.Subscriptions.UpsertFromWebhook(r.Context(), sub)
	switch {
	case err == nil:
		// applied (or a stale event that the last_event_at guard ignored)
	case models.IsForeignKeyViolation(err):
		// app_user_id is not (yet) a bound server user — e.g. an anonymous RC id
		// before sign-up. Ack so RC stops retrying; the client re-syncs on binding.
		app.Logger.PrintInfo("revenuecat webhook for unbound app_user_id", map[string]string{
			"app_user_id": ev.AppUserID, "event": ev.Type,
		})
	default:
		app.serverErrorResponse(w, r, err)
		return
	}
	app.respond(w, r, http.StatusOK, envelope{"message": "ok"})
}

// rcStatusAndExpiry maps a RevenueCat event type to our stored status and the
// entitlement expiry. CANCELLATION keeps the future expiry (entitled until the
// period ends); EXPIRATION/BILLING_ISSUE push expiry to now so access lapses.
func rcStatusAndExpiry(eventType string, expirationAtMs int64) (string, *time.Time) {
	exp := msToTimePtr(expirationAtMs)
	switch eventType {
	case "INITIAL_PURCHASE", "RENEWAL", "UNCANCELLATION", "PRODUCT_CHANGE", "NON_RENEWING_PURCHASE", "TRANSFER":
		return "active", exp
	case "CANCELLATION":
		return "cancelled", exp
	case "EXPIRATION":
		now := time.Now()
		return "expired", &now
	case "BILLING_ISSUE":
		now := time.Now()
		return "billing_issue", &now
	default:
		return strings.ToLower(eventType), exp
	}
}

func msToTime(ms int64) time.Time {
	if ms <= 0 {
		return time.Now()
	}
	return time.UnixMilli(ms).UTC()
}

func msToTimePtr(ms int64) *time.Time {
	if ms <= 0 {
		return nil
	}
	t := time.UnixMilli(ms).UTC()
	return &t
}
