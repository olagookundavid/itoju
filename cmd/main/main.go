// Command main starts the Itoju API server. Configuration (DB_URL,
// RESEND_API_KEY, RESEND_FROM_EMAIL, FIREBASE_PROJECT_ID) is supplied via
// environment variables (loaded from .env in local development).
package main

import (
	"os"
	"time"

	_ "github.com/lib/pq"
	"github.com/olagookundavid/itoju/cmd/api"
	"github.com/olagookundavid/itoju/internal/firebaseauth"
	"github.com/olagookundavid/itoju/internal/jsonlog"
	"github.com/olagookundavid/itoju/internal/mailer"
	"github.com/olagookundavid/itoju/internal/models"
	"github.com/olagookundavid/itoju/internal/server"
	"github.com/olagookundavid/itoju/internal/worker"
)

func main() {
	dbUrl := loadDbUrl()
	cfg := flagSetup(dbUrl)
	displayVersion("version")

	logger := jsonlog.New(os.Stdout, jsonlog.LevelInfo)
	db, err := openDB(*cfg)
	if err != nil {
		logger.PrintFatal(err, nil)
	}
	logger.PrintInfo("database connection pool established", nil)

	defer db.Close()

	// Apply any pending schema migrations before serving.
	if err := runMigrations(cfg.Db.Dsn, logger); err != nil {
		logger.PrintFatal(err, nil)
	}

	expvarSetup(db)

	dataModels := models.NewModels(db)

	// Bounded worker pool for fire-and-forget jobs (emails, one-off setup).
	pool := worker.NewPool(cfg.Worker.PoolSize, cfg.Worker.QueueSize, logger)

	// Batcher that coalesces gamification point awards into bulk writes.
	points := worker.NewPointsBatcher(
		func(evs []worker.PointEvent) error {
			batch := make([]models.PointEvent, len(evs))
			for i, e := range evs {
				batch[i] = models.PointEvent{UserID: e.UserID, Scope: e.Scope, Points: e.Points}
			}
			return dataModels.UserPoint.InsertPointsBatch(batch)
		},
		cfg.Points.BatchSize,
		cfg.Points.BufferSize,
		time.Duration(cfg.Points.FlushIntervalMs)*time.Millisecond,
		logger,
	)

	app := &api.Application{
		Config:   *cfg,
		Logger:   logger,
		Models:   dataModels,
		Mailer:   mailer.New(cfg.Resend.ApiKey, cfg.Resend.From),
		Firebase: firebaseauth.New(cfg.Firebase.ProjectID),
		Pool:     pool,
		Points:   points,
	}

	if !app.Mailer.Enabled() {
		logger.PrintInfo("mailer disabled: RESEND_API_KEY or RESEND_FROM_EMAIL not set; emails will be skipped", nil)
	}
	if !app.Firebase.Enabled() {
		logger.PrintInfo("firebase social login disabled: FIREBASE_PROJECT_ID not set; /social-login will be unavailable", nil)
	}

	intializeBackGroundTask(app)

	err = server.Serve(app)
	if err != nil {
		logger.PrintFatal(err, nil)
	}
}
