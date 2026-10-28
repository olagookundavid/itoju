import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:itoju_mobile/data/reminder_schedule.dart';
import 'package:itoju_mobile/data/repositories/reminder_repository.dart';

export 'package:itoju_mobile/data/reminder_schedule.dart' show MedReminderModel;

/// Live list of the person's medication reminders.
final remindersProvider = StreamProvider.autoDispose<List<MedReminderModel>>(
  (ref) => ref.watch(reminderRepositoryProvider).watchAll(),
);
