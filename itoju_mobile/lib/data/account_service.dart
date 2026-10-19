import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../core/Storage/secure_store.dart';
import 'db/app_database.dart';
import 'providers.dart';

/// Owns the device's account identity for offline-first.
///
/// On first launch it mints an anonymous local account id (UUIDv4). That id is
/// the namespace for deterministic (v5) row ids, so the same (account, table,
/// date) always maps to the same id. When cloud sync later binds this device to
/// a server user, [deterministicNamespaceId] switches to the server user id (and
/// the SyncEngine re-keys existing deterministic rows once, before first push).
///
/// Both ids live in secure storage AND are mirrored into the local database
/// (SyncMeta). The mirror matters on Android: a restore from backup brings back
/// the database but not the Keystore-bound secure storage, so without it the
/// phone would mint a new local id, every deterministic row id would change, and
/// the next entry for an existing day would duplicate it (and the "different
/// account signed in?" guard would see no binding at all). The ids are random
/// UUIDs, not secrets.
class AccountService {
  AccountService({AppDatabase? db}) : _db = db;

  static const _uuid = Uuid();
  static const _kLocal = 'localAccountId';
  static const _kBound = 'boundServerUserId';

  final AppDatabase? _db;
  String? _cachedLocal;

  // --- mirror helpers (best-effort: the database is optional and may be busy) ---

  Future<String?> _readMirror(String key) async {
    final db = _db;
    if (db == null) return null;
    try {
      final row = await (db.select(db.syncMeta)..where((t) => t.key.equals(key)))
          .getSingleOrNull();
      final v = row?.value;
      return (v == null || v.isEmpty) ? null : v;
    } catch (_) {
      return null;
    }
  }

  Future<void> _writeMirror(String key, String? value) async {
    final db = _db;
    if (db == null) return;
    try {
      if (value == null) {
        await (db.delete(db.syncMeta)..where((t) => t.key.equals(key))).go();
      } else {
        await db.into(db.syncMeta).insertOnConflictUpdate(
            SyncMetaCompanion.insert(key: key, value: Value(value)));
      }
    } catch (_) {
      // The mirror is a recovery aid; never let it break the app.
    }
  }

  Future<String?> _readSecure(String key) async {
    try {
      final v = await SecureStore.read(key);
      return (v == null || v.isEmpty) ? null : v;
    } catch (_) {
      return null;
    }
  }

  /// The anonymous local account id, minting and persisting it on first use.
  ///
  /// Order: secure storage, then the database mirror (a restored phone), and
  /// only then a brand-new id. Hardened so a secure-storage failure can NEVER
  /// brick launch: on Android, `flutter_secure_storage` can throw when its
  /// encrypted prefs were restored by Auto-Backup but the matching Keystore key
  /// was not. Since the app is offline-first we recover in place — wipe the
  /// unreadable store and carry on (re-seeding it from the mirror) — rather than
  /// letting the exception propagate and hang the app on its splash.
  Future<String> localAccountId() async {
    if (_cachedLocal != null) return _cachedLocal!;

    String? id;
    var secureBroken = false;
    try {
      final v = await SecureStore.read(SecureKeys.localAccountId);
      id = (v == null || v.isEmpty) ? null : v;
    } catch (_) {
      secureBroken = true;
      try {
        await SecureStore.clearAll();
      } catch (_) {}
    }

    if (id == null) {
      id = await _readMirror(_kLocal) ?? _uuid.v4();
      try {
        await SecureStore.write(SecureKeys.localAccountId, id);
      } catch (_) {
        // Couldn't persist to secure storage — the in-memory/mirrored id still
        // keeps this session (and, via the mirror, the next one) consistent.
      }
    }
    // Keep the mirror authoritative-enough to survive a restore.
    if (secureBroken || await _readMirror(_kLocal) != id) {
      await _writeMirror(_kLocal, id);
    }
    _cachedLocal = id;
    return id;
  }

  /// Server user id this device's data is bound to (secure storage first, then
  /// the database mirror), or null if cloud sync was never enabled.
  Future<String?> boundServerUserId() async {
    final secure = await _readSecure(SecureKeys.boundServerUserId);
    if (secure != null) return secure;
    final mirrored = await _readMirror(_kBound);
    if (mirrored != null) {
      // Restored phone: put it back so every reader agrees again.
      try {
        await SecureStore.write(SecureKeys.boundServerUserId, mirrored);
      } catch (_) {}
    }
    return mirrored;
  }

  /// Records the binding in both places.
  Future<void> setBoundServerUserId(String serverUserId) async {
    await SecureStore.write(SecureKeys.boundServerUserId, serverUserId);
    await _writeMirror(_kBound, serverUserId);
  }

  /// Forgets the local identity so the next [localAccountId] mints a fresh one
  /// (used when a different account takes over the device after an erase).
  Future<void> resetLocalIdentity() async {
    _cachedLocal = null;
    await SecureStore.write(SecureKeys.localAccountId, null);
    await _writeMirror(_kLocal, null);
  }

  /// The namespace used to derive deterministic ids: the bound server user id
  /// once sync is enabled, otherwise the local account id.
  Future<String> deterministicNamespaceId() async {
    final bound = await boundServerUserId();
    if (bound != null) return bound;
    return localAccountId();
  }
}

final accountServiceProvider = Provider<AccountService>(
    (ref) => AccountService(db: ref.watch(appDatabaseProvider)));
