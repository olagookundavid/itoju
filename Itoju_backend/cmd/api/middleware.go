package api

import (
	"errors"
	"expvar"
	"fmt"
	"net"
	"net/http"
	"strconv"
	"strings"
	"time"

	"github.com/olagookundavid/itoju/internal/models"
	"github.com/olagookundavid/itoju/internal/validator"
	"github.com/tomasen/realip"
)

func (app *Application) RecoverPanic(next http.Handler) http.Handler {

	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {

		defer func() {
			// Use the builtin recover function to check if there has been a panic or // not.
			if err := recover(); err != nil {
				w.Header().Set("Connection", "close")
				app.serverErrorResponse(w, r, fmt.Errorf("%s", err))
			}
		}()
		next.ServeHTTP(w, r)
	})
}

// clientIP returns the address to key rate limits on. It prefers the header a
// trusted edge proxy sets (Config.ClientIPHeader — Cloudflare overwrites
// CF-Connecting-IP, so it can't be forged through the edge) and otherwise falls
// back to realip's X-Forwarded-For handling.
func (app *Application) clientIP(r *http.Request) string {
	if h := app.Config.ClientIPHeader; h != "" {
		if ip := net.ParseIP(strings.TrimSpace(r.Header.Get(h))); ip != nil {
			return ip.String()
		}
	}
	return realip.FromRequest(r)
}

// RequireAdminUser only allows activated, authenticated users whose account is
// flagged as admin. Used to gate content-management and diagnostics endpoints.
func (app *Application) RequireAdminUser(next http.HandlerFunc) http.HandlerFunc {
	return app.RequireActivatedAndAuthedUser(func(w http.ResponseWriter, r *http.Request) {
		user := app.contextGetUser(r)
		if !user.IsAdmin {
			app.NotPermittedResponse(w, r)
			return
		}
		next.ServeHTTP(w, r)
	})
}

// RequireSyncEntitlement gates cloud sync. During MVP (pre-launch) sync is FREE
// for every authenticated, activated user — no paid entitlement is required and
// there is no payment screen, so early users can try everything. The paid
// entitlement check is deliberately DISABLED (not deleted) below; re-enable it
// when monetization ships. See ARCHITECTURE_AND_DECISIONS.md (D11).
func (app *Application) RequireSyncEntitlement(next http.HandlerFunc) http.HandlerFunc {
	return app.RequireActivatedAndAuthedUser(next)

	// Paywalled version — restore post-MVP to gate sync behind an active "sync"
	// entitlement (server-side, never trusting a client flag; 402 when absent):
	//
	// return app.RequireActivatedAndAuthedUser(func(w http.ResponseWriter, r *http.Request) {
	// 	user := app.contextGetUser(r)
	// 	ok, err := app.Models.Subscriptions.HasActiveEntitlement(r.Context(), user.ID, "sync")
	// 	if err != nil {
	// 		app.serverErrorResponse(w, r, err)
	// 		return
	// 	}
	// 	if !ok {
	// 		app.paymentRequiredResponse(w, r)
	// 		return
	// 	}
	// 	next.ServeHTTP(w, r)
	// })
}

func (app *Application) RequireActivatedAndAuthedUser(next http.HandlerFunc) http.HandlerFunc {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		user := app.contextGetUser(r)
		status := app.contextGetStatus(r)

		if !status {
			app.invalidAuthenticationTokenResponse(w, r)
			return
		}
		if user.IsAnonymous() {
			app.authenticationRequiredResponse(w, r)
			return
		}

		if !user.Activated {
			app.inactiveAccountResponse(w, r)
			return
		}
		next.ServeHTTP(w, r)
	})
}

