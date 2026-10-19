import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itoju_mobile/data/account_service.dart';
import 'package:itoju_mobile/data/db/app_database.dart';
import 'package:itoju_mobile/data/providers.dart';
import 'package:itoju_mobile/data/repositories/menses_repository.dart';
import 'package:itoju_mobile/features/menses/notifiers/menses_notifier.dart';

class _Acct extends AccountService {
  @override
  Future<String> deterministicNamespaceId() async => 'acct';
  @override
  Future<String> localAccountId() async => 'acct';
}

/// Two cycles can overlap (a period logged early). The calendar keeps ONE day per
/// date; which one used to depend on row order. It should show the most
/// informative day: a period day beats a plain one, and anything the user has
/// actually logged (flow, pain, notes, tags) beats an empty generated day.
void main() {
  late AppDatabase db;
  late ProviderContainer container;
  late MensesRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    container = ProviderContainer(overrides: [
      appDatabaseProvider.overrideWithValue(db),
      accountServiceProvider.overrideWithValue(_Acct()),
    ]);
    repo = container.read(mensesRepositoryProvider);
  });
  tearDown(() {
    container.dispose();
    db.close();
  });

  Future<PeriodModel> shownOn(String date) async {
    await container.read(periodProvider.notifier).loadRange('2026-05-01', '2026-05-31');
    return container.read(periodProvider).period![date]!.single;
  }

  test('a period day beats a plain day when cycles overlap', () async {
    await repo.createCycle('2026-05-01', 28, 5); // 05-06 is a regular day here
    await repo.createCycle('2026-05-04', 28, 5); // 05-06 is a period day here
    // try both insertion orders by loading repeatedly
    for (var i = 0; i < 5; i++) {
      final day = await shownOn('2026-05-06');
      expect(day.isPeriod, isTrue);
    }
  });

  test('a day the user logged beats an empty generated one', () async {
    await repo.createCycle('2026-05-01', 28, 5);
    await repo.createCycle('2026-05-20', 28, 5);
    // 05-22 is a period day in the second cycle; log notes on the FIRST cycle's
    // (plain) 05-22 and make the second one's an empty period day.
    final days = await db.select(db.cycleDays).get();
    final firstCycleDay = days.firstWhere(
        (d) => d.date == '2026-05-22' && !d.isPeriod); // from cycle 1
    await (db.update(db.cycleDays)..where((t) => t.id.equals(firstCycleDay.id)))
        .write(const CycleDaysCompanion(cmq: Value('cramps, rested')));
    final day = await shownOn('2026-05-22');
    expect(day.cmq, 'cramps, rested',
        reason: 'user-entered data must not be hidden by an empty overlap');
  });
}
