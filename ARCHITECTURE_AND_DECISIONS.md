# Itoju — Architecture, Decisions & Audit Map

This is the single reference for **what was decided, why, and where it lives** —
written so independent agents can audit each subsystem against the plan. Sibling
docs: [`OFFLINE_FIRST_PLAN.md`](OFFLINE_FIRST_PLAN.md) (the plan) and
[`SYNC_ID_SPEC.md`](SYNC_ID_SPEC.md) (the id strategy). This doc maps plan →
implementation → how to verify.

Repo layout (monorepo): `Itoju_backend/` (Go API) + `itoju_mobile/` (Flutter).

---

## 0. The end-to-end flow (how it all comes together)

```
FIRST LAUNCH
  AuthGate  ──►  Onboarding slides  ──►  NameStep ("What should we call you?")
     │                                      │  stores HiveKeys.localName (local only)
     │                                      ▼
     └──────────────────────────────►  LandingPage  (app is fully usable, offline)
                                            │
  All tracking (metrics, menses, food…) writes to Drift (SQLite) via Repositories.
  Repositories set sync_state=pending. NOTIFIERS NEVER TOUCH THE NETWORK.
                                            │
                          ┌─────────────────┴───────────────────┐
                          │  User chooses to sync (Settings)     │
                          ▼                                       │
              Not signed in → "Sign in to back up & sync"        │
                          │                                       │
             Sign up / Google  (first name PREFILLED from        │
             HiveKeys.localName)                                  │
                          │                                       │
             Backend verifies identity, binds Firebase UID       │
             to the account (takeover-safe), issues session      │
                          │                                       │
             boundServerUserId stored → SyncEngine re-keys        │
             deterministic ids from localAccountId → serverUserId │
                          ▼                                       ▼
              SyncEngine.push()/pull()  ◄── gated by entitlement (paid) ──►  Backend
                 (the ONLY network path for health data)         /v1/sync/push, /pull
```

**Re-entry & lock:** on every cold start the AuthGate shows the biometric
app-lock (→ device passcode fallback); on resume it re-locks if backgrounded
> 15 min. Independent of whether an account exists.

**Sync cadence:** catch-up-on-open. On launch/resume/reconnect the app checks
"is a sync due?" per the user's cadence (Off / Daily@5PM / Weekly / Monthly) and
runs one if so. No exact-time background alarm (unreliable on mobile).

---

## 1. Decisions (and the rationale)

| # | Decision | Rationale |
|---|----------|-----------|
| D1 | **Local-first, account optional.** App fully usable with no account; a local UUID account owns all data. | Users get value before any signup; auth only matters for sync. |
| D2 | **Name-only onboarding.** Capture just a name locally; DOB/credentials collected later at sign-up. | Lowest friction to start; name prefills signup. |
| D3 | **Sync is premium + auth-gated, server-enforced.** `RequireSyncEntitlement` + `Authenticate`. Client flag never trusted. | Health data centralization must be gated server-side. |
| D4 | **Catch-up-on-open periodic sync**, not background alarms. | iOS/Android won't reliably fire an exact-time task while killed. |
| D5 | **App-lock on by default, toggleable, 15-min re-lock**, biometric→passcode. | Matches WhatsApp-style expectation; protects local health data regardless of account. |
| D6 | **Client-generated ids**: UUIDv5 (deterministic) for singleton-per-day rows, UUIDv7 for list rows. | Two devices compute the same id for "today's food" → merge, not conflict. See `SYNC_ID_SPEC.md`. |
| D7 | **Per-record last-write-wins by `updated_at`** — the *writing device's* edit time (client clock). The server-stamped `server_updated_at` is a separate column used only as the pull watermark/cursor, so a skewed client clock can lose an LWW race but can never make a row invisible to pulls. | Single user, 2-device conflicts only; simplest correct policy. |
| D8 | **Firebase-UID account binding (takeover fix).** An account binds to at most one Firebase UID; a foreign identity with the same email is rejected. | Closes the email-only social-login takeover flagged in the 2026-06 audit — a hard prerequisite for cloud-syncing health data. |
| D9 | **Backend layering: handlers → (auth) service → repositories.** Consumer-side interfaces only where branch logic warrants (auth); thin CRUD stays handler→repo. | Idiomatic Go; avoids ceremony for passthrough CRUD. |
| D10 | **Request context threaded** through repos; **multi-statement ops atomic** via `withTx`. | Cancellation on disconnect; no half-applied writes. |
| D11 | **MVP: cloud sync is FREE, no paywall.** Pre-launch, any signed-in user can sync anytime; there is no payment screen and no entitlement is required. The RevenueCat/entitlement gating is **disabled, not deleted** — preserved in comments so it flips back on for monetization. | We want early users to see everything; monetization comes later. Supersedes D3 for now. |

