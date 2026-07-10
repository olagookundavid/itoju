-- +goose Up
-- Promote the client UUID (sync_id) to be the primary key of each metric table,
-- retiring the SERIAL id as legacy_id (kept, with its sequence default, so
-- still-deployed old app builds that send integer :id params keep working via
-- the legacy-int fallback in the handlers). Ships lockstep with the binary that
-- switches the metric model IDs to strings.

-- +goose StatementBegin
DO $$
DECLARE
    t text;
    tables text[] := ARRAY[
        'user_symptoms_metric', 'user_food_metric', 'user_sleep_metric',
        'user_exercise_metric', 'user_urine_metric', 'user_bowel_metric',
        'user_medication_metric'
    ];
BEGIN
    FOREACH t IN ARRAY tables LOOP
        EXECUTE format('ALTER TABLE %I DROP CONSTRAINT %I', t, t || '_pkey');
        EXECUTE format('ALTER TABLE %I RENAME COLUMN id TO legacy_id', t);
        EXECUTE format('ALTER TABLE %I RENAME COLUMN sync_id TO id', t);
        EXECUTE format('ALTER TABLE %I ADD CONSTRAINT %I PRIMARY KEY USING INDEX %I',
            t, t || '_pkey', 'ux_' || t || '_sync_id');
    END LOOP;
END;
$$;
-- +goose StatementEnd

-- The deterministic-id insert triggers set the id column, which was just renamed
-- from sync_id, so point them at NEW.id.
-- +goose StatementBegin
CREATE OR REPLACE FUNCTION food_sync_id() RETURNS trigger AS $$
BEGIN
    IF NEW.id IS NULL THEN
        NEW.id := uuid_generate_v5(
            uuid_generate_v5(uuid_ns_dns(), 'sync.itoju.app'),
            NEW.user_id::text || ':user_food_metric:' || to_char(NEW.date, 'YYYY-MM-DD'));
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
-- +goose StatementEnd

-- +goose StatementBegin
CREATE OR REPLACE FUNCTION syms_sync_id() RETURNS trigger AS $$
BEGIN
    IF NEW.id IS NULL THEN
        NEW.id := uuid_generate_v5(
            uuid_generate_v5(uuid_ns_dns(), 'sync.itoju.app'),
            NEW.user_id::text || ':user_symptoms_metric:' || NEW.symptoms_id::text || ':' || to_char(NEW.date, 'YYYY-MM-DD'));
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
-- +goose StatementEnd

-- +goose Down
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

-- +goose StatementBegin
DO $$
DECLARE
    t text;
    tables text[] := ARRAY[
        'user_symptoms_metric', 'user_food_metric', 'user_sleep_metric',
        'user_exercise_metric', 'user_urine_metric', 'user_bowel_metric',
        'user_medication_metric'
    ];
BEGIN
    FOREACH t IN ARRAY tables LOOP
        EXECUTE format('ALTER TABLE %I DROP CONSTRAINT %I', t, t || '_pkey');
        EXECUTE format('ALTER TABLE %I RENAME COLUMN id TO sync_id', t);
        EXECUTE format('ALTER TABLE %I RENAME COLUMN legacy_id TO id', t);
        EXECUTE format('ALTER TABLE %I ADD CONSTRAINT %I PRIMARY KEY (id)', t, t || '_pkey');
        EXECUTE format('CREATE UNIQUE INDEX %I ON %I (sync_id)', 'ux_' || t || '_sync_id', t);
    END LOOP;
END;
$$;
-- +goose StatementEnd
