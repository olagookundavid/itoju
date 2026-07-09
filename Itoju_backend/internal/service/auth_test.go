package service

import (
	"context"
	"errors"
	"testing"
	"time"

	"github.com/olagookundavid/itoju/internal/firebaseauth"
	"github.com/olagookundavid/itoju/internal/models"
)

// --- fakes -------------------------------------------------------------------

type fakeUserStore struct {
	byEmail   map[string]*models.User
	getErr    error
	insertErr error
	inserted  []*models.User
}

func (f *fakeUserStore) GetByEmail(_ context.Context, email string) (*models.User, error) {
	if f.getErr != nil {
		return nil, f.getErr
	}
	u, ok := f.byEmail[email]
	if !ok {
		return nil, models.ErrRecordNotFound
	}
	return u, nil
}

func (f *fakeUserStore) Insert(_ context.Context, u *models.User) error {
	if f.insertErr != nil {
		return f.insertErr
	}
	if u.ID == "" {
		u.ID = "generated-" + u.Email
	}
	f.inserted = append(f.inserted, u)
	if f.byEmail == nil {
		f.byEmail = map[string]*models.User{}
	}
	f.byEmail[u.Email] = u
	return nil
}

type fakeTokenStore struct {
	err   error
	calls int
}

func (f *fakeTokenStore) New(_ context.Context, userID string, _ time.Duration, scope string) (*models.Token, error) {
	if f.err != nil {
		return nil, f.err
	}
	f.calls++
	return &models.Token{Plaintext: "tok-" + userID, UserID: userID, Scope: scope}, nil
}

type fakePoints struct{ awards []string }

func (f *fakePoints) AwardPoints(userID, scope string, _ int64) {
	f.awards = append(f.awards, scope+":"+userID)
}

type fakeVerifier struct {
	enabled  bool
	identity *firebaseauth.Identity
	err      error
}

func (f *fakeVerifier) Enabled() bool { return f.enabled }
func (f *fakeVerifier) Verify(_ context.Context, _ string) (*firebaseauth.Identity, error) {
	return f.identity, f.err
}

func userWithPassword(t *testing.T, id, email, pw string) *models.User {
	t.Helper()
	u := &models.User{ID: id, Email: email, FirstName: "A", LastName: "B", Activated: true}
	if err := u.Password.Set(pw); err != nil {
		t.Fatalf("set pw: %v", err)
	}
	return u
}

// --- Login -------------------------------------------------------------------

func TestLogin(t *testing.T) {
	ctx := context.Background()

	t.Run("unknown email -> invalid credentials", func(t *testing.T) {
		s := &AuthService{Users: &fakeUserStore{}, Tokens: &fakeTokenStore{}, Points: &fakePoints{}}
		_, err := s.Login(ctx, "nobody@x.com", "whatever")
		if !errors.Is(err, ErrInvalidCredentials) {
			t.Fatalf("got %v, want ErrInvalidCredentials", err)
		}
	})

	t.Run("wrong password -> invalid credentials", func(t *testing.T) {
		us := &fakeUserStore{byEmail: map[string]*models.User{"a@x.com": userWithPassword(t, "u1", "a@x.com", "correct-horse")}}
		s := &AuthService{Users: us, Tokens: &fakeTokenStore{}, Points: &fakePoints{}}
		_, err := s.Login(ctx, "a@x.com", "wrong")
		if !errors.Is(err, ErrInvalidCredentials) {
			t.Fatalf("got %v, want ErrInvalidCredentials", err)
		}
	})

	t.Run("valid -> token + login points", func(t *testing.T) {
		us := &fakeUserStore{byEmail: map[string]*models.User{"a@x.com": userWithPassword(t, "u1", "a@x.com", "correct-horse")}}
		pts := &fakePoints{}
		s := &AuthService{Users: us, Tokens: &fakeTokenStore{}, Points: pts}
		tok, err := s.Login(ctx, "a@x.com", "correct-horse")
		if err != nil {
			t.Fatalf("unexpected err: %v", err)
		}
		if tok.UserID != "u1" {
			t.Fatalf("token for wrong user: %q", tok.UserID)
		}
		if len(pts.awards) != 1 || pts.awards[0] != "Login:u1" {
			t.Fatalf("expected one Login award, got %v", pts.awards)
		}
	})
}

// --- SocialLogin -------------------------------------------------------------

func verifier(email string, verified bool, name string) *fakeVerifier {
	return &fakeVerifier{enabled: true, identity: &firebaseauth.Identity{Email: email, EmailVerified: verified, Name: name}}
}