---

## 2. Backend — implementation map & audit checklist

Base dir: `Itoju_backend/`. Build/verify: `go build ./... && go vet ./... && gofmt -l internal cmd`.

### 2A. Sync protocol (plan B2)
- [ ] Push/pull handlers exist and are entitlement-gated.
  - `cmd/api/sync.go` → `PushSyncHandler`, `PullSyncHandler`
  - `internal/routes/routes.go` → `/v1/sync/push`, `/v1/sync/pull` wrapped in `app.RequireSyncEntitlement(...)`
  - Verify: `grep -n "sync/push\|sync/pull" internal/routes/routes.go`
- [ ] Push is idempotent LWW upsert by uuid; honors `deleted_at`; returns server `updated_at`.
      Each row runs under a savepoint; a natural-key collision (legacy id vs
      client deterministic id for the same day) **heals** onto the existing row
      (`internal/models/sync.go` `healRow`) instead of failing the batch. The
      client pushes in ≤500-row chunks per table until drained.
- [ ] Pull is **keyset-paginated**: one request-stable `until` watermark per
      sweep + per-table `(server_updated_at, id)` cursors when a page fills;
      the client advances its persisted watermark only after a complete sweep
      (`has_more=false`), so >500-row tables restore losslessly. Tombstones included.
      Regression tests: `internal/models/sync_pagination_db_test.go`,
      `itoju_mobile/test/sync/sync_engine_test.dart`.

### 2B. Entitlements (plan B3) — **DISABLED for MVP (D11)**
- [ ] `RequireSyncEntitlement` currently allows any authed+activated user (paid
      check commented out); the paywalled body is preserved for post-MVP.
  - `cmd/api/middleware.go` `RequireSyncEntitlement` → `return app.RequireActivatedAndAuthedUser(next)`
  - Mobile mirror: `lib/sync/sync_engine.dart` `isSyncEnabled` returns `hasToken`.
  - Verify: `grep -n "RequireActivatedAndAuthedUser(next)" cmd/api/middleware.go`
- [ ] RevenueCat webhook upserts subscriptions and **verifies the shared secret**.
  - `cmd/api/webhooks_revenuecat.go` → `HandleRevenueCatWebhook` (Authorization header check ~line 41)
- [ ] `subscriptions` table exists.
  - migration `internal/sql/migrations/035_create_subscriptions.sql`

### 2C. Sync-readiness schema (plan B1)
- [ ] `updated_at` / `deleted_at` on syncable tables → `032_sync_columns.sql`
- [ ] Partial unique indexes coexisting with soft-delete → `033_partial_uniques.sql`
- [ ] Metric SERIAL→UUID → `034_metric_uuid.sql`, `036_uuid_pk_cutover.sql`
- [ ] `firebase_uid` column + unique index `ux_users_firebase_uid` → `037_add_firebase_uid.sql`
- Verify: `ls internal/sql/migrations | tail -8`; migrations auto-apply on startup (`cmd/main/main_setup.go` `runMigrations`).

