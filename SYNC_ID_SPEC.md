# Deterministic Sync-ID Spec (client ⇄ server contract)

One spec, three implementations that MUST agree byte-for-byte: mobile Dart
(`itoju_mobile/lib/data/ids.dart`), Go sync code, and the SQL backfill/triggers
(`Itoju_backend/internal/sql/migrations/034_metric_uuid.sql`).

## Namespace

```
ITOJU_SYNC_NS = uuidv5(NAMESPACE_DNS, "sync.itoju.app")
              = cda0d494-38a4-51db-b52d-62713a57ad8c
```

`NAMESPACE_DNS` is the RFC-4122 constant `6ba7b810-9dad-11d1-80b4-00c04fd430c8`.
Hardcode the resulting `cda0d494-…` literal on all three sides.

## Deterministic id (one-per-day tables)

`id = uuidv5(ITOJU_SYNC_NS, name)` where `name` is:

| table                  | name string                                             |
|------------------------|---------------------------------------------------------|
| `user_food_metric`     | `{user_id}:user_food_metric:{YYYY-MM-DD}`               |
| `user_symptoms_metric` | `{user_id}:user_symptoms_metric:{symptoms_id}:{YYYY-MM-DD}` |
| `menstrual_cycles`     | `{user_id}:menstrual_cycles:{YYYY-MM-DD start_date}`    |
| `cycles_days`          | `{user_id}:cycles_days:{cycle_id}:{YYYY-MM-DD}`         |
| `user_settings` (client-local singleton) | `{user_id}:user_settings`             |

- `user_id` — lowercase canonical UUID text (anonymous clients use the local
  account UUID; it is re-keyed to the server user UUID at first sync — see plan §M2).
- `symptoms_id` — the catalog integer, base-10, no padding.
- `cycle_id` — the parent cycle's (itself deterministic) uuid, lowercase text.
- date — `YYYY-MM-DD` (zero-padded) of the row's `date`/`start_date` column.
- Client-local selection rows (`user_trackedmetric`, `user_condition`) use
  `{user_id}:user_trackedmetric:{metric_id}` / `{user_id}:user_condition:{condition_id}`
  — client-only for now (those tables are outside sync scope v1).

## List tables → random, not deterministic

`user_sleep_metric`, `user_exercise_metric`, `user_urine_metric`,
`user_bowel_metric`, `user_medication_metric`, `user_smiley`: client mints
**UUIDv7** (time-ordered). Server backfilled existing rows with v4. Any unique
uuid is fine; there is no name recipe.

## Golden vectors (assert these in every implementation)

```
user_id = 00000000-0000-0000-0000-000000000001
date    = 2026-05-10
symptoms_id = 1

food      → 392ec4ce-09f7-5cb0-848e-921265e26b1f
symptoms  → 89ed2f07-25de-5807-ba0e-e1c6ebb998b3
cycle     → 21647642-d3b3-5eaa-b17a-46f1b6806d57
cycle day → 77229aff-1df0-5e14-9361-bf49c94497f3   (cycle_id = the cycle vector above)
```

Server anchor tests: `internal/models/det_sync_id_db_test.go`,
`internal/models/sync_pagination_db_test.go` (`TestCycleDeterministicIDsDB`).
Client anchor test: `itoju_mobile/test/data/ids_test.dart`.
Server-side implementations: `034_metric_uuid.sql` (food/symptoms triggers) and
`038_deterministic_cycle_ids.sql` (cycle/day triggers + backfill).
