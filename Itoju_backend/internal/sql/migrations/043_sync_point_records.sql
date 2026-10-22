-- +goose Up
-- Points sync with the rest of the user's data, so a restored device shows the
-- same total instead of re-deriving a smaller one from entries.
--
-- user_point_record keeps its SERIAL id; sync gets a separate uuid key (sync_id)
-- that the client mints. The registration award uses a deterministic id (see
-- SYNC_ID_SPEC.md) so the server's sign-up award and the app's own award are one
-- row, not 10 + 10.
ALTER TABLE user_point_record ADD COLUMN sync_id           UUID        NOT NULL DEFAULT uuid_generate_v4();
ALTER TABLE user_point_record ADD COLUMN updated_at        TIMESTAMPTZ NOT NULL DEFAULT now();
ALTER TABLE user_point_record ADD COLUMN server_updated_at TIMESTAMPTZ NOT NULL DEFAULT now();
ALTER TABLE user_point_record ADD COLUMN deleted_at        TIMESTAMPTZ;
CREATE UNIQUE INDEX ux_user_point_record_sync_id ON user_point_record (sync_id);
CREATE INDEX idx_user_point_record_user_server_updated
    ON user_point_record (user_id, server_updated_at);
DROP TRIGGER IF EXISTS trg_user_point_record_sync_touch ON user_point_record;
CREATE TRIGGER trg_user_point_record_sync_touch
    BEFORE UPDATE ON user_point_record FOR EACH ROW EXECUTE FUNCTION sync_touch();

-- +goose Down
DROP TRIGGER IF EXISTS trg_user_point_record_sync_touch ON user_point_record;
DROP INDEX IF EXISTS idx_user_point_record_user_server_updated;
DROP INDEX IF EXISTS ux_user_point_record_sync_id;
ALTER TABLE user_point_record DROP COLUMN deleted_at;
ALTER TABLE user_point_record DROP COLUMN server_updated_at;
ALTER TABLE user_point_record DROP COLUMN updated_at;
ALTER TABLE user_point_record DROP COLUMN sync_id;
