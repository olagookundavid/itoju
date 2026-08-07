import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../core/Storage/secure_store.dart';

/// Owns the device's account identity for offline-first.
///
/// On first launch it mints an anonymous local account id (UUIDv4). That id is
/// the namespace for deterministic (v5) row ids, so the same (account, table,
/// date) always maps to the same id. When cloud sync later binds this device to
/// a server user, [deterministicNamespaceId] switches to the server user id (and
/// the SyncEngine re-keys existing deterministic rows once, before first push).
class AccountService {
  AccountService();

  static const _uuid = Uuid();
  String? _cachedLocal;

  /// The anonymous local account id, minting and persisting it on first use.
  ///
  /// Hardened so a secure-storage failure can NEVER brick launch: on Android,
  /// `flutter_secure_storage` can throw when its encrypted prefs were restored
  /// by Auto-Backup but the matching Keystore key was not (the classic
  /// delete-and-reinstall decrypt failure). Since the app is offline-first, we
  /// recover in place — wipe the unreadable store and mint a fresh id — rather
  /// than letting the exception propagate and hang the app on its splash.
  Future<String> localAccountId() async {
    if (_cachedLocal != null) return _cachedLocal!;

    String? id;
    try {
      id = await SecureStore.read(SecureKeys.localAccountId);
    } catch (_) {
      // Store is unreadable (undecryptable after a reinstall). Best-effort
      // reset so subsequent reads/writes start clean; ignore if even that
      // fails — we still mint an in-memory id below so the app opens.
      id = null;
      try {
        await SecureStore.clearAll();
      } catch (_) {}
    }

    if (id == null || id.isEmpty) {
      id = _uuid.v4();
      try {
        await SecureStore.write(SecureKeys.localAccountId, id);
      } catch (_) {
        // Couldn't persist — use the in-memory id for this session so the app
        // is still fully usable offline; it re-mints on the next launch.
      }
    }
    _cachedLocal = id;
    return id;
  }

  /// The namespace used to derive deterministic ids: the bound server user id
  /// once sync is enabled, otherwise the local account id.
  Future<String> deterministicNamespaceId() async {
    final bound = await SecureStore.read(SecureKeys.boundServerUserId);
    if (bound != null && bound.isNotEmpty) return bound;
    return localAccountId();
  }

  Future<String?> boundServerUserId() =>
      SecureStore.read(SecureKeys.boundServerUserId);
}

final accountServiceProvider =
    Provider<AccountService>((ref) => AccountService());
