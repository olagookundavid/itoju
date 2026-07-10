import 'package:flutter_test/flutter_test.dart';
import 'package:itoju_mobile/sync/sync_schedule.dart';

void main() {
  group('SyncSchedule.isDue', () {
    final now = DateTime(2026, 7, 10, 18, 0); // 6 PM

    test('off is never due', () {
      expect(SyncSchedule.isDue(now, null, SyncSchedule.off, 17), isFalse);
      expect(
          SyncSchedule.isDue(
              now, now.subtract(const Duration(days: 999)), SyncSchedule.off, 17),
          isFalse);
    });

    test('never-synced is always due (except off)', () {
      expect(SyncSchedule.isDue(now, null, SyncSchedule.daily, 17), isTrue);
      expect(SyncSchedule.isDue(now, null, SyncSchedule.weekly, 17), isTrue);
      expect(SyncSchedule.isDue(now, null, SyncSchedule.monthly, 17), isTrue);
    });

    group('daily (5 PM boundary)', () {
      test('after 5pm, not synced since today 5pm -> due', () {
        final last = DateTime(2026, 7, 10, 9, 0); // this morning
        expect(SyncSchedule.isDue(now, last, SyncSchedule.daily, 17), isTrue);
      });

      test('after 5pm, already synced after today 5pm -> not due', () {
        final last = DateTime(2026, 7, 10, 17, 30);
        expect(SyncSchedule.isDue(now, last, SyncSchedule.daily, 17), isFalse);
      });

      test('before 5pm, synced yesterday evening -> not due yet', () {
        final beforeFive = DateTime(2026, 7, 10, 10, 0);
        final last = DateTime(2026, 7, 9, 20, 0); // after yesterday 5pm
        expect(SyncSchedule.isDue(beforeFive, last, SyncSchedule.daily, 17),
            isFalse);
      });

      test('before 5pm, last sync before yesterday 5pm -> due', () {
        final beforeFive = DateTime(2026, 7, 10, 10, 0);
        final last = DateTime(2026, 7, 9, 8, 0); // before yesterday 5pm
        expect(SyncSchedule.isDue(beforeFive, last, SyncSchedule.daily, 17),
            isTrue);
      });
    });

    group('weekly / monthly', () {
      test('weekly due at >= 7 days', () {
        expect(
            SyncSchedule.isDue(now, now.subtract(const Duration(days: 6)),
                SyncSchedule.weekly, 17),
            isFalse);
        expect(
            SyncSchedule.isDue(now, now.subtract(const Duration(days: 7)),
                SyncSchedule.weekly, 17),
            isTrue);
      });

      test('monthly due at >= 30 days', () {
        expect(
            SyncSchedule.isDue(now, now.subtract(const Duration(days: 29)),
                SyncSchedule.monthly, 17),
            isFalse);
        expect(
            SyncSchedule.isDue(now, now.subtract(const Duration(days: 30)),
                SyncSchedule.monthly, 17),
            isTrue);
      });
    });
  });
}
