package models

import (
	"context"
	"crypto/sha256"
	"database/sql"
	"errors"
	"time"

	"github.com/olagookundavid/itoju/internal/validator"
	"golang.org/x/crypto/bcrypt"
)

var AnonymousUser = &User{}

type User struct {
	ID        string    `json:"id"`
	CreatedAt time.Time `json:"created_at"`
	FirstName string    `json:"first_name"`
	LastName  string    `json:"last_name"`
	Dob       time.Time `json:"dob"`
	Email     string    `json:"email"`
	Password  password  `json:"-"`
	Activated bool      `json:"activated"`
	IsAdmin   bool      `json:"is_admin"`
	PicNo     int       `json:"pic_no"`
	Alias     string    `json:"alias"`
	Version   int       `json:"-"`
}

func (u *User) IsAnonymous() bool {
	return u == AnonymousUser
}

var (
	ErrDuplicateEmail = errors.New("duplicate email")
)

type UserModel struct {
	DB *sql.DB
}

type password struct {
	plaintext *string
	hash      []byte
}

func (p *password) Set(plaintextPassword string) error {
	hash, err := bcrypt.GenerateFromPassword([]byte(plaintextPassword), 12)
	if err != nil {
		return err
	}
	p.plaintext = &plaintextPassword
	p.hash = hash
	return nil
}

// HashPassword returns a bcrypt hash of the plaintext at the same cost used by
// (*password).Set. Exposed so callers that only need a hash (e.g. the atomic
// password-reset flow) can compute one without constructing a User.
func HashPassword(plaintextPassword string) ([]byte, error) {
	return bcrypt.GenerateFromPassword([]byte(plaintextPassword), 12)
}

func (p *password) Matches(plaintextPassword string) (bool, error) {
	err := bcrypt.CompareHashAndPassword(p.hash, []byte(plaintextPassword))
	if err != nil {
		switch {
		case errors.Is(err, bcrypt.ErrMismatchedHashAndPassword):
			return false, nil
		default:
			return false, err
		}
	}
	return true, nil
}

func ValidateEmail(v *validator.Validator, email string) {
	v.Check(email != "", "email", "must be provided")
	v.Check(validator.Matches(email, validator.EmailRX), "email", "must be a valid email address")
}
func ValidatePasswordPlaintext(v *validator.Validator, password string) {
	v.Check(password != "", "password", "must be provided")
	v.Check(len(password) >= 8, "password", "must be at least 8 bytes long")
	v.Check(len(password) <= 72, "password", "must not be more than 72 bytes long")
}
func ValidateUser(v *validator.Validator, user *User) {
	v.Check(user.FirstName != "", "first name", "must be provided")
	v.Check(user.LastName != "", "last name", "must be provided")
	v.Check(user.Dob.String() != "", "Date of birth", "must be provided")
	v.Check(len(user.FirstName) <= 500, "first_name", "must not be more than 500 bytes long")
	v.Check(len(user.LastName) <= 500, "last_name", "must not be more than 500 bytes long")
	v.Check(time.Since(user.Dob) >= 18*365*24*time.Hour, "dob", "must be older than 18years")
	ValidateEmail(v, user.Email)
	if user.Password.plaintext != nil {
		ValidatePasswordPlaintext(v, *user.Password.plaintext)
	}
	if user.Password.hash == nil {
		panic("missing password hash for user")
	}
}

func (m UserModel) Insert(ctx context.Context, user *User) error {
	query := ` INSERT INTO users (first_name, last_name, date_of_birth, email, password_hash, activated)
				VALUES ($1, $2, $3, $4, $5, $6)
				RETURNING id, created_at, version`
	args := []any{user.FirstName, user.LastName, user.Dob, user.Email, user.Password.hash, user.Activated}
	ctx, cancel := context.WithTimeout(ctx, 3*time.Second)
	defer cancel()
	err := m.DB.QueryRowContext(ctx, query, args...).Scan(&user.ID, &user.CreatedAt, &user.Version)
	if err != nil {
		switch {
		case isUniqueViolation(err, "users_email_key"):
			return ErrDuplicateEmail
		default:
			return err
		}
	}
	return nil
}

func (m UserModel) GetByEmail(ctx context.Context, email string) (*User, error) {
	query := ` SELECT id, created_at, first_name, last_name, date_of_birth, email, password_hash, activated, version, pic_no, alias, isAdmin FROM users
	WHERE email = $1`
	var user User
	ctx, cancel := context.WithTimeout(ctx, 3*time.Second)
	defer cancel()
	err := m.DB.QueryRowContext(ctx, query, email).Scan(
		&user.ID,
		&user.CreatedAt,
		&user.FirstName,
		&user.LastName,
		&user.Dob,
		&user.Email,
		&user.Password.hash,
		&user.Activated,
		&user.Version,
		&user.PicNo,
		&user.Alias,
		&user.IsAdmin)

	if err != nil {
		switch {
		case errors.Is(err, sql.ErrNoRows):
			return nil, ErrRecordNotFound
		default:
			return nil, err
		}
	}
	return &user, nil
}

