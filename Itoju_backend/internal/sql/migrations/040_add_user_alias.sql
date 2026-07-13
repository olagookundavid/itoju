-- +goose Up
-- Display name ("What should we call you?") chosen during onboarding. Distinct
-- from first_name (legal-ish signup field): the alias is what the app greets
-- the user with, and syncing it on the account lets it roam across devices.
ALTER TABLE users ADD COLUMN alias TEXT NOT NULL DEFAULT '';

-- +goose Down
ALTER TABLE users DROP COLUMN alias;
