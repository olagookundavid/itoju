import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itoju_mobile/data/db/app_database.dart';
import 'package:itoju_mobile/data/models/bowel_model.dart';
import 'package:itoju_mobile/data/providers.dart';
import 'package:itoju_mobile/data/repositories/bowel_repository.dart';
import 'package:itoju_mobile/sync/sync_engine.dart';

class FakeSyncApi implements SyncApi {
  FakeSyncApi({this.pushResponse = const {}, this.pullResponse = const {}});
  Map<String, dynamic> pushResponse;
  Map<String, dynamic> pullResponse;
  List<Map<String, dynamic>>? lastPush;

  @override
  Future<Map<String, dynamic>> push(List<Map<String, dynamic>> changes) async {
    lastPush = changes;
    return pushResponse;
  }

  @override
  Future<Map<String, dynamic>> pull(String since, int limit) async =>
      pullResponse;
}

void main() {
  late AppDatabase db;
  late FakeSyncApi api;
  late ProviderContainer container;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    api = FakeSyncApi();
    container = ProviderContainer(overrides: [
      appDatabaseProvider.overrideWithValue(db),
      syncApiProvider.overrideWithValue(api),
    ]);
  });
  tearDown(() {
    container.dispose();
    db.close();
  });

  test('push serializes a pending bowel row to the backend contract', () async {
    await container.read(bowelRepositoryProvider).create(
        '2026-05-01',
        BowelModel(time: '08:00', tags: const ['am'], type: 3, pain: 0.4));

    api.pushResponse = {
      'results': {
        'user_bowel_metric': [
          {'id': 'ignored', 'status': 'applied'}
        ]
      }
    };
    // capture the id first
    final rowBefore = await db.select(db.bowelMetrics).getSingle();
    api.pushResponse['results']['user_bowel_metric'][0]['id'] = rowBefore.id;

    await container.read(syncEngineProvider).push();

    // the payload carried exactly one bowel change with the right shape
    final change = api.lastPush!.firstWhere((c) => c['table'] == 'user_bowel_metric');
    final row = (change['rows'] as List).single as Map;
    expect(row['id'], rowBefore.id);
    expect(row['date'], '2026-05-01');
    expect(row['type'], 3);
    expect(row['pain'], 0.4);
    expect(row['time'], '08:00');
    expect(row['tags'], ['am']); // tags serialized as a JSON array, not a string
    expect(row['updated_at'], isA<String>());
    expect(row['deleted_at'], isNull);
    expect(row.containsKey('sync_state'), isFalse); // bookkeeping not sent

    // after an 'applied' ack the row is marked synced
    final rowAfter = await db.select(db.bowelMetrics).getSingle();
    expect(rowAfter.syncState, 'synced');
  });

  test('pull applies a remote row and a tombstone', () async {
    api.pullResponse = {
      'changes': {
        'user_bowel_metric': [
          {
            'id': 'remote-1',
            'date': '2026-06-01',
            'type': 5,
            'pain': 0.9,
            'time': '10:00',
            'tags': ['pm'],
            'updated_at': '2026-06-01T10:00:00Z',
            'deleted_at': null,
          },
          {
            'id': 'remote-2',
            'date': '2026-06-02',
            'type': 2,
            'pain': 0.1,
            'time': '11:00',
            'tags': [],
            'updated_at': '2026-06-02T11:00:00Z',
            'deleted_at': '2026-06-02T12:00:00Z', // tombstone
          },
        ]
      },
      'watermark': '2026-06-02T12:00:00Z',
      'has_more': false,
    };

    await container.read(syncEngineProvider).pull();

    final live = await (db.select(db.bowelMetrics)
          ..where((t) => t.deletedAt.isNull()))
        .get();
    expect(live.length, 1);
    expect(live.single.id, 'remote-1');
    expect(live.single.type, 5);
    expect(live.single.tags, ['pm']);
    expect(live.single.syncState, 'synced');

    final tomb = await (db.select(db.bowelMetrics)
          ..where((t) => t.id.equals('remote-2')))
        .getSingle();
    expect(tomb.deletedAt, isNotNull);

    // watermark advanced
    final wm = await (db.select(db.syncMeta)
          ..where((t) => t.key.equals('pullWatermark')))
        .getSingleOrNull();
    expect(wm?.value, '2026-06-02T12:00:00Z');
  });

  test('pull keeps a newer local pending edit over an older remote (LWW)',
      () async {
    // local pending row, edited "now"
    await container.read(bowelRepositoryProvider).create(
        '2026-07-01',
        BowelModel(time: 'local', tags: const [], type: 9, pain: 0.5));
    final local = await db.select(db.bowelMetrics).getSingle();

    // remote claims the same id but with an OLDER updated_at
    api.pullResponse = {
      'changes': {
        'user_bowel_metric': [
          {
            'id': local.id,
            'date': '2026-07-01',
            'type': 1,
            'pain': 0.1,
            'time': 'remote-old',
            'tags': [],
            'updated_at': '2000-01-01T00:00:00Z',
            'deleted_at': null,
          }
        ]
      },
      'watermark': '2026-07-02T00:00:00Z',
      'has_more': false,
    };

    await container.read(syncEngineProvider).pull();

    final after = await db.select(db.bowelMetrics).getSingle();
    expect(after.time, 'local'); // local newer edit preserved
    expect(after.type, 9);
    expect(after.syncState, 'pending'); // still needs pushing
  });
}
