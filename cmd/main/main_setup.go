package main

import (
	"context"
	"database/sql"
	"expvar"
	"flag"
	"fmt"
	"log"
	"os"
	"runtime"
	"strconv"
	"time"

	"github.com/joho/godotenv"
	"github.com/olagookundavid/itoju/cmd/api"
	"github.com/olagookundavid/itoju/internal/jsonlog"
	sqlembed "github.com/olagookundavid/itoju/internal/sql"
	"github.com/olagookundavid/itoju/internal/vcs"
	"github.com/pressly/goose/v3"
	"github.com/robfig/cron/v3"
)

// runMigrations applies all pending database migrations (embedded in the
// binary) on startup, using a short-lived connection. goose.Up is idempotent —
// only migrations newer than the recorded version are applied.
func runMigrations(dsn string, logger *jsonlog.Logger) error {
	db, err := sql.Open("postgres", dsn)
	if err != nil {
		return fmt.Errorf("open db for migrations: %w", err)
	}
	defer db.Close()

	if err := goose.SetDialect("postgres"); err != nil {
		return fmt.Errorf("set goose dialect: %w", err)
	}
	goose.SetBaseFS(sqlembed.EmbedMigrations)
	if err := goose.Up(db, "migrations"); err != nil {
		return fmt.Errorf("apply migrations: %w", err)
	}
	logger.PrintInfo("database migrations up to date", nil)
	return nil
}

var (
	version = vcs.Version()
)

// func mainx() {
// 	app := intialize()
// 	intializeBackGroundTask(app)
// 	err := server.Serve(app)
// 	if err != nil {
// 		jsonlog.New(os.Stdout, jsonlog.LevelInfo).PrintFatal(err, nil)
// 	}
// }

func intializeBackGroundTask(app *api.Application) {
	app.Background(func() {
		cronJob(app)
	})
}

func loadDbUrl() string {
	godotenv.Load()
	dbUrl := os.Getenv("DB_URL")
	if dbUrl == "" {
		log.Fatal("DB_URL env variable missing")
	}
	return dbUrl
}

func expvarSetup(db *sql.DB) {
	expvar.NewString("version").Set(version)
	expvar.Publish("goroutines", expvar.Func(func() any {
		return runtime.NumGoroutine()
	}))
	expvar.Publish("database", expvar.Func(func() any {
		return db.Stats()
	}))
	expvar.Publish("timestamp", expvar.Func(func() any {
		return time.Now().Unix()
	}))
}

func displayVersion(flagStr string) {
	displayVersion := flag.Bool(flagStr, false, "Display version and exit")
	flag.Parse()
	if *displayVersion {
		fmt.Printf("Version:\t%s\n", version)
		os.Exit(0)
	}
}

func openDB(cfg api.Config) (*sql.DB, error) {
	db, err := sql.Open("postgres", cfg.Db.Dsn)
	if err != nil {
		return nil, err
	}
	db.SetMaxOpenConns(cfg.Db.MaxOpenConns)
	db.SetMaxIdleConns(cfg.Db.MaxIdleConns)
	duration, err := time.ParseDuration(cfg.Db.MaxIdleTime)
	if err != nil {
		return nil, err
	}
	db.SetConnMaxIdleTime(duration)
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	err = db.PingContext(ctx)
	if err != nil {
		return nil, err
	}
	return db, nil
}

