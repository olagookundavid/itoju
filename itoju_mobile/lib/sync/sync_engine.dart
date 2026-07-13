import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/Storage/secure_store.dart';
import '../core/helpers/logger.dart';
import '../data/account_service.dart';
import '../data/db/app_database.dart';
import '../data/ids.dart';
import '../data/providers.dart';
import '../services/dio_provider.dart';
import 'sync_tables.dart';

/// Gates cloud sync. Sync is paywalled server-side; this is the client-side
/// pre-check so we don't attempt a (would-be 402) sync when the user isn't
/// entitled. The flag is refreshed from the server's /v1/user/entitlements
/// endpoint (which reflects the RevenueCat-driven subscription) and cached in
/// SyncMeta so gating works offline too.
abstract class EntitlementService {
  Future<bool> isSyncEnabled();
  Future<void> refreshFromServer();
}

class ServerEntitlementService implements EntitlementService {
  ServerEntitlementService(this._ref);
  final Ref _ref;

  AppDatabase get _db => _ref.read(appDatabaseProvider);

  @override
  Future<bool> isSyncEnabled() async {
    // MVP (pre-launch): cloud sync is FREE for any signed-in user — no paid
    // entitlement, no paywall. Gating on the cached "syncEnabled" flag is
    // disabled (not deleted); restore it when monetization ships. See
    // ARCHITECTURE_AND_DECISIONS.md (D11).
    final hasToken =
        (await SecureStore.read(SecureKeys.token) ?? '').isNotEmpty;
    return hasToken;

    // Paywalled version — restore post-MVP:
    // if (!hasToken) return false;
    // final row = await (_db.select(_db.syncMeta)
    //       ..where((t) => t.key.equals('syncEnabled')))
    //     .getSingleOrNull();
    // return row?.value == 'true';
  }

  @override
  Future<void> refreshFromServer() async {
    try {
      final res = await _ref.read(dioProvider).get('user/entitlements');
      final enabled =
          ((res.data?['entitlements'] as Map?)?['sync'] ?? false) == true;
      await _db.into(_db.syncMeta).insertOnConflictUpdate(
            SyncMetaCompanion.insert(
                key: 'syncEnabled', value: Value(enabled ? 'true' : 'false')),
          );
    } catch (_) {
      // Offline or unauthorized — keep the cached value.
    }
  }
}

final entitlementServiceProvider = Provider<EntitlementService>(
  (ref) => ServerEntitlementService(ref),
);

/// Transport for the two sync endpoints. An interface so tests can substitute a
/// fake without a live server. `until`/`cursors` continue a paginated pull
/// sweep: the server answers page 1 with a stable watermark and per-table
/// keyset cursors, and every follow-up page passes both back unchanged.
abstract class SyncApi {
  Future<Map<String, dynamic>> push(List<Map<String, dynamic>> changes);
  Future<Map<String, dynamic>> pull(String since, int limit,
      {String? until, Map<String, dynamic> cursors});
}

/// The real transport over the authed Dio.
class DioSyncApi implements SyncApi {
  DioSyncApi(this._ref);
  final Ref _ref;

  @override
  Future<Map<String, dynamic>> push(
      List<Map<String, dynamic>> changes) async {
    final dio = _ref.read(dioProvider);
    final res = await dio.post('sync/push', data: {'changes': changes});
    return Map<String, dynamic>.from(res.data as Map);
  }

  @override
  Future<Map<String, dynamic>> pull(String since, int limit,
      {String? until, Map<String, dynamic> cursors = const {}}) async {
    final dio = _ref.read(dioProvider);
    final res = await dio.post('sync/pull', data: {
      'since': since,
      'limit': limit,
      if (until != null) 'until': until,
      if (cursors.isNotEmpty) 'cursors': cursors,
    });
    return Map<String, dynamic>.from(res.data as Map);
  }
}

final syncApiProvider = Provider<SyncApi>((ref) => DioSyncApi(ref));

final syncEngineProvider = Provider<SyncEngine>((ref) => SyncEngine(ref));

/// The client half of the offline-first sync protocol. Pushes locally-pending
/// rows, then pulls the server delta, applying last-write-wins by updated_at.
/// The SyncEngine is the ONLY thing that touches the network for health data;
/// repositories never do.
class SyncEngine {
  SyncEngine(this._ref);
  final Ref _ref;

  bool _running = false;

  AppDatabase get _db => _ref.read(appDatabaseProvider);
  SyncApi get _api => _ref.read(syncApiProvider);

