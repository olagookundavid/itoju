import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itoju_mobile/data/account_service.dart';
import 'package:itoju_mobile/data/db/app_database.dart';
import 'package:itoju_mobile/data/repositories/settings_repository.dart';

class _FakeAccountService extends AccountService {
  @override
  Future<String> deterministicNamespaceId() async => 'test-account';
}

void main() {
  late AppDatabase db;
  late SettingsRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = SettingsRepository(db, _FakeAccountService());
  });
  tearDown(() => db.close());

  test('updateMenses saves and getMenses retrieves new values', () async {
    // Initially should return defaults (0)
    var m = await repo.getMenses();
    expect(m.periodLen, 0);
    expect(m.cycleLen, 0);

    // Save initial values
    await repo.updateMenses(3, 6);
    m = await repo.getMenses();
    expect(m.periodLen, 3);
    expect(m.cycleLen, 6);

    // Update to new values
    await repo.updateMenses(3, 7);
    m = await repo.getMenses();
    expect(m.periodLen, 3);
    expect(m.cycleLen, 7);
  });
}
