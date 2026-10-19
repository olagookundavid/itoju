package api

import (
	"net/http"
	"net/http/httptest"
	"testing"
	"time"

	"github.com/olagookundavid/itoju/internal/models"
)

func TestKeyedLimiterBurstThenBlockThenRefill(t *testing.T) {
	l := newKeyedLimiter(20, 3) // 20/s => a token every 50ms
	for i := 0; i < 3; i++ {
		if !l.allow("k") {
			t.Fatalf("request %d inside the burst should pass", i)
		}
	}
	if l.allow("k") {
		t.Fatal("request past the burst should be blocked")
	}
	if !l.allow("other") {
		t.Fatal("a different key has its own bucket")
	}
	time.Sleep(120 * time.Millisecond)
	if !l.allow("k") {
		t.Fatal("bucket should have refilled")
	}
}

func TestKeyedLimiterForgetsIdleKeys(t *testing.T) {
	l := newKeyedLimiter(1, 1)
	l.idleAfter = 10 * time.Millisecond
	l.sweepEvery = time.Millisecond
	for i := 0; i < 50; i++ {
		l.allow(string(rune('a'+i%26)) + string(rune('0'+i/26)))
	}
	time.Sleep(30 * time.Millisecond)
	l.allow("trigger-sweep")
	if n := l.size(); n > 2 {
		t.Fatalf("idle entries should be swept (memory bound), still have %d", n)
	}
}

func userReq(ip, userID string, app *Application) *http.Request {
	r := httptest.NewRequest(http.MethodGet, "/v1/x", nil)
	r.RemoteAddr = ip + ":1234"
	u := models.AnonymousUser
	if userID != "" {
		u = &models.User{ID: userID}
	}
	return app.contextSetUser(r, u)
}

func hit(h http.Handler, r *http.Request) int {
	w := httptest.NewRecorder()
	h.ServeHTTP(w, r)
	return w.Code
}

// The point of keying by user: lots of different people behind ONE carrier IP
// must not share a bucket, while one user can't dodge it by changing IP.
func TestPerUserLimiterIsolatesUsersSharingAnIP(t *testing.T) {
	app := newTestApp("")
	app.Config.Limiter.Enabled = true
	app.Config.Limiter.UserRps = 0.001 // effectively no refill during the test
	app.Config.Limiter.UserBurst = 3
	h := app.RateLimitUser(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
	}))

	const sharedIP = "100.64.0.1" // carrier-grade NAT: everyone looks like this
	// user-a burns through their own budget...
	for i := 0; i < 3; i++ {
		if c := hit(h, userReq(sharedIP, "user-a", app)); c != 200 {
			t.Fatalf("user-a request %d: want 200, got %d", i, c)
		}
	}
	if c := hit(h, userReq(sharedIP, "user-a", app)); c != http.StatusTooManyRequests {
		t.Fatalf("user-a over budget: want 429, got %d", c)
	}
	// ...but user-b on the SAME IP is untouched.
	if c := hit(h, userReq(sharedIP, "user-b", app)); c != 200 {
		t.Fatalf("user-b must not be throttled by user-a, got %d", c)
	}
	// And user-a can't escape by switching address.
	if c := hit(h, userReq("198.51.100.9", "user-a", app)); c != http.StatusTooManyRequests {
		t.Fatalf("user-a changing IP must stay limited, got %d", c)
	}
}

func TestPerUserLimiterIgnoresAnonymousAndHonoursDisabled(t *testing.T) {
	app := newTestApp("")
	app.Config.Limiter.Enabled = true
	app.Config.Limiter.UserRps = 0.001
	app.Config.Limiter.UserBurst = 1
	ok := http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) { w.WriteHeader(200) })
	h := app.RateLimitUser(ok)
	for i := 0; i < 10; i++ { // anonymous traffic is the IP limiter's job
		if c := hit(h, userReq("203.0.113.1", "", app)); c != 200 {
			t.Fatalf("anonymous request %d should pass this layer, got %d", i, c)
		}
	}
	app.Config.Limiter.Enabled = false
	h = app.RateLimitUser(ok)
	for i := 0; i < 10; i++ {
		if c := hit(h, userReq("203.0.113.1", "user-z", app)); c != 200 {
			t.Fatalf("disabled limiter must pass everything, got %d", c)
		}
	}
}
