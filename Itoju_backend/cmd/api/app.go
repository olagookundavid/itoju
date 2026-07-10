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
		Rps     float64
		Burst   int
		Enabled bool
	}
	Cors struct {
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
