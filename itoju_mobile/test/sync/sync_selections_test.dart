import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itoju_mobile/core/Storage/secure_store.dart';
import 'package:itoju_mobile/data/db/app_database.dart';
import 'package:itoju_mobile/data/ids.dart';
import 'package:itoju_mobile/data/providers.dart';
import 'package:itoju_mobile/data/repositories/conditions_repository.dart';
import 'package:itoju_mobile/data/repositories/points_repository.dart';
import 'package:itoju_mobile/data/repositories/settings_repository.dart';
import 'package:itoju_mobile/data/repositories/tracked_metrics_repository.dart';
import 'package:itoju_mobile/sync/sync_engine.dart';

class _Api implements SyncApi {
  Map<String, dynamic> pushResponse = {};
  Map<String, dynamic> pullResponse = {
    'changes': {},
    'has_more': false,
    'watermark': '2026-06-01T00:00:00Z'
  };
  final List<List<Map<String, dynamic>>> pushes = [];

  @override
  Future<Map<String, dynamic>> push(List<Map<String, dynamic>> changes) async {
    pushes.add(changes);
    // ack everything as applied
    return {
      'results': {
        for (final c in changes)
          c['table']: [
            for (final r in c['rows'] as List)
              {'id': (r as Map)['id'], 'status': 'applied'}
          ]
      }
    };
  }

