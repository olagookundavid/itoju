import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itoju_mobile/core/Storage/secure_store.dart';
import 'package:itoju_mobile/data/account_service.dart';
import 'package:itoju_mobile/data/db/app_database.dart';

/// Android restores the app's database and prefs from backup but NOT the
/// secure-storage keys (they're bound to a Keystore key). Without a mirror, a
/// restored phone mints a brand-new local account id, so every deterministic row
/// id changes and the next entry for an existing day duplicates it. These tests
/// pin the mirror-in-the-database behaviour that prevents that.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    db = AppDatabase(NativeDatabase.memory());
  });
  tearDown(() => db.close());

  Future<String?> meta(String key) async => (await (db.select(db.syncMeta)
            ..where((t) => t.key.equals(key)))
          .getSingleOrNull())
      ?.value;

  test('a freshly minted local id is stored in both places', () async {
    final svc = AccountService(db: db);
    final id = await svc.localAccountId();
    expect(id, isNotEmpty);
    expect(await SecureStore.read(SecureKeys.localAccountId), id);
    expect(await meta('localAccountId'), id);
  });

  test('restore: database has the id, secure storage is empty -> same id',
      () async {
    await db.into(db.syncMeta).insertOnConflictUpdate(SyncMetaCompanion.insert(
        key: 'localAccountId', value: const Value('restored-local-id')));
    // fresh instance (no in-memory cache), empty secure store = restored phone
    final id = await AccountService(db: db).localAccountId();
    expect(id, 'restored-local-id');
    expect(await SecureStore.read(SecureKeys.localAccountId), 'restored-local-id',
        reason: 'secure storage is re-seeded so both agree again');
  });

  test('upgrade: secure storage has the id, database does not -> mirrored',
      () async {
    await SecureStore.write(SecureKeys.localAccountId, 'legacy-id');
    final id = await AccountService(db: db).localAccountId();
    expect(id, 'legacy-id');
    expect(await meta('localAccountId'), 'legacy-id');
  });

  test('restore keeps the sync binding, so ids stay in the server namespace',
      () async {
    await db.into(db.syncMeta).insertOnConflictUpdate(SyncMetaCompanion.insert(
        key: 'boundServerUserId', value: const Value('server-user-1')));
    final svc = AccountService(db: db);
    expect(await svc.boundServerUserId(), 'server-user-1');
    expect(await svc.deterministicNamespaceId(), 'server-user-1');
  });

  test('binding is written to both places', () async {
    final svc = AccountService(db: db);
    await svc.setBoundServerUserId('server-user-2');
    expect(await SecureStore.read(SecureKeys.boundServerUserId), 'server-user-2');
    expect(await meta('boundServerUserId'), 'server-user-2');
    expect(await svc.deterministicNamespaceId(), 'server-user-2');
  });

  test('before any binding the namespace is the local id', () async {
    final svc = AccountService(db: db);
    expect(await svc.boundServerUserId(), isNull);
    expect(await svc.deterministicNamespaceId(), await svc.localAccountId());
  });

  test('resetLocalIdentity gives a new local id and forgets the old one',
      () async {
    final svc = AccountService(db: db);
    final first = await svc.localAccountId();
    await svc.resetLocalIdentity();
    final second = await svc.localAccountId();
    expect(second, isNot(first));
    expect(await meta('localAccountId'), second);
  });

  test('works without a database (early startup / tests)', () async {
    final id = await AccountService().localAccountId();
    expect(id, isNotEmpty);
  });
}
