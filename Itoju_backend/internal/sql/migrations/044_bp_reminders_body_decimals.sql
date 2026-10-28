-- +goose Up
-- Three additions that ship together with app 1.2:
--   1. a Blood Pressure tracked metric (catalog row + user_bp_metric table),
--   2. medication reminders (user_med_reminder), synced so a restored device keeps them,
--   3. decimal body measurements (bodymeasure.height_cm / weight_kg).
-- All three are brand-new sync tables or additive columns: nothing a deployed 1.1.x
-- build reads or writes changes shape.

-- 1. Blood Pressure -----------------------------------------------------------
-- The catalog is positional (the app seeds it by index), so the new metric MUST be
-- id 9. Insert it with an explicit id and move the sequence past it.
INSERT INTO trackedmetrics (id, name) VALUES (9, 'Blood Pressure') ON CONFLICT DO NOTHING;
SELECT setval(pg_get_serial_sequence('trackedmetrics', 'id'),
              GREATEST(9, (SELECT max(id) FROM trackedmetrics)));

-- Bounds are deliberately wider than the app's entry validation: they only exist
-- to keep garbage out. A row the DB refuses is quarantined by the sync push
-- ('rejected') instead of wedging the batch.
CREATE TABLE user_bp_metric (
    id                UUID PRIMARY KEY,
    user_id           UUID        NOT NULL REFERENCES users ON DELETE CASCADE,
    date              DATE        NOT NULL,
    time              VARCHAR(20) NOT NULL DEFAULT '',
    systolic          SMALLINT    NOT NULL CHECK (systolic  BETWEEN 40 AND 300),
    diastolic         SMALLINT    NOT NULL CHECK (diastolic BETWEEN 20 AND 200),
    pulse             SMALLINT    NOT NULL DEFAULT 0 CHECK (pulse BETWEEN 0 AND 300),
    updated_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
    server_updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at        TIMESTAMPTZ
);
CREATE INDEX idx_user_bp_metric_user_server_updated ON user_bp_metric (user_id, server_updated_at);
CREATE INDEX idx_user_bp_metric_user_date ON user_bp_metric (user_id, date);
CREATE TRIGGER trg_user_bp_metric_sync_touch
    BEFORE UPDATE ON user_bp_metric FOR EACH ROW EXECUTE FUNCTION sync_touch();

-- 2. Medication reminders -----------------------------------------------------
-- days is a Mon..Sun bitmask (Mon=1, Tue=2, Wed=4, ... Sun=64; 127 = every day);
-- times is a list of 'HH:mm' strings in the user's local time.
CREATE TABLE user_med_reminder (
    id                UUID PRIMARY KEY,
    user_id           UUID         NOT NULL REFERENCES users ON DELETE CASCADE,
    name              VARCHAR(100) NOT NULL,
    dosage            SMALLINT     NOT NULL DEFAULT 0,
    unit              VARCHAR(16)  NOT NULL DEFAULT 'mg',
    quantity          SMALLINT     NOT NULL DEFAULT 1,
    days              SMALLINT     NOT NULL DEFAULT 127 CHECK (days BETWEEN 0 AND 127),
    times             TEXT[]       NOT NULL DEFAULT '{}',
    enabled           BOOLEAN      NOT NULL DEFAULT true,
    updated_at        TIMESTAMPTZ  NOT NULL DEFAULT now(),
    server_updated_at TIMESTAMPTZ  NOT NULL DEFAULT now(),
    deleted_at        TIMESTAMPTZ
);
CREATE INDEX idx_user_med_reminder_user_server_updated ON user_med_reminder (user_id, server_updated_at);
CREATE TRIGGER trg_user_med_reminder_sync_touch
    BEFORE UPDATE ON user_med_reminder FOR EACH ROW EXECUTE FUNCTION sync_touch();

-- 3. Decimal body measurements ------------------------------------------------
-- height/weight were whole-number SMALLINTs whose unit (cm/inch, kg/lb) was a
-- label kept only on the device. The new columns hold centimetres and kilograms
-- with one decimal. The old columns STAY, kept in step by a trigger, so a 1.1.x
-- build sharing the account (it syncs `bodymeasure` and reads whole numbers)
-- never receives a value it cannot parse. Direction of the copy:
--   - a write that changes only the legacy column (old build) -> copied into the new one;
--   - otherwise the legacy column is always re-derived from the new one (rounded).
ALTER TABLE bodymeasure ADD COLUMN height_cm NUMERIC(5,1) NOT NULL DEFAULT 0;
ALTER TABLE bodymeasure ADD COLUMN weight_kg NUMERIC(5,1) NOT NULL DEFAULT 0;
UPDATE bodymeasure SET height_cm = height, weight_kg = weight;

-- +goose StatementBegin
CREATE OR REPLACE FUNCTION bodymeasure_units() RETURNS trigger AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        IF NEW.height_cm = 0 AND NEW.height <> 0 THEN NEW.height_cm := NEW.height; END IF;
        IF NEW.weight_kg = 0 AND NEW.weight <> 0 THEN NEW.weight_kg := NEW.weight; END IF;
    ELSE
        IF NEW.height_cm IS NOT DISTINCT FROM OLD.height_cm
           AND NEW.height IS DISTINCT FROM OLD.height THEN
            NEW.height_cm := NEW.height;
        END IF;
        IF NEW.weight_kg IS NOT DISTINCT FROM OLD.weight_kg
           AND NEW.weight IS DISTINCT FROM OLD.weight THEN
            NEW.weight_kg := NEW.weight;
        END IF;
    END IF;
    NEW.height := LEAST(32767, ROUND(NEW.height_cm))::smallint;
    NEW.weight := LEAST(32767, ROUND(NEW.weight_kg))::smallint;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
-- +goose StatementEnd

CREATE TRIGGER trg_bodymeasure_units
    BEFORE INSERT OR UPDATE ON bodymeasure FOR EACH ROW EXECUTE FUNCTION bodymeasure_units();

-- +goose Down
DROP TRIGGER IF EXISTS trg_bodymeasure_units ON bodymeasure;
DROP FUNCTION IF EXISTS bodymeasure_units();
ALTER TABLE bodymeasure DROP COLUMN weight_kg;
ALTER TABLE bodymeasure DROP COLUMN height_cm;
DROP TABLE IF EXISTS user_med_reminder;
DROP TABLE IF EXISTS user_bp_metric;
DELETE FROM user_trackedmetric WHERE metric_id = 9;
DELETE FROM trackedmetrics WHERE id = 9 AND name = 'Blood Pressure';
