import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itoju_mobile/data/db/app_database.dart';
import 'package:itoju_mobile/data/providers.dart';
import 'package:itoju_mobile/data/repositories/points_repository.dart';
import 'package:itoju_mobile/sync/sync_engine.dart';

class _Api implements SyncApi {
  Map<String, dynamic> pullResponse = {
    'changes': {},
    'has_more': false,
    'watermark': '2026-11-01T00:00:00Z'
  };

  @override
  Future<Map<String, dynamic>> push(List<Map<String, dynamic>> changes) async =>
      {'results': {}};

  @override
  Future<Map<String, dynamic>> pull(String since, int limit,
          {String? until,
          Map<String, dynamic> cursors = const {},
          List<String>? tables}) async =>
      pullResponse;
}

/// A signed-in account's points are only worked out once its first download has
/// finished (see PointsRepository.ensureBackfill). The dashboard asks for points
/// the moment sign-in completes — before that download — so the sync itself has
/// to trigger the catch-up when it ends, or a new account shows 0 points.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AppDatabase db;
  late _Api api;
  late ProviderContainer container;

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({
      'bound_server_user_id': 'server-1',
    });
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

  test('a new account gets its registration points when the first download ends',
      () async {
    final points = container.read(pointsRepositoryProvider);

    // What the dashboard does at sign-in: asks before the download has run.
    await points.ensureBackfill();
    expect((await points.getPoints()).totalPts, 0,
        reason: 'nothing may be awarded before the first download');

    await container.read(syncEngineProvider).pull();

    final after = await points.getPoints();
    expect(after.totalPts, 10);
    expect(after.todayPts, 10);
  });

  test('points already on the server are not doubled by the catch-up', () async {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    api.pullResponse = {
      'changes': {
        'user_point_record': [
          {
            'id': '11111111-1111-5111-8111-111111111111',
            'point': 10,
            'scope': 'Register',
            'date': today,
            'updated_at': '2026-11-01T00:00:00Z',
            'deleted_at': null,
          }
        ]
      },
      'has_more': false,
      'watermark': '2026-11-01T00:00:00Z'
    };

    await container.read(syncEngineProvider).pull();

    expect((await container.read(pointsRepositoryProvider).getPoints()).totalPts, 10);
  });
}
