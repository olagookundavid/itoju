import 'package:drift/drift.dart' as drift;
import 'package:drift/drift.dart' show Value;
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

  /// Queued page responses for paginated pulls (used before [pullResponse]).
  final List<Map<String, dynamic>> pullPages = [];
  List<Map<String, dynamic>>? lastPush;
  final List<List<Map<String, dynamic>>> pushCalls = [];
  final List<Map<String, dynamic>> pullCalls = [];

  @override
  Future<Map<String, dynamic>> push(List<Map<String, dynamic>> changes) async {
    lastPush = changes;
    pushCalls.add(changes);
    return pushResponse;
  }

  @override
  Future<Map<String, dynamic>> pull(String since, int limit,
      {String? until,
      Map<String, dynamic> cursors = const {},
      List<String>? tables}) async {
    pullCalls.add(
        {'since': since, 'until': until, 'cursors': cursors, 'tables': tables});
    if (pullPages.isNotEmpty) return pullPages.removeAt(0);
    return pullResponse;
  }
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
    await container.read(bowelRepositoryProvider).create('2026-05-01',
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
    final change =
        api.lastPush!.firstWhere((c) => c['table'] == 'user_bowel_metric');
    final row = (change['rows'] as List).single as Map;
    expect(row['id'], rowBefore.id);
    expect(row['date'], '2026-05-01');
    expect(row['type'], 3);
    expect(row['pain'], 0.4);
    expect(row['time'], '08:00');
    expect(
        row['tags'], ['am']); // tags serialized as a JSON array, not a string
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
    await container.read(bowelRepositoryProvider).create('2026-07-01',
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

  test('push drains >500 pending rows in chunks instead of wedging', () async {
    // 620 pending bowel rows — over the server's 500-rows-per-table cap.
    await db.transaction(() async {
      for (var i = 0; i < 620; i++) {
        await db.customStatement(
          'INSERT INTO bowel_metrics (id, date, type, pain, time, tags, '
          'sync_state, local_updated_at, updated_at) '
          "VALUES (?, '2026-01-01', 1, 0.1, '08:00', '[]', 'pending', 1, 1)",
          ['chunk-$i'],
        );
      }
    });

    // The fake acks whatever it was sent, like the real server does.
    api.pushResponse = {};
    Map<String, dynamic> ackAll(List<Map<String, dynamic>> changes) => {
          'results': {
            for (final c in changes)
              c['table'] as String: [
                for (final r in c['rows'] as List)
                  {'id': (r as Map)['id'], 'status': 'applied'}
              ]
          }
        };
    // Wire the fake to ack dynamically by replaying through pushResponse.
    // (FakeSyncApi returns pushResponse; set it per call via a wrapper.)
    var call = 0;
    final ackingApi = _AckingSyncApi(onPush: (changes) {
      call++;
      return ackAll(changes);
    });
    final c2 = ProviderContainer(overrides: [
      appDatabaseProvider.overrideWithValue(db),
      syncApiProvider.overrideWithValue(ackingApi),
    ]);
    addTearDown(c2.dispose);

    await c2.read(syncEngineProvider).push();

    expect(call, 2, reason: '620 rows at 500/chunk should take 2 requests');
    expect(ackingApi.rowCounts, [500, 120]);
    final pending = await db
        .customSelect(
            "SELECT count(*) AS c FROM bowel_metrics WHERE sync_state = 'pending'")
        .getSingle();
    expect(pending.data['c'], 0, reason: 'everything must end up synced');
  });

  test(
      'pull follows per-table cursors across pages and only then advances the watermark',
      () async {
    Map<String, dynamic> row(String id, String date) => {
          'id': id,
          'date': date,
          'type': 1,
          'pain': 0.1,
          'time': '08:00',
          'tags': <String>[],
          'updated_at': '2026-06-01T00:00:00Z',
          'deleted_at': null,
        };
    const w = '2026-06-03T00:00:00.123456Z';
    api.pullPages.addAll([
      {
        'changes': {
          'user_bowel_metric': [
            row('p1', '2026-06-01'),
            row('p2', '2026-06-01')
          ]
        },
        'watermark': w,
        'has_more': true,
        'cursors': {
          'user_bowel_metric': {'ts': '2026-06-01T00:00:00.5Z', 'id': 'p2'}
        },
      },
      {
        'changes': {
          'user_bowel_metric': [row('p3', '2026-06-02')]
        },
        'watermark': w,
        'has_more': false,
        'cursors': {},
      },
    ]);

    await container.read(syncEngineProvider).pull();

    // Page 2 resumed with the sweep's watermark and page 1's cursor.
    expect(api.pullCalls.length, 2);
    expect(api.pullCalls[1]['until'], w);
    // First page asks for every table; the follow-up asks ONLY for the table that
    // still has rows (finished tables must not be re-sent and re-applied).
    expect(api.pullCalls[0]['tables'], isNull);
    expect(api.pullCalls[1]['tables'], ['user_bowel_metric']);
    expect(
        (api.pullCalls[1]['cursors'] as Map)['user_bowel_metric']['id'], 'p2');

    // All three rows landed; the persisted watermark is the sweep bound.
    final n = await db
        .customSelect('SELECT count(*) AS c FROM bowel_metrics')
        .getSingle();
    expect(n.data['c'], 3);
    final wm = await (db.select(db.syncMeta)
          ..where((t) => t.key.equals('pullWatermark')))
        .getSingleOrNull();
    expect(wm?.value, w);
  });

  Map<String, dynamic> remoteBowel(String id, String updatedAt, int type) => {
        'id': id,
        'date': '2026-06-01',
        'type': type,
        'pain': 0.5,
        'time': '10:00',
        'tags': <String>[],
        'updated_at': updatedAt,
        'deleted_at': null,
      };

  Future<void> insertPendingBowelWithoutUpdatedAt(String id) =>
      db.into(db.bowelMetrics).insert(BowelMetricsCompanion.insert(
            id: id,
            localUpdatedAt: DateTime.now().toUtc(), // updated_at stays NULL
            date: '2026-06-01',
            type: const Value(1),
          ));

  test('pull tolerates a pending local row that has no updated_at', () async {
    // Rows written without an explicit updatedAt (older builds / direct inserts)
    // have a NULL updated_at; conflict resolution must fall back to the local
    // edit time instead of crashing the whole pull.
    await insertPendingBowelWithoutUpdatedAt('r1');
    api.pullResponse = {
      'changes': {
        'user_bowel_metric': [remoteBowel('r1', '2000-01-01T00:00:00Z', 9)]
      },
      'watermark': '2026-06-02T12:00:00Z',
      'has_more': false,
    };
    await container.read(syncEngineProvider).pull(); // must not throw
    final row = await db.select(db.bowelMetrics).getSingle();
    expect(row.type, 1,
        reason: 'older remote must not clobber the pending edit');
    expect(row.syncState, 'pending');
  });

  test('a strictly newer remote row wins over a pending local one', () async {
    await insertPendingBowelWithoutUpdatedAt('r2');
    api.pullResponse = {
      'changes': {
        'user_bowel_metric': [remoteBowel('r2', '2099-01-01T00:00:00Z', 9)]
      },
      'watermark': '2026-06-02T12:00:00Z',
      'has_more': false,
    };
    await container.read(syncEngineProvider).pull();
    final row = await db.select(db.bowelMetrics).getSingle();
    expect(row.type, 9);
    expect(row.syncState, 'synced');
  });

  test('push: rejected rows are quarantined, retry rows stay pending',
      () async {
    final repo = container.read(bowelRepositoryProvider);
    for (final t in [1, 2, 3]) {
      await repo.create('2026-05-0$t',
          BowelModel(time: '', tags: const [], type: t, pain: 0));
    }
    final rows = await (db.select(db.bowelMetrics)
          ..orderBy([(t) => drift.OrderingTerm(expression: t.date)]))
        .get();
    api.pushResponse = {
      'results': {
        'user_bowel_metric': [
          {'id': rows[0].id, 'status': 'applied'},
          {'id': rows[1].id, 'status': 'rejected'},
          {'id': rows[2].id, 'status': 'retry'},
        ]
      }
    };
    await container.read(syncEngineProvider).push();
    final after = {
      for (final r in await db.select(db.bowelMetrics).get()) r.id: r.syncState
    };
    expect(after[rows[0].id], 'synced');
    expect(after[rows[1].id], 'rejected',
        reason: 'permanent failure: stop resending');
    expect(after[rows[2].id], 'pending',
        reason: 'transient: try again next sync');
  });
}

class _AckingSyncApi implements SyncApi {
  _AckingSyncApi({required this.onPush});
  final Map<String, dynamic> Function(List<Map<String, dynamic>>) onPush;
  final List<int> rowCounts = [];

  @override
  Future<Map<String, dynamic>> push(List<Map<String, dynamic>> changes) async {
    rowCounts.add(
        changes.fold<int>(0, (sum, c) => sum + (c['rows'] as List).length));
    return onPush(changes);
  }

  @override
  Future<Map<String, dynamic>> pull(String since, int limit,
          {String? until,
          Map<String, dynamic> cursors = const {},
          List<String>? tables}) async =>
      {'changes': {}, 'has_more': false};
}