  /// Push then pull, once, guarded so overlapping triggers don't stack. No-ops
  /// (returns false) unless the user is authenticated and holds the sync
  /// entitlement; returns true only when a full push+pull completed, so callers
  /// can record the last-synced time. Never throws — offline/server errors
  /// surface as `false` so every trigger (manual, launch, resume, reconnect)
  /// degrades to "didn't sync" instead of an unhandled async exception.
  Future<bool> syncNow() async {
    if (_running) return false;
    if (!await _ref.read(entitlementServiceProvider).isSyncEnabled()) {
      return false;
    }
    _running = true;
    try {
      if (!await _bindIfNeeded()) return false;
      await push();
      await pull();
      return true;
    } catch (e) {
      debugLog('sync failed: $e');
      return false;
    } finally {
      _running = false;
    }
  }

  // --- push ---

  /// The server caps a push at 500 rows per table per request, so pending rows
  /// are drained in chunks: each round sends up to one chunk per table, marks
  /// the acked rows synced, and repeats until nothing is pending. A user with
  /// months of offline data therefore syncs in several requests instead of
  /// wedging on one oversized batch.
  static const _pushChunk = 500;

  Future<void> push() async {
    var guard = 0;
    while (guard++ < 200) {
      final changes = <Map<String, dynamic>>[];
      for (final spec in kSyncTables) {
        final rows = await _db.customSelect(
          'SELECT * FROM ${spec.client} WHERE sync_state = ?1 LIMIT $_pushChunk',
          variables: [Variable<String>('pending')],
        ).get();
        if (rows.isEmpty) continue;

        final payload = rows.map((r) {
          final d = r.data;
          final m = <String, dynamic>{'id': d['id']};
          for (final c in spec.cols) {
            m[c.name] = _toJson(c.kind, d[c.name]);
          }
          m['updated_at'] = _tsToIso(d['updated_at'] as int);
          m['deleted_at'] =
              d['deleted_at'] == null ? null : _tsToIso(d['deleted_at'] as int);
          return m;
        }).toList();
        changes.add({'table': spec.backend, 'rows': payload});
      }
      if (changes.isEmpty) return;

      final resp = await _api.push(changes);
      final results = (resp['results'] as Map?) ?? {};
      var acked = 0;
      await _db.transaction(() async {
        for (final spec in kSyncTables) {
          final list = (results[spec.backend] as List?) ?? [];
          for (final r in list) {
            final status = r['status'];
            if (status == 'applied' || status == 'stale') {
              await _db.customStatement(
                'UPDATE ${spec.client} SET sync_state = ? WHERE id = ?',
                ['synced', r['id']],
              );
              acked++;
            } else if (status == 'rejected') {
              // Quarantine: a rejected row (foreign id) will never be accepted —
              // stop re-sending it every sync. It stays local-only.
              await _db.customStatement(
                'UPDATE ${spec.client} SET sync_state = ? WHERE id = ?',
                ['rejected', r['id']],
              );
            }
          }
        }
      });
      // Nothing was acked this round: don't spin on rows the server won't take.
      if (acked == 0) return;
    }
  }

  // --- pull ---

  /// Pulls the server delta in a paginated sweep. Every page of one sweep runs
  /// against the SAME server-chosen upper bound (`until`) and resumes each
  /// table from the keyset cursor the server returned, so a table with more
  /// rows than one page can never have rows skipped. The persisted watermark
  /// only advances once the sweep completes — an interrupted sweep simply
  /// re-runs from the old watermark (applies are idempotent).
  Future<void> pull() async {
    final since = await _meta('pullWatermark') ?? '';
    String? until;
    var cursors = <String, dynamic>{};
    var hasMore = true;
    var guard = 0;
    while (hasMore && guard++ < 1000) {
      final resp = await _api.pull(since, 500, until: until, cursors: cursors);
      final changes = (resp['changes'] as Map?) ?? {};
      await _db.transaction(() async {
        for (final spec in kSyncTables) {
          final rows = (changes[spec.backend] as List?) ?? [];
          for (final row in rows) {
            await _applyRemote(spec, Map<String, dynamic>.from(row as Map));
          }
        }
      });
      until = (resp['watermark'] as String?) ?? until;
      cursors = Map<String, dynamic>.from(resp['cursors'] as Map? ?? {});
      hasMore = (resp['has_more'] as bool?) ?? false;
    }
    if (until != null && !hasMore) {
      await _setMeta('pullWatermark', until);
    }
  }

