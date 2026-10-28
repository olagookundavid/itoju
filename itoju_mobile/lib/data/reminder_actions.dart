import 'package:intl/intl.dart';

import 'db/app_database.dart';
import 'models/medication_model.dart';
import 'repositories/medication_repository.dart';
import 'repositories/reminder_repository.dart';

/// What happens when someone taps "Mark as taken" on a reminder notification: a
/// normal medication entry for today (with its points) is logged from the
/// reminder's medication, dose and quantity. Takes the database directly so it
/// runs the same in the app and in the notification's background isolate.
class ReminderActions {
  ReminderActions._();

  /// Returns false when the reminder no longer exists (deleted on another
  /// device since the notification was scheduled), so nothing is logged.
  static Future<bool> markTaken(AppDatabase db, String reminderId,
      {DateTime? now}) async {
    final reminder = await ReminderRepository(db).getById(reminderId);
    if (reminder == null) return false;
    final at = now ?? DateTime.now();
    await MedicationRepository(db).create(
      DateFormat('yyyy-MM-dd').format(at),
      MedicationModel(
        id: null,
        name: reminder.name,
        dosage: reminder.dosage,
        metric: reminder.unit,
        quantity: reminder.quantity,
        time: DateFormat.jm().format(at),
      ),
    );
    return true;
  }
}
