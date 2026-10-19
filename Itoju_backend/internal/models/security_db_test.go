package models

import (
	"context"
	"crypto/sha256"
	"errors"
	"sync"
	"testing"
	"time"
)

// backdateResetTokens makes a user's reset tokens look older than the request
// cooldown, so a test can request another code without sleeping 60s.
func backdateResetTokens(t *testing.T, m Models, userID string) {
	t.Helper()
	if _, err := m.Users.DB.Exec(
		`UPDATE tokens SET created_at = now() - interval '5 minutes' WHERE user_id = $1 AND scope = $2`,
		userID, ScopePasswordReset); err != nil {
		t.Fatalf("backdate: %v", err)
	}
}

func wrongCode(real string) string {
	if real == "000000" {
		return "000001"
	}
	return "000000"
}

// A 6-digit reset code must not survive an online guessing attack: after
// maxResetOTPAttempts wrong guesses the code is burned, even for the right value.
func TestResetOTPBruteForceCapDB(t *testing.T) {
	db := syncTestDB(t)
	defer db.Close()
	m := NewModels(db)
	ctx := context.Background()
	uid := mkUser(t, db, m, "sec-bruteforce@example.com")
	email := "sec-bruteforce@example.com"

	otp, err := m.Tokens.ReplacePasswordResetOTP(ctx, uid, 15*time.Minute)
	if err != nil {
		t.Fatalf("issue otp: %v", err)
	}
	newHash, _ := HashPassword("brandnewpass456")

	// Spend the whole guess budget on the verify endpoint.
	for i := 0; i < maxResetOTPAttempts; i++ {
		if err := m.Users.VerifyPasswordResetOTP(ctx, email, wrongCode(otp)); !errors.Is(err, ErrRecordNotFound) {
			t.Fatalf("wrong guess %d: want ErrRecordNotFound, got %v", i, err)
		}
	}
	// The CORRECT code is now dead on both the verify and the reset paths.
	if err := m.Users.VerifyPasswordResetOTP(ctx, email, otp); !errors.Is(err, ErrRecordNotFound) {
		t.Fatalf("burned code must not verify, got %v", err)
	}
	if err := m.Users.ResetPasswordWithOTP(ctx, email, otp, newHash); !errors.Is(err, ErrRecordNotFound) {
		t.Fatalf("burned code must not reset the password, got %v", err)
	}
	var pw []byte
	db.QueryRow(`SELECT password_hash FROM users WHERE id = $1`, uid).Scan(&pw)
	if string(pw) == string(newHash) {
		t.Fatal("password was changed using a burned code")
	}
}

// Wrong guesses on the reset path count too, and a right guess within budget works.
func TestResetOTPAttemptsAcrossPathsDB(t *testing.T) {
	db := syncTestDB(t)
	defer db.Close()
	m := NewModels(db)
	ctx := context.Background()
	uid := mkUser(t, db, m, "sec-paths@example.com")
	email := "sec-paths@example.com"
	newHash, _ := HashPassword("brandnewpass456")

	otp, _ := m.Tokens.ReplacePasswordResetOTP(ctx, uid, 15*time.Minute)
	for i := 0; i < maxResetOTPAttempts-1; i++ { // 4 wrong, mixed paths
		if i%2 == 0 {
			m.Users.VerifyPasswordResetOTP(ctx, email, wrongCode(otp))
		} else {
			m.Users.ResetPasswordWithOTP(ctx, email, wrongCode(otp), newHash)
		}
	}
	// Still within budget: the right code succeeds.
	if err := m.Users.ResetPasswordWithOTP(ctx, email, otp, newHash); err != nil {
		t.Fatalf("right code within budget should work, got %v", err)
	}
}

