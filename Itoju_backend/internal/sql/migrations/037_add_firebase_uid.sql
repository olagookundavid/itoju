-- +goose Up
-- Bind a social identity to an account by its verified Firebase UID, not by
-- email alone. This closes the social-login account-takeover surface: a second
-- Firebase identity can no longer claim an account already linked to a
-- different UID.
ALTER TABLE users ADD COLUMN firebase_uid TEXT;
CREATE UNIQUE INDEX ux_users_firebase_uid ON users (firebase_uid) WHERE firebase_uid IS NOT NULL;

-- +goose Down
DROP INDEX IF EXISTS ux_users_firebase_uid;
ALTER TABLE users DROP COLUMN firebase_uid;
