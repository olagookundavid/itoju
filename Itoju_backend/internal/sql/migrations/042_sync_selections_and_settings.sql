-- +goose Up
-- Bring the selection tables (tracked metrics, conditions) and the per-user
-- settings tables (menstruation, bodymeasure) into the sync protocol, so a new
-- or restored device gets the user's tracked metrics, conditions and settings
-- back. Each gets a deterministic client-compatible id (see SYNC_ID_SPEC.md):
--   user_trackedmetric: v5(NS, '{user_id}:user_trackedmetric:{metric_id}')
--   user_conditions:    v5(NS, '{user_id}:user_condition:{conditions_id}')
--   menstruation:       v5(NS, '{user_id}:user_settings')   -- same id as bodymeasure:
--   bodymeasure:        v5(NS, '{user_id}:user_settings')   -- the client keeps ONE settings row
-- where NS = uuid_generate_v5(uuid_ns_dns(), 'sync.itoju.app').

-- user_trackedmetric never got the sync columns (user_conditions, menstruation and
-- bodymeasure did in 032).
ALTER TABLE user_trackedmetric ADD COLUMN updated_at        TIMESTAMPTZ NOT NULL DEFAULT now();
ALTER TABLE user_trackedmetric ADD COLUMN server_updated_at TIMESTAMPTZ NOT NULL DEFAULT now();
ALTER TABLE user_trackedmetric ADD COLUMN deleted_at        TIMESTAMPTZ;
CREATE INDEX IF NOT EXISTS idx_user_trackedmetric_user_server_updated
    ON user_trackedmetric (user_id, server_updated_at);
DROP TRIGGER IF EXISTS trg_user_trackedmetric_sync_touch ON user_trackedmetric;
CREATE TRIGGER trg_user_trackedmetric_sync_touch
    BEFORE UPDATE ON user_trackedmetric FOR EACH ROW EXECUTE FUNCTION sync_touch();

-- One trigger function for every table here. TG_ARGV[0] is the recipe's table
-- label, TG_ARGV[1] the key column ('' for a per-user singleton). A caller that
-- supplies an id (sync push) keeps it; legacy REST inserts get the deterministic one.
-- +goose StatementBegin
CREATE OR REPLACE FUNCTION det_row_id() RETURNS trigger AS $$
BEGIN
    IF NEW.id IS NULL THEN
        NEW.id := uuid_generate_v5(
            uuid_generate_v5(uuid_ns_dns(), 'sync.itoju.app'),
            NEW.user_id::text || ':' || TG_ARGV[0] ||
            CASE WHEN TG_ARGV[1] = '' THEN '' ELSE ':' || (to_jsonb(NEW) ->> TG_ARGV[1]) END);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
-- +goose StatementEnd

-- +goose StatementBegin
DO $$
DECLARE
    ns uuid := uuid_generate_v5(uuid_ns_dns(), 'sync.itoju.app');
BEGIN
    ALTER TABLE user_trackedmetric ADD COLUMN id UUID;
    UPDATE user_trackedmetric SET id = uuid_generate_v5(ns, user_id::text || ':user_trackedmetric:' || metric_id::text);
    ALTER TABLE user_trackedmetric ALTER COLUMN id SET NOT NULL;
    CREATE UNIQUE INDEX ux_user_trackedmetric_id ON user_trackedmetric (id);
    CREATE TRIGGER trg_user_trackedmetric_det_id BEFORE INSERT ON user_trackedmetric
        FOR EACH ROW EXECUTE FUNCTION det_row_id('user_trackedmetric', 'metric_id');

    ALTER TABLE user_conditions ADD COLUMN id UUID;
    UPDATE user_conditions SET id = uuid_generate_v5(ns, user_id::text || ':user_condition:' || conditions_id::text);
    ALTER TABLE user_conditions ALTER COLUMN id SET NOT NULL;
    CREATE UNIQUE INDEX ux_user_conditions_id ON user_conditions (id);
    CREATE TRIGGER trg_user_conditions_det_id BEFORE INSERT ON user_conditions
        FOR EACH ROW EXECUTE FUNCTION det_row_id('user_condition', 'conditions_id');

    ALTER TABLE menstruation ADD COLUMN id UUID;
    UPDATE menstruation SET id = uuid_generate_v5(ns, user_id::text || ':user_settings');
    ALTER TABLE menstruation ALTER COLUMN id SET NOT NULL;
    CREATE UNIQUE INDEX ux_menstruation_id ON menstruation (id);
    CREATE TRIGGER trg_menstruation_det_id BEFORE INSERT ON menstruation
        FOR EACH ROW EXECUTE FUNCTION det_row_id('user_settings', '');

    ALTER TABLE bodymeasure ADD COLUMN id UUID;
    UPDATE bodymeasure SET id = uuid_generate_v5(ns, user_id::text || ':user_settings');
    ALTER TABLE bodymeasure ALTER COLUMN id SET NOT NULL;
    CREATE UNIQUE INDEX ux_bodymeasure_id ON bodymeasure (id);
    CREATE TRIGGER trg_bodymeasure_det_id BEFORE INSERT ON bodymeasure
        FOR EACH ROW EXECUTE FUNCTION det_row_id('user_settings', '');
END;
$$;
-- +goose StatementEnd

-- +goose Down
DROP TRIGGER IF EXISTS trg_bodymeasure_det_id ON bodymeasure;
DROP INDEX IF EXISTS ux_bodymeasure_id;
ALTER TABLE bodymeasure DROP COLUMN id;
DROP TRIGGER IF EXISTS trg_menstruation_det_id ON menstruation;
DROP INDEX IF EXISTS ux_menstruation_id;
ALTER TABLE menstruation DROP COLUMN id;
DROP TRIGGER IF EXISTS trg_user_conditions_det_id ON user_conditions;
DROP INDEX IF EXISTS ux_user_conditions_id;
ALTER TABLE user_conditions DROP COLUMN id;
DROP TRIGGER IF EXISTS trg_user_trackedmetric_det_id ON user_trackedmetric;
DROP INDEX IF EXISTS ux_user_trackedmetric_id;
ALTER TABLE user_trackedmetric DROP COLUMN id;
DROP FUNCTION IF EXISTS det_row_id();
DROP TRIGGER IF EXISTS trg_user_trackedmetric_sync_touch ON user_trackedmetric;
DROP INDEX IF EXISTS idx_user_trackedmetric_user_server_updated;
ALTER TABLE user_trackedmetric DROP COLUMN deleted_at;
ALTER TABLE user_trackedmetric DROP COLUMN server_updated_at;
ALTER TABLE user_trackedmetric DROP COLUMN updated_at;
