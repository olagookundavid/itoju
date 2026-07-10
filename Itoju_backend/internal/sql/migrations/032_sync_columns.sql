-- +goose Up
-- Sync-readiness columns for offline-first. Additive and behaviour-preserving:
-- existing explicit-column INSERTs ignore the new columns (defaults apply) and
-- existing UPDATEs get updated_at/server_updated_at stamped by the trigger.
--
--   updated_at        LWW comparator. Client-supplied on sync writes; server-
--                     stamped (via trigger) on legacy REST writes.
--   server_updated_at Pull watermark. ALWAYS server-stamped, so a skewed client
--                     clock can lose an LWW race but can never make a row
--                     invisible to another device's delta pull.
--   deleted_at        Soft-delete tombstone (hard deletes cannot sync).

-- +goose StatementBegin
CREATE OR REPLACE FUNCTION sync_touch() RETURNS trigger AS $$
BEGIN
    -- Watermark is always authoritative server time.
    NEW.server_updated_at := now();
    -- Preserve a caller-supplied updated_at (sync push carries the client's
    -- edit time); only stamp it for legacy paths that leave it untouched.
    IF NEW.updated_at IS NOT DISTINCT FROM OLD.updated_at THEN
        NEW.updated_at := now();
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
        'user_symptoms_metric', 'user_sleep_metric', 'user_food_metric',
        'user_exercise_metric', 'user_urine_metric', 'user_bowel_metric',
        'user_medication_metric', 'menstrual_cycles', 'cycles_days',
        'menstruation', 'bodymeasure', 'user_symptoms', 'user_conditions',
        'user_smiley'
    ];
BEGIN
    FOREACH t IN ARRAY tables LOOP
        EXECUTE format('ALTER TABLE %I ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ NOT NULL DEFAULT now()', t);
        EXECUTE format('ALTER TABLE %I ADD COLUMN IF NOT EXISTS server_updated_at TIMESTAMPTZ NOT NULL DEFAULT now()', t);
        EXECUTE format('ALTER TABLE %I ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMPTZ', t);
        EXECUTE format('CREATE INDEX IF NOT EXISTS %I ON %I (user_id, server_updated_at)', 'idx_' || t || '_user_server_updated', t);
        EXECUTE format('DROP TRIGGER IF EXISTS %I ON %I', 'trg_' || t || '_sync_touch', t);
        EXECUTE format('CREATE TRIGGER %I BEFORE UPDATE ON %I FOR EACH ROW EXECUTE FUNCTION sync_touch()', 'trg_' || t || '_sync_touch', t);
    END LOOP;
END;
$$;
-- +goose StatementEnd

-- user_smiley is an append-only event log with no surrogate key (PK is the
-- composite (user_id, smiley_id, granted_at)). Sync upserts need a single stable
-- id, so add a uuid PK while KEEPING the composite as a unique constraint under
-- the original name user_smiley_pkey — so InsertUserSmileys' existing
-- isUniqueViolation(err, "user_smiley_pkey") check keeps its exact behaviour.
-- +goose StatementBegin
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'user_smiley' AND column_name = 'id'
    ) THEN
        ALTER TABLE user_smiley ADD COLUMN id UUID NOT NULL DEFAULT uuid_generate_v4();
        ALTER TABLE user_smiley DROP CONSTRAINT user_smiley_pkey;
        ALTER TABLE user_smiley ADD CONSTRAINT user_smiley_pkey UNIQUE (user_id, smiley_id, granted_at);
        ALTER TABLE user_smiley ADD CONSTRAINT user_smiley_id_pk PRIMARY KEY (id);
    END IF;
END;
$$;
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'user_smiley' AND column_name = 'id'
    ) THEN
        ALTER TABLE user_smiley DROP CONSTRAINT IF EXISTS user_smiley_id_pk;
        ALTER TABLE user_smiley DROP CONSTRAINT IF EXISTS user_smiley_pkey;
        ALTER TABLE user_smiley ADD CONSTRAINT user_smiley_pkey PRIMARY KEY (user_id, smiley_id, granted_at);
        ALTER TABLE user_smiley DROP COLUMN id;
    END IF;
END;
$$;
-- +goose StatementEnd

-- +goose StatementBegin
DO $$
DECLARE
    t text;
    tables text[] := ARRAY[
        'user_symptoms_metric', 'user_sleep_metric', 'user_food_metric',
        'user_exercise_metric', 'user_urine_metric', 'user_bowel_metric',
        'user_medication_metric', 'menstrual_cycles', 'cycles_days',
        'menstruation', 'bodymeasure', 'user_symptoms', 'user_conditions',
        'user_smiley'
    ];
BEGIN
    FOREACH t IN ARRAY tables LOOP
        EXECUTE format('DROP TRIGGER IF EXISTS %I ON %I', 'trg_' || t || '_sync_touch', t);
        EXECUTE format('DROP INDEX IF EXISTS %I', 'idx_' || t || '_user_server_updated');
        EXECUTE format('ALTER TABLE %I DROP COLUMN IF EXISTS deleted_at', t);
        EXECUTE format('ALTER TABLE %I DROP COLUMN IF EXISTS server_updated_at', t);
        EXECUTE format('ALTER TABLE %I DROP COLUMN IF EXISTS updated_at', t);
    END LOOP;
END;
$$;
-- +goose StatementEnd

-- +goose StatementBegin
DROP FUNCTION IF EXISTS sync_touch();
-- +goose StatementEnd
