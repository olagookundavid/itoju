-- +goose Up
-- Brute-force protection for 6-digit password-reset codes. `attempts` counts
-- wrong guesses against a live code (the code is burned after a handful), and
-- `created_at` lets the server enforce a cooldown between code requests so an
-- attacker can't farm fresh codes (and fresh attempt budgets) for one account.
ALTER TABLE tokens ADD COLUMN attempts SMALLINT NOT NULL DEFAULT 0;
ALTER TABLE tokens ADD COLUMN created_at TIMESTAMPTZ NOT NULL DEFAULT now();

-- +goose Down
ALTER TABLE tokens DROP COLUMN created_at;
ALTER TABLE tokens DROP COLUMN attempts;