// GetByFirebaseUID looks up the account a verified Firebase identity is bound
// to. Returns ErrRecordNotFound if no account is linked to that uid yet.
func (m UserModel) GetByFirebaseUID(ctx context.Context, uid string) (*User, error) {
	query := ` SELECT id, created_at, first_name, last_name, date_of_birth, email, password_hash, activated, version, pic_no, alias, isAdmin FROM users
	WHERE firebase_uid = $1`
	var user User
	ctx, cancel := context.WithTimeout(ctx, 3*time.Second)
	defer cancel()
	err := m.DB.QueryRowContext(ctx, query, uid).Scan(
		&user.ID, &user.CreatedAt, &user.FirstName, &user.LastName, &user.Dob,
		&user.Email, &user.Password.hash, &user.Activated, &user.Version,
		&user.PicNo, &user.Alias, &user.IsAdmin)
	if err != nil {
		switch {
		case errors.Is(err, sql.ErrNoRows):
			return nil, ErrRecordNotFound
		default:
			return nil, err
		}
	}
	return &user, nil
}

// LinkFirebaseUID binds a Firebase uid to an account, but only if the account
// has none yet — the WHERE firebase_uid IS NULL guard makes concurrent/repeat
// links a no-op rather than silently rebinding. A duplicate-uid unique
// violation surfaces as ErrRecordAlreadyExist (uid already on another account).
func (m UserModel) LinkFirebaseUID(ctx context.Context, userID, uid string) error {
	query := `UPDATE users SET firebase_uid = $1 WHERE id = $2 AND firebase_uid IS NULL`
	ctx, cancel := context.WithTimeout(ctx, 3*time.Second)
	defer cancel()
	res, err := m.DB.ExecContext(ctx, query, uid, userID)
	if err != nil {
		if isUniqueViolation(err, "ux_users_firebase_uid") {
			return ErrRecordAlreadyExist
		}
		return err
	}
	n, err := res.RowsAffected()
	if err != nil {
		return err
	}
	// 0 rows means the account already has a (different) uid — the incoming
	// identity is not the one this account is bound to.
	if n == 0 {
		return ErrRecordAlreadyExist
	}
	return nil
}

// UpdateAlias sets the user's onboarding display name ("What should we call
// you?"). Kept separate from Update: it's a single-field write with no
// optimistic-version semantics, callable from the client's fire-and-forget
// name-step save.
func (m UserModel) UpdateAlias(ctx context.Context, userID, alias string) error {
	query := `UPDATE users SET alias = $1 WHERE id = $2`
	ctx, cancel := context.WithTimeout(ctx, 3*time.Second)
	defer cancel()
	result, err := m.DB.ExecContext(ctx, query, alias, userID)
	if err != nil {
		return err
	}
	rowsAffected, err := result.RowsAffected()
	if err != nil {
		return err
	}
	if rowsAffected == 0 {
		return ErrRecordNotFound
	}
	return nil
}

// Delete removes the user row for the given id. Every table that references
// users with ON DELETE CASCADE (tokens, tracked metrics, cycles, etc.) has its
// dependent rows removed by Postgres in the same statement, so this is the only
// write needed to erase a user's server-side data. Returns ErrRecordNotFound
// when no row matched (already deleted / unknown id).
func (m UserModel) Delete(ctx context.Context, id string) error {
	query := `DELETE FROM users WHERE id = $1`
	ctx, cancel := context.WithTimeout(ctx, 3*time.Second)
	defer cancel()
	result, err := m.DB.ExecContext(ctx, query, id)
	if err != nil {
		return err
	}
	rowsAffected, err := result.RowsAffected()
	if err != nil {
		return err
	}
	if rowsAffected == 0 {
		return ErrRecordNotFound
	}
	return nil
}

func (m UserModel) Update(ctx context.Context, user *User) error {
	query := ` UPDATE users SET first_name = $1, email = $2, password_hash = $3, activated = $4, version = version + 1, last_name = $5, date_of_birth = $6, pic_no = $7
	WHERE id = $8 AND version = $9
	RETURNING version`
	args := []any{user.FirstName, user.Email, user.Password.hash, user.Activated, user.LastName, user.Dob, user.PicNo, user.ID, user.Version}
	ctx, cancel := context.WithTimeout(ctx, 3*time.Second)
	defer cancel()
	err := m.DB.QueryRowContext(ctx, query, args...).Scan(&user.Version)
	if err != nil {
		switch {
		case isUniqueViolation(err, "users_email_key"):
			return ErrDuplicateEmail
		case errors.Is(err, sql.ErrNoRows):
			return ErrEditConflict
		default:
			return err
		}
	}
	return nil
}

