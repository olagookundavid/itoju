/// Medication-reminder rules and schedule maths. Pure Dart plus the `timezone`
/// package: no Flutter, no plugin, no database, so it is fully unit-testable.
library;

import 'package:timezone/timezone.dart' as tz;

/// A person can set up to this many reminder TIMES per medication per day.
const int kMaxReminderTimes = 6;

/// iOS keeps at most 64 pending local notifications per app, and every
/// (weekday x time) pair is one of them. Stay under it with a little room.
const int kMaxScheduledNotifications = 60;

const int kAllDays = 127; // Mon..Sun bitmask, Mon = 1 ... Sun = 64

/// Days are stored as a bitmask over ISO weekdays (DateTime.monday == 1).
class ReminderDays {
  ReminderDays._();

  static int bit(int weekday) => 1 << (weekday - 1);
  static bool has(int mask, int weekday) => mask & bit(weekday) != 0;
  static int toggle(int mask, int weekday) => mask ^ bit(weekday);
  static List<int> weekdays(int mask) =>
      [for (var d = 1; d <= 7; d++) if (has(mask, d)) d];

  static const _names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static String name(int weekday) => _names[weekday - 1];

  /// "Every day", "Weekdays", "Weekends", or "Mon, Wed, Fri".
  static String summary(int mask) {
    final m = mask & kAllDays;
    if (m == 0) return 'No days';
    if (m == kAllDays) return 'Every day';
    if (m == 31) return 'Weekdays';
    if (m == 96) return 'Weekends';
    return weekdays(m).map(name).join(', ');
  }
}

class MedReminderModel {
  final String? id;
  final String name;
  final int dosage;
  final String unit;
  final int quantity;
  final int days;
  final List<String> times; // 'HH:mm', 24 h
  final bool enabled;

  const MedReminderModel({
    required this.id,
    required this.name,
    this.dosage = 0,
    this.unit = 'mg',
    this.quantity = 1,
    this.days = kAllDays,
    this.times = const [],
    this.enabled = true,
  });

  MedReminderModel copyWith({
    String? id,
    String? name,
    int? dosage,
    String? unit,
    int? quantity,
    int? days,
    List<String>? times,
    bool? enabled,
  }) =>
      MedReminderModel(
        id: id ?? this.id,
        name: name ?? this.name,
        dosage: dosage ?? this.dosage,
        unit: unit ?? this.unit,
        quantity: quantity ?? this.quantity,
        days: days ?? this.days,
        times: times ?? this.times,
        enabled: enabled ?? this.enabled,
      );

  /// How many OS notifications this reminder needs when enabled.
  int get slotCount =>
      ReminderDays.weekdays(days).length * parsedTimes(times).length;
}

/// 'HH:mm' -> (hour, minute), or null if it is not a valid 24 h time.
({int hour, int minute})? parseHhmm(String s) {
  final m = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(s.trim());
  if (m == null) return null;
  final h = int.parse(m.group(1)!), min = int.parse(m.group(2)!);
  if (h > 23 || min > 59) return null;
  return (hour: h, minute: min);
}

String formatHhmm(int hour, int minute) =>
    '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

/// The distinct valid times, normalised to 'HH:mm' and sorted.
List<String> parsedTimes(List<String> times) {
  final out = <String>{};
  for (final t in times) {
    final p = parseHhmm(t);
    if (p != null) out.add(formatHhmm(p.hour, p.minute));
  }
  return out.toList()..sort();
}

/// A user-facing problem with [r], or null if it can be saved. [others] are the
/// person's OTHER live reminders (an edit passes everyone but itself), used to
/// keep the total number of scheduled notifications within the OS limit.
String? validateReminder(MedReminderModel r, {List<MedReminderModel> others = const []}) {
  if (r.name.trim().isEmpty) return 'Enter the name of the medication';
  if (r.days & kAllDays == 0) return 'Choose at least one day';
  if (r.times.isEmpty) return 'Add at least one reminder time';
  if (r.times.any((t) => parseHhmm(t) == null)) return 'One of the times is not valid';
  final unique = parsedTimes(r.times);
  if (unique.length > kMaxReminderTimes) {
    return 'You can set up to $kMaxReminderTimes times a day for one medication';
  }
  if (r.quantity < 1) return 'Quantity must be at least 1';
  if (r.dosage < 0) return 'Dosage cannot be negative';
  if (r.enabled) {
    final mine = ReminderDays.weekdays(r.days).length * unique.length;
    final rest = others.where((o) => o.enabled).fold<int>(0, (s, o) => s + o.slotCount);
    if (mine + rest > kMaxScheduledNotifications) {
      return 'That is more reminders than your phone can hold '
          '($kMaxScheduledNotifications at a time). Remove a time or a day, '
          'or turn another reminder off.';
    }
  }
  return null;
}

/// One weekly repeating notification.
class ReminderSlot {
  final String reminderId;
  final int weekday; // 1 = Monday .. 7 = Sunday
  final int hour;
  final int minute;
  const ReminderSlot(this.reminderId, this.weekday, this.hour, this.minute);

  @override
  bool operator ==(Object other) =>
      other is ReminderSlot &&
      other.reminderId == reminderId &&
      other.weekday == weekday &&
      other.hour == hour &&
      other.minute == minute;
  @override
  int get hashCode => Object.hash(reminderId, weekday, hour, minute);
  @override
  String toString() => 'Slot($reminderId, d$weekday ${formatHhmm(hour, minute)})';
}

