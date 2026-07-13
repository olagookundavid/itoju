-- +goose Up
-- Indexes the remaining per-user, per-date read paths need (missed by
-- migrations 030/031), plus the cycle-day lookup by cycle.
CREATE INDEX IF NOT EXISTS idx_user_sleep_date ON user_sleep_metric (user_id, date);
CREATE INDEX IF NOT EXISTS idx_user_urine_date ON user_urine_metric (user_id, date);
CREATE INDEX IF NOT EXISTS idx_user_medication_date ON user_medication_metric (user_id, date);
CREATE INDEX IF NOT EXISTS idx_cycles_days_cycle_id ON cycles_days (cycle_id);

-- +goose Down
DROP INDEX IF EXISTS idx_cycles_days_cycle_id;
DROP INDEX IF EXISTS idx_user_medication_date;
DROP INDEX IF EXISTS idx_user_urine_date;
DROP INDEX IF EXISTS idx_user_sleep_date;
