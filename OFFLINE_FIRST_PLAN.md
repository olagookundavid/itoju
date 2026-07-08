# Itoju Offline-First Migration Plan

**Goal:** Make the mobile device the source of truth. The app is fully usable offline with all data stored locally. Cloud sync becomes an *optional* capability — triggered on request and/or gated behind a paywall (premium = backup + multi-device sync).

**Stack today:** Flutter (Riverpod `StateNotifier`, Dio, Hive-for-scalars) ↔ Go (`httprouter` + raw SQL Postgres).

---

## 1. Target architecture

```
┌─────────────────────────── MOBILE (source of truth) ───────────────────────────┐
│  UI (pages/widgets)                                                             │
│     ↓ watch                                                                     │
│  Riverpod Notifiers  ──────────────►  Repository (per feature)                  │
│                                          ├── LocalDataSource  → Drift (SQLite)   │  ← reads/writes ALWAYS local
│                                          └── (no direct remote calls)           │
│                                                                                 │
│  SyncEngine (background)  ── reads "dirty" rows ──► push/pull ──► Backend       │  ← optional, gated
│                              applies pulled rows back into Drift                │
└─────────────────────────────────────────────────────────────────────────────────┘
                                        │  (only when entitled + online + requested)
                                        ▼
┌─────────────────────────────── BACKEND (sync mirror) ──────────────────────────┐
│  /v1/sync/push   /v1/sync/pull   (new)   ── entitlement-gated middleware        │
│  Existing REST endpoints kept for now (legacy / web / admin)                    │
│  Postgres: + uuid PKs, + updated_at, + deleted_at, + per-user change watermark  │
│  Subscriptions/entitlements table  ← RevenueCat webhook                         │
└─────────────────────────────────────────────────────────────────────────────────┘
```

**Core principle:** notifiers never call Dio again. They talk to repositories; repositories talk only to Drift. The SyncEngine is the *only* thing that touches the network, and it's fully decoupled from the UI. This is what makes the app work identically whether the user has ever signed in or paid.

---

## 2. The four hard problems (decide these first)

### 2.1 IDs — client-generated UUIDs everywhere
The metric tables (`user_symptoms_metric`, `user_sleep_metric`, `user_food_metric`, `user_exercise_metric`, `user_urine_metric`, `user_bowel_metric`, `user_medication_metric`, `user_point*`) use **SERIAL** PKs today. Offline-first requires the client to mint IDs *before* any server contact.

**Decision:** move all user-owned tables to UUID PKs, generated on the client.
- `menstrual_cycles` / `cycles_days` / `users` already use UUID — good.
- For the metric tables, add a `uuid` column, backfill, then cut the PK over (see §5, backend migration). New rows get client UUIDs; legacy SERIAL kept only as a transitional unique key during backfill.

### 2.2 The `(user_id, date)` "one-per-day" tables — deterministic UUIDs
`food`, `sleep`, `symptoms` (and `menstrual_cycles.start_date`) enforce one row per day. If two devices each create a random UUID for "today's food," the server upsert hits a duplicate-by-date and you get a conflict that isn't really a conflict.

**Decision:** for singleton-per-day tables, derive the id as **UUIDv5(namespace, user_id + table + date)** so both devices independently compute the *same* id. The collision disappears — it becomes a normal same-row last-write-wins merge. List-style tables (`exercise`, `medication`, point records — many per day) use random **UUIDv7** (time-ordered).

