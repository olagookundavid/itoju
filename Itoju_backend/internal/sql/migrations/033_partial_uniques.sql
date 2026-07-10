-- +goose Up
-- Replace the one-per-day UNIQUE constraints with partial unique indexes scoped
-- to live rows (WHERE deleted_at IS NULL), so a soft-deleted row no longer blocks
-- re-creating the same (user_id, date) — and a deterministic client UUID can heal
-- onto the live row. Also fixes a real bug: menstrual_cycles.start_date was UNIQUE
-- GLOBALLY, so two different users could not start a cycle on the same date.

ALTER TABLE user_food_metric DROP CONSTRAINT unique_user_food_date;
CREATE UNIQUE INDEX ux_user_food_user_date
    ON user_food_metric (user_id, date) WHERE deleted_at IS NULL;

ALTER TABLE user_symptoms_metric DROP CONSTRAINT unique_user_symptom_date;
CREATE UNIQUE INDEX ux_user_syms_user_symptom_date
    ON user_symptoms_metric (user_id, symptoms_id, date) WHERE deleted_at IS NULL;

ALTER TABLE menstrual_cycles DROP CONSTRAINT menstrual_cycles_start_date_key;
CREATE UNIQUE INDEX ux_menstrual_cycles_user_start
    ON menstrual_cycles (user_id, start_date) WHERE deleted_at IS NULL;

-- +goose Down
DROP INDEX IF EXISTS ux_menstrual_cycles_user_start;
ALTER TABLE menstrual_cycles ADD CONSTRAINT menstrual_cycles_start_date_key UNIQUE (start_date);

DROP INDEX IF EXISTS ux_user_syms_user_symptom_date;
ALTER TABLE user_symptoms_metric ADD CONSTRAINT unique_user_symptom_date UNIQUE (user_id, symptoms_id, date);

DROP INDEX IF EXISTS ux_user_food_user_date;
ALTER TABLE user_food_metric ADD CONSTRAINT unique_user_food_date UNIQUE (user_id, date);
