package routes

import (
	"io"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/olagookundavid/itoju/cmd/api"
	"github.com/olagookundavid/itoju/internal/jsonlog"
)

func TestRouteSecurityBasics(t *testing.T) {
	app := &api.Application{Logger: jsonlog.New(io.Discard, jsonlog.LevelError)}
	h := Routes(app)

	do := func(method, path string) int {
		w := httptest.NewRecorder()
		h.ServeHTTP(w, httptest.NewRequest(method, path, nil))
		return w.Code
	}

	// Self-awarding points was removed: no POST handler remains on this path.
	if got := do(http.MethodPost, "/v1/user/point"); got != http.StatusMethodNotAllowed {
		t.Errorf("POST /v1/user/point should have no handler (405), got %d", got)
	}
	// The remaining read is still behind auth.
	if got := do(http.MethodGet, "/v1/user/point"); got != http.StatusUnauthorized {
		t.Errorf("anonymous GET /v1/user/point should be 401, got %d", got)
	}
	// Sensitive routes reject anonymous callers.
	for _, p := range []struct{ m, path string }{
		{http.MethodPost, "/v1/sync/push"},
		{http.MethodPost, "/v1/sync/pull"},
		{http.MethodDelete, "/v1/users/me"},
		{http.MethodPut, "/v1/users/change-password"},
		{http.MethodPost, "/v1/logout"},
		{http.MethodGet, "/v1/debug/vars"},
		{http.MethodPost, "/v1/resources"},
	} {
		if got := do(p.m, p.path); got != http.StatusUnauthorized {
			t.Errorf("anonymous %s %s should be 401, got %d", p.m, p.path, got)
		}
	}
}
