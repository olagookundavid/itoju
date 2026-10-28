import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itoju_mobile/data/db/app_database.dart';
import 'package:itoju_mobile/data/models/bp_model.dart';
import 'package:itoju_mobile/data/providers.dart';
import 'package:itoju_mobile/data/repositories/bp_repository.dart';
import 'package:itoju_mobile/sync/sync_engine.dart';

class _Api implements SyncApi {
  Map<String, dynamic> pullResponse = {
    'changes': {},
    'has_more': false,
    'watermark': '2026-11-01T00:00:00Z'
  };
  final List<List<Map<String, dynamic>>> pushes = [];

  @override
  Future<Map<String, dynamic>> push(List<Map<String, dynamic>> changes) async {
    pushes.add(changes);
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

  test('a saved reading is pushed under user_bp_metric and marked synced', () async {
    await container.read(bpRepositoryProvider).create(
        '2026-10-01',
        const BpModel(
            id: null, date: '2026-10-01', time: '08:15', systolic: 122, diastolic: 81, pulse: 68));

    await container.read(syncEngineProvider).push();

    final change = api.pushes.expand((p) => p).firstWhere((c) => c['table'] == 'user_bp_metric');
    final row = (change['rows'] as List).single as Map;
    expect(row['date'], '2026-10-01');
    expect(row['time'], '08:15');
    expect([row['systolic'], row['diastolic'], row['pulse']], [122, 81, 68]);
    expect(row['deleted_at'], isNull);
    expect((await db.select(db.bpMetrics).getSingle()).syncState, 'synced');
  });

  test('a restored device pulls readings back, including a tombstone', () async {
    api.pullResponse = {
      'changes': {
        'user_bp_metric': [
          {'id': 'bp-1', 'date': '2026-10-01', 'time': '08:15', 'systolic': 122.0,
           'diastolic': 81.0, 'pulse': 68.0,
           'updated_at': '2026-10-01T08:15:00Z', 'deleted_at': null},
          {'id': 'bp-2', 'date': '2026-10-01', 'time': '21:00', 'systolic': 140.0,
           'diastolic': 90.0, 'pulse': 80.0,
           'updated_at': '2026-10-02T00:00:00Z', 'deleted_at': '2026-10-02T00:00:00Z'},
        ],
      },
      'has_more': false,
      'watermark': '2026-11-01T00:00:00Z',
    };

    await container.read(syncEngineProvider).pull();

    final list = await container.read(bpRepositoryProvider).getForDate('2026-10-01');
    expect(list.map((r) => r.id), ['bp-1'], reason: 'the deleted reading stays hidden');
    expect([list.single.systolic, list.single.diastolic, list.single.pulse], [122, 81, 68]);
  });
}
