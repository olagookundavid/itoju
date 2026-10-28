import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itoju_mobile/data/account_service.dart';
import 'package:itoju_mobile/data/db/app_database.dart';
import 'package:itoju_mobile/data/ids.dart';
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

  group('body measurements', () {
    test('decimals round trip as cm / kg and are bounded', () async {
      await repo.updateBodyData(172.5, 68.4);
      var b = await repo.getBodyData();
      expect([b.heightCm, b.weightKg], [172.5, 68.4]);

      await repo.updateBodyData(172.46, 9999);
      b = await repo.getBodyData();
      expect(b.heightCm, 172.5, reason: 'stored to one decimal');
      expect(b.weightKg, 500, reason: 'clamped to the sane maximum');
    });

    Future<void> legacyRow(int height, int weight) async {
      // What the 1.1 -> 1.2 upgrade leaves behind: raw numbers copied across.
      await db.into(db.userSettings).insert(UserSettingsCompanion.insert(
            id: IdMinter.settings('test-account'),
            localUpdatedAt: DateTime.utc(2026, 5, 1),
            height: Value(height),
            weight: Value(weight),
            heightCm: Value(height.toDouble()),
            weightKg: Value(weight.toDouble()),
            syncState: const Value('synced'),
          ));
    }

    test('legacy inches and pounds are converted once, and marked for sync',
        () async {
      await legacyRow(70, 150); // 70 in, 150 lb
      await repo.migrateLegacyBodyUnits(heightUnit: 'inch', weightUnit: 'ib');

      var b = await repo.getBodyData();
      expect(b.heightCm, 177.8);
      expect(b.weightKg, 68.0);
      expect(
          (await db.select(db.userSettings).getSingle()).syncState, 'pending');

      // A second run (e.g. next launch) must not convert the converted value again.
      await repo.migrateLegacyBodyUnits(heightUnit: 'inch', weightUnit: 'ib');
      b = await repo.getBodyData();
      expect([b.heightCm, b.weightKg], [177.8, 68.0]);
    });

    test('values already in cm / kg are left alone', () async {
      await legacyRow(172, 65);
      await repo.migrateLegacyBodyUnits(heightUnit: 'cm', weightUnit: 'kg');
      final b = await repo.getBodyData();
      expect([b.heightCm, b.weightKg], [172, 65]);
      expect((await db.select(db.userSettings).getSingle()).syncState, 'synced',
          reason: 'nothing changed, nothing to push');
    });

    test('a value re-entered before the fix-up runs is not converted',
        () async {
      await legacyRow(70, 150);
      await repo.updateBodyData(180.5, 82.0); // user edited in the new UI first
      await repo.migrateLegacyBodyUnits(heightUnit: 'inch', weightUnit: 'ib');
      final b = await repo.getBodyData();
      expect([b.heightCm, b.weightKg], [180.5, 82.0]);
    });

    test('with no settings row it just records that it ran', () async {
      await repo.migrateLegacyBodyUnits(heightUnit: 'inch', weightUnit: 'ib');
      final flag = await (db.select(db.syncMeta)
            ..where((t) => t.key.equals('bodyUnitsMigrated')))
          .getSingleOrNull();
      expect(flag?.value, '1');
    });
  });
}
