-- +goose Up
-- Menstrual cycles + cycle days move to deterministic client-compatible ids,
-- like food/symptoms did in 034. Legacy rows carry random v4 ids while the
-- offline-first client mints UUIDv5 — for one-per-day rows that mismatch either
-- 500s a push (partial-unique collision) or duplicates rows on pull. Recipes
-- (must match the client's IdMinter and SYNC_ID_SPEC.md):
--   menstrual_cycles: v5(NS, '{user_id}:menstrual_cycles:{YYYY-MM-DD start_date}')
--   cycles_days:      v5(NS, '{user_id}:cycles_days:{cycle_id}:{YYYY-MM-DD date}')
-- where NS = uuid_generate_v5(uuid_ns_dns(), 'sync.itoju.app').

-- cycles_days follows its parent id when the parent is re-keyed (backfill below,
-- and the push heal path that lets a client's deterministic id adopt an existing
-- legacy row).
ALTER TABLE cycles_days DROP CONSTRAINT cycles_days_cycle_id_fkey;
ALTER TABLE cycles_days ADD CONSTRAINT cycles_days_cycle_id_fkey
    FOREIGN KEY (cycle_id) REFERENCES menstrual_cycles
    ON DELETE CASCADE ON UPDATE CASCADE;

-- Ids are now minted by trigger (deterministic) instead of a random default, so
-- legacy REST creates converge with client-minted ids for the same day.
ALTER TABLE menstrual_cycles ALTER COLUMN id DROP DEFAULT;
ALTER TABLE cycles_days ALTER COLUMN id DROP DEFAULT;

-- +goose StatementBegin
CREATE OR REPLACE FUNCTION cycle_sync_id() RETURNS trigger AS $$
BEGIN
    IF NEW.id IS NULL THEN
        NEW.id := uuid_generate_v5(
            uuid_generate_v5(uuid_ns_dns(), 'sync.itoju.app'),
            NEW.user_id::text || ':menstrual_cycles:' || to_char(NEW.start_date, 'YYYY-MM-DD'));
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
-- +goose StatementEnd
CREATE TRIGGER trg_menstrual_cycles_sync_id
    BEFORE INSERT ON menstrual_cycles FOR EACH ROW EXECUTE FUNCTION cycle_sync_id();

-- +goose StatementBegin
CREATE OR REPLACE FUNCTION cycle_day_sync_id() RETURNS trigger AS $$
BEGIN
    IF NEW.id IS NULL THEN
        NEW.id := uuid_generate_v5(
            uuid_generate_v5(uuid_ns_dns(), 'sync.itoju.app'),
            NEW.user_id::text || ':cycles_days:' || NEW.cycle_id::text || ':' || to_char(NEW.date, 'YYYY-MM-DD'));
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
-- +goose StatementEnd
CREATE TRIGGER trg_cycles_days_sync_id
    BEFORE INSERT ON cycles_days FOR EACH ROW EXECUTE FUNCTION cycle_day_sync_id();

-- Backfill LIVE rows to their deterministic ids. Guards: skip a row whose
-- target id is already taken (a stray earlier client sync), and for days skip
-- duplicates sharing the same (cycle_id, date) — only an unambiguous row can
-- claim the deterministic id. Cycle re-keys cascade into cycles_days.cycle_id
-- via the ON UPDATE CASCADE FK, so days are re-keyed AFTER their parents.
-- +goose StatementBegin
DO $$
DECLARE ns uuid := uuid_generate_v5(uuid_ns_dns(), 'sync.itoju.app');
BEGIN
    UPDATE menstrual_cycles c
    SET id = uuid_generate_v5(ns, c.user_id::text || ':menstrual_cycles:' || to_char(c.start_date, 'YYYY-MM-DD'))
    WHERE c.deleted_at IS NULL
      AND c.id <> uuid_generate_v5(ns, c.user_id::text || ':menstrual_cycles:' || to_char(c.start_date, 'YYYY-MM-DD'))
      AND NOT EXISTS (
          SELECT 1 FROM menstrual_cycles c2
          WHERE c2.id = uuid_generate_v5(ns, c.user_id::text || ':menstrual_cycles:' || to_char(c.start_date, 'YYYY-MM-DD')));

    UPDATE cycles_days d
    SET id = uuid_generate_v5(ns, d.user_id::text || ':cycles_days:' || d.cycle_id::text || ':' || to_char(d.date, 'YYYY-MM-DD'))
    WHERE d.deleted_at IS NULL
      AND d.id <> uuid_generate_v5(ns, d.user_id::text || ':cycles_days:' || d.cycle_id::text || ':' || to_char(d.date, 'YYYY-MM-DD'))
      AND NOT EXISTS (
          SELECT 1 FROM cycles_days d2
          WHERE d2.id = uuid_generate_v5(ns, d.user_id::text || ':cycles_days:' || d.cycle_id::text || ':' || to_char(d.date, 'YYYY-MM-DD')))
      AND NOT EXISTS (
          SELECT 1 FROM cycles_days d3
          WHERE d3.cycle_id = d.cycle_id AND d3.date = d.date AND d3.id <> d.id AND d3.deleted_at IS NULL);
END;
$$;
-- +goose StatementEnd

-- +goose Down
DROP TRIGGER IF EXISTS trg_cycles_days_sync_id ON cycles_days;
DROP TRIGGER IF EXISTS trg_menstrual_cycles_sync_id ON menstrual_cycles;
DROP FUNCTION IF EXISTS cycle_day_sync_id();
DROP FUNCTION IF EXISTS cycle_sync_id();
ALTER TABLE cycles_days ALTER COLUMN id SET DEFAULT uuid_generate_v4();
ALTER TABLE menstrual_cycles ALTER COLUMN id SET DEFAULT uuid_generate_v4();
ALTER TABLE cycles_days DROP CONSTRAINT cycles_days_cycle_id_fkey;
ALTER TABLE cycles_days ADD CONSTRAINT cycles_days_cycle_id_fkey
    FOREIGN KEY (cycle_id) REFERENCES menstrual_cycles ON DELETE CASCADE;