func TestSocialLogin(t *testing.T) {
	ctx := context.Background()

	t.Run("disabled", func(t *testing.T) {
		s := &AuthService{Firebase: &fakeVerifier{enabled: false}, Users: &fakeUserStore{}, Tokens: &fakeTokenStore{}, Points: &fakePoints{}}
		_, err := s.SocialLogin(ctx, "tok", "")
		if !errors.Is(err, ErrSocialLoginDisabled) {
			t.Fatalf("got %v, want ErrSocialLoginDisabled", err)
		}
	})

	t.Run("verify failure -> invalid id token", func(t *testing.T) {
		s := &AuthService{Firebase: &fakeVerifier{enabled: true, err: errors.New("bad sig")}, Users: &fakeUserStore{}, Tokens: &fakeTokenStore{}, Points: &fakePoints{}}
		_, err := s.SocialLogin(ctx, "tok", "")
		if !errors.Is(err, ErrInvalidIDToken) {
			t.Fatalf("got %v, want ErrInvalidIDToken", err)
		}
	})

	t.Run("unverified email", func(t *testing.T) {
		s := &AuthService{Firebase: verifier("a@x.com", false, "A B"), Users: &fakeUserStore{}, Tokens: &fakeTokenStore{}, Points: &fakePoints{}}
		_, err := s.SocialLogin(ctx, "tok", "")
		if !errors.Is(err, ErrEmailUnverified) {
			t.Fatalf("got %v, want ErrEmailUnverified", err)
		}
	})

	t.Run("existing user -> login", func(t *testing.T) {
		us := &fakeUserStore{byEmail: map[string]*models.User{"a@x.com": userWithPassword(t, "u1", "a@x.com", "pw12345678")}}
		pts := &fakePoints{}
		s := &AuthService{Firebase: verifier("a@x.com", true, "A B"), Users: us, Tokens: &fakeTokenStore{}, Points: pts}
		res, err := s.SocialLogin(ctx, "tok", "")
		if err != nil {
			t.Fatalf("unexpected err: %v", err)
		}
		if res.RegistrationRequired || res.Token == nil || res.Token.UserID != "u1" {
			t.Fatalf("expected login for u1, got %+v", res)
		}
		if len(us.inserted) != 0 {
			t.Fatalf("existing user should not be inserted")
		}
		if len(pts.awards) != 1 || pts.awards[0] != "Login:u1" {
			t.Fatalf("expected one Login award, got %v", pts.awards)
		}
	})

	t.Run("new user, no dob -> registration required", func(t *testing.T) {
		s := &AuthService{Firebase: verifier("new@x.com", true, "Ada Lovelace"), Users: &fakeUserStore{}, Tokens: &fakeTokenStore{}, Points: &fakePoints{}}
		res, err := s.SocialLogin(ctx, "tok", "")
		if err != nil {
			t.Fatalf("unexpected err: %v", err)
		}
		if !res.RegistrationRequired || res.Token != nil {
			t.Fatalf("expected registration required, got %+v", res)
		}
		if res.FirstName != "Ada" || res.LastName != "Lovelace" || res.Email != "new@x.com" {
			t.Fatalf("wrong names/email: %+v", res)
		}
	})

	t.Run("new user, invalid dob", func(t *testing.T) {
		s := &AuthService{Firebase: verifier("new@x.com", true, "Ada Lovelace"), Users: &fakeUserStore{}, Tokens: &fakeTokenStore{}, Points: &fakePoints{}}
		_, err := s.SocialLogin(ctx, "tok", "01-02-2000")
		if !errors.Is(err, ErrInvalidDOB) {
			t.Fatalf("got %v, want ErrInvalidDOB", err)
		}
	})

	t.Run("new user, underage -> validation error", func(t *testing.T) {
		s := &AuthService{Firebase: verifier("new@x.com", true, "Ada Lovelace"), Users: &fakeUserStore{}, Tokens: &fakeTokenStore{}, Points: &fakePoints{}}
		_, err := s.SocialLogin(ctx, "tok", "2020-01-01")
		var ve *ValidationError
		if !errors.As(err, &ve) {
			t.Fatalf("got %v, want *ValidationError", err)
		}
	})

	t.Run("new user, valid dob -> create + register + login", func(t *testing.T) {
		us := &fakeUserStore{}
		pts := &fakePoints{}
		s := &AuthService{Firebase: verifier("new@x.com", true, "Ada Lovelace"), Users: us, Tokens: &fakeTokenStore{}, Points: pts}
		res, err := s.SocialLogin(ctx, "tok", "1990-01-01")
		if err != nil {
			t.Fatalf("unexpected err: %v", err)
		}
		if res.RegistrationRequired || res.Token == nil {
			t.Fatalf("expected login after create, got %+v", res)
		}
		if len(us.inserted) != 1 || us.inserted[0].Email != "new@x.com" {
			t.Fatalf("expected one inserted user, got %v", us.inserted)
		}
		// Register (10) then Login (5) both awarded.
		if len(pts.awards) != 2 || pts.awards[0] != "Register:generated-new@x.com" || pts.awards[1] != "Login:generated-new@x.com" {
			t.Fatalf("expected Register then Login awards, got %v", pts.awards)
		}
	})

	t.Run("insert races duplicate -> logs in existing", func(t *testing.T) {
		existing := userWithPassword(t, "existing-id", "new@x.com", "pw12345678")
		// raceUserStore reports not-found on the first lookup (reaching the signup
		// path), fails Insert with a duplicate, then returns the existing user on the
		// retry — modelling a concurrent sign-up that won.
		us := &raceUserStore{first: true, existing: existing}
		pts := &fakePoints{}
		s := &AuthService{Firebase: verifier("new@x.com", true, "Ada Lovelace"), Users: us, Tokens: &fakeTokenStore{}, Points: pts}
		res, err := s.SocialLogin(ctx, "tok", "1990-01-01")
		if err != nil {
			t.Fatalf("unexpected err: %v", err)
		}
		if res.Token == nil || res.Token.UserID != "existing-id" {
			t.Fatalf("expected login as existing-id, got %+v", res)
		}
	})
}

// raceUserStore reports not-found on the first GetByEmail (pre-insert) and the
// existing user afterwards, with Insert always returning a duplicate error —
// modelling a concurrent sign-up that wins the race.
type raceUserStore struct {
	first    bool
	existing *models.User
}

func (r *raceUserStore) GetByEmail(_ context.Context, _ string) (*models.User, error) {
	if r.first {
		r.first = false
		return nil, models.ErrRecordNotFound
	}
	return r.existing, nil
}

func (r *raceUserStore) Insert(_ context.Context, _ *models.User) error {
	return models.ErrDuplicateEmail
}
