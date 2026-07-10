package api

import (
	"encoding/json"
	"net/http"
	"time"

	"github.com/olagookundavid/itoju/internal/models"
)

// maxSyncBody caps a push/pull body at 5 MB — larger than readJSON's 1 MB
// default because food rows are wide (17 columns incl. four tag arrays).
const maxSyncBody = 5 << 20

const maxRowsPerTable = 500

// PushSyncHandler applies a batch of client changes. Every row is written under
// the authenticated user's id — any user_id in the payload is ignored.
func (app *Application) PushSyncHandler(w http.ResponseWriter, r *http.Request) {
	user := app.contextGetUser(r)

	var input struct {
		DeviceID string `json:"device_id"`
		Changes  []struct {
			Table string            `json:"table"`
			Rows  []json.RawMessage `json:"rows"`
		} `json:"changes"`
	}
	r.Body = http.MaxBytesReader(w, r.Body, maxSyncBody)
	if err := json.NewDecoder(r.Body).Decode(&input); err != nil {
		app.badRequestResponse(w, r, err)
		return
	}

	results := map[string][]models.PushResult{}
	for _, change := range input.Changes {
		if _, ok := syncTableAllowed(change.Table); !ok {
			app.failedValidationResponse(w, r, map[string]string{"table": "unknown sync table: " + change.Table})
			return
		}
		if len(change.Rows) > maxRowsPerTable {
			app.failedValidationResponse(w, r, map[string]string{"rows": "batch exceeds 500 rows for " + change.Table})
			return
		}
		res, err := app.Models.Sync.Push(r.Context(), user.ID, change.Table, change.Rows)
		if err != nil {
			app.serverErrorResponse(w, r, err)
			return
		}
		results[change.Table] = res
	}

	app.respond(w, r, http.StatusOK, envelope{
		"results":     results,
		"server_time": time.Now().UTC().Format(time.RFC3339),
	})
}

// PullSyncHandler returns rows changed since the client's watermark, per table.
func (app *Application) PullSyncHandler(w http.ResponseWriter, r *http.Request) {
	user := app.contextGetUser(r)

	var input struct {
		Since  string   `json:"since"`
		Tables []string `json:"tables"`
		Limit  int      `json:"limit"`
	}
	r.Body = http.MaxBytesReader(w, r.Body, maxSyncBody)
	if err := json.NewDecoder(r.Body).Decode(&input); err != nil {
		app.badRequestResponse(w, r, err)
		return
	}

	since := time.Time{}
	if input.Since != "" {
		t, err := time.Parse(time.RFC3339, input.Since)
		if err != nil {
			app.badRequestResponse(w, r, err)
			return
		}
		since = t
	}

	tables := input.Tables
	if len(tables) == 0 {
		tables = models.SyncableTables()
	}

	changes := map[string][]map[string]any{}
	hasMore := false
	for _, table := range tables {
		if _, ok := syncTableAllowed(table); !ok {
			app.failedValidationResponse(w, r, map[string]string{"tables": "unknown sync table: " + table})
			return
		}
		rows, more, err := app.Models.Sync.Pull(r.Context(), user.ID, table, since, input.Limit)
		if err != nil {
			app.serverErrorResponse(w, r, err)
			return
		}
		changes[table] = rows
		hasMore = hasMore || more
	}

	app.respond(w, r, http.StatusOK, envelope{
		"changes":   changes,
		"watermark": time.Now().Add(-5 * time.Second).UTC().Format(time.RFC3339),
		"has_more":  hasMore,
	})
}

// GetUserEntitlements lets the client render paywall state without attempting a
// (would-be 402) sync. Returns whether the user currently holds "sync".
func (app *Application) GetUserEntitlements(w http.ResponseWriter, r *http.Request) {
	user := app.contextGetUser(r)
	ok, err := app.Models.Subscriptions.HasActiveEntitlement(r.Context(), user.ID, "sync")
	if err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}
	app.respond(w, r, http.StatusOK, envelope{
		"entitlements": envelope{"sync": ok},
	})
}

func syncTableAllowed(table string) (string, bool) {
	for _, t := range models.SyncableTables() {
		if t == table {
			return t, true
		}
	}
	return "", false
}
