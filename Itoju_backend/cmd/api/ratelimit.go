package api

import (
	"net/http"
	"sync"
	"time"

	"golang.org/x/time/rate"
)

// keyedLimiter is a set of token buckets, one per key (client IP or user id).
// Idle keys are swept lazily from allow() — no background goroutine to leak or
// stop — so memory stays bounded by the number of recently-active keys.
type keyedLimiter struct {
	mu      sync.Mutex
	clients map[string]*bucket
	rps     rate.Limit
	burst   int

	idleAfter  time.Duration // forget a key after this long without traffic
	sweepEvery time.Duration // at most one sweep per this interval
	lastSweep  time.Time
}

type bucket struct {
	limiter  *rate.Limiter
	lastSeen time.Time
}

func newKeyedLimiter(rps float64, burst int) *keyedLimiter {
	return &keyedLimiter{
		clients:    make(map[string]*bucket),
		rps:        rate.Limit(rps),
		burst:      burst,
		idleAfter:  3 * time.Minute,
		sweepEvery: time.Minute,
		lastSweep:  time.Now(),
	}
}

// allow reports whether one more request for key fits its bucket.
func (k *keyedLimiter) allow(key string) bool {
	k.mu.Lock()
	defer k.mu.Unlock()
	now := time.Now()
	if now.Sub(k.lastSweep) >= k.sweepEvery {
		for key, b := range k.clients {
			if now.Sub(b.lastSeen) > k.idleAfter {
				delete(k.clients, key)
			}
		}
		k.lastSweep = now
	}
	b, ok := k.clients[key]
	if !ok {
		b = &bucket{limiter: rate.NewLimiter(k.rps, k.burst)}
		k.clients[key] = b
	}
	b.lastSeen = now
	return b.limiter.Allow()
}

func (k *keyedLimiter) size() int {
	k.mu.Lock()
	defer k.mu.Unlock()
	return len(k.clients)
}

// RateLimit is the outer, per-IP flood guard. It runs BEFORE authentication, so
// it is deliberately generous (many phones can share one carrier-NAT address);
// the stricter per-account limit is RateLimitUser.
func (app *Application) RateLimit(next http.Handler) http.Handler {
	limiter := newKeyedLimiter(app.Config.Limiter.Rps, app.Config.Limiter.Burst)
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if !app.Config.Limiter.Enabled {
			next.ServeHTTP(w, r)
			return
		}
		ip, fromEdge := app.clientIPWithSource(r)
		// Diagnostics: is the trusted edge header actually arriving? (see /v1/debug/vars)
		source := "fallback"
		if fromEdge {
			source = "edge_header"
		}
		expvarMap("client_ip_source").Add(source, 1)
		seen := expvarMap("client_ip_headers_seen")
		for _, name := range clientIPHeadersToWatch {
			if r.Header.Get(name) != "" {
				seen.Add(name, 1)
			}
		}
		if !limiter.allow(ip) {
			app.rateLimitExceededResponse(w, r)
			return
		}
		next.ServeHTTP(w, r)
	})
}

// RateLimitUser throttles each authenticated account on its own bucket, however
// many devices or IPs it uses and without penalising other people who happen to
// share its IP. It must sit AFTER Authenticate. Anonymous requests pass through
// (the per-IP guard and the auth-endpoint limiter cover them).
func (app *Application) RateLimitUser(next http.Handler) http.Handler {
	limiter := newKeyedLimiter(app.Config.Limiter.UserRps, app.Config.Limiter.UserBurst)
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if app.Config.Limiter.Enabled {
			if user := app.contextGetUser(r); !user.IsAnonymous() && !limiter.allow(user.ID) {
				app.rateLimitExceededResponse(w, r)
				return
			}
		}
		next.ServeHTTP(w, r)
	})
}

// NewAuthRateLimiter returns a wrapper that throttles sensitive auth endpoints
// (login, register, password reset) per client IP to slow down brute-force and
// credential-stuffing attempts, without affecting the app's data endpoints.
func (app *Application) NewAuthRateLimiter() func(http.HandlerFunc) http.HandlerFunc {
	limiter := newKeyedLimiter(1, 5) // ~1 request/sec sustained, burst of 5
	return func(next http.HandlerFunc) http.HandlerFunc {
		return func(w http.ResponseWriter, r *http.Request) {
			if !limiter.allow(app.clientIP(r)) {
				app.rateLimitExceededResponse(w, r)
				return
			}
			next(w, r)
		}
	}
}
