package api

import (
	"expvar"
	"net/http"
	"net/http/httptest"
	"testing"
)

func TestLegacyRouteKey(t *testing.T) {
	legacy := []struct{ method, path, want string }{
		{"GET", "/v1/user/symsMetric/2026-05-01", "GET /v1/user/symsMetric"},
		{"PUT", "/v1/user/bowel_metrics/0192b000-0000-7000-8000-000000000001", "PUT /v1/user/bowel_metrics"},
		{"GET", "/v1/user/syms_days_analytics/21/7", "GET /v1/user/syms_days_analytics"},
		{"POST", "/v1/user/period", "POST /v1/user/period"},
		{"GET", "/v1/allsymptoms", "GET /v1/allsymptoms"},
		{"GET", "/v1/user/metrics", "GET /v1/user/metrics"},
	}
	for _, c := range legacy {
		got, ok := legacyRouteKey(c.method, c.path)
		if !ok || got != c.want {
			t.Errorf("%s %s: got (%q,%v), want (%q,true)", c.method, c.path, got, ok, c.want)
		}
	}
	// Endpoints the CURRENT app uses must never be counted as legacy.
	current := []string{
		"/v1/login", "/v1/social-login", "/v1/register", "/v1/logout",
		"/v1/password-reset", "/v1/verify-otp", "/v1/users/profile", "/v1/users/alias",
		"/v1/users/me", "/v1/users/change-password", "/v1/users/password", "/v1/users/profile_pic",
		"/v1/resources", "/v1/resources/4", "/v1/sync/push", "/v1/sync/pull",
		"/v1/user/entitlements", "/v1/healthcheck", "/v1/webhooks/revenuecat", "/v1/debug/vars",
	}
	for _, p := range current {
		if k, ok := legacyRouteKey("GET", p); ok {
			t.Errorf("%s is used by the current app but was classed legacy (%q)", p, k)
		}
	}
}

func TestMetricsMiddlewareCountsLegacyHits(t *testing.T) {
	app := newTestApp("")
	h := app.Metrics(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {}))
	for i := 0; i < 3; i++ {
		h.ServeHTTP(httptest.NewRecorder(), httptest.NewRequest("GET", "/v1/user/symsMetric/2026-05-01", nil))
	}
	h.ServeHTTP(httptest.NewRecorder(), httptest.NewRequest("POST", "/v1/sync/push", nil))

	m, ok := expvar.Get("legacy_requests").(*expvar.Map)
	if !ok {
		t.Fatal("legacy_requests expvar missing")
	}
	if v := m.Get("GET /v1/user/symsMetric"); v == nil || v.String() != "3" {
		t.Fatalf("legacy hits = %v, want 3", v)
	}
	if v := m.Get("POST /v1/sync/push"); v != nil {
		t.Fatalf("current endpoint was counted as legacy: %v", v)
	}
	// building the middleware twice must not panic (expvar names are global)
	_ = app.Metrics(http.NotFoundHandler())
}
