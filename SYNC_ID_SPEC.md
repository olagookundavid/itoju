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

- `user_id` — lowercase canonical UUID text (anonymous clients use the local
  account UUID; it is re-keyed to the server user UUID at first sync — see plan §M2).
- `symptoms_id` — the catalog integer, base-10, no padding.
- date — `YYYY-MM-DD` (zero-padded) of the row's `date` column.

## List tables → random, not deterministic

`user_sleep_metric`, `user_exercise_metric`, `user_urine_metric`,
`user_bowel_metric`, `user_medication_metric`: client mints **UUIDv7**
(time-ordered). Server backfilled existing rows with v4. Any unique uuid is fine;
there is no name recipe.

## Golden vectors (assert these in every implementation)

```
user_id = 00000000-0000-0000-0000-000000000001
date    = 2026-05-10
symptoms_id = 1

food     → 392ec4ce-09f7-5cb0-848e-921265e26b1f
symptoms → 89ed2f07-25de-5807-ba0e-e1c6ebb998b3
```

Server anchor test: `internal/models/det_sync_id_db_test.go`.
Client anchor test: to be added with `lib/data/ids.dart`.
