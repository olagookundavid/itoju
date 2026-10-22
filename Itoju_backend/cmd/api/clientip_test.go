package api

import (
	"expvar"
	"io"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/olagookundavid/itoju/internal/jsonlog"
)

func newTestApp(header string) *Application {
	app := &Application{Logger: jsonlog.New(io.Discard, jsonlog.LevelError)}
	app.Config.ClientIPHeader = header
	return app
}

func reqWith(h map[string]string) *http.Request {
	r := httptest.NewRequest(http.MethodPost, "/v1/login", nil)
	r.RemoteAddr = "10.1.2.3:4444" // the edge proxy / load balancer
	for k, v := range h {
		r.Header.Set(k, v)
	}
	return r
}

func TestClientIPPrefersTrustedEdgeHeader(t *testing.T) {
	app := newTestApp("CF-Connecting-IP")
	// The edge says 203.0.113.9; a client-forged XFF must be ignored entirely.
	r := reqWith(map[string]string{
		"CF-Connecting-IP": "203.0.113.9",
		"X-Forwarded-For":  "198.51.100.77, 198.51.100.78",
	})
	if got := app.clientIP(r); got != "203.0.113.9" {
		t.Fatalf("want edge-reported IP, got %q", got)
	}
}

func TestClientIPIgnoresGarbageEdgeHeader(t *testing.T) {
	app := newTestApp("CF-Connecting-IP")
	r := reqWith(map[string]string{"CF-Connecting-IP": "not-an-ip", "X-Forwarded-For": "198.51.100.5"})
	if got := app.clientIP(r); got != "198.51.100.5" {
		t.Fatalf("invalid header should fall back to XFF handling, got %q", got)
	}
}

// The attack: rotate X-Forwarded-For every request to look like a new client and
// dodge the per-IP auth throttle. With the edge header in place it must not work.
func TestAuthRateLimiterNotBypassedBySpoofedXFF(t *testing.T) {
	app := newTestApp("CF-Connecting-IP")
	limited := app.NewAuthRateLimiter()(func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
	})

	ok, blocked := 0, 0
	for i := 0; i < 20; i++ {
		r := reqWith(map[string]string{
			"CF-Connecting-IP": "203.0.113.50", // the attacker's true address
			"X-Forwarded-For":  "198.51." + string(rune('0'+i/10)) + "." + string(rune('0'+i%10)),
		})
		w := httptest.NewRecorder()
		limited(w, r)
		switch w.Code {
		case http.StatusOK:
			ok++
		case http.StatusTooManyRequests:
			blocked++
		}
	}
	if ok > 6 || blocked < 14 {
		t.Fatalf("throttle bypassed by rotating XFF: ok=%d blocked=%d (want ok<=6)", ok, blocked)
	}

	// A genuinely different client (different edge-reported IP) is unaffected.
	r := reqWith(map[string]string{"CF-Connecting-IP": "203.0.113.51"})
	w := httptest.NewRecorder()
	limited(w, r)
	if w.Code != http.StatusOK {
		t.Fatalf("a different real client must not share the attacker's bucket, got %d", w.Code)
	}
}

// So the operator can SEE whether the edge header actually reaches the server
// (read via the admin-only /v1/debug/vars), instead of guessing.
func TestClientIPDiagnosticsCountSourceAndHeadersSeen(t *testing.T) {
	app := newTestApp("CF-Connecting-IP")
	src := expvarMap("client_ip_source")
	seen := expvarMap("client_ip_headers_seen")
	val := func(m *expvar.Map, k string) int {
		if v, ok := m.Get(k).(*expvar.Int); ok {
			return int(v.Value())
		}
		return 0
	}
	edge0, fb0 := val(src, "edge_header"), val(src, "fallback")
	cf0, xff0 := val(seen, "CF-Connecting-IP"), val(seen, "X-Forwarded-For")

	h := app.RateLimit(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {}))
	app.Config.Limiter.Enabled = true
	app.Config.Limiter.Rps, app.Config.Limiter.Burst = 1000, 1000
	h = app.RateLimit(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {}))

	h.ServeHTTP(httptest.NewRecorder(), reqWith(map[string]string{"CF-Connecting-IP": "203.0.113.9", "X-Forwarded-For": "198.51.100.1"}))
	h.ServeHTTP(httptest.NewRecorder(), reqWith(map[string]string{"X-Forwarded-For": "198.51.100.2"}))

	if d := val(src, "edge_header") - edge0; d != 1 {
		t.Errorf("edge_header count rose by %d, want 1", d)
	}
	if d := val(src, "fallback") - fb0; d != 1 {
		t.Errorf("fallback count rose by %d, want 1", d)
	}
	if d := val(seen, "CF-Connecting-IP") - cf0; d != 1 {
		t.Errorf("CF-Connecting-IP seen rose by %d, want 1", d)
	}
	if d := val(seen, "X-Forwarded-For") - xff0; d != 2 {
		t.Errorf("X-Forwarded-For seen rose by %d, want 2", d)
	}
}