func cronJob(app *api.Application) {
	// 	ticker := time.NewTicker(2 * time.Second)
	// 	defer ticker.Stop()
	//	for {
	//		select {
	//		case <-ticker.C:
	//			fmt.Println("Running task every second")
	//		}
	//	}
	c := cron.New()

	if _, err := c.AddFunc("@daily", func() {
		defer recoverCron(app, "delete expired tokens")
		app.Logger.PrintInfo("Deleting Tokens from tokens table", nil)
		if err := app.Models.Tokens.DeleteAllExpiredTokens(); err != nil {
			app.Logger.PrintError(err, map[string]string{"error": "An error occured with deleting tokens from Tokens Table"})
		}
	}); err != nil {
		app.Logger.PrintError(err, map[string]string{"error": "An error occured scheduling the token cleanup cron job"})
		return
	}

	if _, err := c.AddFunc("@daily", func() {
		defer recoverCron(app, "delete week-old points")
		app.Logger.PrintInfo("Deleting Over 1 week Points", nil)
		if err := app.Models.UserPoint.DeletePointRecordMoreThanWeek(); err != nil {
			app.Logger.PrintError(err, map[string]string{"error": "An error occured with deleting from points records table"})
		}
	}); err != nil {
		app.Logger.PrintError(err, map[string]string{"error": "An error occured scheduling the points cleanup cron job"})
		return
	}

	c.Start()
}

// envStr returns the value of env var `key`, or `fallback` when unset/empty.
func envStr(key, fallback string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return fallback
}

// envInt returns the integer value of env var `key`, or `fallback` when unset
// or unparseable.
func envInt(key string, fallback int) int {
	if v := os.Getenv(key); v != "" {
		if n, err := strconv.Atoi(v); err == nil {
			return n
		}
	}
	return fallback
}

// recoverCron keeps a panic inside a scheduled job from taking down the cron goroutine.
func recoverCron(app *api.Application, job string) {
	if r := recover(); r != nil {
		app.Logger.PrintError(fmt.Errorf("cron job %q panicked: %v", job, r), nil)
	}
}

func flagSetup(dbUrl string) *api.Config {

	var cfg api.Config

	//env and port (env-var driven so the container/platform can configure them)
	flag.IntVar(&cfg.Port, "port", envInt("PORT", 8080), "API server port")
	flag.StringVar(&cfg.Env, "env", envStr("APP_ENV", "development"), "Environment (development|staging|production)")
	//db
	flag.StringVar(&cfg.Db.Dsn, "db-dsn", dbUrl, "PostgreSQL DSN")
	flag.IntVar(&cfg.Db.MaxOpenConns, "db-max-open-conns", 15, "PostgreSQL max open connections")
	flag.IntVar(&cfg.Db.MaxIdleConns, "db-max-idle-conns", 12, "PostgreSQL max idle connections")
	flag.StringVar(&cfg.Db.MaxIdleTime, "db-max-idle-time", "1m", "PostgreSQL max connection idle time")
	//limiters
	flag.Float64Var(&cfg.Limiter.Rps, "limiter-rps", 2, "Rate limiter maximum requests per second")
	flag.IntVar(&cfg.Limiter.Burst, "limiter-burst", 4, "Rate limiter maximum burst")
	flag.BoolVar(&cfg.Limiter.Enabled, "limiter-enabled", true, "Enable rate limiter")
	//resend (transactional email)
	flag.StringVar(&cfg.Resend.ApiKey, "resend-api-key", os.Getenv("RESEND_API_KEY"), "Resend API key")
	flag.StringVar(&cfg.Resend.From, "resend-from", os.Getenv("RESEND_FROM_EMAIL"), "Resend verified sender email (e.g. Itoju <noreply@yourdomain.com>)")
	//firebase (social login id-token verification)
	flag.StringVar(&cfg.Firebase.ProjectID, "firebase-project-id", os.Getenv("FIREBASE_PROJECT_ID"), "Firebase project ID used to verify Google/Firebase ID tokens")
	//background worker pool (fire-and-forget jobs)
	flag.IntVar(&cfg.Worker.PoolSize, "worker-pool-size", 8, "Number of background worker goroutines")
	flag.IntVar(&cfg.Worker.QueueSize, "worker-queue-size", 1024, "Background worker job queue size")
	//points batcher
	flag.IntVar(&cfg.Points.BatchSize, "points-batch-size", 100, "Max point awards flushed per batch")
	flag.IntVar(&cfg.Points.BufferSize, "points-buffer-size", 2048, "Point-award intake buffer size")
	flag.IntVar(&cfg.Points.FlushIntervalMs, "points-flush-interval-ms", 1000, "Point-award max flush interval in milliseconds")

	return &cfg
}
