import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'db/app_database.dart';

/// Single app-wide Drift database. Repositories read/write only through this;
/// notifiers depend on repositories, never on Dio, for local data. Each
/// repository declares its own provider (in its file) on top of this one.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});