func (m UserModel) GetForToken(ctx context.Context, tokenScope, tokenPlaintext string) (*User, error) {

	tokenHash := sha256.Sum256([]byte(tokenPlaintext))
	// Set up the SQL query.
	query := ` SELECT users.id, users.created_at, users.first_name, users.last_name, users.date_of_birth, users.email, users.password_hash, users.activated, users.version, users.pic_no, users.alias, users.isAdmin 
	FROM users
	INNER JOIN tokens ON users.id = tokens.user_id
	WHERE tokens.hash = $1
	AND tokens.scope = $2
	AND tokens.expiry > $3`

	args := []any{tokenHash[:], tokenScope, time.Now()}
	var user User
	ctx, cancel := context.WithTimeout(ctx, 3*time.Second)
	defer cancel()
	// Execute the query, scanning the return values into a User struct. If no matching // record is found we return an ErrRecordNotFound error.
	err := m.DB.QueryRowContext(ctx, query, args...).Scan(
		&user.ID,
		&user.CreatedAt,
		&user.FirstName,
		&user.LastName,
		&user.Dob,
		&user.Email,
		&user.Password.hash,
		&user.Activated,
		&user.Version,
		&user.PicNo,
		&user.Alias,
		&user.IsAdmin)
	if err != nil {
		switch {
		case errors.Is(err, sql.ErrNoRows):
			return nil, ErrRecordNotFound
		default:
			return nil, err
		}
	}
	return &user, nil
}

// GetForPasswordResetOTP returns the user only when the supplied 6-digit OTP
// matches an unexpired password-reset token belonging to that exact email.
// Binding the lookup to the email prevents one user's OTP from matching another
// user's token (6-digit codes have a small space, so a hash-only lookup could
// collide across users).
func (m UserModel) GetForPasswordResetOTP(ctx context.Context, email, otp string) (*User, error) {
	otpHash := sha256.Sum256([]byte(otp))
	query := ` SELECT users.id, users.created_at, users.first_name, users.last_name, users.date_of_birth, users.email, users.password_hash, users.activated, users.version, users.pic_no, users.alias, users.isAdmin
	FROM users
	INNER JOIN tokens ON users.id = tokens.user_id
	WHERE users.email = $1
	AND tokens.hash = $2
	AND tokens.scope = $3
	AND tokens.expiry > $4`

	args := []any{email, otpHash[:], ScopePasswordReset, time.Now()}
	var user User
	ctx, cancel := context.WithTimeout(ctx, 3*time.Second)
	defer cancel()
	err := m.DB.QueryRowContext(ctx, query, args...).Scan(
		&user.ID,
		&user.CreatedAt,
		&user.FirstName,
		&user.LastName,
		&user.Dob,
		&user.Email,
		&user.Password.hash,
		&user.Activated,
		&user.Version,
		&user.PicNo,
		&user.Alias,
		&user.IsAdmin)
	if err != nil {
		switch {
		case errors.Is(err, sql.ErrNoRows):
			return nil, ErrRecordNotFound
		default:
			return nil, err
		}
	}
	return &user, nil
}

// ResetPasswordWithOTP atomically completes a password reset: within one
// transaction it verifies the OTP is still valid for the given email, sets the
// new password hash (bumping the optimistic-lock version), and consumes every
// password-reset token for that user. Doing all three in a single tx closes the
// reuse window the previous three-separate-statements flow had — if any step
// failed after the password update, the OTP used to stay valid and replayable.
// A locking read (FOR UPDATE OF users) also serialises concurrent reset attempts
// so the same code can't be redeemed twice. Returns ErrRecordNotFound when the
// email/OTP pair doesn't match an unexpired reset token.
func (m UserModel) ResetPasswordWithOTP(ctx context.Context, email, otp string, newHash []byte) error {
	otpHash := sha256.Sum256([]byte(otp))
	ctx, cancel := context.WithTimeout(ctx, 3*time.Second)
	defer cancel()
	return withTx(ctx, m.DB, func(tx *sql.Tx) error {
		var userID string
		err := tx.QueryRowContext(ctx, `
			SELECT users.id
			FROM users
			INNER JOIN tokens ON users.id = tokens.user_id
			WHERE users.email = $1
			AND tokens.hash = $2
			AND tokens.scope = $3
			AND tokens.expiry > $4
			FOR UPDATE OF users`,
			email, otpHash[:], ScopePasswordReset, time.Now()).Scan(&userID)
		if err != nil {
			if errors.Is(err, sql.ErrNoRows) {
				return ErrRecordNotFound
			}
			return err
		}
		if _, err := tx.ExecContext(ctx,
			`UPDATE users SET password_hash = $1, version = version + 1 WHERE id = $2`,
			newHash, userID); err != nil {
			return err
		}
		if _, err := tx.ExecContext(ctx,
			`DELETE FROM tokens WHERE user_id = $1 AND scope = $2`,
			userID, ScopePasswordReset); err != nil {
			return err
		}
		return nil
	})
}
