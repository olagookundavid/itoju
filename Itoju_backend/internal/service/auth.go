// Package service holds business-logic orchestration that sits between the HTTP
// handlers and the repositories. It depends on small, consumer-defined
// interfaces (satisfied by the concrete models) so the branch-heavy flows here
// can be unit-tested with fakes, without a database. Thin CRUD handlers keep
// calling the repositories directly — a passthrough service would add nothing.
package service

import (
	"context"
	"errors"
	"time"

	"github.com/olagookundavid/itoju/internal/firebaseauth"
	"github.com/olagookundavid/itoju/internal/models"
	"github.com/olagookundavid/itoju/internal/validator"
)

// UserStore is the subset of the user repository the auth flows need.
type UserStore interface {
	GetByEmail(ctx context.Context, email string) (*models.User, error)
	Insert(ctx context.Context, user *models.User) error
}

// TokenStore is the subset of the token repository the auth flows need.
type TokenStore interface {
	New(ctx context.Context, userID string, ttl time.Duration, scope string) (*models.Token, error)
}

// PointsAwarder queues a gamification award (non-blocking). *api.Application
// satisfies it via its AwardPoints method.
type PointsAwarder interface {
	AwardPoints(userID, scope string, points int64)
}

// IdentityVerifier verifies a provider ID token (Firebase/Google).
type IdentityVerifier interface {
	Enabled() bool
	Verify(ctx context.Context, idToken string) (*firebaseauth.Identity, error)
}

// AuthService orchestrates authentication (password and social login).
type AuthService struct {
	Users    UserStore
	Tokens   TokenStore
	Points   PointsAwarder
	Firebase IdentityVerifier
}

// Sentinel errors the HTTP layer maps to specific responses.
var (
	ErrInvalidCredentials  = errors.New("invalid credentials")
	ErrSocialLoginDisabled = errors.New("social login disabled")
	ErrInvalidIDToken      = errors.New("invalid id token")
	ErrEmailUnverified     = errors.New("email missing or unverified")
	ErrInvalidDOB          = errors.New("invalid dob")
)

// ValidationError carries field-level validation failures so the handler can
// render the same 422 response shape it did when validation lived inline.
type ValidationError struct {
	Errors map[string]string
}

func (e *ValidationError) Error() string { return "validation failed" }

// Login authenticates an email/password pair and returns a fresh session token.
// It returns ErrInvalidCredentials for both an unknown email and a bad password
// so callers can't distinguish the two.
func (s *AuthService) Login(ctx context.Context, email, password string) (*models.Token, error) {
	user, err := s.Users.GetByEmail(ctx, email)
	if err != nil {
		if errors.Is(err, models.ErrRecordNotFound) {
			return nil, ErrInvalidCredentials
		}
		return nil, err
	}
	match, err := user.Password.Matches(password)
	if err != nil {
		return nil, err
	}
	if !match {
		return nil, ErrInvalidCredentials
	}
	return s.issueSession(ctx, user.ID)
}

// SocialLoginResult is the outcome of a social login attempt. Exactly one of
// RegistrationRequired / Token is meaningful.
type SocialLoginResult struct {
	// RegistrationRequired means the token was valid but no account exists yet and
	// no date of birth was supplied; the client should collect one and retry.
	RegistrationRequired bool
	Token                *models.Token
	Email                string
	FirstName            string
	LastName             string
}

// SocialLogin verifies a Firebase ID token and either logs the user in, reports
// that registration details are still required, or creates the account (with an
// unusable random password) and logs them in. It never trusts a client-supplied
// email — only the verified identity.
func (s *AuthService) SocialLogin(ctx context.Context, idToken, dob string) (*SocialLoginResult, error) {
	if !s.Firebase.Enabled() {
		return nil, ErrSocialLoginDisabled
	}
	identity, err := s.Firebase.Verify(ctx, idToken)
	if err != nil {
		return nil, ErrInvalidIDToken
	}
	if identity.Email == "" || !identity.EmailVerified {
		return nil, ErrEmailUnverified
	}

	user, err := s.Users.GetByEmail(ctx, identity.Email)
	switch {
	case err == nil:
		token, terr := s.issueSession(ctx, user.ID)
		if terr != nil {
			return nil, terr
		}
		return &SocialLoginResult{Token: token}, nil
	case !errors.Is(err, models.ErrRecordNotFound):
		return nil, err
	}

	// First-time social sign-up.
	firstName, lastName := SplitName(identity.Name, identity.Email)
	if dob == "" {
		return &SocialLoginResult{RegistrationRequired: true, Email: identity.Email, FirstName: firstName, LastName: lastName}, nil
	}
	parsedDob, err := time.Parse("2006-01-02", dob)
	if err != nil {
		return nil, ErrInvalidDOB
	}
	newUser := &models.User{
		FirstName: firstName,
		LastName:  lastName,
		Dob:       parsedDob,
		Email:     identity.Email,
		Activated: true,
	}
	randomPassword, err := GenerateRandomSecret()
	if err != nil {
		return nil, err
	}
	if err := newUser.Password.Set(randomPassword); err != nil {
		return nil, err
	}
	v := validator.New()
	if models.ValidateUser(v, newUser); !v.Valid() {
		return nil, &ValidationError{Errors: v.Errors}
	}
	if err := s.Users.Insert(ctx, newUser); err != nil {
		if errors.Is(err, models.ErrDuplicateEmail) {
			// Raced with a concurrent sign-up; treat as login.
			existing, gerr := s.Users.GetByEmail(ctx, identity.Email)
			if gerr != nil {
				return nil, gerr
			}
			token, terr := s.issueSession(ctx, existing.ID)
			if terr != nil {
				return nil, terr
			}
			return &SocialLoginResult{Token: token}, nil
		}
		return nil, err
	}
	s.Points.AwardPoints(newUser.ID, "Register", 10)
	token, err := s.issueSession(ctx, newUser.ID)
	if err != nil {
		return nil, err
	}
	return &SocialLoginResult{Token: token}, nil
}

// issueSession mints a session token and awards login points.
func (s *AuthService) issueSession(ctx context.Context, userID string) (*models.Token, error) {
	token, err := s.Tokens.New(ctx, userID, models.AuthTokenTTL, models.ScopeAuthentication)
	if err != nil {
		return nil, err
	}
	s.Points.AwardPoints(token.UserID, "Login", 5)
	return token, nil
}
