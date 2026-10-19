package api

import (
	"net/http/httptest"
	"strings"
	"testing"
)

// Go randomises map iteration, so reporting "the first" validation error used to
// give a different message for the same bad input from one request to the next.
func TestFailedValidationResponseIsDeterministic(t *testing.T) {
	app := newTestApp("")
	errs := map[string]string{
		"password": "must be at least 8 bytes long",
		"email":    "must be a valid email address",
		"dob":      "must be older than 18years",
	}
	seen := map[string]bool{}
	for i := 0; i < 200; i++ {
		w := httptest.NewRecorder()
		app.failedValidationResponse(w, httptest.NewRequest("POST", "/", nil), errs)
		if w.Code != 422 {
			t.Fatalf("status = %d", w.Code)
		}
		seen[strings.TrimSpace(w.Body.String())] = true
	}
	if len(seen) != 1 {
		t.Fatalf("same input produced %d different responses: %v", len(seen), seen)
	}
	for body := range seen {
		if !strings.Contains(body, "dob must be older than 18years") {
			t.Fatalf("expected the alphabetically-first field (dob), got %s", body)
		}
	}
}
