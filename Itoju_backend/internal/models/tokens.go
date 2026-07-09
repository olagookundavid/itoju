package models

import (
	"context"
	"crypto/rand"
	"crypto/sha256"
	"database/sql"
	"encoding/base32"
	"fmt"
	"math/big"
	"time"

	"github.com/olagookundavid/itoju/internal/validator"
)

const (
	ScopeActivation     = "activation"
	ScopeAuthentication = "authentication"
	ScopePasswordReset  = "password-reset"
)

// AuthTokenTTL is how long an authentication (session) token stays valid before
// a full re-login is required. Kept long-lived so users aren't logged out
// frequently; the on-device app lock protects the session in the meantime, and
// tokens can be revoked server-side via logout.
const AuthTokenTTL = 90 * 24 * time.Hour

type Token struct {
	Plaintext string    `json:"token"`
	Hash      []byte    `json:"-"`
	UserID    string    `json:"-"`
	Expiry    time.Time `json:"expiry"`
	Scope     string    `json:"-"`
}

func generateToken(userID string, ttl time.Duration, scope string) (*Token, error) {
	token := &Token{
		UserID: userID,
		Expiry: time.Now().Add(ttl),
		Scope:  scope,
	}
	randomBytes := make([]byte, 16)
	_, err := rand.Read(randomBytes)
	if err != nil {
		return nil, err
	}
	token.Plaintext = base32.StdEncoding.WithPadding(base32.NoPadding).EncodeToString(randomBytes)
	hash := sha256.Sum256([]byte(token.Plaintext))
	token.Hash = hash[:]
	return token, nil
}
func ValidateTokenPlaintext(v *validator.Validator, tokenPlaintext string) {
	v.Check(tokenPlaintext != "", "token", "must be provided")
	v.Check(len(tokenPlaintext) == 26, "token", "must be 26 bytes long")
}

func ValidateOTPPlaintext(v *validator.Validator, otp string) {
	v.Check(otp != "", "otp", "must be provided")
	v.Check(len(otp) == 6, "otp", "must be 6 digits long")
}

// generateOTP builds a cryptographically-random 6-digit numeric one-time code.
// Only the SHA-256 hash is stored; the plaintext is emailed to the user.
func generateOTP(userID string, ttl time.Duration, scope string) (*Token, error) {
	token := &Token{
		UserID: userID,
		Expiry: time.Now().Add(ttl),
		Scope:  scope,
	}
	n, err := rand.Int(rand.Reader, big.NewInt(1000000))
	if err != nil {
		return nil, err
	}
	token.Plaintext = fmt.Sprintf("%06d", n.Int64())
	hash := sha256.Sum256([]byte(token.Plaintext))
	token.Hash = hash[:]
	return token, nil
}

type TokenModel struct {
	DB *sql.DB
}

func (m TokenModel) New(ctx context.Context, userID string, ttl time.Duration, scope string) (*Token, error) {
	token, err := generateToken(userID, ttl, scope)
	if err != nil {
		return nil, err
	}
	err = m.Insert(ctx, token)
	return token, err
}

// ReplacePasswordResetOTP atomically invalidates any existing password-reset
// codes for the user and issues a fresh one, returning the new plaintext OTP to
// email out. Doing the delete+insert in a single transaction avoids both the
// window where a user has no valid code (delete succeeded, insert failed) and
// the race where two concurrent requests leave two live codes.
func (m TokenModel) ReplacePasswordResetOTP(ctx context.Context, userID string, ttl time.Duration) (string, error) {
	token, err := generateOTP(userID, ttl, ScopePasswordReset)
	if err != nil {
		return "", err
	}
	ctx, cancel := context.WithTimeout(ctx, 3*time.Second)
	defer cancel()
	err = withTx(ctx, m.DB, func(tx *sql.Tx) error {
		if _, err := tx.ExecContext(ctx,
			`DELETE FROM tokens WHERE scope = $1 AND user_id = $2`,
			ScopePasswordReset, userID); err != nil {
			return err
		}
		if _, err := tx.ExecContext(ctx,
			`INSERT INTO tokens (hash, user_id, expiry, scope) VALUES ($1, $2, $3, $4)`,
			token.Hash, token.UserID, token.Expiry, token.Scope); err != nil {
			return err
		}
		return nil
	})
	if err != nil {
		return "", err
	}
	return token.Plaintext, nil
}

// Insert() adds the data for a specific token to the tokens table.
func (m TokenModel) Insert(ctx context.Context, token *Token) error {
	query := ` INSERT INTO tokens (hash, user_id, expiry, scope) VALUES ($1, $2, $3, $4)`
	args := []any{token.Hash, token.UserID, token.Expiry, token.Scope}
	ctx, cancel := context.WithTimeout(ctx, 3*time.Second)
	defer cancel()
	_, err := m.DB.ExecContext(ctx, query, args...)
	return err
}

// DeleteAllForUser() deletes all tokens for a specific user and scope.
func (m TokenModel) DeleteAllForUser(ctx context.Context, scope string, userID string) error {
	query := ` DELETE FROM tokens WHERE scope = $1 AND user_id = $2`
	ctx, cancel := context.WithTimeout(ctx, 3*time.Second)
	defer cancel()
	_, err := m.DB.ExecContext(ctx, query, scope, userID)
	return err
}

func (m TokenModel) DeleteAllExpiredTokens() error {
	query := ` DELETE FROM tokens WHERE tokens.expiry < NOW()`
	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()
	_, err := m.DB.ExecContext(ctx, query)

	return err
}