// SecureHeaders sets conservative security response headers on every response.
func (app *Application) SecureHeaders(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("X-Content-Type-Options", "nosniff")
		w.Header().Set("X-Frame-Options", "DENY")
		w.Header().Set("Referrer-Policy", "no-referrer")
		// This is a JSON API; disallow embedding/loading of active content.
		w.Header().Set("Content-Security-Policy", "default-src 'none'; frame-ancestors 'none'")
		next.ServeHTTP(w, r)
	})
}
func (app *Application) Authenticate(next http.Handler) http.Handler {

	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Add("Vary", "Authorization")
		authorizationHeader := r.Header.Get("Authorization")
		if authorizationHeader == "" {
			r = app.contextSetUser(r, models.AnonymousUser)
			r = app.contextSetTokenStatus(r, true)
			next.ServeHTTP(w, r)
			return
		}
		headerParts := strings.Split(authorizationHeader, " ")
		if len(headerParts) != 2 || headerParts[0] != "Bearer" {
			r = app.contextSetUser(r, models.AnonymousUser)
			r = app.contextSetTokenStatus(r, false)
			next.ServeHTTP(w, r)
			return
		}
		token := headerParts[1]
		v := validator.New()
		if models.ValidateTokenPlaintext(v, token); !v.Valid() {
			r = app.contextSetUser(r, models.AnonymousUser)
			r = app.contextSetTokenStatus(r, false)
			next.ServeHTTP(w, r)
			return
		}

		user, err := app.Models.Users.GetForToken(r.Context(), models.ScopeAuthentication, token)
		if err != nil {
			switch {
			case errors.Is(err, models.ErrRecordNotFound):
				r = app.contextSetUser(r, models.AnonymousUser)
				r = app.contextSetTokenStatus(r, false)
				next.ServeHTTP(w, r)
			default:
				app.serverErrorResponse(w, r, err)
			}
			return
		}

		r = app.contextSetTokenStatus(r, true)
		r = app.contextSetUser(r, user)
		next.ServeHTTP(w, r)
	})
}

// expvarInt / expvarMap return the named expvar, creating it on first use. (The
// plain expvar.NewInt panics on a duplicate name, which broke any process that
// builds the middleware twice, e.g. tests.)
func expvarInt(name string) *expvar.Int {
	if v, ok := expvar.Get(name).(*expvar.Int); ok {
		return v
	}
	return expvar.NewInt(name)
}

func expvarMap(name string) *expvar.Map {
	if v, ok := expvar.Get(name).(*expvar.Map); ok {
		return v
	}
	return expvar.NewMap(name)
}

// legacyRouteKey reports whether a request targets one of the old REST endpoints
// that the offline-first app no longer calls (per-metric CRUD, analytics, points,
// period, settings, catalogs), and returns a low-cardinality key for it
// ("METHOD /v1/user/<resource>"; ids and dates are dropped). The app now talks to
// auth, profile, resources, sync, entitlements and logout only.
func legacyRouteKey(method, path string) (string, bool) {
	parts := strings.Split(strings.Trim(path, "/"), "/") // v1, user, symsMetric, ...
	if len(parts) < 2 || parts[0] != "v1" {
		return "", false
	}
	switch {
	case parts[1] == "user" && len(parts) >= 3 && parts[2] != "entitlements":
		return method + " /v1/user/" + parts[2], true
	case parts[1] == "allmetrics", parts[1] == "allsmileys",
		parts[1] == "allsymptoms", parts[1] == "allconditions":
		return method + " /v1/" + parts[1], true
	}
	return "", false
}

func (app *Application) Metrics(next http.Handler) http.Handler {
	var (
		totalRequestsReceived           = expvarInt("total_requests_received")
		totalResponsesSent              = expvarInt("total_responses_sent")
		totalProcessingTimeMicroseconds = expvarInt("total_processing_time_μs")
		totalResponsesSentByStatus      = expvarMap("total_responses_sent_by_status")
		// Hits on endpoints the current app doesn't use. Watch this (admin-only
		// /v1/debug/vars) over a release or two: when it flatlines, the legacy
		// handlers are safe to delete.
		legacyRequests = expvarMap("legacy_requests")
	)
	// The following code will be run for every request...
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		// Record the time that we started to process the request.
		start := time.Now()
		totalRequestsReceived.Add(1)
		if key, ok := legacyRouteKey(r.Method, r.URL.Path); ok {
			legacyRequests.Add(key, 1)
		}
		mw := &metricsResponseWriter{wrapped: w}
		next.ServeHTTP(mw, r)
		totalResponsesSent.Add(1)
		totalResponsesSentByStatus.Add(strconv.Itoa(mw.statusCode), 1)
		duration := time.Since(start).Microseconds()
		totalProcessingTimeMicroseconds.Add(duration)
	})
}

type metricsResponseWriter struct {
	wrapped       http.ResponseWriter
	statusCode    int
	headerWritten bool
}

func (mw *metricsResponseWriter) Header() http.Header {
	return mw.wrapped.Header()
}
func (mw *metricsResponseWriter) WriteHeader(statusCode int) {
	mw.wrapped.WriteHeader(statusCode)
	if !mw.headerWritten {
		mw.statusCode = statusCode
		mw.headerWritten = true
	}
}
func (mw *metricsResponseWriter) Write(b []byte) (int, error) {
	if !mw.headerWritten {
		mw.statusCode = http.StatusOK
		mw.headerWritten = true
	}
	return mw.wrapped.Write(b)
}
func (mw *metricsResponseWriter) Unwrap() http.ResponseWriter {
	return mw.wrapped
}
