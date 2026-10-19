import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itoju_mobile/data/account_service.dart';
import 'package:itoju_mobile/data/db/app_database.dart';
import 'package:itoju_mobile/data/repositories/symptoms_repository.dart';

class _Acct extends AccountService {
  @override
  Future<String> deterministicNamespaceId() async => 'acct';
  @override
  Future<String> localAccountId() async => 'acct';
}

/// The analytics screen defaulted to "Headache" even for someone who never logs
/// it, showing an empty chart. It now defaults to what the user actually logs.
void main() {
  late AppDatabase db;
  late SymptomsRepository repo;
  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = SymptomsRepository(db, _Acct());
  });
  tearDown(() => db.close());

  test('null when nothing has been logged', () async {
    expect(await repo.mostLogged(), isNull);
  });

  test('returns the symptom logged on the most days', () async {
    await repo.create(5, '2026-05-01'); // Acne once
    await repo.create(9, '2026-05-01'); // Bloating three times
    await repo.create(9, '2026-05-02');
    await repo.create(9, '2026-05-03');
    final top = await repo.mostLogged();
    expect(top!.id, 9);
    expect(top.name, 'Bloating');
  });

  test('deleted entries do not count', () async {
    await repo.create(5, '2026-05-01');
    await repo.create(5, '2026-05-02');
    await repo.create(9, '2026-05-01');
    await repo.create(9, '2026-05-02');
    await repo.create(9, '2026-05-03');
    final rows = await db.select(db.symptomMetrics).get();
    for (final r in rows.where((r) => r.symptomsId == 9)) {
      await repo.delete(r.id);
    }
    expect((await repo.mostLogged())!.id, 5);
  });
}