### 2D. Auth security — Firebase-UID binding (D8)
- [ ] Social login matches on **verified UID first**, binds email accounts, rejects foreign identities.
  - `internal/service/auth.go` → `SocialLogin` (UID lookup → email-match link → `ErrAccountConflict`)
  - `internal/models/users.go` → `GetByFirebaseUID` (`WHERE firebase_uid = $1`), `LinkFirebaseUID` (`WHERE firebase_uid IS NULL` guard + unique-violation → conflict)
- [ ] Covered by tests: `internal/service/auth_test.go` → `TestSocialLoginRejectsForeignIdentity`, `TestSocialLoginBindsThenLoginsSameIdentity`.
- Verify: `go test ./internal/service -run TestSocialLogin -v`

### 2E. Architecture hardening (this session — D9/D10)
- [ ] Atomic password reset in one tx (OTP verify + set hash + consume tokens): `internal/models/users.go` `ResetPasswordWithOTP`; helper `internal/models/tx.go` `withTx`.
- [ ] Period cycle creation atomic: `internal/models/period_cycle.go` `CreateCycle`.
- [ ] Request context threaded (no `context.Background()` on request paths except the 3 detached: `InsertPointsBatch`, `DeletePointRecordMoreThanWeek`, `DeleteAllExpiredTokens`).
  - Verify: `grep -rn "context.Background()" internal/models` → expect only those 3.
- [ ] Analytics SQL deduped: `internal/models/analytics_query.go` (day/month/year share executors); tag CTE single-scan.
- [ ] SQLSTATE error checks (no driver-string matching): `internal/models/pgerrors.go` `isUniqueViolation` / `IsForeignKeyViolation`.
  - Verify: `grep -rn 'err.Error() == \`pq:' internal/models` → expect none.
- [ ] DB-backed tests (gated on `ITOJU_TEST_DB`): `internal/models/{reset_flow,analytics_equiv,period_cycle}_db_test.go`.
  - Run: `docker run -d --name pg -e POSTGRES_USER=itoju -e POSTGRES_PASSWORD=itoju -e POSTGRES_DB=itoju -p 55432:5432 postgres:16-alpine` then `ITOJU_TEST_DB='postgres://itoju:itoju@localhost:55432/itoju?sslmode=disable' go test ./internal/models`

---

## 3. Mobile — implementation map & audit checklist

Base dir: `itoju_mobile/`. Verify: `fvm flutter pub get && fvm flutter analyze && fvm flutter test`.

