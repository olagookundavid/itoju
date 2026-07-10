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
  Future<String> localAccountId() async {
    if (_cachedLocal != null) return _cachedLocal!;
    var id = await SecureStore.read(SecureKeys.localAccountId);
    if (id == null || id.isEmpty) {
      id = _uuid.v4();
      await SecureStore.write(SecureKeys.localAccountId, id);
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