  Future<void> _applyRemote(SyncTableSpec spec, Map<String, dynamic> row) async {
    final id = row['id'] as String;
    final remoteUpdated = DateTime.parse(row['updated_at'] as String).toUtc();

    final local = await _db.customSelect(
      'SELECT updated_at, sync_state FROM ${spec.client} WHERE id = ?1',
      variables: [Variable<String>(id)],
    ).getSingleOrNull();
    if (local != null && local.data['sync_state'] == 'pending') {
      final localUpdated = DateTime.fromMillisecondsSinceEpoch(
          (local.data['updated_at'] as int) * 1000,
          isUtc: true);
      // Keep the local unsynced edit unless the server's is strictly newer.
      if (!remoteUpdated.isAfter(localUpdated)) return;
    }

    final cols = <String>['id'];
    final vals = <dynamic>[id];
    for (final c in spec.cols) {
      cols.add(c.name);
      vals.add(_toDb(c.kind, row[c.name]));
    }
    cols.addAll(['updated_at', 'deleted_at', 'sync_state', 'local_updated_at']);
    vals.add(_isoToTs(row['updated_at'] as String));
    vals.add(row['deleted_at'] == null
        ? null
        : _isoToTs(row['deleted_at'] as String));
    vals.add('synced');
    vals.add(DateTime.now().millisecondsSinceEpoch ~/ 1000);

    final placeholders = List.filled(cols.length, '?').join(', ');
    final updates =
        cols.where((c) => c != 'id').map((c) => '$c = excluded.$c').join(', ');
    await _db.customStatement(
      'INSERT INTO ${spec.client} (${cols.join(', ')}) VALUES ($placeholders) '
      'ON CONFLICT(id) DO UPDATE SET $updates',
      vals,
    );
  }

  // --- account binding (anonymous local account -> server user) ---

  /// On the first authenticated sync, re-key deterministic rows minted under the
  /// anonymous local account to the server user id, so the same day maps to the
  /// same id the server computes. Safe because nothing has synced yet. Runs once.
  ///
  /// Returns false — refusing the sync — when the CURRENT session belongs to a
  /// different server user than the one this device's data is bound to: pushing
  /// would upload user A's health data into user B's account and pulling would
  /// merge B's cloud data into A's local store. The switch must be resolved
  /// explicitly (keep-or-erase at sign-in) before sync resumes.
  Future<bool> _bindIfNeeded() async {
    // boundServerUserId is written by the sign-in flow before the first sync. A
    // session from a build predating that flow won't have it — self-heal by
    // asking the server who the token belongs to.
    var serverUserId = await SecureStore.read(SecureKeys.boundServerUserId);
    if (serverUserId == null || serverUserId.isEmpty) {
      final fetched = await _fetchAuthedUserId();
      if (fetched == null || fetched.isEmpty) return false;
      serverUserId = fetched;
      await SecureStore.write(SecureKeys.boundServerUserId, serverUserId);
      await SecureStore.write(SecureKeys.currentServerUserId, serverUserId);
    }
    final current = await SecureStore.read(SecureKeys.currentServerUserId);
    if (current != null && current.isNotEmpty && current != serverUserId) {
      debugLog('sync refused: signed-in user differs from bound user');
      return false;
    }
    // Re-key exactly once, tracked separately from boundServerUserId (which is
    // set at login, before this runs).
    if (await _meta('reKeyed') == 'true') return true;
    final localAccount =
        await _ref.read(accountServiceProvider).localAccountId();
    if (localAccount != serverUserId) {
      await _rekeyDeterministicIds(localAccount, serverUserId);
    }
    await _setMeta('reKeyed', 'true');
    return true;
  }

