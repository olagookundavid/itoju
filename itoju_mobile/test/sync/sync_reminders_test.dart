import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itoju_mobile/data/db/app_database.dart';
import 'package:itoju_mobile/data/providers.dart';
import 'package:itoju_mobile/data/reminder_schedule.dart';
import 'package:itoju_mobile/data/repositories/reminder_repository.dart';
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

  test('a reminder is pushed with its days mask, times list and enabled flag', () async {
    await container.read(reminderRepositoryProvider).save(const MedReminderModel(
        id: null, name: 'Metformin', dosage: 500, unit: 'mg', quantity: 1,
        days: 31, times: ['08:00', '20:00']));

    await container.read(syncEngineProvider).push();

    final change = api.pushes.expand((p) => p).firstWhere((c) => c['table'] == 'user_med_reminder');
    final row = (change['rows'] as List).single as Map;
    expect(row['name'], 'Metformin');
    expect([row['dosage'], row['unit'], row['quantity'], row['days']], [500, 'mg', 1, 31]);
    expect(row['times'], ['08:00', '20:00']);
    expect(row['enabled'], isTrue);
    expect((await db.select(db.medReminders).getSingle()).syncState, 'synced');
  });

  test('reminders restore on a new device; a deleted one stays gone', () async {
    api.pullResponse = {
      'changes': {
        'user_med_reminder': [
          {'id': 'r-1', 'name': 'Metformin', 'dosage': 500.0, 'unit': 'mg', 'quantity': 1.0,
           'days': 127.0, 'times': ['08:00', '20:00'], 'enabled': true,
           'updated_at': '2026-10-01T08:00:00Z', 'deleted_at': null},
          {'id': 'r-2', 'name': 'Old', 'dosage': 1.0, 'unit': 'mg', 'quantity': 1.0,
           'days': 1.0, 'times': ['09:00'], 'enabled': false,
           'updated_at': '2026-10-02T00:00:00Z', 'deleted_at': '2026-10-02T00:00:00Z'},
        ],
      },
      'has_more': false,
      'watermark': '2026-11-01T00:00:00Z',
    };

    await container.read(syncEngineProvider).pull();

    final all = await container.read(reminderRepositoryProvider).getAll();
    expect(all.map((r) => r.id), ['r-1']);
    expect(all.single.times, ['08:00', '20:00']);
    expect(all.single.days, 127);
    expect(all.single.enabled, isTrue);
  });
}
