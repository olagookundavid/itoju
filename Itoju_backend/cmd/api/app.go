package api

import (
	"github.com/olagookundavid/itoju/internal/firebaseauth"
	"github.com/olagookundavid/itoju/internal/jsonlog"
	"github.com/olagookundavid/itoju/internal/mailer"
	"github.com/olagookundavid/itoju/internal/models"
	"github.com/olagookundavid/itoju/internal/worker"
)

type Application struct {
	Config   Config
	Logger   *jsonlog.Logger
	Models   models.Models
	Mailer   *mailer.Mailer
	Firebase *firebaseauth.Verifier
	Pool     *worker.Pool
	Points   *worker.PointsBatcher
}

type Config struct {
	Port int
	Env  string
	Db   struct {
		Dsn          string
		MaxOpenConns int
		MaxIdleConns int
		MaxIdleTime  string
	}
	Limiter struct {
		// Rps/Burst: per-IP flood guard (before auth) — generous, since carrier NAT
		// puts many phones behind one address. UserRps/UserBurst: per account.
		Rps       float64
		Burst     int
		UserRps   float64
		UserBurst int
		Enabled   bool
	}
	// ClientIPHeader names a header set by a TRUSTED edge proxy (e.g. Cloudflare's
	// "CF-Connecting-IP") that carries the true client address. The edge overwrites
	// it, so clients can't forge it. When empty/absent we fall back to
	// X-Forwarded-For parsing, which a client CAN spoof if no proxy rewrites it.
	ClientIPHeader string
	Cors           struct {
		TrustedOrigins []string
	}
	Resend struct {
		ApiKey string
		From   string
	}
	Firebase struct {
		ProjectID string
	}
	Worker struct {
		PoolSize  int
		QueueSize int
	}
	Points struct {
		BatchSize       int
		BufferSize      int
		FlushIntervalMs int
	}
	RevenueCat struct {
		// WebhookToken is the shared secret RevenueCat sends in the Authorization
		// header of webhook calls (configured in the RC dashboard). Empty disables
		// the webhook endpoint (returns 503) so a misconfigured deploy fails safe.
		WebhookToken string
	}
}