// Concurrent guessers must not be able to out-race the counter.
func TestResetOTPConcurrentGuessesDB(t *testing.T) {
	db := syncTestDB(t)
	defer db.Close()
	m := NewModels(db)
	ctx := context.Background()
	uid := mkUser(t, db, m, "sec-concurrent@example.com")
	email := "sec-concurrent@example.com"

	otp, _ := m.Tokens.ReplacePasswordResetOTP(ctx, uid, 15*time.Minute)
	var wg sync.WaitGroup
	for i := 0; i < 40; i++ {
		wg.Add(1)
		go func() {
			defer wg.Done()
			m.Users.VerifyPasswordResetOTP(ctx, email, wrongCode(otp))
		}()
	}
	wg.Wait()
	var attempts int
	db.QueryRow(`SELECT attempts FROM tokens WHERE user_id = $1 AND scope = $2`, uid, ScopePasswordReset).Scan(&attempts)
	if attempts != maxResetOTPAttempts {
		t.Fatalf("40 concurrent wrong guesses must stop at the cap (%d), counter = %d", maxResetOTPAttempts, attempts)
	}
	if err := m.Users.VerifyPasswordResetOTP(ctx, email, otp); !errors.Is(err, ErrRecordNotFound) {
		t.Fatalf("code must be burned after the flood, got %v", err)
	}
}

// Requesting fresh codes must not refill the guess budget: a cooldown applies,
// and a burned code still counts toward it.
func TestResetOTPCooldownDB(t *testing.T) {
	db := syncTestDB(t)
	defer db.Close()
	m := NewModels(db)
	ctx := context.Background()
	uid := mkUser(t, db, m, "sec-cooldown@example.com")
	email := "sec-cooldown@example.com"

	otp, err := m.Tokens.ReplacePasswordResetOTP(ctx, uid, 15*time.Minute)
	if err != nil {
		t.Fatalf("first issue: %v", err)
	}
	if _, err := m.Tokens.ReplacePasswordResetOTP(ctx, uid, 15*time.Minute); !errors.Is(err, ErrResetTooSoon) {
		t.Fatalf("immediate re-request: want ErrResetTooSoon, got %v", err)
	}
	// Burn the code, then try to farm a new one right away.
	for i := 0; i < maxResetOTPAttempts; i++ {
		m.Users.VerifyPasswordResetOTP(ctx, email, wrongCode(otp))
	}
	if _, err := m.Tokens.ReplacePasswordResetOTP(ctx, uid, 15*time.Minute); !errors.Is(err, ErrResetTooSoon) {
		t.Fatalf("re-request after burning: want ErrResetTooSoon, got %v", err)
	}
	// After the cooldown a new code is issued with a fresh budget.
	backdateResetTokens(t, m, uid)
	otp2, err := m.Tokens.ReplacePasswordResetOTP(ctx, uid, 15*time.Minute)
	if err != nil {
		t.Fatalf("issue after cooldown: %v", err)
	}
	if err := m.Users.VerifyPasswordResetOTP(ctx, email, otp2); err != nil {
		t.Fatalf("fresh code should verify, got %v", err)
	}
}

// Resetting the password must sign out every existing session.
func TestResetRevokesSessionsDB(t *testing.T) {
	db := syncTestDB(t)
	defer db.Close()
	m := NewModels(db)
	ctx := context.Background()
	uid := mkUser(t, db, m, "sec-revoke@example.com")
	email := "sec-revoke@example.com"

	a, _ := m.Tokens.New(ctx, uid, time.Hour, ScopeAuthentication)
	b, _ := m.Tokens.New(ctx, uid, time.Hour, ScopeAuthentication)
	otp, _ := m.Tokens.ReplacePasswordResetOTP(ctx, uid, 15*time.Minute)
	newHash, _ := HashPassword("brandnewpass456")
	if err := m.Users.ResetPasswordWithOTP(ctx, email, otp, newHash); err != nil {
		t.Fatalf("reset: %v", err)
	}
	for _, tok := range []*Token{a, b} {
		if _, err := m.Users.GetForToken(ctx, ScopeAuthentication, tok.Plaintext); !errors.Is(err, ErrRecordNotFound) {
			t.Fatalf("session must be revoked after reset, got %v", err)
		}
	}
}

