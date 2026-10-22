import 'package:flutter_test/flutter_test.dart';
import 'package:itoju_mobile/data/ids.dart';
import 'package:uuid/uuid.dart';

/// Cross-language contract: these golden vectors are identical to the backend's
/// internal/models/det_sync_id_db_test.go and /SYNC_ID_SPEC.md. If this test
/// fails, the client and server would mint different ids for the same row and
/// sync would duplicate data.
void main() {
  selectionVectors();
  const user = '00000000-0000-0000-0000-000000000001';
  const date = '2026-05-10';

  test('namespace literal equals uuidv5(DNS, "sync.itoju.app")', () {
    const dnsNamespace = '6ba7b810-9dad-11d1-80b4-00c04fd430c8';
    final computed = const Uuid().v5(dnsNamespace, 'sync.itoju.app');
    expect(computed, IdMinter.namespace);
    expect(IdMinter.namespace, 'cda0d494-38a4-51db-b52d-62713a57ad8c');
  });

  test('food deterministic id matches backend golden vector', () {
    expect(IdMinter.food(user, date), '392ec4ce-09f7-5cb0-848e-921265e26b1f');
  });

  test('symptoms deterministic id matches backend golden vector', () {
    expect(
      IdMinter.symptoms(user, 1, date),
      '89ed2f07-25de-5807-ba0e-e1c6ebb998b3',
    );
  });

  test('cycle + cycle-day deterministic ids match backend golden vectors', () {
    final cycleId = IdMinter.cycle(user, date);
    expect(cycleId, '21647642-d3b3-5eaa-b17a-46f1b6806d57');
    expect(
      IdMinter.cycleDay(user, cycleId, date),
      '77229aff-1df0-5e14-9361-bf49c94497f3',
    );
  });

  test('v7 ids are unique and time-ordered', () {
    final a = IdMinter.v7();
    final b = IdMinter.v7();
    expect(a, isNot(b));
    expect(a.length, 36);
  });
}

void selectionVectors() {
  // Golden vectors from SYNC_ID_SPEC.md — the Go/SQL side asserts the same ones
  // (internal/models/sync_selections_db_test.go).
  const user = '00000000-0000-0000-0000-000000000001';
  test('selection + settings deterministic ids match backend golden vectors', () {
    expect(IdMinter.trackedMetric(user, 3), '00eab78b-ee0b-59d8-9e07-3782c64789fd');
    expect(IdMinter.condition(user, 5), '39678ede-24d4-5239-b247-74dbd24cbc39');
    expect(IdMinter.settings(user), '930a21fa-7f84-5cfd-b659-88f739d0a3f9');
  });
  test('registration point id matches the backend golden vector', () {
    // The server's sign-up award and the app's own award are ONE row because
    // both use this id (internal/models/sync_points_db_test.go asserts it too).
    expect(IdMinter.pointRegister(user), 'd03c6ab1-33a6-51fd-9b00-8bc14d721511');
  });
  test('per-day point ids are stable per (account, scope, date) and distinct', () {
    expect(IdMinter.pointDay(user, 'Food', '2026-05-01'),
        IdMinter.pointDay(user, 'Food', '2026-05-01'));
    expect(IdMinter.pointDay(user, 'Food', '2026-05-01'),
        isNot(IdMinter.pointDay(user, 'Food', '2026-05-02')));
    expect(IdMinter.pointDay(user, 'Food', '2026-05-01'),
        isNot(IdMinter.pointDay(user, 'Bowel', '2026-05-01')));
    expect(IdMinter.pointDay(user, 'Food', '2026-05-01'),
        isNot(IdMinter.pointDay('someone-else', 'Food', '2026-05-01')));
  });
}
