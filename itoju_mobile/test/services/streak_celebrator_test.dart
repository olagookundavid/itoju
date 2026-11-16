import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itoju_mobile/data/db/app_database.dart';
import 'package:itoju_mobile/data/models/medication_model.dart';
import 'package:itoju_mobile/data/repositories/medication_repository.dart';
import 'package:itoju_mobile/data/streak_messages.dart';
import 'package:itoju_mobile/services/streak_celebrator.dart';

Future<void> settle() => Future<void>.delayed(const Duration(milliseconds: 80));

String iso(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

void main() {
  group('the words', () {
    test('nothing for a streak that is not one yet', () {
      expect(streakMessage(0), isNull);
      expect(streakMessage(1), isNull);
    });

    test('everyday streaks say the number, with no template left over', () {
      for (var n = 2; n <= 400; n++) {
        if (kStreakMilestones.contains(n)) continue;
        final m = streakMessage(n)!;
        expect('${m.title} ${m.body}', contains('$n'), reason: 'streak $n');
        expect('${m.title}${m.body}', isNot(contains('{n}')));
        expect(m.title.length, lessThanOrEqualTo(30));
        expect(m.body.length, lessThanOrEqualTo(90));
      }
    });

    test('milestones get their own message', () {
      for (final n in kStreakMilestones) {
        final m = streakMessage(n)!;
        expect('${m.title} ${m.body}', contains(RegExp('$n|week|year|Two')),
            reason: 'streak $n');
      }
      expect(streakMessage(7)!.title, 'A full week!');
      expect(streakMessage(30)!.title, '30 days!');
    });

    test('consecutive days don\'t read the same', () {
      final week = {for (var n = 3; n < 7; n++) streakMessage(n)!.body};
      expect(week.length, greaterThan(1));
    });
  });

  group('the celebration', () {
    late AppDatabase db;
    late StreakCelebrator celebrator;
    late List<(String, String)> shown;
    String? celebrated;
    var foreground = true;
    var now = DateTime.now();

    Future<void> logMed(DateTime day) => MedicationRepository(db).create(
        iso(day),
        MedicationModel(
            id: null, time: '', metric: 'mg', name: 'Iron', dosage: 65, quantity: 1));

    DateTime daysAgo(int n) => DateTime(now.year, now.month, now.day - n);

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      shown = [];
      celebrated = null;
      foreground = true;
      now = DateTime.now();
      celebrator = StreakCelebrator(
        db: db,
        show: (t, b) => shown.add((t, b)),
        celebratedOn: () => celebrated,
        markCelebrated: (d) => celebrated = d,
        isForeground: () => foreground,
        now: () => now,
      );
    });
    tearDown(() async {
      celebrator.dispose();
      await db.close();
    });

    test('the first log of the day says the streak, counting today', () async {
      await logMed(daysAgo(2));
      await logMed(daysAgo(1));
      await celebrator.start();
      await settle();
      expect(shown, isEmpty, reason: 'nothing logged today yet');

      await logMed(now);
      await settle();
      expect(shown, hasLength(1));
      final (title, body) = shown.single;
      expect('$title $body', contains('3'));
      expect(celebrated, iso(now));
    });

    test('later logs the same day say nothing more', () async {
      await logMed(daysAgo(1));
      await celebrator.start();
      await logMed(now);
      await settle();
      expect(shown, hasLength(1));

      await logMed(now);
      await logMed(now);
      await settle();
      expect(shown, hasLength(1));
    });

    test('deleting the entry and logging again does not repeat it', () async {
      await logMed(daysAgo(1));
      await celebrator.start();
      await logMed(now);
      await settle();
      final row = (await MedicationRepository(db).getForDate(iso(now))).single;
      await MedicationRepository(db).delete(row.id!);
      await settle();
      await logMed(now);
      await settle();
      expect(shown, hasLength(1));
    });

    test('what was logged before the app opened is not celebrated', () async {
      await logMed(daysAgo(1));
      await logMed(now);
      await celebrator.start();
      await settle();
      expect(shown, isEmpty);
    });

    test('a streak of one is not mentioned, but a later day\'s is', () async {
      await celebrator.start();
      await logMed(now); // day 1 of a streak
      await settle();
      expect(shown, isEmpty);

      // The next day, still with the app open (midnight passes).
      now = DateTime(now.year, now.month, now.day + 1, 9);
      await logMed(now);
      await settle();
      expect(shown, hasLength(1));
      expect('${shown.single.$1} ${shown.single.$2}', contains('2'));
    });

    test('a break resets the count', () async {
      await logMed(daysAgo(5));
      await logMed(daysAgo(4));
      await logMed(daysAgo(3)); // then nothing for two days
      await celebrator.start();
      await logMed(now);
      await settle();
      expect(shown, isEmpty, reason: 'back to a streak of one');
    });

    test('nothing is shown while the app is in the background', () async {
      await logMed(daysAgo(1));
      await celebrator.start();
      foreground = false;
      await logMed(now); // e.g. "Mark as taken" from a notification
      await settle();
      expect(shown, isEmpty);
      expect(celebrated, isNull, reason: 'still owed when they come back');

      foreground = true;
      await celebrator.check(); // the app resumes
      expect(shown, hasLength(1));
    });

    test('a toast for today is not repeated after a restart', () async {
      await logMed(daysAgo(1));
      celebrated = iso(now); // shown earlier today, then the app was killed
      await celebrator.start();
      await celebrator.check();
      await logMed(now);
      await settle();
      expect(shown, isEmpty);
    });

    test('a mood on its own counts as the first log', () async {
      await logMed(daysAgo(1));
      await celebrator.start();
      await db.into(db.smileyEntries).insert(SmileyEntriesCompanion.insert(
          id: 's1', localUpdatedAt: now, smileyId: 4, grantedAt: now));
      await settle();
      // The streak itself only counts the eight trackers, as on Home.
      expect(shown, isEmpty, reason: 'a streak of one through yesterday');
      expect(celebrated, iso(now));
    });
  });
}