### 2.3 Change tracking & deletes
Add to every syncable table:
- `updated_at TIMESTAMPTZ` (server stamps on write; client keeps its own local `updated_at`)
- `deleted_at TIMESTAMPTZ NULL` (soft-delete tombstone — hard deletes can't sync)

Client-local Drift tables additionally carry `sync_state` (`pending` / `synced`) and `local_updated_at`. Pull uses a per-user monotonic watermark (server `updated_at` high-water mark) as the cursor.

### 2.4 Conflict resolution — per-record last-write-wins
Single user, no collaboration → the only conflicts are the *same user on two devices*. Per-record **LWW by `updated_at`** is sufficient and simple. One refinement worth keeping: for symptom severity you may prefer field-level merge (e.g. keep the max of morning/afternoon/night) rather than clobbering — design the merge function per table, defaulting to LWW.

---

## 3. Auth & paywall model (product decision)

Offline-first changes *when* auth matters. Today login is mandatory and blocks everything. Target:

- **Account is local-first.** A user can install, onboard, and track for weeks **without registering**. A local `account` row (UUID) owns all local data.
- **Auth is required only at sync time.** Sign-up/login becomes the gate to *cloud sync*, not to *using the app*. On first sync we bind the local account UUID to the server user.
- **Paywall gates sync, not the app.** The app is fully free offline. Premium unlocks cloud backup + multi-device.

**Recommended tiering (default — confirm with product):**
| Capability | Free | Premium |
|---|---|---|
| All tracking, analytics, offline | ✅ | ✅ |
| Local-only (no account needed) | ✅ | ✅ |
| Manual "Back up now" (one-way snapshot) | ✅ (on request) | ✅ |
| Continuous + multi-device 2-way sync | ❌ | ✅ |

This satisfies both halves of the ask: free users get *on-request* backup; *continuous sync* is the paywalled feature. (Alternative: paywall all cloud sync entirely. Flag for product.)

**Entitlements:** use **RevenueCat** (best Flutter IAP fit — wraps App Store / Play billing, gives an `entitlements` object client-side and a webhook server-side). Backend stores a `subscriptions` table updated by the RevenueCat webhook. **The `/v1/sync/*` endpoints enforce entitlement server-side** — never trust the client flag.

> ⚠️ **Security gate (from the 2026-06 audit, [[itoju-audit-2026-06]]):** the email-only `/social-login` account-takeover and the IDORs must be fixed **before** cloud-syncing health data. Sync centralizes sensitive health records under that same auth; shipping sync on top of a takeover bug is a serious exposure. Treat those fixes as a hard prerequisite for Phase 4.

---

## 4. Mobile work (Phases M)

### M1 — Local DB + repository layer (the actual offline-first core; no network)
1. Add **Drift** (`drift`, `drift_flutter`, `sqlite3_flutter_libs`, `uuid`). Keep Hive only for app prefs/flags; move the auth token to **`flutter_secure_storage`** (token is currently plaintext in Hive — fix in passing).
2. Define Drift tables mirroring the backend schema, one per domain entity, each with `id (uuid)`, domain fields, `updated_at`, `deleted_at`, `sync_state`, `local_updated_at`. Promote the inline notifier models into a shared `lib/data/models/` + Drift table set.
3. Build a **Repository per feature** (`SymptomsRepository`, `MensesRepository`, `FoodRepository`, …) exposing reactive `Stream`s from Drift (`watchX`) and write methods that set `sync_state=pending` + bump `local_updated_at`.
4. **Refactor notifiers** to depend on repositories instead of Dio. This is the bulk of the mobile work — do it feature-by-feature (auth → home/smileys → each metric → menses → analytics → points). Analytics can read from local Drift aggregates instead of the server analytics endpoints.
5. After M1, the app is **fully functional offline**. No sync yet. Ship-able as a milestone.

### M2 — Sync engine (client)
1. `SyncEngine` service: `push()` collects `sync_state=pending` rows per table → `POST /v1/sync/push`; on ack marks them `synced` and stores server `updated_at`. `pull()` sends last watermark → `POST /v1/sync/pull` → merges returned rows via the per-table LWW merge → advances watermark.
2. Triggers: manual button (free "Back up now"), and for premium: on app foreground/background, on connectivity regained (`connectivity_plus`), and a debounced post-write trigger.
3. Bind local account UUID ↔ server user on first authenticated sync (claim/migrate local rows under the server `user_id`).
4. Robustness: batch + paginate, retry with backoff, all writes idempotent via UUID upsert, wrap each batch in a single transaction client-side.

---

## 5. Backend work (Phases B)

### B1 — Sync-readiness schema migrations (Goose, in `internal/sql/migrations/`)
For every user-owned table:
1. Add `updated_at TIMESTAMPTZ NOT NULL DEFAULT now()` + trigger (or set in each UPDATE/INSERT).
2. Add `deleted_at TIMESTAMPTZ NULL`; change all reads to filter `deleted_at IS NULL`; change deletes to soft-delete.
3. Migrate metric PKs SERIAL → UUID: add `uuid` col, backfill `uuid_generate_v4()`, add unique index, switch FKs/handlers to uuid, retire SERIAL. (Do per-table; metric tables are leaf entities so FK fan-out is small.)
4. Index `(user_id, updated_at)` on each for efficient delta pulls.
5. Relax/adjust the `(user_id, date)` unique constraints to coexist with soft-deletes (partial unique index `WHERE deleted_at IS NULL`), since deterministic UUIDs (§2.2) now key those rows.

### B2 — Sync endpoints
- `POST /v1/sync/push` — accepts `{table, rows[]}` batches; per row **upsert by uuid** with LWW (`ON CONFLICT … DO UPDATE … WHERE excluded.updated_at > existing.updated_at`); honors `deleted_at`. Returns server-authoritative `updated_at` per row. Idempotent by construction.
- `POST /v1/sync/pull` — `{since_watermark}` → all rows for the user with `updated_at > since`, including tombstones; returns new watermark.
- Both behind `Authenticate` + `RequireActivatedAndAuthedUser` + **new `RequireSyncEntitlement` middleware**.
- Keep existing per-resource REST routes during transition (legacy clients / admin / resources content stay as-is).

### B3 — Entitlements
- `subscriptions` table (`user_id`, `entitlement`, `status`, `expires_at`, `platform`, `rc_app_user_id`).
- `POST /v1/webhooks/revenuecat` (signature-verified) upserts it. `RequireSyncEntitlement` checks active entitlement.

---

## 6. Sequencing / rollout

1. **B1 schema** (additive: `updated_at`, `deleted_at`, indexes) — safe to ship early, no behavior change.
2. **M1 mobile local DB + repository refactor** — the big one; ships an offline-capable app with *no* sync. Validate thoroughly.
3. **Backend UUID PK cutover** (rest of B1) + **B2 sync endpoints**.
4. **M2 client sync engine** — wire push/pull, manual "Back up now" for everyone.
5. **B3 + RevenueCat + entitlement gating** — turn on continuous/multi-device as premium. *(Auth hardening from §3 must land before this.)*
6. **Migration for existing users:** on first launch of the new build, pull their server data down into Drift once (seed local store), then flip to offline-first. Existing logged-in users keep their data; new users start local-only.

---

## 7. Key risks / watch-items
- **The notifier→repository refactor is the largest, riskiest chunk** (touches every feature). Do it incrementally behind the existing UI; don't combine with sync in the same PR.
- **SERIAL→UUID cutover** needs care on any FK references and the analytics queries.
- **Deterministic-UUID strategy must be identical on client and server** for singleton-per-day tables, or you'll resurrect the collision problem.
- **Health data + existing auth bugs** — hard blocker on enabling cloud sync (§3).
- **Time/clock skew** — stamp authoritative `updated_at` server-side on push-ack; use the server value as truth for the watermark to avoid client-clock LWW errors.

---

## 8. Open decisions for you
1. **Tiering:** free = on-request backup + premium = continuous/multi-device (recommended), **or** paywall *all* cloud sync? 
2. **IAP provider:** RevenueCat (recommended) vs. Stripe vs. native StoreKit/Billing directly.
3. **Local DB:** Drift (recommended — SQL parity with Postgres makes sync mapping trivial) vs. Isar (faster, NoSQL-style).
4. **Account model:** allow fully anonymous local accounts (recommended) vs. still require sign-up up front.
