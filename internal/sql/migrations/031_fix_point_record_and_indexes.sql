-- +goose Up
-- The UNIQUE(scope, date) constraint was global (not per-user), so a batched
-- insert of point events for two different users with the same scope on the
-- same day violated it and the whole batch was lost. user_point_record is an
-- append-only ledger (aggregated via SUM), so drop the constraint entirely.
ALTER TABLE user_point_record DROP CONSTRAINT IF EXISTS unique_user_point_record_scope;

-- Indexes the analytics/points read paths need (missed by migration 030).
CREATE INDEX IF NOT EXISTS idx_user_point_record_user_date ON user_point_record (user_id, date);
CREATE INDEX IF NOT EXISTS idx_user_point_record_date ON user_point_record (date);
CREATE INDEX IF NOT EXISTS idx_user_exercise_date ON user_exercise_metric (user_id, date);

-- +goose Down
DROP INDEX IF EXISTS idx_user_exercise_date;
DROP INDEX IF EXISTS idx_user_point_record_date;
DROP INDEX IF EXISTS idx_user_point_record_user_date;
ALTER TABLE user_point_record ADD CONSTRAINT unique_user_point_record_scope UNIQUE (scope, date);
