import 'package:drift/drift.dart' show OrderingTerm;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itoju_mobile/data/account_service.dart';
import 'package:itoju_mobile/data/cycle_math.dart';
import 'package:itoju_mobile/data/db/app_database.dart';
import 'package:itoju_mobile/data/repositories/menses_repository.dart';

class _Acct extends AccountService {
  @override
  Future<String> localAccountId() async => 'acct';
  @override
  Future<String> deterministicNamespaceId() async => 'acct';
}

void main() {
  // Same table as the backend's ovulation_test.go — the two must agree, since
  // both generate day rows for the same cycles.
  const vectors = [
    // cycle, period, start, end, ok
    (28, 5, 8, 13, true),
    (21, 5, 5, 6, true),
    (35, 5, 15, 20, true),
    (30, 7, 10, 15, true),
    (18, 5, 5, 5, true),
    (28, 10, 10, 13, true),
    (5, 5, 0, 0, false),
  ];

  test('ovulationWindow matches the backend vectors', () {
    for (final v in vectors) {
      final w = ovulationWindow(v.$2, v.$1);
      if (!v.$5) {
        expect(w, isNull, reason: 'cycle=${v.$1} period=${v.$2}');
      } else {
        expect(w, isNotNull, reason: 'cycle=${v.$1} period=${v.$2}');
        expect((w!.start, w.end), (v.$3, v.$4),
            reason: 'cycle=${v.$1} period=${v.$2}');
      }
    }
  });

  test('a created 28/5 cycle marks a 6-day fertile window, not half the cycle',
      () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = MensesRepository(db, _Acct());
    expect(await repo.createCycle('2026-05-01', 28, 5), isTrue);
    final days = await (db.select(db.cycleDays)
          ..orderBy([(t) => OrderingTerm(expression: t.date)]))
        .get();
    expect(days.length, 28);
    final period = [for (var i = 0; i < 28; i++) if (days[i].isPeriod) i];
    final fertile = [for (var i = 0; i < 28; i++) if (days[i].isOvulation) i];
    expect(period, [0, 1, 2, 3, 4]);
    expect(fertile, [8, 9, 10, 11, 12, 13]);
    expect(days.any((d) => d.isPeriod && d.isOvulation), isFalse);
  });
}
