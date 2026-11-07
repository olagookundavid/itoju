-- +goose Up
-- Decimal medication doses and quantities (0.5 mg, 2.5 ml, half a tablet) for
-- app 1.2.1+, on both logged doses and reminders.
--
-- dosage/quantity were whole-number SMALLINTs. The new *_dec columns hold up to
-- three decimals. The old columns STAY, kept in step by a trigger, so a build
-- that only knows whole numbers (1.1.x and 1.2.0 sync `user_medication_metric`,
-- 1.2.0 syncs `user_med_reminder`, legacy REST reads `dosage`) never receives a
-- value it cannot parse. Same scheme as bodymeasure in 044. Direction of the copy:
--   - a write that changes only the legacy column (old build) -> copied into the new one;
--   - otherwise the legacy column is always re-derived from the new one (rounded).

ALTER TABLE user_medication_metric ADD COLUMN dosage_dec   NUMERIC(9,3) NOT NULL DEFAULT 0;
ALTER TABLE user_medication_metric ADD COLUMN quantity_dec NUMERIC(9,3) NOT NULL DEFAULT 0;
ALTER TABLE user_med_reminder      ADD COLUMN dosage_dec   NUMERIC(9,3) NOT NULL DEFAULT 0;
ALTER TABLE user_med_reminder      ADD COLUMN quantity_dec NUMERIC(9,3) NOT NULL DEFAULT 1;
-- A row written by a new build names only the *_dec columns; the trigger fills
-- the legacy one, but give it a default so the INSERT never depends on that.
ALTER TABLE user_medication_metric ALTER COLUMN dosage SET DEFAULT 0;

-- The backfill must not look like a user edit: sync_touch would stamp every
-- row's updated_at with now(), and an offline edit on an old build would then
-- lose last-write-wins against it. Suspend it for these statements.
ALTER TABLE user_medication_metric DISABLE TRIGGER trg_user_medication_metric_sync_touch;
UPDATE user_medication_metric SET dosage_dec = dosage, quantity_dec = COALESCE(quantity, 0);
ALTER TABLE user_medication_metric ENABLE TRIGGER trg_user_medication_metric_sync_touch;
ALTER TABLE user_med_reminder DISABLE TRIGGER trg_user_med_reminder_sync_touch;
UPDATE user_med_reminder SET dosage_dec = dosage, quantity_dec = quantity;
ALTER TABLE user_med_reminder ENABLE TRIGGER trg_user_med_reminder_sync_touch;

-- +goose StatementBegin
CREATE OR REPLACE FUNCTION med_amounts() RETURNS trigger AS $$
DECLARE
    -- Column default for quantity (and quantity_dec): 1 on reminders, else 0.
    qdef NUMERIC := CASE WHEN TG_TABLE_NAME = 'user_med_reminder' THEN 1 ELSE 0 END;
BEGIN
    IF TG_OP = 'INSERT' THEN
        -- An insert sets only one family of columns; the other is at its
        -- default. A new column still at its default next to a non-default
        -- legacy value means an old build wrote it.
        IF NEW.dosage_dec = 0 AND COALESCE(NEW.dosage, 0) <> 0 THEN
            NEW.dosage_dec := NEW.dosage;
        END IF;
        IF NEW.quantity_dec = qdef AND COALESCE(NEW.quantity, qdef) <> qdef THEN
            NEW.quantity_dec := NEW.quantity;
        END IF;
    ELSE
        IF NEW.dosage_dec IS NOT DISTINCT FROM OLD.dosage_dec
           AND NEW.dosage IS DISTINCT FROM OLD.dosage THEN
            NEW.dosage_dec := COALESCE(NEW.dosage, 0);
        END IF;
        IF NEW.quantity_dec IS NOT DISTINCT FROM OLD.quantity_dec
           AND NEW.quantity IS DISTINCT FROM OLD.quantity THEN
            NEW.quantity_dec := COALESCE(NEW.quantity, 0);
        END IF;
    END IF;
    NEW.dosage   := LEAST(32767, GREATEST(-32768, ROUND(NEW.dosage_dec)))::smallint;
    NEW.quantity := LEAST(32767, GREATEST(-32768, ROUND(NEW.quantity_dec)))::smallint;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
-- +goose StatementEnd

CREATE TRIGGER trg_user_medication_metric_amounts
    BEFORE INSERT OR UPDATE ON user_medication_metric FOR EACH ROW EXECUTE FUNCTION med_amounts();
CREATE TRIGGER trg_user_med_reminder_amounts
    BEFORE INSERT OR UPDATE ON user_med_reminder FOR EACH ROW EXECUTE FUNCTION med_amounts();

-- +goose Down
DROP TRIGGER IF EXISTS trg_user_med_reminder_amounts ON user_med_reminder;
DROP TRIGGER IF EXISTS trg_user_medication_metric_amounts ON user_medication_metric;
DROP FUNCTION IF EXISTS med_amounts();
ALTER TABLE user_medication_metric ALTER COLUMN dosage DROP DEFAULT;
ALTER TABLE user_med_reminder DROP COLUMN quantity_dec;
ALTER TABLE user_med_reminder DROP COLUMN dosage_dec;
ALTER TABLE user_medication_metric DROP COLUMN quantity_dec;
ALTER TABLE user_medication_metric DROP COLUMN dosage_dec;
