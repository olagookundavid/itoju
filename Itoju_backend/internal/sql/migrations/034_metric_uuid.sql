-- +goose Up
-- Add a client-compatible UUID (sync_id) to every SERIAL-keyed metric table,
-- ahead of the PK cutover in 035. Still additive: sync_id is a new column with a
-- unique index; the SERIAL id remains the PK for now, so old binaries keep working.
--
-- Deterministic UUIDv5 for the one-per-day tables (food, symptoms): both the
-- server and the mobile client independently compute the SAME id from
-- (user_id, table, [symptoms_id,] date), so a legacy server row and a later
-- client push for the same day converge instead of colliding. List tables get
-- random v4 here (clients mint v7 going forward — any unique uuid is fine).
--
-- Namespace ITOJU_SYNC_NS = uuid_generate_v5(uuid_ns_dns(), 'sync.itoju.app').
-- Name string (must match client Dart + Go byte-for-byte):
--   food:     '{user_id}:user_food_metric:{YYYY-MM-DD}'
--   symptoms: '{user_id}:user_symptoms_metric:{symptoms_id}:{YYYY-MM-DD}'
-- where user_id is the lowercase canonical UUID text.

-- --- one-per-day: user_food_metric (deterministic v5) ---
ALTER TABLE user_food_metric ADD COLUMN sync_id UUID;
UPDATE user_food_metric SET sync_id = uuid_generate_v5(
    uuid_generate_v5(uuid_ns_dns(), 'sync.itoju.app'),
    user_id::text || ':user_food_metric:' || to_char(date, 'YYYY-MM-DD'));
ALTER TABLE user_food_metric ALTER COLUMN sync_id SET NOT NULL;
CREATE UNIQUE INDEX ux_user_food_metric_sync_id ON user_food_metric (sync_id);

-- --- one-per-day: user_symptoms_metric (deterministic v5) ---
ALTER TABLE user_symptoms_metric ADD COLUMN sync_id UUID;
UPDATE user_symptoms_metric SET sync_id = uuid_generate_v5(
    uuid_generate_v5(uuid_ns_dns(), 'sync.itoju.app'),
    user_id::text || ':user_symptoms_metric:' || symptoms_id::text || ':' || to_char(date, 'YYYY-MM-DD'));
ALTER TABLE user_symptoms_metric ALTER COLUMN sync_id SET NOT NULL;
CREATE UNIQUE INDEX ux_user_symptoms_metric_sync_id ON user_symptoms_metric (sync_id);

-- --- list tables: random v4 (default fills existing rows and future legacy inserts) ---
-- +goose StatementBegin
DO $$
DECLARE
    t text;
    tables text[] := ARRAY[
        'user_sleep_metric', 'user_exercise_metric', 'user_urine_metric',
        'user_bowel_metric', 'user_medication_metric'
    ];
BEGIN
    FOREACH t IN ARRAY tables LOOP
        EXECUTE format('ALTER TABLE %I ADD COLUMN sync_id UUID NOT NULL DEFAULT uuid_generate_v4()', t);
        EXECUTE format('CREATE UNIQUE INDEX %I ON %I (sync_id)', 'ux_' || t || '_sync_id', t);
    END LOOP;
END;
$$;
-- +goose StatementEnd

-- Insert triggers so LEGACY REST inserts (which never supply sync_id) also get
-- the deterministic v5 for the one-per-day tables, keeping server and client ids
-- identical for the same day. A future sync insert that DOES supply sync_id is
-- preserved (the trigger only fills a NULL).
-- +goose StatementBegin
CREATE OR REPLACE FUNCTION food_sync_id() RETURNS trigger AS $$
BEGIN
    IF NEW.sync_id IS NULL THEN
        NEW.sync_id := uuid_generate_v5(
            uuid_generate_v5(uuid_ns_dns(), 'sync.itoju.app'),
            NEW.user_id::text || ':user_food_metric:' || to_char(NEW.date, 'YYYY-MM-DD'));
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
-- +goose StatementEnd
CREATE TRIGGER trg_user_food_metric_sync_id
    BEFORE INSERT ON user_food_metric FOR EACH ROW EXECUTE FUNCTION food_sync_id();

-- +goose StatementBegin
CREATE OR REPLACE FUNCTION syms_sync_id() RETURNS trigger AS $$
BEGIN
    IF NEW.sync_id IS NULL THEN
        NEW.sync_id := uuid_generate_v5(
            uuid_generate_v5(uuid_ns_dns(), 'sync.itoju.app'),
            NEW.user_id::text || ':user_symptoms_metric:' || NEW.symptoms_id::text || ':' || to_char(NEW.date, 'YYYY-MM-DD'));
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
-- +goose StatementEnd
CREATE TRIGGER trg_user_symptoms_metric_sync_id
    BEFORE INSERT ON user_symptoms_metric FOR EACH ROW EXECUTE FUNCTION syms_sync_id();

-- +goose Down
DROP TRIGGER IF EXISTS trg_user_symptoms_metric_sync_id ON user_symptoms_metric;
DROP TRIGGER IF EXISTS trg_user_food_metric_sync_id ON user_food_metric;
DROP FUNCTION IF EXISTS syms_sync_id();
DROP FUNCTION IF EXISTS food_sync_id();

-- +goose StatementBegin
DO $$
DECLARE
    t text;
    tables text[] := ARRAY[
        'user_sleep_metric', 'user_exercise_metric', 'user_urine_metric',
        'user_bowel_metric', 'user_medication_metric'
    ];
BEGIN
    FOREACH t IN ARRAY tables LOOP
        EXECUTE format('DROP INDEX IF EXISTS %I', 'ux_' || t || '_sync_id');
        EXECUTE format('ALTER TABLE %I DROP COLUMN IF EXISTS sync_id', t);
    END LOOP;
END;
$$;
-- +goose StatementEnd

DROP INDEX IF EXISTS ux_user_symptoms_metric_sync_id;
ALTER TABLE user_symptoms_metric DROP COLUMN IF EXISTS sync_id;
DROP INDEX IF EXISTS ux_user_food_metric_sync_id;
ALTER TABLE user_food_metric DROP COLUMN IF EXISTS sync_id;