/// Every notification that should exist: enabled reminders only, each valid time
/// on each chosen day, in a stable order (weekday, then time, then reminder id).
/// Capped at [kMaxScheduledNotifications] as a safety net; [validateReminder]
/// stops a person reaching the cap in the first place.
List<ReminderSlot> buildSlots(List<MedReminderModel> reminders,
    {int cap = kMaxScheduledNotifications}) {
  final slots = <ReminderSlot>[];
  for (final r in reminders) {
    final id = r.id;
    if (!r.enabled || id == null) continue;
    for (final t in parsedTimes(r.times)) {
      final p = parseHhmm(t)!;
      for (final d in ReminderDays.weekdays(r.days)) {
        slots.add(ReminderSlot(id, d, p.hour, p.minute));
      }
    }
  }
  slots.sort((a, b) {
    final c = a.weekday != b.weekday
        ? a.weekday.compareTo(b.weekday)
        : (a.hour * 60 + a.minute).compareTo(b.hour * 60 + b.minute);
    return c != 0 ? c : a.reminderId.compareTo(b.reminderId);
  });
  return slots.length > cap ? slots.sublist(0, cap) : slots;
}

/// The first instant strictly after [now] that falls on [weekday] at
/// [hour]:[minute] wall-clock time in [now]'s location. Built from calendar
/// fields (not by adding 24 h) so daylight-saving changes cannot shift the hour.
tz.TZDateTime nextWeekly(tz.TZDateTime now, int weekday, int hour, int minute) {
  var candidate = tz.TZDateTime(now.location, now.year, now.month, now.day, hour, minute);
  while (candidate.weekday != weekday || !candidate.isAfter(now)) {
    candidate = tz.TZDateTime(
        now.location, candidate.year, candidate.month, candidate.day + 1, hour, minute);
  }
  return candidate;
}

/// What the notification says. With [hideNames] it reveals nothing about the
/// person's health on a lock screen.
({String title, String body}) reminderTexts(MedReminderModel r, {bool hideNames = false}) {
  if (hideNames) {
    return (title: 'Medication reminder', body: 'Time to take your medication');
  }
  final parts = <String>[
    if (r.dosage > 0) '${r.dosage} ${r.unit}',
    if (r.quantity > 1) 'take ${r.quantity}',
  ];
  return (
    title: 'Time for ${r.name.trim()}',
    body: parts.isEmpty ? 'Time to take your medication' : parts.join(' · '),
  );
}

// --- Keeping the OS schedule in step without disturbing shown notifications ---
//
// Cancelling a notification id also removes that notification from the tray if it
// is currently shown. Rebuilding everything on every app launch/resume therefore
// wiped reminders the person hadn't acted on yet. Instead each slot gets a stable
// id derived from what it is, and only slots that actually changed are touched.

/// Payload carried by a scheduled notification: the reminder id first (what
/// "Mark as taken" needs), then what makes this slot distinct, including the
/// timezone it was scheduled in so a timezone change reschedules it.
String slotPayload(ReminderSlot s, String timezone) =>
    '${s.reminderId}|${s.weekday}|${formatHhmm(s.hour, s.minute)}|$timezone';

/// The reminder id from a notification payload, or null. Accepts the bare id
/// that early 1.2 builds used.
String? reminderIdFromPayload(String? payload) {
  if (payload == null || payload.isEmpty) return null;
  final id = payload.split('|').first;
  return id.isEmpty ? null : id;
}

int _fnv1a(String s) {
  var h = 0x811c9dc5;
  for (final c in s.codeUnits) {
    h ^= c;
    h = (h * 0x01000193) & 0xffffffff;
  }
  return h;
}

/// A notification id per slot, stable across runs (a hash of the slot), positive
/// and 31-bit as Android requires. Collisions — vanishingly rare with at most
/// [kMaxScheduledNotifications] slots — are resolved by probing upwards in the
/// slots' stable sort order, so the result is still deterministic.
Map<ReminderSlot, int> notificationIds(List<ReminderSlot> slots) {
  final used = <int>{};
  final out = <ReminderSlot, int>{};
  for (final s in slots) {
    var id = _fnv1a('${s.reminderId}|${s.weekday}|${formatHhmm(s.hour, s.minute)}') & 0x7fffffff;
    if (id == 0) id = 1;
    while (used.contains(id)) {
      id = (id + 1) & 0x7fffffff;
      if (id == 0) id = 1;
    }
    used.add(id);
    out[s] = id;
  }
  return out;
}

/// One notification as the OS should hold it.
class ScheduledNote {
  const ScheduledNote(this.id, this.title, this.body, this.payload);
  final int id;
  final String? title;
  final String? body;
  final String? payload;

  bool sameAs(ScheduledNote o) =>
      o.id == id && o.title == title && o.body == body && o.payload == payload;
}

/// What to change so the OS holds exactly [desired], given what it holds now
/// ([pending]): ids to cancel, and notes to (re)schedule. Untouched when equal.
({List<int> cancel, List<ScheduledNote> schedule}) planReschedule(
    List<ScheduledNote> desired, List<ScheduledNote> pending) {
  final want = {for (final d in desired) d.id: d};
  final have = {for (final p in pending) p.id: p};
  return (
    cancel: [for (final id in have.keys) if (!want.containsKey(id)) id],
    schedule: [
      for (final d in desired)
        if (!(have[d.id]?.sameAs(d) ?? false)) d
    ],
  );
}
