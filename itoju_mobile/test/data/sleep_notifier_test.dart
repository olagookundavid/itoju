import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itoju_mobile/data/db/app_database.dart';
import 'package:itoju_mobile/data/repositories/sleep_repository.dart';
import 'package:itoju_mobile/features/metrics/notifiers/sleep_notifier.dart';

void main() {
  late AppDatabase db;
  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  test('editing a sleep entry saves it (it used to fail every time)', () async {
    final container = ProviderContainer(overrides: [
      sleepRepositoryProvider.overrideWithValue(SleepRepository(db)),
    ]);
    addTearDown(container.dispose);
    final notifier = container.read(sleepProvider.notifier);
    await notifier.createSleepMetric(
        '2026-11-05',
        SleepModel(
            id: null,
            timeSlept: '9:00 PM',
            timeWokeUp: '6:00 AM',
            tags: const [],
            severity: 0.5,
            isNight: true));
    final saved = (await SleepRepository(db).getForDate('2026-11-05')).single;

    // The sleep card passes the row id separately and the model without one.
    final res = await notifier.updateSleepMetric(
        saved.id!,
        SleepModel(
            id: null,
            timeSlept: '10:00 PM',
            timeWokeUp: '6:30 AM',
            tags: const ['Early bedtime'],
            severity: 1,
            isNight: true));

    expect(res.successMessage, isNotEmpty);
    final after = (await SleepRepository(db).getForDate('2026-11-05')).single;
    expect(after.timeSlept, '10:00 PM');
    expect(after.timeWokeUp, '6:30 AM');
    expect(after.tags, ['Early bedtime']);
  });
}