### 3A. Offline-first core (plan M1)
- [ ] Drift DB with generated code: `lib/data/db/app_database.dart` (+ `.g.dart`).
- [ ] One repository per domain (15): `lib/data/repositories/*.dart`.
- [ ] **Invariant: notifiers never call the network.** Metric/menses/food notifiers depend on repositories → Drift; only auth + resources notifiers use Dio (allowed — not synced health data).
  - Verify: `grep -rln "services/dio_provider" lib/features/*/notifiers lib/features/*/notifer` → expect only auth/profile, NOT metrics. *(Note the second glob: home's directory is spelled `notifer`.)*
- [ ] Deterministic + time-ordered ids: `lib/data/ids.dart` (`IdMinter`); namespace = `SYNC_ID_SPEC.md`.

### 3B. Sync engine & scheduling (plan M2 + D4)
- [ ] `lib/sync/sync_engine.dart` — `SyncEngine` is the only network path for health data; `syncNow()` returns whether it synced; gates on `EntitlementService.isSyncEnabled()`.
- [ ] `lib/sync/sync_schedule.dart` — pure `SyncSchedule.isDue(now, last, cadence, dailyHour)`; unit-tested (`test/sync/sync_schedule_test.dart`).
- [ ] `lib/sync/sync_controller.dart` — owns cadence + `lastSyncAt`; `maybePeriodicSync()` runs only when due; `backupNow()` for manual + stamps `lastSyncAt`.
- [ ] Triggers go through the controller: `lib/main.dart` (`_triggerSync`), `lib/sync/sync_scheduler.dart` (connectivity).
- [ ] Account binding + one-time re-key: `lib/sync/sync_engine.dart` `_bindIfNeeded` / `_rekeyDeterministicIds`; `lib/data/account_service.dart`.

### 3C. Onboarding (D1/D2)
- [ ] `AuthGate` mints local account, routes first-launch → onboarding: `lib/features/auth/pages/auth_gate.dart`.
- [ ] Name step (local, skippable): `lib/features/onboarding/name_step.dart`; onboarding routes to it: `lib/features/onboarding/onboardng.dart`.
- [ ] Sign-up first name prefilled from `HiveKeys.localName`: `lib/features/auth/pages/signUp_Page.dart.dart` `initState`.

### 3D. App-lock (D5)
- [ ] Biometric→passcode lock: `lib/features/auth/pages/app_lock.dart` (`LocalAuthApi.unlockApp`).
- [ ] On by default, toggleable: `lib/core/auth/session.dart` `isAppLockEnabled`; Settings toggle.
- [ ] 15-min re-lock threshold: `lib/main.dart` `_lockAfter = Duration(minutes: 15)`; cold start via `AuthGate`.

### 3E. Settings — Cloud Sync UI (D3/D11)
- [ ] `lib/features/settings/pages/settings.dart` `_cloudSyncSection`: cadence dropdown, "Back up now" (snackbar on failure), last-backup time; "Sign in to sync" when logged out. *(No premium/paywall message during MVP — D11; the unentitled state returns with monetization.)*
- [ ] **Account-switch guard (shared device):** a sign-in by a DIFFERENT server user than the device's bound account prompts keep-or-erase (`login.dart` `_completeLogin`); until resolved the engine refuses to sync (`sync_engine.dart` `_bindIfNeeded` compares `currentServerUserId` vs `boundServerUserId`), so two users' health data can never mix.

---

## 4. Are we done? (honest status)

**Implemented & green** (build + analyze + tests): backend sync endpoints, entitlements, RevenueCat webhook, Firebase-UID takeover fix, sync-readiness migrations (032–037); mobile Drift+repositories, sync engine/controller/schedule, onboarding, app-lock. Backend `go build` clean; mobile `flutter analyze` 0 errors; `flutter test` 19/19.

**Not yet done / verify before shipping:**
1. **On-device E2E**: no automated coverage of the full offline→sign-in→sync round-trip on a real device/emulator. Manual test needed (airplane-mode usage; then sign in + sync; a legacy account with >500 rows; a locally-logged cycle overlapping a legacy cycle; a second account on the same device → keep-or-erase prompt).
2. ~~Existing-user seed migration~~ **CLOSED (2026-07 audit remediation):** first sign-in pulls everything via keyset-paginated sweeps (no 500-row loss); push chunks and heals onto legacy rows; migration 038 makes legacy cycle/day ids deterministic. Note: sync scope v1 still excludes selections/settings tables — a restored device re-selects tracked metrics/conditions.
3. **Production config/secrets**: real `BASE_URL` via the makefile release targets (dio defaults to the emulator alias), **rotate the previously-committed Koyeb DB password — still pending and proven unrotated (it remains live in `.env` and recoverable from git history)**; rotate the Resend key as precaution. *(RevenueCat keys/webhook secret NOT needed for MVP — sync is free, D11.)*
4. **RevenueCat / paywall**: **deferred to post-MVP (D11).** Backend entitlement middleware + mobile `isSyncEnabled` are the two switches to flip back on; the webhook, `subscriptions` table, and `purchase_service` code remain in place, dormant.
5. ~~Notifier coverage~~ **CLOSED (2026-07 audit):** every health-data feature verified repository/local-service-backed; dead diagnosis notifiers and the stray Dio dependency removed.

**Suggested audit partition (one agent each):** (A) §2A+2B sync/entitlements, (B) §2C schema migrations vs plan B1, (C) §2D+2E auth security & tx atomicity, (D) §3A+3B offline core & sync invariant, (E) §3C+3D+3E onboarding/lock/settings, (F) §4 gaps — E2E & config. Each verifies its checklist boxes against the referenced files and reports discrepancies.
