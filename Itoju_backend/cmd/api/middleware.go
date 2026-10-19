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

func (app *Application) Metrics(next http.Handler) http.Handler {
	var (
		totalRequestsReceived           = expvar.NewInt("total_requests_received")
		totalResponsesSent              = expvar.NewInt("total_responses_sent")
		totalProcessingTimeMicroseconds = expvar.NewInt("total_processing_time_μs")
		totalResponsesSentByStatus      = expvar.NewMap("total_responses_sent_by_status")
	)
	// The following code will be run for every request...
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		// Record the time that we started to process the request.
		start := time.Now()
		totalRequestsReceived.Add(1) // Call the next handler in the chain.
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
