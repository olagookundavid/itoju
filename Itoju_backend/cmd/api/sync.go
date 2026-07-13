package api

import (
	"encoding/json"
	"errors"
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
			// A malformed client row is the client's error, not a server incident.
			if errors.Is(err, models.ErrBadSyncRow) {
				app.failedValidationResponse(w, r, map[string]string{"rows": err.Error()})
				return
			}
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

// PullSyncHandler returns rows changed since the client's watermark, per table,
// with keyset pagination. The first request of a sweep carries only `since`;
// the server answers with a request-stable `watermark` (the sweep's upper
// bound) and, for any table that filled its page, a per-table `(ts, id)`
// cursor. The client repeats with the SAME `until` (= that watermark) and the
// returned `cursors` until has_more is false, and only then advances its
// persisted watermark — so a table with more rows than one page can never have
// rows silently skipped.
func (app *Application) PullSyncHandler(w http.ResponseWriter, r *http.Request) {
	user := app.contextGetUser(r)

	var input struct {
		Since   string                       `json:"since"`
		Until   string                       `json:"until"`
		Cursors map[string]models.PullCursor `json:"cursors"`
		Tables  []string                     `json:"tables"`
		Limit   int                          `json:"limit"`
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

	// One stable upper bound for the whole sweep, computed BEFORE any query (a
	// per-query bound could outrun rows committing mid-request). Follow-up pages
	// of the same sweep pass it back via `until`.
	until := time.Now().Add(-5 * time.Second).UTC()
	if input.Until != "" {
		t, err := time.Parse(time.RFC3339, input.Until)
		if err != nil {
			app.badRequestResponse(w, r, err)
			return
		}
		until = t
	}

	tables := input.Tables
	if len(tables) == 0 {
		tables = models.SyncableTables()
	}
	// Dedup and cap: a request must not multiply work by repeating table names.
	seen := map[string]bool{}
	deduped := make([]string, 0, len(tables))
	for _, t := range tables {
		if !seen[t] {
			seen[t] = true
			deduped = append(deduped, t)
		}
	}
	tables = deduped
	if len(tables) > len(models.SyncableTables()) {
		app.failedValidationResponse(w, r, map[string]string{"tables": "too many tables"})
		return
	}

	changes := map[string][]map[string]any{}
	outCursors := map[string]models.PullCursor{}
	hasMore := false
	for _, table := range tables {
		if _, ok := syncTableAllowed(table); !ok {
			app.failedValidationResponse(w, r, map[string]string{"tables": "unknown sync table: " + table})
			return
		}
		tableSince, cursorID := since, ""
		if c, ok := input.Cursors[table]; ok && c.ID != "" {
			t, err := time.Parse(time.RFC3339, c.Ts)
			if err != nil {
				app.badRequestResponse(w, r, err)
				return
			}
			tableSince, cursorID = t, c.ID
		}
		rows, more, err := app.Models.Sync.Pull(r.Context(), user.ID, table, tableSince, cursorID, until, input.Limit)
		if err != nil {
			app.serverErrorResponse(w, r, err)
			return
		}
		changes[table] = rows
		if more && len(rows) > 0 {
			last := rows[len(rows)-1]
			ts, _ := last["server_updated_at"].(string)
			id, _ := last["id"].(string)
			outCursors[table] = models.PullCursor{Ts: ts, ID: id}
			hasMore = true
		}
	}

	app.respond(w, r, http.StatusOK, envelope{
		"changes":   changes,
		"watermark": until.Format(time.RFC3339Nano),
		"has_more":  hasMore,
		"cursors":   outCursors,
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
