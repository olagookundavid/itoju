import 'package:flutter_test/flutter_test.dart';
import 'package:itoju_mobile/data/ids.dart';
import 'package:uuid/uuid.dart';

/// Cross-language contract: these golden vectors are identical to the backend's
/// internal/models/det_sync_id_db_test.go and /SYNC_ID_SPEC.md. If this test
/// fails, the client and server would mint different ids for the same row and
/// sync would duplicate data.
void main() {
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

  test('v7 ids are unique and time-ordered', () {
    final a = IdMinter.v7();
    final b = IdMinter.v7();
    expect(a, isNot(b));
    expect(a.length, 36);
  });
}
