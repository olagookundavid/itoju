import 'package:drift/drift.dart';
import 'converters.dart';

/// Columns every syncable table carries. `id` is a client-minted UUID (v5 for
/// one-per-day tables, v7 for list tables — see IdMinter). `updatedAt` is the
/// LWW comparator (server-authoritative after a sync ack); `deletedAt` is the
/// tombstone; `syncState` is pending|synced; `localUpdatedAt` is the local edit
/// time used to find dirty rows to push.
mixin SyncColumns on Table {
  TextColumn get id => text()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  TextColumn get syncState => text().withDefault(const Constant('pending'))();
  DateTimeColumn get localUpdatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

// Dates are stored as ISO 'yyyy-MM-dd' text to match the app's pervasive string
// dates and the deterministic-id recipe.

class SymptomMetrics extends Table with SyncColumns {
  IntColumn get symptomsId => integer()();
  TextColumn get date => text()();
  RealColumn get morningSeverity => real().withDefault(const Constant(0))();
  RealColumn get afternoonSeverity => real().withDefault(const Constant(0))();
  RealColumn get nightSeverity => real().withDefault(const Constant(0))();
}

class FoodMetrics extends Table with SyncColumns {
  TextColumn get date => text()();
  TextColumn get breakfastMeal => text().withDefault(const Constant(''))();
  TextColumn get lunchMeal => text().withDefault(const Constant(''))();
  TextColumn get dinnerMeal => text().withDefault(const Constant(''))();
  TextColumn get breakfastExtra => text().withDefault(const Constant(''))();
  TextColumn get lunchExtra => text().withDefault(const Constant(''))();
  TextColumn get dinnerExtra => text().withDefault(const Constant(''))();
  TextColumn get breakfastFruit => text().withDefault(const Constant(''))();
  TextColumn get lunchFruit => text().withDefault(const Constant(''))();
  TextColumn get dinnerFruit => text().withDefault(const Constant(''))();
  TextColumn get breakfastTags =>
      text().map(const StringListConverter()).withDefault(const Constant('[]'))();
  TextColumn get lunchTags =>
      text().map(const StringListConverter()).withDefault(const Constant('[]'))();
  TextColumn get dinnerTags =>
      text().map(const StringListConverter()).withDefault(const Constant('[]'))();
  TextColumn get snackName => text().withDefault(const Constant(''))();
  TextColumn get snackTags =>
      text().map(const StringListConverter()).withDefault(const Constant('[]'))();
  IntColumn get glassNo => integer().withDefault(const Constant(0))();
}

class SleepMetrics extends Table with SyncColumns {
  TextColumn get date => text()();
  BoolColumn get isNight => boolean()();
  TextColumn get timeSlept => text().withDefault(const Constant(''))();
  TextColumn get timeWokeUp => text().withDefault(const Constant(''))();
  TextColumn get tags =>
      text().map(const StringListConverter()).withDefault(const Constant('[]'))();
  RealColumn get severity => real().withDefault(const Constant(0))();
}

class MedicationMetrics extends Table with SyncColumns {
  TextColumn get date => text()();
  TextColumn get name => text().withDefault(const Constant(''))();
  IntColumn get dosage => integer().withDefault(const Constant(0))();
  TextColumn get metric => text().withDefault(const Constant(''))();
  IntColumn get quantity => integer().withDefault(const Constant(0))();
  TextColumn get time => text().withDefault(const Constant(''))();
}

class ExerciseMetrics extends Table with SyncColumns {
  TextColumn get date => text()();
  TextColumn get name => text().withDefault(const Constant(''))();
  TextColumn get started => text().withDefault(const Constant(''))();
  TextColumn get ended => text().withDefault(const Constant(''))();
  TextColumn get tags =>
      text().map(const StringListConverter()).withDefault(const Constant('[]'))();
  IntColumn get noOfTimes => integer().withDefault(const Constant(0))();
}

class UrineMetrics extends Table with SyncColumns {
  TextColumn get date => text()();
  IntColumn get type => integer().withDefault(const Constant(0))();
  RealColumn get pain => real().withDefault(const Constant(0))();
  TextColumn get time => text().withDefault(const Constant(''))();
  TextColumn get tags =>
      text().map(const StringListConverter()).withDefault(const Constant('[]'))();
  RealColumn get quantity => real().withDefault(const Constant(0))();
}

class BowelMetrics extends Table with SyncColumns {
  TextColumn get date => text()();
  IntColumn get type => integer().withDefault(const Constant(0))();
  RealColumn get pain => real().withDefault(const Constant(0))();
  TextColumn get time => text().withDefault(const Constant(''))();
  TextColumn get tags =>
      text().map(const StringListConverter()).withDefault(const Constant('[]'))();
}

class MenstrualCycles extends Table with SyncColumns {
  TextColumn get startDate => text()();
  IntColumn get cycleLength => integer().withDefault(const Constant(28))();
  IntColumn get periodLength => integer().withDefault(const Constant(5))();
}

class CycleDays extends Table with SyncColumns {
  TextColumn get cycleId => text()();
  TextColumn get date => text()();
  BoolColumn get isPeriod => boolean().withDefault(const Constant(false))();
  BoolColumn get isOvulation => boolean().withDefault(const Constant(false))();
  RealColumn get flow => real().withDefault(const Constant(0))();
  RealColumn get pain => real().withDefault(const Constant(0))();
  TextColumn get tags =>
      text().map(const StringListConverter()).withDefault(const Constant('[]'))();
  TextColumn get cmq => text().withDefault(const Constant(''))();
}

class SmileyEntries extends Table with SyncColumns {
  IntColumn get smileyId => integer()();
  TextColumn get tags =>
      text().map(const StringListConverter()).withDefault(const Constant('[]'))();
  DateTimeColumn get grantedAt => dateTime()();
}

class PointRecords extends Table with SyncColumns {
  IntColumn get point => integer()();
  TextColumn get scope => text()();
  TextColumn get date => text()();
}

class UserTrackedMetrics extends Table with SyncColumns {
  IntColumn get metricId => integer()();
  DateTimeColumn get grantedAt => dateTime()();
}

class UserConditions extends Table with SyncColumns {
  IntColumn get conditionId => integer()();
}

/// Single-row settings (period/cycle length, body measurements). id is a fixed
/// deterministic value so there is exactly one row per account.
class UserSettings extends Table with SyncColumns {
  IntColumn get periodLen => integer().withDefault(const Constant(0))();
  IntColumn get cycleLen => integer().withDefault(const Constant(0))();
  IntColumn get height => integer().withDefault(const Constant(0))();
  IntColumn get weight => integer().withDefault(const Constant(0))();
}

// --- Seeded catalogs (NOT synced; ids match the server SERIAL catalog ids) ---

class Symptoms extends Table {
  IntColumn get id => integer()();
  TextColumn get name => text()();
  @override
  Set<Column> get primaryKey => {id};
}

class TrackedMetricsCatalog extends Table {
  IntColumn get id => integer()();
  TextColumn get name => text()();
  @override
  Set<Column> get primaryKey => {id};
}

class SmileyCatalog extends Table {
  IntColumn get id => integer()();
  TextColumn get name => text()();
  @override
  Set<Column> get primaryKey => {id};
}

class Conditions extends Table {
  IntColumn get id => integer()();
  TextColumn get name => text()();
  @override
  Set<Column> get primaryKey => {id};
}

/// Key/value bag for sync bookkeeping (pull watermark, last push time, bound
/// server user id, catalog seed version). NOT synced.
class SyncMeta extends Table {
  TextColumn get key => text()();
  TextColumn get value => text().nullable()();
  @override
  Set<Column> get primaryKey => {key};
}