  Future<void> _rekeyDeterministicIds(String from, String to) async {
    await _db.transaction(() async {
      // food (id = v5(account, date))
      final foods =
          await _db.customSelect('SELECT id, date FROM food_metrics').get();
      for (final r in foods) {
        final date = r.data['date'] as String;
        await _reid('food_metrics', r.data['id'] as String,
            IdMinter.food(to, date));
      }
      // symptoms (id = v5(account, symptomsId, date))
      final syms = await _db
          .customSelect('SELECT id, symptoms_id, date FROM symptom_metrics')
          .get();
      for (final r in syms) {
        await _reid(
            'symptom_metrics',
            r.data['id'] as String,
            IdMinter.symptoms(
                to, r.data['symptoms_id'] as int, r.data['date'] as String));
      }
      // cycles (id = v5(account, startDate)) + fix cycle_days.cycle_id refs
      final cycles = await _db
          .customSelect('SELECT id, start_date FROM menstrual_cycles')
          .get();
      for (final r in cycles) {
        final oldId = r.data['id'] as String;
        final newId = IdMinter.cycle(to, r.data['start_date'] as String);
        await _db.customStatement(
            'UPDATE cycle_days SET cycle_id = ? WHERE cycle_id = ?',
            [newId, oldId]);
        await _reid('menstrual_cycles', oldId, newId);
      }
      // cycle days (id = v5(account, cycleId, date)) — after their parents, so
      // cycle_id already carries the new deterministic value.
      final days = await _db
          .customSelect('SELECT id, cycle_id, date FROM cycle_days')
          .get();
      for (final r in days) {
        await _reid(
            'cycle_days',
            r.data['id'] as String,
            IdMinter.cycleDay(to, r.data['cycle_id'] as String,
                r.data['date'] as String));
      }
      // settings (single row)
      await _reid('user_settings', IdMinter.settings(from),
          IdMinter.settings(to));
    });
    // From now on deterministic ids derive from the server user id.
  }

  /// Renames a row's id, merging when the target id already exists (a row for
  /// the same day was created under the new namespace during the binding
  /// window). The newer edit wins; the loser is dropped — without this, the
  /// UPDATE would hit a PK collision and abort the whole re-key transaction,
  /// permanently wedging binding.
  Future<void> _reid(String table, String oldId, String newId) async {
    if (oldId == newId) return;
    final clash = await _db.customSelect(
      'SELECT updated_at FROM $table WHERE id = ?1',
      variables: [Variable<String>(newId)],
    ).getSingleOrNull();
    if (clash != null) {
      final old = await _db.customSelect(
        'SELECT updated_at FROM $table WHERE id = ?1',
        variables: [Variable<String>(oldId)],
      ).getSingleOrNull();
      if (old == null) return;
      final oldTs = (old.data['updated_at'] as int?) ?? 0;
      final newTs = (clash.data['updated_at'] as int?) ?? 0;
      if (oldTs > newTs) {
        await _db.customStatement(
            'DELETE FROM $table WHERE id = ?', [newId]);
      } else {
        await _db.customStatement(
            'DELETE FROM $table WHERE id = ?', [oldId]);
        return;
      }
    }
    await _db.customStatement(
        'UPDATE $table SET id = ? WHERE id = ?', [newId, oldId]);
  }

  /// Asks the server who the current session token belongs to (used to self-heal
  /// a missing binding from a pre-binding build). Null when offline/unauthorized.
  Future<String?> _fetchAuthedUserId() async {
    try {
      final res = await _ref.read(dioProvider).get('users/profile');
      return (res.data?['user'] as Map?)?['id'] as String?;
    } catch (_) {
      return null;
    }
  }

  // --- SyncMeta helpers ---

  Future<String?> _meta(String key) async {
    final row = await (_db.select(_db.syncMeta)
          ..where((t) => t.key.equals(key)))
        .getSingleOrNull();
    return row?.value;
  }

  Future<void> _setMeta(String key, String value) async {
    await _db.into(_db.syncMeta).insertOnConflictUpdate(
        SyncMetaCompanion.insert(key: key, value: Value(value)));
  }

  // --- value (de)serialization: SQLite storage <-> sync JSON ---

  static dynamic _toJson(ColKind kind, dynamic dbVal) {
    switch (kind) {
      case ColKind.tags:
        return dbVal == null ? <String>[] : jsonDecode(dbVal as String);
      case ColKind.boolean:
        return (dbVal as int) == 1;
      case ColKind.timestamp:
        return _tsToIso(dbVal as int);
      default:
        return dbVal;
    }
  }

  static dynamic _toDb(ColKind kind, dynamic jsonVal) {
    switch (kind) {
      case ColKind.tags:
        return jsonEncode(jsonVal ?? const <String>[]);
      case ColKind.boolean:
        return (jsonVal == true) ? 1 : 0;
      case ColKind.timestamp:
        return _isoToTs(jsonVal as String);
      default:
        return jsonVal;
    }
  }

  static String _tsToIso(int seconds) =>
      DateTime.fromMillisecondsSinceEpoch(seconds * 1000, isUtc: true)
          .toIso8601String();

  static int _isoToTs(String iso) =>
      DateTime.parse(iso).toUtc().millisecondsSinceEpoch ~/ 1000;
}