  @override
  Future<Map<String, dynamic>> pull(String since, int limit,
          {String? until,
          Map<String, dynamic> cursors = const {},
          List<String>? tables}) async =>
      pullResponse;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AppDatabase db;
  late _Api api;
  late ProviderContainer container;

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    db = AppDatabase(NativeDatabase.memory());
    api = _Api();
    container = ProviderContainer(overrides: [
      appDatabaseProvider.overrideWithValue(db),
      syncApiProvider.overrideWithValue(api),
    ]);
  });
  tearDown(() {
    container.dispose();
    db.close();
  });

  Map rowsFor(String table) => (api.pushes
      .expand((p) => p)
      .firstWhere((c) => c['table'] == table))['rows'][0] as Map;

  test('push sends selections and both settings tables from one local row',
      () async {
    await container.read(trackedMetricsRepositoryProvider).add(3);
    await container.read(conditionsRepositoryProvider).add(5);
    await container.read(settingsRepositoryProvider).updateMenses(5, 28);
    await container.read(settingsRepositoryProvider).updateBodyData(170.5, 60.3);

    await container.read(syncEngineProvider).push();

    final tm = rowsFor('user_trackedmetric');
    expect(tm['metric_id'], 3);
    expect(tm['granted_at'], isA<String>());
    final cd = rowsFor('user_conditions');
    expect(cd['conditions_id'], 5, reason: 'payload name differs from local condition_id');
    expect(cd.containsKey('condition_id'), isFalse);
    final mens = rowsFor('menstruation');
    final body = rowsFor('bodymeasure_v2');
    expect(mens['id'], body['id'], reason: 'one client row -> same id on both server tables');
    expect(mens['period_len'], 5);
    expect(mens['cycle_len'], 28);
    expect(mens.containsKey('height_cm'), isFalse, reason: 'each table carries only its own columns');
    expect(body['height_cm'], 170.5);
    expect(body['weight_kg'], 60.3);
    expect(body.containsKey('height'), isFalse,
        reason: 'the whole-number legacy columns are no longer synced');
    // everything acked
    for (final t in [
      db.userTrackedMetrics.actualTableName,
      db.userConditions.actualTableName,
      db.userSettings.actualTableName
    ]) {
      final pending = await db.customSelect(
          "SELECT count(*) AS n FROM $t WHERE sync_state = 'pending'").getSingle();
      expect(pending.read<int>('n'), 0, reason: t);
    }
  });

  test('pull restores selections, a tombstoned deselect, and settings', () async {
    FlutterSecureStorage.setMockInitialValues({'local_account_id': 'acct'});
    final settingsId = IdMinter.settings('acct'); // the id the app looks up
    api.pullResponse = {
      'changes': {
        'user_trackedmetric': [
          {'id': 'tm-1', 'metric_id': 2, 'granted_at': '2026-05-01T10:00:00Z',
           'updated_at': '2026-05-01T10:00:00Z', 'deleted_at': null},
          {'id': 'tm-2', 'metric_id': 4, 'granted_at': '2026-05-01T10:00:00Z',
           'updated_at': '2026-05-02T10:00:00Z', 'deleted_at': '2026-05-02T10:00:00Z'},
        ],
        'user_conditions': [
          {'id': 'cd-1', 'conditions_id': 7,
           'updated_at': '2026-05-01T10:00:00Z', 'deleted_at': null},
        ],
        'menstruation': [
          {'id': settingsId, 'period_len': 4, 'cycle_len': 30,
           'updated_at': '2026-05-01T10:00:00Z', 'deleted_at': null},
        ],
        'bodymeasure_v2': [
          {'id': settingsId, 'height_cm': 165.5, 'weight_kg': 58.2,
           'updated_at': '2026-05-01T10:00:00Z', 'deleted_at': null},
        ],
      },
      'has_more': false,
      'watermark': '2026-06-01T00:00:00Z',
    };
    await container.read(syncEngineProvider).pull();

    final selected = await container.read(trackedMetricsRepositoryProvider).getSelected();
    expect(selected.map((m) => m.id), [2], reason: 'metric 4 was deselected on the other device');
    final conds = await container.read(conditionsRepositoryProvider).getSelected();
    expect(conds.map((c) => c.id), [7]);
    final repo = container.read(settingsRepositoryProvider);
    final menses = await repo.getMenses();
    final bodyData = await repo.getBodyData();
    expect([menses.periodLen, menses.cycleLen], [4, 30]);
    expect([bodyData.heightCm, bodyData.weightKg], [165.5, 58.2]);
  });

  test('a newer remote menstruation row does not swallow an unsent body edit',
      () async {
    // Local settings row with a pending HEIGHT edit...
    final id = IdMinter.settings('acct');
    await db.into(db.userSettings).insert(UserSettingsCompanion.insert(
          id: id,
          localUpdatedAt: DateTime.utc(2026, 5, 1, 12),
          heightCm: const Value(180),
          updatedAt: Value(DateTime.utc(2026, 5, 1, 12)),
        ));
    // ...then another device changed the PERIOD length later (newer remote).
    api.pullResponse = {
      'changes': {
        'menstruation': [
          {'id': id, 'period_len': 6, 'cycle_len': 31,
           'updated_at': '2026-05-03T00:00:00Z', 'deleted_at': null},
        ],
      },
      'has_more': false,
      'watermark': '2026-06-01T00:00:00Z',
    };
    await container.read(syncEngineProvider).pull();

    final row = await db.select(db.userSettings).getSingle();
    expect(row.periodLen, 6, reason: 'newer remote values applied');
    expect(row.heightCm, 180, reason: 'local height untouched');
    expect(row.syncState, 'pending',
        reason: 'the unsent height edit must still be pushed, not marked synced');
  });

  test('binding an anonymous device re-keys selections to the server user',
      () async {
    // Created while anonymous (namespace = local account id).
    FlutterSecureStorage.setMockInitialValues({'local_account_id': 'local-1'});
    await container.read(trackedMetricsRepositoryProvider).add(3);
    await container.read(conditionsRepositoryProvider).add(5);
    await container.read(settingsRepositoryProvider).updateMenses(5, 28);
    expect((await db.select(db.userTrackedMetrics).getSingle()).id,
        IdMinter.trackedMetric('local-1', 3));

    // Now the user signs in: token + binding to a server user.
    FlutterSecureStorage.setMockInitialValues({
      'local_account_id': 'local-1',
      'token': 'tok',
      'bound_server_user_id': 'server-1',
      'current_server_user_id': 'server-1',
    });
    final outcome = await container.read(syncEngineProvider).syncNow();
    expect(outcome, SyncOutcome.synced);

    expect((await db.select(db.userTrackedMetrics).getSingle()).id,
        IdMinter.trackedMetric('server-1', 3));
    expect((await db.select(db.userConditions).getSingle()).id,
        IdMinter.condition('server-1', 5));
    expect((await db.select(db.userSettings).getSingle()).id,
        IdMinter.settings('server-1'));
    // and what was pushed carries the server-namespaced ids
    expect(rowsFor('user_trackedmetric')['id'],
        IdMinter.trackedMetric('server-1', 3));
    expect(SecureStore, isNotNull);
  });

  test('point records push and pull like everything else', () async {
    FlutterSecureStorage.setMockInitialValues({'local_account_id': 'acct'});
    await db.into(db.pointRecords).insert(PointRecordsCompanion.insert(
        id: 'p-local',
        localUpdatedAt: DateTime.now(),
        point: 10,
        scope: 'Symptoms',
        date: '2026-05-01'));
    await container.read(syncEngineProvider).push();
    final row = rowsFor('user_point_record');
    expect(row['id'], 'p-local');
    expect(row['point'], 10);
    expect(row['scope'], 'Symptoms');
    expect(row['date'], '2026-05-01');
    expect(row['updated_at'], isA<String>(), reason: 'falls back to local edit time');

    api.pullResponse = {
      'changes': {
        'user_point_record': [
          {'id': 'p-cloud', 'point': 2, 'scope': 'Bowel', 'date': '2026-05-02',
           'updated_at': '2026-05-02T10:00:00Z', 'deleted_at': null},
        ],
      },
      'has_more': false,
      'watermark': '2026-06-01T00:00:00Z',
    };
    await container.read(syncEngineProvider).pull();
    final total = await container.read(pointsRepositoryProvider).getPoints();
    expect(total.totalPts, 12, reason: 'restored device shows the cloud total');
  });

  test('binding re-keys the registration and per-day point ids', () async {
    FlutterSecureStorage.setMockInitialValues({'local_account_id': 'local-1'});
    final day = '2026-05-03';
    for (final r in [
      (IdMinter.pointRegister('local-1'), 'Register', '2026-05-01'),
      (IdMinter.pointDay('local-1', 'Food', day), 'Food', day),
    ]) {
      await db.into(db.pointRecords).insert(PointRecordsCompanion.insert(
          id: r.$1, localUpdatedAt: DateTime.now(), point: 2, scope: r.$2, date: r.$3));
    }
    // an ordinary per-entry award must be left alone
    await db.into(db.pointRecords).insert(PointRecordsCompanion.insert(
        id: 'live-award', localUpdatedAt: DateTime.now(), point: 2, scope: 'Bowel', date: day));

    FlutterSecureStorage.setMockInitialValues({
      'local_account_id': 'local-1',
      'token': 'tok',
      'bound_server_user_id': 'server-1',
      'current_server_user_id': 'server-1',
    });
    expect(await container.read(syncEngineProvider).syncNow(), SyncOutcome.synced);

    final ids = (await db.select(db.pointRecords).get()).map((r) => r.id).toSet();
    expect(ids, {
      IdMinter.pointRegister('server-1'), // == what the server's own award uses
      IdMinter.pointDay('server-1', 'Food', day),
      'live-award',
    });
  });
}