// Changing a password keeps the caller's session but drops all the others.
func TestDeleteAllForUserExceptDB(t *testing.T) {
	db := syncTestDB(t)
	defer db.Close()
	m := NewModels(db)
	ctx := context.Background()
	uid := mkUser(t, db, m, "sec-except@example.com")
	other := mkUser(t, db, m, "sec-except-other@example.com")

	keep, _ := m.Tokens.New(ctx, uid, time.Hour, ScopeAuthentication)
	drop, _ := m.Tokens.New(ctx, uid, time.Hour, ScopeAuthentication)
	otherUser, _ := m.Tokens.New(ctx, other, time.Hour, ScopeAuthentication)

	h := sha256.Sum256([]byte(keep.Plaintext))
	if err := m.Tokens.DeleteAllForUserExcept(ctx, ScopeAuthentication, uid, h[:]); err != nil {
		t.Fatalf("revoke others: %v", err)
	}
	if _, err := m.Users.GetForToken(ctx, ScopeAuthentication, keep.Plaintext); err != nil {
		t.Fatalf("caller's own session must survive, got %v", err)
	}
	if _, err := m.Users.GetForToken(ctx, ScopeAuthentication, drop.Plaintext); !errors.Is(err, ErrRecordNotFound) {
		t.Fatalf("other session must be revoked, got %v", err)
	}
	if _, err := m.Users.GetForToken(ctx, ScopeAuthentication, otherUser.Plaintext); err != nil {
		t.Fatalf("a DIFFERENT user's session must be untouched, got %v", err)
	}
}

// One value the database rejects must not poison the batch or wedge sync.
func TestSyncPushQuarantinesBadRowDB(t *testing.T) {
	db := syncTestDB(t)
	defer db.Close()
	m := NewModels(db)
	uid := mkUser(t, db, m, "sec-badrow@example.com")
	now := time.Now().UTC().Format(time.RFC3339)

	good1 := "0192b000-0000-7000-8000-000000000001"
	bad := "0192b000-0000-7000-8000-000000000002"
	good2 := "0192b000-0000-7000-8000-000000000003"
	row := func(id string, qty float64) map[string]any {
		return map[string]any{
			"id": id, "date": "2026-05-01", "type": 1.0, "pain": 0.2, "time": "08:00",
			"tags": []string{}, "quantity": qty, "updated_at": now, "deleted_at": nil,
		}
	}
	// quantity is NUMERIC(5,2): 1000 overflows it (SQLSTATE 22003).
	res := pushRows(t, m, uid, "user_urine_metric", row(good1, 10), row(bad, 1000), row(good2, 20))
	want := map[string]string{good1: "applied", bad: "rejected", good2: "applied"}
	if len(res) != 3 {
		t.Fatalf("want 3 results, got %+v", res)
	}
	for _, r := range res {
		if want[r.ID] != r.Status {
			t.Fatalf("row %s: want %s, got %s", r.ID, want[r.ID], r.Status)
		}
	}
	var n int
	db.QueryRow(`SELECT count(*) FROM user_urine_metric WHERE user_id = $1`, uid).Scan(&n)
	if n != 2 {
		t.Fatalf("the two good rows must be stored (bad one not), got %d rows", n)
	}

	// Text longer than VARCHAR(255) is the same class of failure.
	long := make([]byte, 300)
	for i := range long {
		long[i] = 'x'
	}
	res = pushRows(t, m, uid, "user_food_metric", map[string]any{
		"id": "0192b000-0000-7000-8000-000000000010", "date": "2026-05-02",
		"breakfast_meal": string(long), "updated_at": now, "deleted_at": nil,
	})
	if len(res) != 1 || res[0].Status != "rejected" {
		t.Fatalf("over-long text should be rejected, got %+v", res)
	}

	// A cycle day whose parent cycle isn't on the server yet is ordering, not a
	// bad row: it must come back as "retry" (stay pending), not "rejected".
	res = pushRows(t, m, uid, "cycles_days", map[string]any{
		"id": "0192b000-0000-7000-8000-000000000020", "cycle_id": "0192b000-0000-7000-8000-0000000000ff",
		"date": "2026-05-03", "is_period": true, "is_ovulation": false, "flow": 0.5, "pain": 0.1,
		"tags": []string{}, "cmq": "", "updated_at": now, "deleted_at": nil,
	})
	if len(res) != 1 || res[0].Status != "retry" {
		t.Fatalf("orphan cycle day should be retry, got %+v", res)
	}
}
