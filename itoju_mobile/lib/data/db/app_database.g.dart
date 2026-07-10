// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $SymptomMetricsTable extends SymptomMetrics
    with TableInfo<$SymptomMetricsTable, SymptomMetric> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SymptomMetricsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _syncStateMeta =
      const VerificationMeta('syncState');
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
      'sync_state', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _localUpdatedAtMeta =
      const VerificationMeta('localUpdatedAt');
  @override
  late final GeneratedColumn<DateTime> localUpdatedAt =
      GeneratedColumn<DateTime>('local_updated_at', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _symptomsIdMeta =
      const VerificationMeta('symptomsId');
  @override
  late final GeneratedColumn<int> symptomsId = GeneratedColumn<int>(
      'symptoms_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
      'date', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _morningSeverityMeta =
      const VerificationMeta('morningSeverity');
  @override
  late final GeneratedColumn<double> morningSeverity = GeneratedColumn<double>(
      'morning_severity', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _afternoonSeverityMeta =
      const VerificationMeta('afternoonSeverity');
  @override
  late final GeneratedColumn<double> afternoonSeverity =
      GeneratedColumn<double>('afternoon_severity', aliasedName, false,
          type: DriftSqlType.double,
          requiredDuringInsert: false,
          defaultValue: const Constant(0));
  static const VerificationMeta _nightSeverityMeta =
      const VerificationMeta('nightSeverity');
  @override
  late final GeneratedColumn<double> nightSeverity = GeneratedColumn<double>(
      'night_severity', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        updatedAt,
        deletedAt,
        syncState,
        localUpdatedAt,
        symptomsId,
        date,
        morningSeverity,
        afternoonSeverity,
        nightSeverity
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'symptom_metrics';
  @override
  VerificationContext validateIntegrity(Insertable<SymptomMetric> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    if (data.containsKey('sync_state')) {
      context.handle(_syncStateMeta,
          syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta));
    }
    if (data.containsKey('local_updated_at')) {
      context.handle(
          _localUpdatedAtMeta,
          localUpdatedAt.isAcceptableOrUnknown(
              data['local_updated_at']!, _localUpdatedAtMeta));
    } else if (isInserting) {
      context.missing(_localUpdatedAtMeta);
    }
    if (data.containsKey('symptoms_id')) {
      context.handle(
          _symptomsIdMeta,
          symptomsId.isAcceptableOrUnknown(
              data['symptoms_id']!, _symptomsIdMeta));
    } else if (isInserting) {
      context.missing(_symptomsIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('morning_severity')) {
      context.handle(
          _morningSeverityMeta,
          morningSeverity.isAcceptableOrUnknown(
              data['morning_severity']!, _morningSeverityMeta));
    }
    if (data.containsKey('afternoon_severity')) {
      context.handle(
          _afternoonSeverityMeta,
          afternoonSeverity.isAcceptableOrUnknown(
              data['afternoon_severity']!, _afternoonSeverityMeta));
    }
    if (data.containsKey('night_severity')) {
      context.handle(
          _nightSeverityMeta,
          nightSeverity.isAcceptableOrUnknown(
              data['night_severity']!, _nightSeverityMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SymptomMetric map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SymptomMetric(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at']),
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
      syncState: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_state'])!,
      localUpdatedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}local_updated_at'])!,
      symptomsId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}symptoms_id'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}date'])!,
      morningSeverity: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}morning_severity'])!,
      afternoonSeverity: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}afternoon_severity'])!,
      nightSeverity: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}night_severity'])!,
    );
  }

  @override
  $SymptomMetricsTable createAlias(String alias) {
    return $SymptomMetricsTable(attachedDatabase, alias);
  }
}

class SymptomMetric extends DataClass implements Insertable<SymptomMetric> {
  final String id;
  final DateTime? updatedAt;
  final DateTime? deletedAt;
  final String syncState;
  final DateTime localUpdatedAt;
  final int symptomsId;
  final String date;
  final double morningSeverity;
  final double afternoonSeverity;
  final double nightSeverity;
  const SymptomMetric(
      {required this.id,
      this.updatedAt,
      this.deletedAt,
      required this.syncState,
      required this.localUpdatedAt,
      required this.symptomsId,
      required this.date,
      required this.morningSeverity,
      required this.afternoonSeverity,
      required this.nightSeverity});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['sync_state'] = Variable<String>(syncState);
    map['local_updated_at'] = Variable<DateTime>(localUpdatedAt);
    map['symptoms_id'] = Variable<int>(symptomsId);
    map['date'] = Variable<String>(date);
    map['morning_severity'] = Variable<double>(morningSeverity);
    map['afternoon_severity'] = Variable<double>(afternoonSeverity);
    map['night_severity'] = Variable<double>(nightSeverity);
    return map;
  }

  SymptomMetricsCompanion toCompanion(bool nullToAbsent) {
    return SymptomMetricsCompanion(
      id: Value(id),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncState: Value(syncState),
      localUpdatedAt: Value(localUpdatedAt),
      symptomsId: Value(symptomsId),
      date: Value(date),
      morningSeverity: Value(morningSeverity),
      afternoonSeverity: Value(afternoonSeverity),
      nightSeverity: Value(nightSeverity),
    );
  }

  factory SymptomMetric.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SymptomMetric(
      id: serializer.fromJson<String>(json['id']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      syncState: serializer.fromJson<String>(json['syncState']),
      localUpdatedAt: serializer.fromJson<DateTime>(json['localUpdatedAt']),
      symptomsId: serializer.fromJson<int>(json['symptomsId']),
      date: serializer.fromJson<String>(json['date']),
      morningSeverity: serializer.fromJson<double>(json['morningSeverity']),
      afternoonSeverity: serializer.fromJson<double>(json['afternoonSeverity']),
      nightSeverity: serializer.fromJson<double>(json['nightSeverity']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'syncState': serializer.toJson<String>(syncState),
      'localUpdatedAt': serializer.toJson<DateTime>(localUpdatedAt),
      'symptomsId': serializer.toJson<int>(symptomsId),
      'date': serializer.toJson<String>(date),
      'morningSeverity': serializer.toJson<double>(morningSeverity),
      'afternoonSeverity': serializer.toJson<double>(afternoonSeverity),
      'nightSeverity': serializer.toJson<double>(nightSeverity),
    };
  }

  SymptomMetric copyWith(
          {String? id,
          Value<DateTime?> updatedAt = const Value.absent(),
          Value<DateTime?> deletedAt = const Value.absent(),
          String? syncState,
          DateTime? localUpdatedAt,
          int? symptomsId,
          String? date,
          double? morningSeverity,
          double? afternoonSeverity,
          double? nightSeverity}) =>
      SymptomMetric(
        id: id ?? this.id,
        updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        syncState: syncState ?? this.syncState,
        localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
        symptomsId: symptomsId ?? this.symptomsId,
        date: date ?? this.date,
        morningSeverity: morningSeverity ?? this.morningSeverity,
        afternoonSeverity: afternoonSeverity ?? this.afternoonSeverity,
        nightSeverity: nightSeverity ?? this.nightSeverity,
      );
  SymptomMetric copyWithCompanion(SymptomMetricsCompanion data) {
    return SymptomMetric(
      id: data.id.present ? data.id.value : this.id,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
      localUpdatedAt: data.localUpdatedAt.present
          ? data.localUpdatedAt.value
          : this.localUpdatedAt,
      symptomsId:
          data.symptomsId.present ? data.symptomsId.value : this.symptomsId,
      date: data.date.present ? data.date.value : this.date,
      morningSeverity: data.morningSeverity.present
          ? data.morningSeverity.value
          : this.morningSeverity,
      afternoonSeverity: data.afternoonSeverity.present
          ? data.afternoonSeverity.value
          : this.afternoonSeverity,
      nightSeverity: data.nightSeverity.present
          ? data.nightSeverity.value
          : this.nightSeverity,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SymptomMetric(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncState: $syncState, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('symptomsId: $symptomsId, ')
          ..write('date: $date, ')
          ..write('morningSeverity: $morningSeverity, ')
          ..write('afternoonSeverity: $afternoonSeverity, ')
          ..write('nightSeverity: $nightSeverity')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      updatedAt,
      deletedAt,
      syncState,
      localUpdatedAt,
      symptomsId,
      date,
      morningSeverity,
      afternoonSeverity,
      nightSeverity);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SymptomMetric &&
          other.id == this.id &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.syncState == this.syncState &&
          other.localUpdatedAt == this.localUpdatedAt &&
          other.symptomsId == this.symptomsId &&
          other.date == this.date &&
          other.morningSeverity == this.morningSeverity &&
          other.afternoonSeverity == this.afternoonSeverity &&
          other.nightSeverity == this.nightSeverity);
}

class SymptomMetricsCompanion extends UpdateCompanion<SymptomMetric> {
  final Value<String> id;
  final Value<DateTime?> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> syncState;
  final Value<DateTime> localUpdatedAt;
  final Value<int> symptomsId;
  final Value<String> date;
  final Value<double> morningSeverity;
  final Value<double> afternoonSeverity;
  final Value<double> nightSeverity;
  final Value<int> rowid;
  const SymptomMetricsCompanion({
    this.id = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    this.localUpdatedAt = const Value.absent(),
    this.symptomsId = const Value.absent(),
    this.date = const Value.absent(),
    this.morningSeverity = const Value.absent(),
    this.afternoonSeverity = const Value.absent(),
    this.nightSeverity = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SymptomMetricsCompanion.insert({
    required String id,
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    required DateTime localUpdatedAt,
    required int symptomsId,
    required String date,
    this.morningSeverity = const Value.absent(),
    this.afternoonSeverity = const Value.absent(),
    this.nightSeverity = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        localUpdatedAt = Value(localUpdatedAt),
        symptomsId = Value(symptomsId),
        date = Value(date);
  static Insertable<SymptomMetric> custom({
    Expression<String>? id,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? syncState,
    Expression<DateTime>? localUpdatedAt,
    Expression<int>? symptomsId,
    Expression<String>? date,
    Expression<double>? morningSeverity,
    Expression<double>? afternoonSeverity,
    Expression<double>? nightSeverity,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncState != null) 'sync_state': syncState,
      if (localUpdatedAt != null) 'local_updated_at': localUpdatedAt,
      if (symptomsId != null) 'symptoms_id': symptomsId,
      if (date != null) 'date': date,
      if (morningSeverity != null) 'morning_severity': morningSeverity,
      if (afternoonSeverity != null) 'afternoon_severity': afternoonSeverity,
      if (nightSeverity != null) 'night_severity': nightSeverity,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SymptomMetricsCompanion copyWith(
      {Value<String>? id,
      Value<DateTime?>? updatedAt,
      Value<DateTime?>? deletedAt,
      Value<String>? syncState,
      Value<DateTime>? localUpdatedAt,
      Value<int>? symptomsId,
      Value<String>? date,
      Value<double>? morningSeverity,
      Value<double>? afternoonSeverity,
      Value<double>? nightSeverity,
      Value<int>? rowid}) {
    return SymptomMetricsCompanion(
      id: id ?? this.id,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncState: syncState ?? this.syncState,
      localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
      symptomsId: symptomsId ?? this.symptomsId,
      date: date ?? this.date,
      morningSeverity: morningSeverity ?? this.morningSeverity,
      afternoonSeverity: afternoonSeverity ?? this.afternoonSeverity,
      nightSeverity: nightSeverity ?? this.nightSeverity,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(syncState.value);
    }
    if (localUpdatedAt.present) {
      map['local_updated_at'] = Variable<DateTime>(localUpdatedAt.value);
    }
    if (symptomsId.present) {
      map['symptoms_id'] = Variable<int>(symptomsId.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (morningSeverity.present) {
      map['morning_severity'] = Variable<double>(morningSeverity.value);
    }
    if (afternoonSeverity.present) {
      map['afternoon_severity'] = Variable<double>(afternoonSeverity.value);
    }
    if (nightSeverity.present) {
      map['night_severity'] = Variable<double>(nightSeverity.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SymptomMetricsCompanion(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncState: $syncState, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('symptomsId: $symptomsId, ')
          ..write('date: $date, ')
          ..write('morningSeverity: $morningSeverity, ')
          ..write('afternoonSeverity: $afternoonSeverity, ')
          ..write('nightSeverity: $nightSeverity, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FoodMetricsTable extends FoodMetrics
    with TableInfo<$FoodMetricsTable, FoodMetric> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FoodMetricsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _syncStateMeta =
      const VerificationMeta('syncState');
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
      'sync_state', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _localUpdatedAtMeta =
      const VerificationMeta('localUpdatedAt');
  @override
  late final GeneratedColumn<DateTime> localUpdatedAt =
      GeneratedColumn<DateTime>('local_updated_at', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
      'date', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _breakfastMealMeta =
      const VerificationMeta('breakfastMeal');
  @override
  late final GeneratedColumn<String> breakfastMeal = GeneratedColumn<String>(
      'breakfast_meal', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _lunchMealMeta =
      const VerificationMeta('lunchMeal');
  @override
  late final GeneratedColumn<String> lunchMeal = GeneratedColumn<String>(
      'lunch_meal', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _dinnerMealMeta =
      const VerificationMeta('dinnerMeal');
  @override
  late final GeneratedColumn<String> dinnerMeal = GeneratedColumn<String>(
      'dinner_meal', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _breakfastExtraMeta =
      const VerificationMeta('breakfastExtra');
  @override
  late final GeneratedColumn<String> breakfastExtra = GeneratedColumn<String>(
      'breakfast_extra', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _lunchExtraMeta =
      const VerificationMeta('lunchExtra');
  @override
  late final GeneratedColumn<String> lunchExtra = GeneratedColumn<String>(
      'lunch_extra', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _dinnerExtraMeta =
      const VerificationMeta('dinnerExtra');
  @override
  late final GeneratedColumn<String> dinnerExtra = GeneratedColumn<String>(
      'dinner_extra', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _breakfastFruitMeta =
      const VerificationMeta('breakfastFruit');
  @override
  late final GeneratedColumn<String> breakfastFruit = GeneratedColumn<String>(
      'breakfast_fruit', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _lunchFruitMeta =
      const VerificationMeta('lunchFruit');
  @override
  late final GeneratedColumn<String> lunchFruit = GeneratedColumn<String>(
      'lunch_fruit', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _dinnerFruitMeta =
      const VerificationMeta('dinnerFruit');
  @override
  late final GeneratedColumn<String> dinnerFruit = GeneratedColumn<String>(
      'dinner_fruit', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String>
      breakfastTags = GeneratedColumn<String>(
              'breakfast_tags', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              defaultValue: const Constant('[]'))
          .withConverter<List<String>>(
              $FoodMetricsTable.$converterbreakfastTags);
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String> lunchTags =
      GeneratedColumn<String>('lunch_tags', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              defaultValue: const Constant('[]'))
          .withConverter<List<String>>($FoodMetricsTable.$converterlunchTags);
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String> dinnerTags =
      GeneratedColumn<String>('dinner_tags', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              defaultValue: const Constant('[]'))
          .withConverter<List<String>>($FoodMetricsTable.$converterdinnerTags);
  static const VerificationMeta _snackNameMeta =
      const VerificationMeta('snackName');
  @override
  late final GeneratedColumn<String> snackName = GeneratedColumn<String>(
      'snack_name', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String> snackTags =
      GeneratedColumn<String>('snack_tags', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              defaultValue: const Constant('[]'))
          .withConverter<List<String>>($FoodMetricsTable.$convertersnackTags);
  static const VerificationMeta _glassNoMeta =
      const VerificationMeta('glassNo');
  @override
  late final GeneratedColumn<int> glassNo = GeneratedColumn<int>(
      'glass_no', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        updatedAt,
        deletedAt,
        syncState,
        localUpdatedAt,
        date,
        breakfastMeal,
        lunchMeal,
        dinnerMeal,
        breakfastExtra,
        lunchExtra,
        dinnerExtra,
        breakfastFruit,
        lunchFruit,
        dinnerFruit,
        breakfastTags,
        lunchTags,
        dinnerTags,
        snackName,
        snackTags,
        glassNo
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'food_metrics';
  @override
  VerificationContext validateIntegrity(Insertable<FoodMetric> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    if (data.containsKey('sync_state')) {
      context.handle(_syncStateMeta,
          syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta));
    }
    if (data.containsKey('local_updated_at')) {
      context.handle(
          _localUpdatedAtMeta,
          localUpdatedAt.isAcceptableOrUnknown(
              data['local_updated_at']!, _localUpdatedAtMeta));
    } else if (isInserting) {
      context.missing(_localUpdatedAtMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('breakfast_meal')) {
      context.handle(
          _breakfastMealMeta,
          breakfastMeal.isAcceptableOrUnknown(
              data['breakfast_meal']!, _breakfastMealMeta));
    }
    if (data.containsKey('lunch_meal')) {
      context.handle(_lunchMealMeta,
          lunchMeal.isAcceptableOrUnknown(data['lunch_meal']!, _lunchMealMeta));
    }
    if (data.containsKey('dinner_meal')) {
      context.handle(
          _dinnerMealMeta,
          dinnerMeal.isAcceptableOrUnknown(
              data['dinner_meal']!, _dinnerMealMeta));
    }
    if (data.containsKey('breakfast_extra')) {
      context.handle(
          _breakfastExtraMeta,
          breakfastExtra.isAcceptableOrUnknown(
              data['breakfast_extra']!, _breakfastExtraMeta));
    }
    if (data.containsKey('lunch_extra')) {
      context.handle(
          _lunchExtraMeta,
          lunchExtra.isAcceptableOrUnknown(
              data['lunch_extra']!, _lunchExtraMeta));
    }
    if (data.containsKey('dinner_extra')) {
      context.handle(
          _dinnerExtraMeta,
          dinnerExtra.isAcceptableOrUnknown(
              data['dinner_extra']!, _dinnerExtraMeta));
    }
    if (data.containsKey('breakfast_fruit')) {
      context.handle(
          _breakfastFruitMeta,
          breakfastFruit.isAcceptableOrUnknown(
              data['breakfast_fruit']!, _breakfastFruitMeta));
    }
    if (data.containsKey('lunch_fruit')) {
      context.handle(
          _lunchFruitMeta,
          lunchFruit.isAcceptableOrUnknown(
              data['lunch_fruit']!, _lunchFruitMeta));
    }
    if (data.containsKey('dinner_fruit')) {
      context.handle(
          _dinnerFruitMeta,
          dinnerFruit.isAcceptableOrUnknown(
              data['dinner_fruit']!, _dinnerFruitMeta));
    }
    if (data.containsKey('snack_name')) {
      context.handle(_snackNameMeta,
          snackName.isAcceptableOrUnknown(data['snack_name']!, _snackNameMeta));
    }
    if (data.containsKey('glass_no')) {
      context.handle(_glassNoMeta,
          glassNo.isAcceptableOrUnknown(data['glass_no']!, _glassNoMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FoodMetric map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FoodMetric(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at']),
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
      syncState: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_state'])!,
      localUpdatedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}local_updated_at'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}date'])!,
      breakfastMeal: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}breakfast_meal'])!,
      lunchMeal: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}lunch_meal'])!,
      dinnerMeal: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}dinner_meal'])!,
      breakfastExtra: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}breakfast_extra'])!,
      lunchExtra: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}lunch_extra'])!,
      dinnerExtra: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}dinner_extra'])!,
      breakfastFruit: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}breakfast_fruit'])!,
      lunchFruit: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}lunch_fruit'])!,
      dinnerFruit: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}dinner_fruit'])!,
      breakfastTags: $FoodMetricsTable.$converterbreakfastTags.fromSql(
          attachedDatabase.typeMapping.read(
              DriftSqlType.string, data['${effectivePrefix}breakfast_tags'])!),
      lunchTags: $FoodMetricsTable.$converterlunchTags.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}lunch_tags'])!),
      dinnerTags: $FoodMetricsTable.$converterdinnerTags.fromSql(
          attachedDatabase.typeMapping.read(
              DriftSqlType.string, data['${effectivePrefix}dinner_tags'])!),
      snackName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}snack_name'])!,
      snackTags: $FoodMetricsTable.$convertersnackTags.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}snack_tags'])!),
      glassNo: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}glass_no'])!,
    );
  }

  @override
  $FoodMetricsTable createAlias(String alias) {
    return $FoodMetricsTable(attachedDatabase, alias);
  }

  static TypeConverter<List<String>, String> $converterbreakfastTags =
      const StringListConverter();
  static TypeConverter<List<String>, String> $converterlunchTags =
      const StringListConverter();
  static TypeConverter<List<String>, String> $converterdinnerTags =
      const StringListConverter();
  static TypeConverter<List<String>, String> $convertersnackTags =
      const StringListConverter();
}

class FoodMetric extends DataClass implements Insertable<FoodMetric> {
  final String id;
  final DateTime? updatedAt;
  final DateTime? deletedAt;
  final String syncState;
  final DateTime localUpdatedAt;
  final String date;
  final String breakfastMeal;
  final String lunchMeal;
  final String dinnerMeal;
  final String breakfastExtra;
  final String lunchExtra;
  final String dinnerExtra;
  final String breakfastFruit;
  final String lunchFruit;
  final String dinnerFruit;
  final List<String> breakfastTags;
  final List<String> lunchTags;
  final List<String> dinnerTags;
  final String snackName;
  final List<String> snackTags;
  final int glassNo;
  const FoodMetric(
      {required this.id,
      this.updatedAt,
      this.deletedAt,
      required this.syncState,
      required this.localUpdatedAt,
      required this.date,
      required this.breakfastMeal,
      required this.lunchMeal,
      required this.dinnerMeal,
      required this.breakfastExtra,
      required this.lunchExtra,
      required this.dinnerExtra,
      required this.breakfastFruit,
      required this.lunchFruit,
      required this.dinnerFruit,
      required this.breakfastTags,
      required this.lunchTags,
      required this.dinnerTags,
      required this.snackName,
      required this.snackTags,
      required this.glassNo});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['sync_state'] = Variable<String>(syncState);
    map['local_updated_at'] = Variable<DateTime>(localUpdatedAt);
    map['date'] = Variable<String>(date);
    map['breakfast_meal'] = Variable<String>(breakfastMeal);
    map['lunch_meal'] = Variable<String>(lunchMeal);
    map['dinner_meal'] = Variable<String>(dinnerMeal);
    map['breakfast_extra'] = Variable<String>(breakfastExtra);
    map['lunch_extra'] = Variable<String>(lunchExtra);
    map['dinner_extra'] = Variable<String>(dinnerExtra);
    map['breakfast_fruit'] = Variable<String>(breakfastFruit);
    map['lunch_fruit'] = Variable<String>(lunchFruit);
    map['dinner_fruit'] = Variable<String>(dinnerFruit);
    {
      map['breakfast_tags'] = Variable<String>(
          $FoodMetricsTable.$converterbreakfastTags.toSql(breakfastTags));
    }
    {
      map['lunch_tags'] = Variable<String>(
          $FoodMetricsTable.$converterlunchTags.toSql(lunchTags));
    }
    {
      map['dinner_tags'] = Variable<String>(
          $FoodMetricsTable.$converterdinnerTags.toSql(dinnerTags));
    }
    map['snack_name'] = Variable<String>(snackName);
    {
      map['snack_tags'] = Variable<String>(
          $FoodMetricsTable.$convertersnackTags.toSql(snackTags));
    }
    map['glass_no'] = Variable<int>(glassNo);
    return map;
  }

  FoodMetricsCompanion toCompanion(bool nullToAbsent) {
    return FoodMetricsCompanion(
      id: Value(id),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncState: Value(syncState),
      localUpdatedAt: Value(localUpdatedAt),
      date: Value(date),
      breakfastMeal: Value(breakfastMeal),
      lunchMeal: Value(lunchMeal),
      dinnerMeal: Value(dinnerMeal),
      breakfastExtra: Value(breakfastExtra),
      lunchExtra: Value(lunchExtra),
      dinnerExtra: Value(dinnerExtra),
      breakfastFruit: Value(breakfastFruit),
      lunchFruit: Value(lunchFruit),
      dinnerFruit: Value(dinnerFruit),
      breakfastTags: Value(breakfastTags),
      lunchTags: Value(lunchTags),
      dinnerTags: Value(dinnerTags),
      snackName: Value(snackName),
      snackTags: Value(snackTags),
      glassNo: Value(glassNo),
    );
  }

  factory FoodMetric.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FoodMetric(
      id: serializer.fromJson<String>(json['id']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      syncState: serializer.fromJson<String>(json['syncState']),
      localUpdatedAt: serializer.fromJson<DateTime>(json['localUpdatedAt']),
      date: serializer.fromJson<String>(json['date']),
      breakfastMeal: serializer.fromJson<String>(json['breakfastMeal']),
      lunchMeal: serializer.fromJson<String>(json['lunchMeal']),
      dinnerMeal: serializer.fromJson<String>(json['dinnerMeal']),
      breakfastExtra: serializer.fromJson<String>(json['breakfastExtra']),
      lunchExtra: serializer.fromJson<String>(json['lunchExtra']),
      dinnerExtra: serializer.fromJson<String>(json['dinnerExtra']),
      breakfastFruit: serializer.fromJson<String>(json['breakfastFruit']),
      lunchFruit: serializer.fromJson<String>(json['lunchFruit']),
      dinnerFruit: serializer.fromJson<String>(json['dinnerFruit']),
      breakfastTags: serializer.fromJson<List<String>>(json['breakfastTags']),
      lunchTags: serializer.fromJson<List<String>>(json['lunchTags']),
      dinnerTags: serializer.fromJson<List<String>>(json['dinnerTags']),
      snackName: serializer.fromJson<String>(json['snackName']),
      snackTags: serializer.fromJson<List<String>>(json['snackTags']),
      glassNo: serializer.fromJson<int>(json['glassNo']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'syncState': serializer.toJson<String>(syncState),
      'localUpdatedAt': serializer.toJson<DateTime>(localUpdatedAt),
      'date': serializer.toJson<String>(date),
      'breakfastMeal': serializer.toJson<String>(breakfastMeal),
      'lunchMeal': serializer.toJson<String>(lunchMeal),
      'dinnerMeal': serializer.toJson<String>(dinnerMeal),
      'breakfastExtra': serializer.toJson<String>(breakfastExtra),
      'lunchExtra': serializer.toJson<String>(lunchExtra),
      'dinnerExtra': serializer.toJson<String>(dinnerExtra),
      'breakfastFruit': serializer.toJson<String>(breakfastFruit),
      'lunchFruit': serializer.toJson<String>(lunchFruit),
      'dinnerFruit': serializer.toJson<String>(dinnerFruit),
      'breakfastTags': serializer.toJson<List<String>>(breakfastTags),
      'lunchTags': serializer.toJson<List<String>>(lunchTags),
      'dinnerTags': serializer.toJson<List<String>>(dinnerTags),
      'snackName': serializer.toJson<String>(snackName),
      'snackTags': serializer.toJson<List<String>>(snackTags),
      'glassNo': serializer.toJson<int>(glassNo),
    };
  }

  FoodMetric copyWith(
          {String? id,
          Value<DateTime?> updatedAt = const Value.absent(),
          Value<DateTime?> deletedAt = const Value.absent(),
          String? syncState,
          DateTime? localUpdatedAt,
          String? date,
          String? breakfastMeal,
          String? lunchMeal,
          String? dinnerMeal,
          String? breakfastExtra,
          String? lunchExtra,
          String? dinnerExtra,
          String? breakfastFruit,
          String? lunchFruit,
          String? dinnerFruit,
          List<String>? breakfastTags,
          List<String>? lunchTags,
          List<String>? dinnerTags,
          String? snackName,
          List<String>? snackTags,
          int? glassNo}) =>
      FoodMetric(
        id: id ?? this.id,
        updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        syncState: syncState ?? this.syncState,
        localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
        date: date ?? this.date,
        breakfastMeal: breakfastMeal ?? this.breakfastMeal,
        lunchMeal: lunchMeal ?? this.lunchMeal,
        dinnerMeal: dinnerMeal ?? this.dinnerMeal,
        breakfastExtra: breakfastExtra ?? this.breakfastExtra,
        lunchExtra: lunchExtra ?? this.lunchExtra,
        dinnerExtra: dinnerExtra ?? this.dinnerExtra,
        breakfastFruit: breakfastFruit ?? this.breakfastFruit,
        lunchFruit: lunchFruit ?? this.lunchFruit,
        dinnerFruit: dinnerFruit ?? this.dinnerFruit,
        breakfastTags: breakfastTags ?? this.breakfastTags,
        lunchTags: lunchTags ?? this.lunchTags,
        dinnerTags: dinnerTags ?? this.dinnerTags,
        snackName: snackName ?? this.snackName,
        snackTags: snackTags ?? this.snackTags,
        glassNo: glassNo ?? this.glassNo,
      );
  FoodMetric copyWithCompanion(FoodMetricsCompanion data) {
    return FoodMetric(
      id: data.id.present ? data.id.value : this.id,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
      localUpdatedAt: data.localUpdatedAt.present
          ? data.localUpdatedAt.value
          : this.localUpdatedAt,
      date: data.date.present ? data.date.value : this.date,
      breakfastMeal: data.breakfastMeal.present
          ? data.breakfastMeal.value
          : this.breakfastMeal,
      lunchMeal: data.lunchMeal.present ? data.lunchMeal.value : this.lunchMeal,
      dinnerMeal:
          data.dinnerMeal.present ? data.dinnerMeal.value : this.dinnerMeal,
      breakfastExtra: data.breakfastExtra.present
          ? data.breakfastExtra.value
          : this.breakfastExtra,
      lunchExtra:
          data.lunchExtra.present ? data.lunchExtra.value : this.lunchExtra,
      dinnerExtra:
          data.dinnerExtra.present ? data.dinnerExtra.value : this.dinnerExtra,
      breakfastFruit: data.breakfastFruit.present
          ? data.breakfastFruit.value
          : this.breakfastFruit,
      lunchFruit:
          data.lunchFruit.present ? data.lunchFruit.value : this.lunchFruit,
      dinnerFruit:
          data.dinnerFruit.present ? data.dinnerFruit.value : this.dinnerFruit,
      breakfastTags: data.breakfastTags.present
          ? data.breakfastTags.value
          : this.breakfastTags,
      lunchTags: data.lunchTags.present ? data.lunchTags.value : this.lunchTags,
      dinnerTags:
          data.dinnerTags.present ? data.dinnerTags.value : this.dinnerTags,
      snackName: data.snackName.present ? data.snackName.value : this.snackName,
      snackTags: data.snackTags.present ? data.snackTags.value : this.snackTags,
      glassNo: data.glassNo.present ? data.glassNo.value : this.glassNo,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FoodMetric(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncState: $syncState, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('date: $date, ')
          ..write('breakfastMeal: $breakfastMeal, ')
          ..write('lunchMeal: $lunchMeal, ')
          ..write('dinnerMeal: $dinnerMeal, ')
          ..write('breakfastExtra: $breakfastExtra, ')
          ..write('lunchExtra: $lunchExtra, ')
          ..write('dinnerExtra: $dinnerExtra, ')
          ..write('breakfastFruit: $breakfastFruit, ')
          ..write('lunchFruit: $lunchFruit, ')
          ..write('dinnerFruit: $dinnerFruit, ')
          ..write('breakfastTags: $breakfastTags, ')
          ..write('lunchTags: $lunchTags, ')
          ..write('dinnerTags: $dinnerTags, ')
          ..write('snackName: $snackName, ')
          ..write('snackTags: $snackTags, ')
          ..write('glassNo: $glassNo')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
        id,
        updatedAt,
        deletedAt,
        syncState,
        localUpdatedAt,
        date,
        breakfastMeal,
        lunchMeal,
        dinnerMeal,
        breakfastExtra,
        lunchExtra,
        dinnerExtra,
        breakfastFruit,
        lunchFruit,
        dinnerFruit,
        breakfastTags,
        lunchTags,
        dinnerTags,
        snackName,
        snackTags,
        glassNo
      ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FoodMetric &&
          other.id == this.id &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.syncState == this.syncState &&
          other.localUpdatedAt == this.localUpdatedAt &&
          other.date == this.date &&
          other.breakfastMeal == this.breakfastMeal &&
          other.lunchMeal == this.lunchMeal &&
          other.dinnerMeal == this.dinnerMeal &&
          other.breakfastExtra == this.breakfastExtra &&
          other.lunchExtra == this.lunchExtra &&
          other.dinnerExtra == this.dinnerExtra &&
          other.breakfastFruit == this.breakfastFruit &&
          other.lunchFruit == this.lunchFruit &&
          other.dinnerFruit == this.dinnerFruit &&
          other.breakfastTags == this.breakfastTags &&
          other.lunchTags == this.lunchTags &&
          other.dinnerTags == this.dinnerTags &&
          other.snackName == this.snackName &&
          other.snackTags == this.snackTags &&
          other.glassNo == this.glassNo);
}

class FoodMetricsCompanion extends UpdateCompanion<FoodMetric> {
  final Value<String> id;
  final Value<DateTime?> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> syncState;
  final Value<DateTime> localUpdatedAt;
  final Value<String> date;
  final Value<String> breakfastMeal;
  final Value<String> lunchMeal;
  final Value<String> dinnerMeal;
  final Value<String> breakfastExtra;
  final Value<String> lunchExtra;
  final Value<String> dinnerExtra;
  final Value<String> breakfastFruit;
  final Value<String> lunchFruit;
  final Value<String> dinnerFruit;
  final Value<List<String>> breakfastTags;
  final Value<List<String>> lunchTags;
  final Value<List<String>> dinnerTags;
  final Value<String> snackName;
  final Value<List<String>> snackTags;
  final Value<int> glassNo;
  final Value<int> rowid;
  const FoodMetricsCompanion({
    this.id = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    this.localUpdatedAt = const Value.absent(),
    this.date = const Value.absent(),
    this.breakfastMeal = const Value.absent(),
    this.lunchMeal = const Value.absent(),
    this.dinnerMeal = const Value.absent(),
    this.breakfastExtra = const Value.absent(),
    this.lunchExtra = const Value.absent(),
    this.dinnerExtra = const Value.absent(),
    this.breakfastFruit = const Value.absent(),
    this.lunchFruit = const Value.absent(),
    this.dinnerFruit = const Value.absent(),
    this.breakfastTags = const Value.absent(),
    this.lunchTags = const Value.absent(),
    this.dinnerTags = const Value.absent(),
    this.snackName = const Value.absent(),
    this.snackTags = const Value.absent(),
    this.glassNo = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FoodMetricsCompanion.insert({
    required String id,
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    required DateTime localUpdatedAt,
    required String date,
    this.breakfastMeal = const Value.absent(),
    this.lunchMeal = const Value.absent(),
    this.dinnerMeal = const Value.absent(),
    this.breakfastExtra = const Value.absent(),
    this.lunchExtra = const Value.absent(),
    this.dinnerExtra = const Value.absent(),
    this.breakfastFruit = const Value.absent(),
    this.lunchFruit = const Value.absent(),
    this.dinnerFruit = const Value.absent(),
    this.breakfastTags = const Value.absent(),
    this.lunchTags = const Value.absent(),
    this.dinnerTags = const Value.absent(),
    this.snackName = const Value.absent(),
    this.snackTags = const Value.absent(),
    this.glassNo = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        localUpdatedAt = Value(localUpdatedAt),
        date = Value(date);
  static Insertable<FoodMetric> custom({
    Expression<String>? id,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? syncState,
    Expression<DateTime>? localUpdatedAt,
    Expression<String>? date,
    Expression<String>? breakfastMeal,
    Expression<String>? lunchMeal,
    Expression<String>? dinnerMeal,
    Expression<String>? breakfastExtra,
    Expression<String>? lunchExtra,
    Expression<String>? dinnerExtra,
    Expression<String>? breakfastFruit,
    Expression<String>? lunchFruit,
    Expression<String>? dinnerFruit,
    Expression<String>? breakfastTags,
    Expression<String>? lunchTags,
    Expression<String>? dinnerTags,
    Expression<String>? snackName,
    Expression<String>? snackTags,
    Expression<int>? glassNo,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncState != null) 'sync_state': syncState,
      if (localUpdatedAt != null) 'local_updated_at': localUpdatedAt,
      if (date != null) 'date': date,
      if (breakfastMeal != null) 'breakfast_meal': breakfastMeal,
      if (lunchMeal != null) 'lunch_meal': lunchMeal,
      if (dinnerMeal != null) 'dinner_meal': dinnerMeal,
      if (breakfastExtra != null) 'breakfast_extra': breakfastExtra,
      if (lunchExtra != null) 'lunch_extra': lunchExtra,
      if (dinnerExtra != null) 'dinner_extra': dinnerExtra,
      if (breakfastFruit != null) 'breakfast_fruit': breakfastFruit,
      if (lunchFruit != null) 'lunch_fruit': lunchFruit,
      if (dinnerFruit != null) 'dinner_fruit': dinnerFruit,
      if (breakfastTags != null) 'breakfast_tags': breakfastTags,
      if (lunchTags != null) 'lunch_tags': lunchTags,
      if (dinnerTags != null) 'dinner_tags': dinnerTags,
      if (snackName != null) 'snack_name': snackName,
      if (snackTags != null) 'snack_tags': snackTags,
      if (glassNo != null) 'glass_no': glassNo,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FoodMetricsCompanion copyWith(
      {Value<String>? id,
      Value<DateTime?>? updatedAt,
      Value<DateTime?>? deletedAt,
      Value<String>? syncState,
      Value<DateTime>? localUpdatedAt,
      Value<String>? date,
      Value<String>? breakfastMeal,
      Value<String>? lunchMeal,
      Value<String>? dinnerMeal,
      Value<String>? breakfastExtra,
      Value<String>? lunchExtra,
      Value<String>? dinnerExtra,
      Value<String>? breakfastFruit,
      Value<String>? lunchFruit,
      Value<String>? dinnerFruit,
      Value<List<String>>? breakfastTags,
      Value<List<String>>? lunchTags,
      Value<List<String>>? dinnerTags,
      Value<String>? snackName,
      Value<List<String>>? snackTags,
      Value<int>? glassNo,
      Value<int>? rowid}) {
    return FoodMetricsCompanion(
      id: id ?? this.id,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncState: syncState ?? this.syncState,
      localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
      date: date ?? this.date,
      breakfastMeal: breakfastMeal ?? this.breakfastMeal,
      lunchMeal: lunchMeal ?? this.lunchMeal,
      dinnerMeal: dinnerMeal ?? this.dinnerMeal,
      breakfastExtra: breakfastExtra ?? this.breakfastExtra,
      lunchExtra: lunchExtra ?? this.lunchExtra,
      dinnerExtra: dinnerExtra ?? this.dinnerExtra,
      breakfastFruit: breakfastFruit ?? this.breakfastFruit,
      lunchFruit: lunchFruit ?? this.lunchFruit,
      dinnerFruit: dinnerFruit ?? this.dinnerFruit,
      breakfastTags: breakfastTags ?? this.breakfastTags,
      lunchTags: lunchTags ?? this.lunchTags,
      dinnerTags: dinnerTags ?? this.dinnerTags,
      snackName: snackName ?? this.snackName,
      snackTags: snackTags ?? this.snackTags,
      glassNo: glassNo ?? this.glassNo,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(syncState.value);
    }
    if (localUpdatedAt.present) {
      map['local_updated_at'] = Variable<DateTime>(localUpdatedAt.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (breakfastMeal.present) {
      map['breakfast_meal'] = Variable<String>(breakfastMeal.value);
    }
    if (lunchMeal.present) {
      map['lunch_meal'] = Variable<String>(lunchMeal.value);
    }
    if (dinnerMeal.present) {
      map['dinner_meal'] = Variable<String>(dinnerMeal.value);
    }
    if (breakfastExtra.present) {
      map['breakfast_extra'] = Variable<String>(breakfastExtra.value);
    }
    if (lunchExtra.present) {
      map['lunch_extra'] = Variable<String>(lunchExtra.value);
    }
    if (dinnerExtra.present) {
      map['dinner_extra'] = Variable<String>(dinnerExtra.value);
    }
    if (breakfastFruit.present) {
      map['breakfast_fruit'] = Variable<String>(breakfastFruit.value);
    }
    if (lunchFruit.present) {
      map['lunch_fruit'] = Variable<String>(lunchFruit.value);
    }
    if (dinnerFruit.present) {
      map['dinner_fruit'] = Variable<String>(dinnerFruit.value);
    }
    if (breakfastTags.present) {
      map['breakfast_tags'] = Variable<String>(
          $FoodMetricsTable.$converterbreakfastTags.toSql(breakfastTags.value));
    }
    if (lunchTags.present) {
      map['lunch_tags'] = Variable<String>(
          $FoodMetricsTable.$converterlunchTags.toSql(lunchTags.value));
    }
    if (dinnerTags.present) {
      map['dinner_tags'] = Variable<String>(
          $FoodMetricsTable.$converterdinnerTags.toSql(dinnerTags.value));
    }
    if (snackName.present) {
      map['snack_name'] = Variable<String>(snackName.value);
    }
    if (snackTags.present) {
      map['snack_tags'] = Variable<String>(
          $FoodMetricsTable.$convertersnackTags.toSql(snackTags.value));
    }
    if (glassNo.present) {
      map['glass_no'] = Variable<int>(glassNo.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FoodMetricsCompanion(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncState: $syncState, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('date: $date, ')
          ..write('breakfastMeal: $breakfastMeal, ')
          ..write('lunchMeal: $lunchMeal, ')
          ..write('dinnerMeal: $dinnerMeal, ')
          ..write('breakfastExtra: $breakfastExtra, ')
          ..write('lunchExtra: $lunchExtra, ')
          ..write('dinnerExtra: $dinnerExtra, ')
          ..write('breakfastFruit: $breakfastFruit, ')
          ..write('lunchFruit: $lunchFruit, ')
          ..write('dinnerFruit: $dinnerFruit, ')
          ..write('breakfastTags: $breakfastTags, ')
          ..write('lunchTags: $lunchTags, ')
          ..write('dinnerTags: $dinnerTags, ')
          ..write('snackName: $snackName, ')
          ..write('snackTags: $snackTags, ')
          ..write('glassNo: $glassNo, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SleepMetricsTable extends SleepMetrics
    with TableInfo<$SleepMetricsTable, SleepMetric> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SleepMetricsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _syncStateMeta =
      const VerificationMeta('syncState');
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
      'sync_state', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _localUpdatedAtMeta =
      const VerificationMeta('localUpdatedAt');
  @override
  late final GeneratedColumn<DateTime> localUpdatedAt =
      GeneratedColumn<DateTime>('local_updated_at', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
      'date', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isNightMeta =
      const VerificationMeta('isNight');
  @override
  late final GeneratedColumn<bool> isNight = GeneratedColumn<bool>(
      'is_night', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_night" IN (0, 1))'));
  static const VerificationMeta _timeSleptMeta =
      const VerificationMeta('timeSlept');
  @override
  late final GeneratedColumn<String> timeSlept = GeneratedColumn<String>(
      'time_slept', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _timeWokeUpMeta =
      const VerificationMeta('timeWokeUp');
  @override
  late final GeneratedColumn<String> timeWokeUp = GeneratedColumn<String>(
      'time_woke_up', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String> tags =
      GeneratedColumn<String>('tags', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              defaultValue: const Constant('[]'))
          .withConverter<List<String>>($SleepMetricsTable.$convertertags);
  static const VerificationMeta _severityMeta =
      const VerificationMeta('severity');
  @override
  late final GeneratedColumn<double> severity = GeneratedColumn<double>(
      'severity', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        updatedAt,
        deletedAt,
        syncState,
        localUpdatedAt,
        date,
        isNight,
        timeSlept,
        timeWokeUp,
        tags,
        severity
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sleep_metrics';
  @override
  VerificationContext validateIntegrity(Insertable<SleepMetric> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    if (data.containsKey('sync_state')) {
      context.handle(_syncStateMeta,
          syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta));
    }
    if (data.containsKey('local_updated_at')) {
      context.handle(
          _localUpdatedAtMeta,
          localUpdatedAt.isAcceptableOrUnknown(
              data['local_updated_at']!, _localUpdatedAtMeta));
    } else if (isInserting) {
      context.missing(_localUpdatedAtMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('is_night')) {
      context.handle(_isNightMeta,
          isNight.isAcceptableOrUnknown(data['is_night']!, _isNightMeta));
    } else if (isInserting) {
      context.missing(_isNightMeta);
    }
    if (data.containsKey('time_slept')) {
      context.handle(_timeSleptMeta,
          timeSlept.isAcceptableOrUnknown(data['time_slept']!, _timeSleptMeta));
    }
    if (data.containsKey('time_woke_up')) {
      context.handle(
          _timeWokeUpMeta,
          timeWokeUp.isAcceptableOrUnknown(
              data['time_woke_up']!, _timeWokeUpMeta));
    }
    if (data.containsKey('severity')) {
      context.handle(_severityMeta,
          severity.isAcceptableOrUnknown(data['severity']!, _severityMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SleepMetric map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SleepMetric(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at']),
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
      syncState: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_state'])!,
      localUpdatedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}local_updated_at'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}date'])!,
      isNight: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_night'])!,
      timeSlept: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}time_slept'])!,
      timeWokeUp: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}time_woke_up'])!,
      tags: $SleepMetricsTable.$convertertags.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tags'])!),
      severity: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}severity'])!,
    );
  }

  @override
  $SleepMetricsTable createAlias(String alias) {
    return $SleepMetricsTable(attachedDatabase, alias);
  }

  static TypeConverter<List<String>, String> $convertertags =
      const StringListConverter();
}

class SleepMetric extends DataClass implements Insertable<SleepMetric> {
  final String id;
  final DateTime? updatedAt;
  final DateTime? deletedAt;
  final String syncState;
  final DateTime localUpdatedAt;
  final String date;
  final bool isNight;
  final String timeSlept;
  final String timeWokeUp;
  final List<String> tags;
  final double severity;
  const SleepMetric(
      {required this.id,
      this.updatedAt,
      this.deletedAt,
      required this.syncState,
      required this.localUpdatedAt,
      required this.date,
      required this.isNight,
      required this.timeSlept,
      required this.timeWokeUp,
      required this.tags,
      required this.severity});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['sync_state'] = Variable<String>(syncState);
    map['local_updated_at'] = Variable<DateTime>(localUpdatedAt);
    map['date'] = Variable<String>(date);
    map['is_night'] = Variable<bool>(isNight);
    map['time_slept'] = Variable<String>(timeSlept);
    map['time_woke_up'] = Variable<String>(timeWokeUp);
    {
      map['tags'] =
          Variable<String>($SleepMetricsTable.$convertertags.toSql(tags));
    }
    map['severity'] = Variable<double>(severity);
    return map;
  }

  SleepMetricsCompanion toCompanion(bool nullToAbsent) {
    return SleepMetricsCompanion(
      id: Value(id),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncState: Value(syncState),
      localUpdatedAt: Value(localUpdatedAt),
      date: Value(date),
      isNight: Value(isNight),
      timeSlept: Value(timeSlept),
      timeWokeUp: Value(timeWokeUp),
      tags: Value(tags),
      severity: Value(severity),
    );
  }

  factory SleepMetric.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SleepMetric(
      id: serializer.fromJson<String>(json['id']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      syncState: serializer.fromJson<String>(json['syncState']),
      localUpdatedAt: serializer.fromJson<DateTime>(json['localUpdatedAt']),
      date: serializer.fromJson<String>(json['date']),
      isNight: serializer.fromJson<bool>(json['isNight']),
      timeSlept: serializer.fromJson<String>(json['timeSlept']),
      timeWokeUp: serializer.fromJson<String>(json['timeWokeUp']),
      tags: serializer.fromJson<List<String>>(json['tags']),
      severity: serializer.fromJson<double>(json['severity']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'syncState': serializer.toJson<String>(syncState),
      'localUpdatedAt': serializer.toJson<DateTime>(localUpdatedAt),
      'date': serializer.toJson<String>(date),
      'isNight': serializer.toJson<bool>(isNight),
      'timeSlept': serializer.toJson<String>(timeSlept),
      'timeWokeUp': serializer.toJson<String>(timeWokeUp),
      'tags': serializer.toJson<List<String>>(tags),
      'severity': serializer.toJson<double>(severity),
    };
  }

  SleepMetric copyWith(
          {String? id,
          Value<DateTime?> updatedAt = const Value.absent(),
          Value<DateTime?> deletedAt = const Value.absent(),
          String? syncState,
          DateTime? localUpdatedAt,
          String? date,
          bool? isNight,
          String? timeSlept,
          String? timeWokeUp,
          List<String>? tags,
          double? severity}) =>
      SleepMetric(
        id: id ?? this.id,
        updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        syncState: syncState ?? this.syncState,
        localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
        date: date ?? this.date,
        isNight: isNight ?? this.isNight,
        timeSlept: timeSlept ?? this.timeSlept,
        timeWokeUp: timeWokeUp ?? this.timeWokeUp,
        tags: tags ?? this.tags,
        severity: severity ?? this.severity,
      );
  SleepMetric copyWithCompanion(SleepMetricsCompanion data) {
    return SleepMetric(
      id: data.id.present ? data.id.value : this.id,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
      localUpdatedAt: data.localUpdatedAt.present
          ? data.localUpdatedAt.value
          : this.localUpdatedAt,
      date: data.date.present ? data.date.value : this.date,
      isNight: data.isNight.present ? data.isNight.value : this.isNight,
      timeSlept: data.timeSlept.present ? data.timeSlept.value : this.timeSlept,
      timeWokeUp:
          data.timeWokeUp.present ? data.timeWokeUp.value : this.timeWokeUp,
      tags: data.tags.present ? data.tags.value : this.tags,
      severity: data.severity.present ? data.severity.value : this.severity,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SleepMetric(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncState: $syncState, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('date: $date, ')
          ..write('isNight: $isNight, ')
          ..write('timeSlept: $timeSlept, ')
          ..write('timeWokeUp: $timeWokeUp, ')
          ..write('tags: $tags, ')
          ..write('severity: $severity')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, updatedAt, deletedAt, syncState,
      localUpdatedAt, date, isNight, timeSlept, timeWokeUp, tags, severity);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SleepMetric &&
          other.id == this.id &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.syncState == this.syncState &&
          other.localUpdatedAt == this.localUpdatedAt &&
          other.date == this.date &&
          other.isNight == this.isNight &&
          other.timeSlept == this.timeSlept &&
          other.timeWokeUp == this.timeWokeUp &&
          other.tags == this.tags &&
          other.severity == this.severity);
}

class SleepMetricsCompanion extends UpdateCompanion<SleepMetric> {
  final Value<String> id;
  final Value<DateTime?> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> syncState;
  final Value<DateTime> localUpdatedAt;
  final Value<String> date;
  final Value<bool> isNight;
  final Value<String> timeSlept;
  final Value<String> timeWokeUp;
  final Value<List<String>> tags;
  final Value<double> severity;
  final Value<int> rowid;
  const SleepMetricsCompanion({
    this.id = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    this.localUpdatedAt = const Value.absent(),
    this.date = const Value.absent(),
    this.isNight = const Value.absent(),
    this.timeSlept = const Value.absent(),
    this.timeWokeUp = const Value.absent(),
    this.tags = const Value.absent(),
    this.severity = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SleepMetricsCompanion.insert({
    required String id,
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    required DateTime localUpdatedAt,
    required String date,
    required bool isNight,
    this.timeSlept = const Value.absent(),
    this.timeWokeUp = const Value.absent(),
    this.tags = const Value.absent(),
    this.severity = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        localUpdatedAt = Value(localUpdatedAt),
        date = Value(date),
        isNight = Value(isNight);
  static Insertable<SleepMetric> custom({
    Expression<String>? id,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? syncState,
    Expression<DateTime>? localUpdatedAt,
    Expression<String>? date,
    Expression<bool>? isNight,
    Expression<String>? timeSlept,
    Expression<String>? timeWokeUp,
    Expression<String>? tags,
    Expression<double>? severity,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncState != null) 'sync_state': syncState,
      if (localUpdatedAt != null) 'local_updated_at': localUpdatedAt,
      if (date != null) 'date': date,
      if (isNight != null) 'is_night': isNight,
      if (timeSlept != null) 'time_slept': timeSlept,
      if (timeWokeUp != null) 'time_woke_up': timeWokeUp,
      if (tags != null) 'tags': tags,
      if (severity != null) 'severity': severity,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SleepMetricsCompanion copyWith(
      {Value<String>? id,
      Value<DateTime?>? updatedAt,
      Value<DateTime?>? deletedAt,
      Value<String>? syncState,
      Value<DateTime>? localUpdatedAt,
      Value<String>? date,
      Value<bool>? isNight,
      Value<String>? timeSlept,
      Value<String>? timeWokeUp,
      Value<List<String>>? tags,
      Value<double>? severity,
      Value<int>? rowid}) {
    return SleepMetricsCompanion(
      id: id ?? this.id,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncState: syncState ?? this.syncState,
      localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
      date: date ?? this.date,
      isNight: isNight ?? this.isNight,
      timeSlept: timeSlept ?? this.timeSlept,
      timeWokeUp: timeWokeUp ?? this.timeWokeUp,
      tags: tags ?? this.tags,
      severity: severity ?? this.severity,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(syncState.value);
    }
    if (localUpdatedAt.present) {
      map['local_updated_at'] = Variable<DateTime>(localUpdatedAt.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (isNight.present) {
      map['is_night'] = Variable<bool>(isNight.value);
    }
    if (timeSlept.present) {
      map['time_slept'] = Variable<String>(timeSlept.value);
    }
    if (timeWokeUp.present) {
      map['time_woke_up'] = Variable<String>(timeWokeUp.value);
    }
    if (tags.present) {
      map['tags'] =
          Variable<String>($SleepMetricsTable.$convertertags.toSql(tags.value));
    }
    if (severity.present) {
      map['severity'] = Variable<double>(severity.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SleepMetricsCompanion(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncState: $syncState, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('date: $date, ')
          ..write('isNight: $isNight, ')
          ..write('timeSlept: $timeSlept, ')
          ..write('timeWokeUp: $timeWokeUp, ')
          ..write('tags: $tags, ')
          ..write('severity: $severity, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MedicationMetricsTable extends MedicationMetrics
    with TableInfo<$MedicationMetricsTable, MedicationMetric> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MedicationMetricsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _syncStateMeta =
      const VerificationMeta('syncState');
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
      'sync_state', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _localUpdatedAtMeta =
      const VerificationMeta('localUpdatedAt');
  @override
  late final GeneratedColumn<DateTime> localUpdatedAt =
      GeneratedColumn<DateTime>('local_updated_at', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
      'date', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _dosageMeta = const VerificationMeta('dosage');
  @override
  late final GeneratedColumn<int> dosage = GeneratedColumn<int>(
      'dosage', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _metricMeta = const VerificationMeta('metric');
  @override
  late final GeneratedColumn<String> metric = GeneratedColumn<String>(
      'metric', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _quantityMeta =
      const VerificationMeta('quantity');
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
      'quantity', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _timeMeta = const VerificationMeta('time');
  @override
  late final GeneratedColumn<String> time = GeneratedColumn<String>(
      'time', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        updatedAt,
        deletedAt,
        syncState,
        localUpdatedAt,
        date,
        name,
        dosage,
        metric,
        quantity,
        time
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'medication_metrics';
  @override
  VerificationContext validateIntegrity(Insertable<MedicationMetric> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    if (data.containsKey('sync_state')) {
      context.handle(_syncStateMeta,
          syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta));
    }
    if (data.containsKey('local_updated_at')) {
      context.handle(
          _localUpdatedAtMeta,
          localUpdatedAt.isAcceptableOrUnknown(
              data['local_updated_at']!, _localUpdatedAtMeta));
    } else if (isInserting) {
      context.missing(_localUpdatedAtMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    }
    if (data.containsKey('dosage')) {
      context.handle(_dosageMeta,
          dosage.isAcceptableOrUnknown(data['dosage']!, _dosageMeta));
    }
    if (data.containsKey('metric')) {
      context.handle(_metricMeta,
          metric.isAcceptableOrUnknown(data['metric']!, _metricMeta));
    }
    if (data.containsKey('quantity')) {
      context.handle(_quantityMeta,
          quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta));
    }
    if (data.containsKey('time')) {
      context.handle(
          _timeMeta, time.isAcceptableOrUnknown(data['time']!, _timeMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MedicationMetric map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MedicationMetric(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at']),
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
      syncState: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_state'])!,
      localUpdatedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}local_updated_at'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}date'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      dosage: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}dosage'])!,
      metric: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}metric'])!,
      quantity: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}quantity'])!,
      time: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}time'])!,
    );
  }

  @override
  $MedicationMetricsTable createAlias(String alias) {
    return $MedicationMetricsTable(attachedDatabase, alias);
  }
}

class MedicationMetric extends DataClass
    implements Insertable<MedicationMetric> {
  final String id;
  final DateTime? updatedAt;
  final DateTime? deletedAt;
  final String syncState;
  final DateTime localUpdatedAt;
  final String date;
  final String name;
  final int dosage;
  final String metric;
  final int quantity;
  final String time;
  const MedicationMetric(
      {required this.id,
      this.updatedAt,
      this.deletedAt,
      required this.syncState,
      required this.localUpdatedAt,
      required this.date,
      required this.name,
      required this.dosage,
      required this.metric,
      required this.quantity,
      required this.time});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['sync_state'] = Variable<String>(syncState);
    map['local_updated_at'] = Variable<DateTime>(localUpdatedAt);
    map['date'] = Variable<String>(date);
    map['name'] = Variable<String>(name);
    map['dosage'] = Variable<int>(dosage);
    map['metric'] = Variable<String>(metric);
    map['quantity'] = Variable<int>(quantity);
    map['time'] = Variable<String>(time);
    return map;
  }

  MedicationMetricsCompanion toCompanion(bool nullToAbsent) {
    return MedicationMetricsCompanion(
      id: Value(id),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncState: Value(syncState),
      localUpdatedAt: Value(localUpdatedAt),
      date: Value(date),
      name: Value(name),
      dosage: Value(dosage),
      metric: Value(metric),
      quantity: Value(quantity),
      time: Value(time),
    );
  }

  factory MedicationMetric.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MedicationMetric(
      id: serializer.fromJson<String>(json['id']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      syncState: serializer.fromJson<String>(json['syncState']),
      localUpdatedAt: serializer.fromJson<DateTime>(json['localUpdatedAt']),
      date: serializer.fromJson<String>(json['date']),
      name: serializer.fromJson<String>(json['name']),
      dosage: serializer.fromJson<int>(json['dosage']),
      metric: serializer.fromJson<String>(json['metric']),
      quantity: serializer.fromJson<int>(json['quantity']),
      time: serializer.fromJson<String>(json['time']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'syncState': serializer.toJson<String>(syncState),
      'localUpdatedAt': serializer.toJson<DateTime>(localUpdatedAt),
      'date': serializer.toJson<String>(date),
      'name': serializer.toJson<String>(name),
      'dosage': serializer.toJson<int>(dosage),
      'metric': serializer.toJson<String>(metric),
      'quantity': serializer.toJson<int>(quantity),
      'time': serializer.toJson<String>(time),
    };
  }

  MedicationMetric copyWith(
          {String? id,
          Value<DateTime?> updatedAt = const Value.absent(),
          Value<DateTime?> deletedAt = const Value.absent(),
          String? syncState,
          DateTime? localUpdatedAt,
          String? date,
          String? name,
          int? dosage,
          String? metric,
          int? quantity,
          String? time}) =>
      MedicationMetric(
        id: id ?? this.id,
        updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        syncState: syncState ?? this.syncState,
        localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
        date: date ?? this.date,
        name: name ?? this.name,
        dosage: dosage ?? this.dosage,
        metric: metric ?? this.metric,
        quantity: quantity ?? this.quantity,
        time: time ?? this.time,
      );
  MedicationMetric copyWithCompanion(MedicationMetricsCompanion data) {
    return MedicationMetric(
      id: data.id.present ? data.id.value : this.id,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
      localUpdatedAt: data.localUpdatedAt.present
          ? data.localUpdatedAt.value
          : this.localUpdatedAt,
      date: data.date.present ? data.date.value : this.date,
      name: data.name.present ? data.name.value : this.name,
      dosage: data.dosage.present ? data.dosage.value : this.dosage,
      metric: data.metric.present ? data.metric.value : this.metric,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      time: data.time.present ? data.time.value : this.time,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MedicationMetric(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncState: $syncState, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('date: $date, ')
          ..write('name: $name, ')
          ..write('dosage: $dosage, ')
          ..write('metric: $metric, ')
          ..write('quantity: $quantity, ')
          ..write('time: $time')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, updatedAt, deletedAt, syncState,
      localUpdatedAt, date, name, dosage, metric, quantity, time);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MedicationMetric &&
          other.id == this.id &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.syncState == this.syncState &&
          other.localUpdatedAt == this.localUpdatedAt &&
          other.date == this.date &&
          other.name == this.name &&
          other.dosage == this.dosage &&
          other.metric == this.metric &&
          other.quantity == this.quantity &&
          other.time == this.time);
}

class MedicationMetricsCompanion extends UpdateCompanion<MedicationMetric> {
  final Value<String> id;
  final Value<DateTime?> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> syncState;
  final Value<DateTime> localUpdatedAt;
  final Value<String> date;
  final Value<String> name;
  final Value<int> dosage;
  final Value<String> metric;
  final Value<int> quantity;
  final Value<String> time;
  final Value<int> rowid;
  const MedicationMetricsCompanion({
    this.id = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    this.localUpdatedAt = const Value.absent(),
    this.date = const Value.absent(),
    this.name = const Value.absent(),
    this.dosage = const Value.absent(),
    this.metric = const Value.absent(),
    this.quantity = const Value.absent(),
    this.time = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MedicationMetricsCompanion.insert({
    required String id,
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    required DateTime localUpdatedAt,
    required String date,
    this.name = const Value.absent(),
    this.dosage = const Value.absent(),
    this.metric = const Value.absent(),
    this.quantity = const Value.absent(),
    this.time = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        localUpdatedAt = Value(localUpdatedAt),
        date = Value(date);
  static Insertable<MedicationMetric> custom({
    Expression<String>? id,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? syncState,
    Expression<DateTime>? localUpdatedAt,
    Expression<String>? date,
    Expression<String>? name,
    Expression<int>? dosage,
    Expression<String>? metric,
    Expression<int>? quantity,
    Expression<String>? time,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncState != null) 'sync_state': syncState,
      if (localUpdatedAt != null) 'local_updated_at': localUpdatedAt,
      if (date != null) 'date': date,
      if (name != null) 'name': name,
      if (dosage != null) 'dosage': dosage,
      if (metric != null) 'metric': metric,
      if (quantity != null) 'quantity': quantity,
      if (time != null) 'time': time,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MedicationMetricsCompanion copyWith(
      {Value<String>? id,
      Value<DateTime?>? updatedAt,
      Value<DateTime?>? deletedAt,
      Value<String>? syncState,
      Value<DateTime>? localUpdatedAt,
      Value<String>? date,
      Value<String>? name,
      Value<int>? dosage,
      Value<String>? metric,
      Value<int>? quantity,
      Value<String>? time,
      Value<int>? rowid}) {
    return MedicationMetricsCompanion(
      id: id ?? this.id,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncState: syncState ?? this.syncState,
      localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
      date: date ?? this.date,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      metric: metric ?? this.metric,
      quantity: quantity ?? this.quantity,
      time: time ?? this.time,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(syncState.value);
    }
    if (localUpdatedAt.present) {
      map['local_updated_at'] = Variable<DateTime>(localUpdatedAt.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (dosage.present) {
      map['dosage'] = Variable<int>(dosage.value);
    }
    if (metric.present) {
      map['metric'] = Variable<String>(metric.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (time.present) {
      map['time'] = Variable<String>(time.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MedicationMetricsCompanion(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncState: $syncState, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('date: $date, ')
          ..write('name: $name, ')
          ..write('dosage: $dosage, ')
          ..write('metric: $metric, ')
          ..write('quantity: $quantity, ')
          ..write('time: $time, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExerciseMetricsTable extends ExerciseMetrics
    with TableInfo<$ExerciseMetricsTable, ExerciseMetric> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExerciseMetricsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _syncStateMeta =
      const VerificationMeta('syncState');
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
      'sync_state', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _localUpdatedAtMeta =
      const VerificationMeta('localUpdatedAt');
  @override
  late final GeneratedColumn<DateTime> localUpdatedAt =
      GeneratedColumn<DateTime>('local_updated_at', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
      'date', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _startedMeta =
      const VerificationMeta('started');
  @override
  late final GeneratedColumn<String> started = GeneratedColumn<String>(
      'started', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _endedMeta = const VerificationMeta('ended');
  @override
  late final GeneratedColumn<String> ended = GeneratedColumn<String>(
      'ended', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String> tags =
      GeneratedColumn<String>('tags', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              defaultValue: const Constant('[]'))
          .withConverter<List<String>>($ExerciseMetricsTable.$convertertags);
  static const VerificationMeta _noOfTimesMeta =
      const VerificationMeta('noOfTimes');
  @override
  late final GeneratedColumn<int> noOfTimes = GeneratedColumn<int>(
      'no_of_times', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        updatedAt,
        deletedAt,
        syncState,
        localUpdatedAt,
        date,
        name,
        started,
        ended,
        tags,
        noOfTimes
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exercise_metrics';
  @override
  VerificationContext validateIntegrity(Insertable<ExerciseMetric> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    if (data.containsKey('sync_state')) {
      context.handle(_syncStateMeta,
          syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta));
    }
    if (data.containsKey('local_updated_at')) {
      context.handle(
          _localUpdatedAtMeta,
          localUpdatedAt.isAcceptableOrUnknown(
              data['local_updated_at']!, _localUpdatedAtMeta));
    } else if (isInserting) {
      context.missing(_localUpdatedAtMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    }
    if (data.containsKey('started')) {
      context.handle(_startedMeta,
          started.isAcceptableOrUnknown(data['started']!, _startedMeta));
    }
    if (data.containsKey('ended')) {
      context.handle(
          _endedMeta, ended.isAcceptableOrUnknown(data['ended']!, _endedMeta));
    }
    if (data.containsKey('no_of_times')) {
      context.handle(
          _noOfTimesMeta,
          noOfTimes.isAcceptableOrUnknown(
              data['no_of_times']!, _noOfTimesMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ExerciseMetric map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExerciseMetric(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at']),
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
      syncState: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_state'])!,
      localUpdatedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}local_updated_at'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}date'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      started: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}started'])!,
      ended: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}ended'])!,
      tags: $ExerciseMetricsTable.$convertertags.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tags'])!),
      noOfTimes: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}no_of_times'])!,
    );
  }

  @override
  $ExerciseMetricsTable createAlias(String alias) {
    return $ExerciseMetricsTable(attachedDatabase, alias);
  }

  static TypeConverter<List<String>, String> $convertertags =
      const StringListConverter();
}

class ExerciseMetric extends DataClass implements Insertable<ExerciseMetric> {
  final String id;
  final DateTime? updatedAt;
  final DateTime? deletedAt;
  final String syncState;
  final DateTime localUpdatedAt;
  final String date;
  final String name;
  final String started;
  final String ended;
  final List<String> tags;
  final int noOfTimes;
  const ExerciseMetric(
      {required this.id,
      this.updatedAt,
      this.deletedAt,
      required this.syncState,
      required this.localUpdatedAt,
      required this.date,
      required this.name,
      required this.started,
      required this.ended,
      required this.tags,
      required this.noOfTimes});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['sync_state'] = Variable<String>(syncState);
    map['local_updated_at'] = Variable<DateTime>(localUpdatedAt);
    map['date'] = Variable<String>(date);
    map['name'] = Variable<String>(name);
    map['started'] = Variable<String>(started);
    map['ended'] = Variable<String>(ended);
    {
      map['tags'] =
          Variable<String>($ExerciseMetricsTable.$convertertags.toSql(tags));
    }
    map['no_of_times'] = Variable<int>(noOfTimes);
    return map;
  }

  ExerciseMetricsCompanion toCompanion(bool nullToAbsent) {
    return ExerciseMetricsCompanion(
      id: Value(id),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncState: Value(syncState),
      localUpdatedAt: Value(localUpdatedAt),
      date: Value(date),
      name: Value(name),
      started: Value(started),
      ended: Value(ended),
      tags: Value(tags),
      noOfTimes: Value(noOfTimes),
    );
  }

  factory ExerciseMetric.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExerciseMetric(
      id: serializer.fromJson<String>(json['id']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      syncState: serializer.fromJson<String>(json['syncState']),
      localUpdatedAt: serializer.fromJson<DateTime>(json['localUpdatedAt']),
      date: serializer.fromJson<String>(json['date']),
      name: serializer.fromJson<String>(json['name']),
      started: serializer.fromJson<String>(json['started']),
      ended: serializer.fromJson<String>(json['ended']),
      tags: serializer.fromJson<List<String>>(json['tags']),
      noOfTimes: serializer.fromJson<int>(json['noOfTimes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'syncState': serializer.toJson<String>(syncState),
      'localUpdatedAt': serializer.toJson<DateTime>(localUpdatedAt),
      'date': serializer.toJson<String>(date),
      'name': serializer.toJson<String>(name),
      'started': serializer.toJson<String>(started),
      'ended': serializer.toJson<String>(ended),
      'tags': serializer.toJson<List<String>>(tags),
      'noOfTimes': serializer.toJson<int>(noOfTimes),
    };
  }

  ExerciseMetric copyWith(
          {String? id,
          Value<DateTime?> updatedAt = const Value.absent(),
          Value<DateTime?> deletedAt = const Value.absent(),
          String? syncState,
          DateTime? localUpdatedAt,
          String? date,
          String? name,
          String? started,
          String? ended,
          List<String>? tags,
          int? noOfTimes}) =>
      ExerciseMetric(
        id: id ?? this.id,
        updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        syncState: syncState ?? this.syncState,
        localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
        date: date ?? this.date,
        name: name ?? this.name,
        started: started ?? this.started,
        ended: ended ?? this.ended,
        tags: tags ?? this.tags,
        noOfTimes: noOfTimes ?? this.noOfTimes,
      );
  ExerciseMetric copyWithCompanion(ExerciseMetricsCompanion data) {
    return ExerciseMetric(
      id: data.id.present ? data.id.value : this.id,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
      localUpdatedAt: data.localUpdatedAt.present
          ? data.localUpdatedAt.value
          : this.localUpdatedAt,
      date: data.date.present ? data.date.value : this.date,
      name: data.name.present ? data.name.value : this.name,
      started: data.started.present ? data.started.value : this.started,
      ended: data.ended.present ? data.ended.value : this.ended,
      tags: data.tags.present ? data.tags.value : this.tags,
      noOfTimes: data.noOfTimes.present ? data.noOfTimes.value : this.noOfTimes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExerciseMetric(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncState: $syncState, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('date: $date, ')
          ..write('name: $name, ')
          ..write('started: $started, ')
          ..write('ended: $ended, ')
          ..write('tags: $tags, ')
          ..write('noOfTimes: $noOfTimes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, updatedAt, deletedAt, syncState,
      localUpdatedAt, date, name, started, ended, tags, noOfTimes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExerciseMetric &&
          other.id == this.id &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.syncState == this.syncState &&
          other.localUpdatedAt == this.localUpdatedAt &&
          other.date == this.date &&
          other.name == this.name &&
          other.started == this.started &&
          other.ended == this.ended &&
          other.tags == this.tags &&
          other.noOfTimes == this.noOfTimes);
}

class ExerciseMetricsCompanion extends UpdateCompanion<ExerciseMetric> {
  final Value<String> id;
  final Value<DateTime?> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> syncState;
  final Value<DateTime> localUpdatedAt;
  final Value<String> date;
  final Value<String> name;
  final Value<String> started;
  final Value<String> ended;
  final Value<List<String>> tags;
  final Value<int> noOfTimes;
  final Value<int> rowid;
  const ExerciseMetricsCompanion({
    this.id = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    this.localUpdatedAt = const Value.absent(),
    this.date = const Value.absent(),
    this.name = const Value.absent(),
    this.started = const Value.absent(),
    this.ended = const Value.absent(),
    this.tags = const Value.absent(),
    this.noOfTimes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExerciseMetricsCompanion.insert({
    required String id,
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    required DateTime localUpdatedAt,
    required String date,
    this.name = const Value.absent(),
    this.started = const Value.absent(),
    this.ended = const Value.absent(),
    this.tags = const Value.absent(),
    this.noOfTimes = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        localUpdatedAt = Value(localUpdatedAt),
        date = Value(date);
  static Insertable<ExerciseMetric> custom({
    Expression<String>? id,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? syncState,
    Expression<DateTime>? localUpdatedAt,
    Expression<String>? date,
    Expression<String>? name,
    Expression<String>? started,
    Expression<String>? ended,
    Expression<String>? tags,
    Expression<int>? noOfTimes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncState != null) 'sync_state': syncState,
      if (localUpdatedAt != null) 'local_updated_at': localUpdatedAt,
      if (date != null) 'date': date,
      if (name != null) 'name': name,
      if (started != null) 'started': started,
      if (ended != null) 'ended': ended,
      if (tags != null) 'tags': tags,
      if (noOfTimes != null) 'no_of_times': noOfTimes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExerciseMetricsCompanion copyWith(
      {Value<String>? id,
      Value<DateTime?>? updatedAt,
      Value<DateTime?>? deletedAt,
      Value<String>? syncState,
      Value<DateTime>? localUpdatedAt,
      Value<String>? date,
      Value<String>? name,
      Value<String>? started,
      Value<String>? ended,
      Value<List<String>>? tags,
      Value<int>? noOfTimes,
      Value<int>? rowid}) {
    return ExerciseMetricsCompanion(
      id: id ?? this.id,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncState: syncState ?? this.syncState,
      localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
      date: date ?? this.date,
      name: name ?? this.name,
      started: started ?? this.started,
      ended: ended ?? this.ended,
      tags: tags ?? this.tags,
      noOfTimes: noOfTimes ?? this.noOfTimes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(syncState.value);
    }
    if (localUpdatedAt.present) {
      map['local_updated_at'] = Variable<DateTime>(localUpdatedAt.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (started.present) {
      map['started'] = Variable<String>(started.value);
    }
    if (ended.present) {
      map['ended'] = Variable<String>(ended.value);
    }
    if (tags.present) {
      map['tags'] = Variable<String>(
          $ExerciseMetricsTable.$convertertags.toSql(tags.value));
    }
    if (noOfTimes.present) {
      map['no_of_times'] = Variable<int>(noOfTimes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExerciseMetricsCompanion(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncState: $syncState, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('date: $date, ')
          ..write('name: $name, ')
          ..write('started: $started, ')
          ..write('ended: $ended, ')
          ..write('tags: $tags, ')
          ..write('noOfTimes: $noOfTimes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UrineMetricsTable extends UrineMetrics
    with TableInfo<$UrineMetricsTable, UrineMetric> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UrineMetricsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _syncStateMeta =
      const VerificationMeta('syncState');
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
      'sync_state', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _localUpdatedAtMeta =
      const VerificationMeta('localUpdatedAt');
  @override
  late final GeneratedColumn<DateTime> localUpdatedAt =
      GeneratedColumn<DateTime>('local_updated_at', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
      'date', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<int> type = GeneratedColumn<int>(
      'type', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _painMeta = const VerificationMeta('pain');
  @override
  late final GeneratedColumn<double> pain = GeneratedColumn<double>(
      'pain', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _timeMeta = const VerificationMeta('time');
  @override
  late final GeneratedColumn<String> time = GeneratedColumn<String>(
      'time', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String> tags =
      GeneratedColumn<String>('tags', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              defaultValue: const Constant('[]'))
          .withConverter<List<String>>($UrineMetricsTable.$convertertags);
  static const VerificationMeta _quantityMeta =
      const VerificationMeta('quantity');
  @override
  late final GeneratedColumn<double> quantity = GeneratedColumn<double>(
      'quantity', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        updatedAt,
        deletedAt,
        syncState,
        localUpdatedAt,
        date,
        type,
        pain,
        time,
        tags,
        quantity
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'urine_metrics';
  @override
  VerificationContext validateIntegrity(Insertable<UrineMetric> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    if (data.containsKey('sync_state')) {
      context.handle(_syncStateMeta,
          syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta));
    }
    if (data.containsKey('local_updated_at')) {
      context.handle(
          _localUpdatedAtMeta,
          localUpdatedAt.isAcceptableOrUnknown(
              data['local_updated_at']!, _localUpdatedAtMeta));
    } else if (isInserting) {
      context.missing(_localUpdatedAtMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    }
    if (data.containsKey('pain')) {
      context.handle(
          _painMeta, pain.isAcceptableOrUnknown(data['pain']!, _painMeta));
    }
    if (data.containsKey('time')) {
      context.handle(
          _timeMeta, time.isAcceptableOrUnknown(data['time']!, _timeMeta));
    }
    if (data.containsKey('quantity')) {
      context.handle(_quantityMeta,
          quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UrineMetric map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UrineMetric(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at']),
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
      syncState: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_state'])!,
      localUpdatedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}local_updated_at'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}date'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}type'])!,
      pain: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}pain'])!,
      time: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}time'])!,
      tags: $UrineMetricsTable.$convertertags.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tags'])!),
      quantity: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}quantity'])!,
    );
  }

  @override
  $UrineMetricsTable createAlias(String alias) {
    return $UrineMetricsTable(attachedDatabase, alias);
  }

  static TypeConverter<List<String>, String> $convertertags =
      const StringListConverter();
}

class UrineMetric extends DataClass implements Insertable<UrineMetric> {
  final String id;
  final DateTime? updatedAt;
  final DateTime? deletedAt;
  final String syncState;
  final DateTime localUpdatedAt;
  final String date;
  final int type;
  final double pain;
  final String time;
  final List<String> tags;
  final double quantity;
  const UrineMetric(
      {required this.id,
      this.updatedAt,
      this.deletedAt,
      required this.syncState,
      required this.localUpdatedAt,
      required this.date,
      required this.type,
      required this.pain,
      required this.time,
      required this.tags,
      required this.quantity});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['sync_state'] = Variable<String>(syncState);
    map['local_updated_at'] = Variable<DateTime>(localUpdatedAt);
    map['date'] = Variable<String>(date);
    map['type'] = Variable<int>(type);
    map['pain'] = Variable<double>(pain);
    map['time'] = Variable<String>(time);
    {
      map['tags'] =
          Variable<String>($UrineMetricsTable.$convertertags.toSql(tags));
    }
    map['quantity'] = Variable<double>(quantity);
    return map;
  }

  UrineMetricsCompanion toCompanion(bool nullToAbsent) {
    return UrineMetricsCompanion(
      id: Value(id),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncState: Value(syncState),
      localUpdatedAt: Value(localUpdatedAt),
      date: Value(date),
      type: Value(type),
      pain: Value(pain),
      time: Value(time),
      tags: Value(tags),
      quantity: Value(quantity),
    );
  }

  factory UrineMetric.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UrineMetric(
      id: serializer.fromJson<String>(json['id']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      syncState: serializer.fromJson<String>(json['syncState']),
      localUpdatedAt: serializer.fromJson<DateTime>(json['localUpdatedAt']),
      date: serializer.fromJson<String>(json['date']),
      type: serializer.fromJson<int>(json['type']),
      pain: serializer.fromJson<double>(json['pain']),
      time: serializer.fromJson<String>(json['time']),
      tags: serializer.fromJson<List<String>>(json['tags']),
      quantity: serializer.fromJson<double>(json['quantity']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'syncState': serializer.toJson<String>(syncState),
      'localUpdatedAt': serializer.toJson<DateTime>(localUpdatedAt),
      'date': serializer.toJson<String>(date),
      'type': serializer.toJson<int>(type),
      'pain': serializer.toJson<double>(pain),
      'time': serializer.toJson<String>(time),
      'tags': serializer.toJson<List<String>>(tags),
      'quantity': serializer.toJson<double>(quantity),
    };
  }

  UrineMetric copyWith(
          {String? id,
          Value<DateTime?> updatedAt = const Value.absent(),
          Value<DateTime?> deletedAt = const Value.absent(),
          String? syncState,
          DateTime? localUpdatedAt,
          String? date,
          int? type,
          double? pain,
          String? time,
          List<String>? tags,
          double? quantity}) =>
      UrineMetric(
        id: id ?? this.id,
        updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        syncState: syncState ?? this.syncState,
        localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
        date: date ?? this.date,
        type: type ?? this.type,
        pain: pain ?? this.pain,
        time: time ?? this.time,
        tags: tags ?? this.tags,
        quantity: quantity ?? this.quantity,
      );
  UrineMetric copyWithCompanion(UrineMetricsCompanion data) {
    return UrineMetric(
      id: data.id.present ? data.id.value : this.id,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
      localUpdatedAt: data.localUpdatedAt.present
          ? data.localUpdatedAt.value
          : this.localUpdatedAt,
      date: data.date.present ? data.date.value : this.date,
      type: data.type.present ? data.type.value : this.type,
      pain: data.pain.present ? data.pain.value : this.pain,
      time: data.time.present ? data.time.value : this.time,
      tags: data.tags.present ? data.tags.value : this.tags,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UrineMetric(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncState: $syncState, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('date: $date, ')
          ..write('type: $type, ')
          ..write('pain: $pain, ')
          ..write('time: $time, ')
          ..write('tags: $tags, ')
          ..write('quantity: $quantity')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, updatedAt, deletedAt, syncState,
      localUpdatedAt, date, type, pain, time, tags, quantity);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UrineMetric &&
          other.id == this.id &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.syncState == this.syncState &&
          other.localUpdatedAt == this.localUpdatedAt &&
          other.date == this.date &&
          other.type == this.type &&
          other.pain == this.pain &&
          other.time == this.time &&
          other.tags == this.tags &&
          other.quantity == this.quantity);
}

class UrineMetricsCompanion extends UpdateCompanion<UrineMetric> {
  final Value<String> id;
  final Value<DateTime?> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> syncState;
  final Value<DateTime> localUpdatedAt;
  final Value<String> date;
  final Value<int> type;
  final Value<double> pain;
  final Value<String> time;
  final Value<List<String>> tags;
  final Value<double> quantity;
  final Value<int> rowid;
  const UrineMetricsCompanion({
    this.id = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    this.localUpdatedAt = const Value.absent(),
    this.date = const Value.absent(),
    this.type = const Value.absent(),
    this.pain = const Value.absent(),
    this.time = const Value.absent(),
    this.tags = const Value.absent(),
    this.quantity = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UrineMetricsCompanion.insert({
    required String id,
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    required DateTime localUpdatedAt,
    required String date,
    this.type = const Value.absent(),
    this.pain = const Value.absent(),
    this.time = const Value.absent(),
    this.tags = const Value.absent(),
    this.quantity = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        localUpdatedAt = Value(localUpdatedAt),
        date = Value(date);
  static Insertable<UrineMetric> custom({
    Expression<String>? id,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? syncState,
    Expression<DateTime>? localUpdatedAt,
    Expression<String>? date,
    Expression<int>? type,
    Expression<double>? pain,
    Expression<String>? time,
    Expression<String>? tags,
    Expression<double>? quantity,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncState != null) 'sync_state': syncState,
      if (localUpdatedAt != null) 'local_updated_at': localUpdatedAt,
      if (date != null) 'date': date,
      if (type != null) 'type': type,
      if (pain != null) 'pain': pain,
      if (time != null) 'time': time,
      if (tags != null) 'tags': tags,
      if (quantity != null) 'quantity': quantity,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UrineMetricsCompanion copyWith(
      {Value<String>? id,
      Value<DateTime?>? updatedAt,
      Value<DateTime?>? deletedAt,
      Value<String>? syncState,
      Value<DateTime>? localUpdatedAt,
      Value<String>? date,
      Value<int>? type,
      Value<double>? pain,
      Value<String>? time,
      Value<List<String>>? tags,
      Value<double>? quantity,
      Value<int>? rowid}) {
    return UrineMetricsCompanion(
      id: id ?? this.id,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncState: syncState ?? this.syncState,
      localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
      date: date ?? this.date,
      type: type ?? this.type,
      pain: pain ?? this.pain,
      time: time ?? this.time,
      tags: tags ?? this.tags,
      quantity: quantity ?? this.quantity,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(syncState.value);
    }
    if (localUpdatedAt.present) {
      map['local_updated_at'] = Variable<DateTime>(localUpdatedAt.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (type.present) {
      map['type'] = Variable<int>(type.value);
    }
    if (pain.present) {
      map['pain'] = Variable<double>(pain.value);
    }
    if (time.present) {
      map['time'] = Variable<String>(time.value);
    }
    if (tags.present) {
      map['tags'] =
          Variable<String>($UrineMetricsTable.$convertertags.toSql(tags.value));
    }
    if (quantity.present) {
      map['quantity'] = Variable<double>(quantity.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UrineMetricsCompanion(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncState: $syncState, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('date: $date, ')
          ..write('type: $type, ')
          ..write('pain: $pain, ')
          ..write('time: $time, ')
          ..write('tags: $tags, ')
          ..write('quantity: $quantity, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BowelMetricsTable extends BowelMetrics
    with TableInfo<$BowelMetricsTable, BowelMetric> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BowelMetricsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _syncStateMeta =
      const VerificationMeta('syncState');
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
      'sync_state', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _localUpdatedAtMeta =
      const VerificationMeta('localUpdatedAt');
  @override
  late final GeneratedColumn<DateTime> localUpdatedAt =
      GeneratedColumn<DateTime>('local_updated_at', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
      'date', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<int> type = GeneratedColumn<int>(
      'type', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _painMeta = const VerificationMeta('pain');
  @override
  late final GeneratedColumn<double> pain = GeneratedColumn<double>(
      'pain', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _timeMeta = const VerificationMeta('time');
  @override
  late final GeneratedColumn<String> time = GeneratedColumn<String>(
      'time', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String> tags =
      GeneratedColumn<String>('tags', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              defaultValue: const Constant('[]'))
          .withConverter<List<String>>($BowelMetricsTable.$convertertags);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        updatedAt,
        deletedAt,
        syncState,
        localUpdatedAt,
        date,
        type,
        pain,
        time,
        tags
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bowel_metrics';
  @override
  VerificationContext validateIntegrity(Insertable<BowelMetric> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    if (data.containsKey('sync_state')) {
      context.handle(_syncStateMeta,
          syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta));
    }
    if (data.containsKey('local_updated_at')) {
      context.handle(
          _localUpdatedAtMeta,
          localUpdatedAt.isAcceptableOrUnknown(
              data['local_updated_at']!, _localUpdatedAtMeta));
    } else if (isInserting) {
      context.missing(_localUpdatedAtMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    }
    if (data.containsKey('pain')) {
      context.handle(
          _painMeta, pain.isAcceptableOrUnknown(data['pain']!, _painMeta));
    }
    if (data.containsKey('time')) {
      context.handle(
          _timeMeta, time.isAcceptableOrUnknown(data['time']!, _timeMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BowelMetric map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BowelMetric(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at']),
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
      syncState: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_state'])!,
      localUpdatedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}local_updated_at'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}date'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}type'])!,
      pain: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}pain'])!,
      time: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}time'])!,
      tags: $BowelMetricsTable.$convertertags.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tags'])!),
    );
  }

  @override
  $BowelMetricsTable createAlias(String alias) {
    return $BowelMetricsTable(attachedDatabase, alias);
  }

  static TypeConverter<List<String>, String> $convertertags =
      const StringListConverter();
}

class BowelMetric extends DataClass implements Insertable<BowelMetric> {
  final String id;
  final DateTime? updatedAt;
  final DateTime? deletedAt;
  final String syncState;
  final DateTime localUpdatedAt;
  final String date;
  final int type;
  final double pain;
  final String time;
  final List<String> tags;
  const BowelMetric(
      {required this.id,
      this.updatedAt,
      this.deletedAt,
      required this.syncState,
      required this.localUpdatedAt,
      required this.date,
      required this.type,
      required this.pain,
      required this.time,
      required this.tags});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['sync_state'] = Variable<String>(syncState);
    map['local_updated_at'] = Variable<DateTime>(localUpdatedAt);
    map['date'] = Variable<String>(date);
    map['type'] = Variable<int>(type);
    map['pain'] = Variable<double>(pain);
    map['time'] = Variable<String>(time);
    {
      map['tags'] =
          Variable<String>($BowelMetricsTable.$convertertags.toSql(tags));
    }
    return map;
  }

  BowelMetricsCompanion toCompanion(bool nullToAbsent) {
    return BowelMetricsCompanion(
      id: Value(id),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncState: Value(syncState),
      localUpdatedAt: Value(localUpdatedAt),
      date: Value(date),
      type: Value(type),
      pain: Value(pain),
      time: Value(time),
      tags: Value(tags),
    );
  }

  factory BowelMetric.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BowelMetric(
      id: serializer.fromJson<String>(json['id']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      syncState: serializer.fromJson<String>(json['syncState']),
      localUpdatedAt: serializer.fromJson<DateTime>(json['localUpdatedAt']),
      date: serializer.fromJson<String>(json['date']),
      type: serializer.fromJson<int>(json['type']),
      pain: serializer.fromJson<double>(json['pain']),
      time: serializer.fromJson<String>(json['time']),
      tags: serializer.fromJson<List<String>>(json['tags']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'syncState': serializer.toJson<String>(syncState),
      'localUpdatedAt': serializer.toJson<DateTime>(localUpdatedAt),
      'date': serializer.toJson<String>(date),
      'type': serializer.toJson<int>(type),
      'pain': serializer.toJson<double>(pain),
      'time': serializer.toJson<String>(time),
      'tags': serializer.toJson<List<String>>(tags),
    };
  }

  BowelMetric copyWith(
          {String? id,
          Value<DateTime?> updatedAt = const Value.absent(),
          Value<DateTime?> deletedAt = const Value.absent(),
          String? syncState,
          DateTime? localUpdatedAt,
          String? date,
          int? type,
          double? pain,
          String? time,
          List<String>? tags}) =>
      BowelMetric(
        id: id ?? this.id,
        updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        syncState: syncState ?? this.syncState,
        localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
        date: date ?? this.date,
        type: type ?? this.type,
        pain: pain ?? this.pain,
        time: time ?? this.time,
        tags: tags ?? this.tags,
      );
  BowelMetric copyWithCompanion(BowelMetricsCompanion data) {
    return BowelMetric(
      id: data.id.present ? data.id.value : this.id,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
      localUpdatedAt: data.localUpdatedAt.present
          ? data.localUpdatedAt.value
          : this.localUpdatedAt,
      date: data.date.present ? data.date.value : this.date,
      type: data.type.present ? data.type.value : this.type,
      pain: data.pain.present ? data.pain.value : this.pain,
      time: data.time.present ? data.time.value : this.time,
      tags: data.tags.present ? data.tags.value : this.tags,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BowelMetric(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncState: $syncState, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('date: $date, ')
          ..write('type: $type, ')
          ..write('pain: $pain, ')
          ..write('time: $time, ')
          ..write('tags: $tags')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, updatedAt, deletedAt, syncState,
      localUpdatedAt, date, type, pain, time, tags);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BowelMetric &&
          other.id == this.id &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.syncState == this.syncState &&
          other.localUpdatedAt == this.localUpdatedAt &&
          other.date == this.date &&
          other.type == this.type &&
          other.pain == this.pain &&
          other.time == this.time &&
          other.tags == this.tags);
}

class BowelMetricsCompanion extends UpdateCompanion<BowelMetric> {
  final Value<String> id;
  final Value<DateTime?> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> syncState;
  final Value<DateTime> localUpdatedAt;
  final Value<String> date;
  final Value<int> type;
  final Value<double> pain;
  final Value<String> time;
  final Value<List<String>> tags;
  final Value<int> rowid;
  const BowelMetricsCompanion({
    this.id = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    this.localUpdatedAt = const Value.absent(),
    this.date = const Value.absent(),
    this.type = const Value.absent(),
    this.pain = const Value.absent(),
    this.time = const Value.absent(),
    this.tags = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BowelMetricsCompanion.insert({
    required String id,
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    required DateTime localUpdatedAt,
    required String date,
    this.type = const Value.absent(),
    this.pain = const Value.absent(),
    this.time = const Value.absent(),
    this.tags = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        localUpdatedAt = Value(localUpdatedAt),
        date = Value(date);
  static Insertable<BowelMetric> custom({
    Expression<String>? id,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? syncState,
    Expression<DateTime>? localUpdatedAt,
    Expression<String>? date,
    Expression<int>? type,
    Expression<double>? pain,
    Expression<String>? time,
    Expression<String>? tags,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncState != null) 'sync_state': syncState,
      if (localUpdatedAt != null) 'local_updated_at': localUpdatedAt,
      if (date != null) 'date': date,
      if (type != null) 'type': type,
      if (pain != null) 'pain': pain,
      if (time != null) 'time': time,
      if (tags != null) 'tags': tags,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BowelMetricsCompanion copyWith(
      {Value<String>? id,
      Value<DateTime?>? updatedAt,
      Value<DateTime?>? deletedAt,
      Value<String>? syncState,
      Value<DateTime>? localUpdatedAt,
      Value<String>? date,
      Value<int>? type,
      Value<double>? pain,
      Value<String>? time,
      Value<List<String>>? tags,
      Value<int>? rowid}) {
    return BowelMetricsCompanion(
      id: id ?? this.id,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncState: syncState ?? this.syncState,
      localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
      date: date ?? this.date,
      type: type ?? this.type,
      pain: pain ?? this.pain,
      time: time ?? this.time,
      tags: tags ?? this.tags,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(syncState.value);
    }
    if (localUpdatedAt.present) {
      map['local_updated_at'] = Variable<DateTime>(localUpdatedAt.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (type.present) {
      map['type'] = Variable<int>(type.value);
    }
    if (pain.present) {
      map['pain'] = Variable<double>(pain.value);
    }
    if (time.present) {
      map['time'] = Variable<String>(time.value);
    }
    if (tags.present) {
      map['tags'] =
          Variable<String>($BowelMetricsTable.$convertertags.toSql(tags.value));
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BowelMetricsCompanion(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncState: $syncState, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('date: $date, ')
          ..write('type: $type, ')
          ..write('pain: $pain, ')
          ..write('time: $time, ')
          ..write('tags: $tags, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MenstrualCyclesTable extends MenstrualCycles
    with TableInfo<$MenstrualCyclesTable, MenstrualCycle> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MenstrualCyclesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _syncStateMeta =
      const VerificationMeta('syncState');
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
      'sync_state', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _localUpdatedAtMeta =
      const VerificationMeta('localUpdatedAt');
  @override
  late final GeneratedColumn<DateTime> localUpdatedAt =
      GeneratedColumn<DateTime>('local_updated_at', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _startDateMeta =
      const VerificationMeta('startDate');
  @override
  late final GeneratedColumn<String> startDate = GeneratedColumn<String>(
      'start_date', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _cycleLengthMeta =
      const VerificationMeta('cycleLength');
  @override
  late final GeneratedColumn<int> cycleLength = GeneratedColumn<int>(
      'cycle_length', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(28));
  static const VerificationMeta _periodLengthMeta =
      const VerificationMeta('periodLength');
  @override
  late final GeneratedColumn<int> periodLength = GeneratedColumn<int>(
      'period_length', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(5));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        updatedAt,
        deletedAt,
        syncState,
        localUpdatedAt,
        startDate,
        cycleLength,
        periodLength
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'menstrual_cycles';
  @override
  VerificationContext validateIntegrity(Insertable<MenstrualCycle> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    if (data.containsKey('sync_state')) {
      context.handle(_syncStateMeta,
          syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta));
    }
    if (data.containsKey('local_updated_at')) {
      context.handle(
          _localUpdatedAtMeta,
          localUpdatedAt.isAcceptableOrUnknown(
              data['local_updated_at']!, _localUpdatedAtMeta));
    } else if (isInserting) {
      context.missing(_localUpdatedAtMeta);
    }
    if (data.containsKey('start_date')) {
      context.handle(_startDateMeta,
          startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta));
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('cycle_length')) {
      context.handle(
          _cycleLengthMeta,
          cycleLength.isAcceptableOrUnknown(
              data['cycle_length']!, _cycleLengthMeta));
    }
    if (data.containsKey('period_length')) {
      context.handle(
          _periodLengthMeta,
          periodLength.isAcceptableOrUnknown(
              data['period_length']!, _periodLengthMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MenstrualCycle map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MenstrualCycle(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at']),
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
      syncState: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_state'])!,
      localUpdatedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}local_updated_at'])!,
      startDate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}start_date'])!,
      cycleLength: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}cycle_length'])!,
      periodLength: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}period_length'])!,
    );
  }

  @override
  $MenstrualCyclesTable createAlias(String alias) {
    return $MenstrualCyclesTable(attachedDatabase, alias);
  }
}

class MenstrualCycle extends DataClass implements Insertable<MenstrualCycle> {
  final String id;
  final DateTime? updatedAt;
  final DateTime? deletedAt;
  final String syncState;
  final DateTime localUpdatedAt;
  final String startDate;
  final int cycleLength;
  final int periodLength;
  const MenstrualCycle(
      {required this.id,
      this.updatedAt,
      this.deletedAt,
      required this.syncState,
      required this.localUpdatedAt,
      required this.startDate,
      required this.cycleLength,
      required this.periodLength});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['sync_state'] = Variable<String>(syncState);
    map['local_updated_at'] = Variable<DateTime>(localUpdatedAt);
    map['start_date'] = Variable<String>(startDate);
    map['cycle_length'] = Variable<int>(cycleLength);
    map['period_length'] = Variable<int>(periodLength);
    return map;
  }

  MenstrualCyclesCompanion toCompanion(bool nullToAbsent) {
    return MenstrualCyclesCompanion(
      id: Value(id),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncState: Value(syncState),
      localUpdatedAt: Value(localUpdatedAt),
      startDate: Value(startDate),
      cycleLength: Value(cycleLength),
      periodLength: Value(periodLength),
    );
  }

  factory MenstrualCycle.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MenstrualCycle(
      id: serializer.fromJson<String>(json['id']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      syncState: serializer.fromJson<String>(json['syncState']),
      localUpdatedAt: serializer.fromJson<DateTime>(json['localUpdatedAt']),
      startDate: serializer.fromJson<String>(json['startDate']),
      cycleLength: serializer.fromJson<int>(json['cycleLength']),
      periodLength: serializer.fromJson<int>(json['periodLength']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'syncState': serializer.toJson<String>(syncState),
      'localUpdatedAt': serializer.toJson<DateTime>(localUpdatedAt),
      'startDate': serializer.toJson<String>(startDate),
      'cycleLength': serializer.toJson<int>(cycleLength),
      'periodLength': serializer.toJson<int>(periodLength),
    };
  }

  MenstrualCycle copyWith(
          {String? id,
          Value<DateTime?> updatedAt = const Value.absent(),
          Value<DateTime?> deletedAt = const Value.absent(),
          String? syncState,
          DateTime? localUpdatedAt,
          String? startDate,
          int? cycleLength,
          int? periodLength}) =>
      MenstrualCycle(
        id: id ?? this.id,
        updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        syncState: syncState ?? this.syncState,
        localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
        startDate: startDate ?? this.startDate,
        cycleLength: cycleLength ?? this.cycleLength,
        periodLength: periodLength ?? this.periodLength,
      );
  MenstrualCycle copyWithCompanion(MenstrualCyclesCompanion data) {
    return MenstrualCycle(
      id: data.id.present ? data.id.value : this.id,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
      localUpdatedAt: data.localUpdatedAt.present
          ? data.localUpdatedAt.value
          : this.localUpdatedAt,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      cycleLength:
          data.cycleLength.present ? data.cycleLength.value : this.cycleLength,
      periodLength: data.periodLength.present
          ? data.periodLength.value
          : this.periodLength,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MenstrualCycle(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncState: $syncState, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('startDate: $startDate, ')
          ..write('cycleLength: $cycleLength, ')
          ..write('periodLength: $periodLength')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, updatedAt, deletedAt, syncState,
      localUpdatedAt, startDate, cycleLength, periodLength);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MenstrualCycle &&
          other.id == this.id &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.syncState == this.syncState &&
          other.localUpdatedAt == this.localUpdatedAt &&
          other.startDate == this.startDate &&
          other.cycleLength == this.cycleLength &&
          other.periodLength == this.periodLength);
}

class MenstrualCyclesCompanion extends UpdateCompanion<MenstrualCycle> {
  final Value<String> id;
  final Value<DateTime?> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> syncState;
  final Value<DateTime> localUpdatedAt;
  final Value<String> startDate;
  final Value<int> cycleLength;
  final Value<int> periodLength;
  final Value<int> rowid;
  const MenstrualCyclesCompanion({
    this.id = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    this.localUpdatedAt = const Value.absent(),
    this.startDate = const Value.absent(),
    this.cycleLength = const Value.absent(),
    this.periodLength = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MenstrualCyclesCompanion.insert({
    required String id,
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    required DateTime localUpdatedAt,
    required String startDate,
    this.cycleLength = const Value.absent(),
    this.periodLength = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        localUpdatedAt = Value(localUpdatedAt),
        startDate = Value(startDate);
  static Insertable<MenstrualCycle> custom({
    Expression<String>? id,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? syncState,
    Expression<DateTime>? localUpdatedAt,
    Expression<String>? startDate,
    Expression<int>? cycleLength,
    Expression<int>? periodLength,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncState != null) 'sync_state': syncState,
      if (localUpdatedAt != null) 'local_updated_at': localUpdatedAt,
      if (startDate != null) 'start_date': startDate,
      if (cycleLength != null) 'cycle_length': cycleLength,
      if (periodLength != null) 'period_length': periodLength,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MenstrualCyclesCompanion copyWith(
      {Value<String>? id,
      Value<DateTime?>? updatedAt,
      Value<DateTime?>? deletedAt,
      Value<String>? syncState,
      Value<DateTime>? localUpdatedAt,
      Value<String>? startDate,
      Value<int>? cycleLength,
      Value<int>? periodLength,
      Value<int>? rowid}) {
    return MenstrualCyclesCompanion(
      id: id ?? this.id,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncState: syncState ?? this.syncState,
      localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
      startDate: startDate ?? this.startDate,
      cycleLength: cycleLength ?? this.cycleLength,
      periodLength: periodLength ?? this.periodLength,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(syncState.value);
    }
    if (localUpdatedAt.present) {
      map['local_updated_at'] = Variable<DateTime>(localUpdatedAt.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<String>(startDate.value);
    }
    if (cycleLength.present) {
      map['cycle_length'] = Variable<int>(cycleLength.value);
    }
    if (periodLength.present) {
      map['period_length'] = Variable<int>(periodLength.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MenstrualCyclesCompanion(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncState: $syncState, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('startDate: $startDate, ')
          ..write('cycleLength: $cycleLength, ')
          ..write('periodLength: $periodLength, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CycleDaysTable extends CycleDays
    with TableInfo<$CycleDaysTable, CycleDay> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CycleDaysTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _syncStateMeta =
      const VerificationMeta('syncState');
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
      'sync_state', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _localUpdatedAtMeta =
      const VerificationMeta('localUpdatedAt');
  @override
  late final GeneratedColumn<DateTime> localUpdatedAt =
      GeneratedColumn<DateTime>('local_updated_at', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _cycleIdMeta =
      const VerificationMeta('cycleId');
  @override
  late final GeneratedColumn<String> cycleId = GeneratedColumn<String>(
      'cycle_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
      'date', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isPeriodMeta =
      const VerificationMeta('isPeriod');
  @override
  late final GeneratedColumn<bool> isPeriod = GeneratedColumn<bool>(
      'is_period', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_period" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isOvulationMeta =
      const VerificationMeta('isOvulation');
  @override
  late final GeneratedColumn<bool> isOvulation = GeneratedColumn<bool>(
      'is_ovulation', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_ovulation" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _flowMeta = const VerificationMeta('flow');
  @override
  late final GeneratedColumn<double> flow = GeneratedColumn<double>(
      'flow', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _painMeta = const VerificationMeta('pain');
  @override
  late final GeneratedColumn<double> pain = GeneratedColumn<double>(
      'pain', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String> tags =
      GeneratedColumn<String>('tags', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              defaultValue: const Constant('[]'))
          .withConverter<List<String>>($CycleDaysTable.$convertertags);
  static const VerificationMeta _cmqMeta = const VerificationMeta('cmq');
  @override
  late final GeneratedColumn<String> cmq = GeneratedColumn<String>(
      'cmq', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        updatedAt,
        deletedAt,
        syncState,
        localUpdatedAt,
        cycleId,
        date,
        isPeriod,
        isOvulation,
        flow,
        pain,
        tags,
        cmq
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cycle_days';
  @override
  VerificationContext validateIntegrity(Insertable<CycleDay> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    if (data.containsKey('sync_state')) {
      context.handle(_syncStateMeta,
          syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta));
    }
    if (data.containsKey('local_updated_at')) {
      context.handle(
          _localUpdatedAtMeta,
          localUpdatedAt.isAcceptableOrUnknown(
              data['local_updated_at']!, _localUpdatedAtMeta));
    } else if (isInserting) {
      context.missing(_localUpdatedAtMeta);
    }
    if (data.containsKey('cycle_id')) {
      context.handle(_cycleIdMeta,
          cycleId.isAcceptableOrUnknown(data['cycle_id']!, _cycleIdMeta));
    } else if (isInserting) {
      context.missing(_cycleIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('is_period')) {
      context.handle(_isPeriodMeta,
          isPeriod.isAcceptableOrUnknown(data['is_period']!, _isPeriodMeta));
    }
    if (data.containsKey('is_ovulation')) {
      context.handle(
          _isOvulationMeta,
          isOvulation.isAcceptableOrUnknown(
              data['is_ovulation']!, _isOvulationMeta));
    }
    if (data.containsKey('flow')) {
      context.handle(
          _flowMeta, flow.isAcceptableOrUnknown(data['flow']!, _flowMeta));
    }
    if (data.containsKey('pain')) {
      context.handle(
          _painMeta, pain.isAcceptableOrUnknown(data['pain']!, _painMeta));
    }
    if (data.containsKey('cmq')) {
      context.handle(
          _cmqMeta, cmq.isAcceptableOrUnknown(data['cmq']!, _cmqMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CycleDay map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CycleDay(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at']),
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
      syncState: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_state'])!,
      localUpdatedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}local_updated_at'])!,
      cycleId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}cycle_id'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}date'])!,
      isPeriod: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_period'])!,
      isOvulation: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_ovulation'])!,
      flow: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}flow'])!,
      pain: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}pain'])!,
      tags: $CycleDaysTable.$convertertags.fromSql(attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tags'])!),
      cmq: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}cmq'])!,
    );
  }

  @override
  $CycleDaysTable createAlias(String alias) {
    return $CycleDaysTable(attachedDatabase, alias);
  }

  static TypeConverter<List<String>, String> $convertertags =
      const StringListConverter();
}

class CycleDay extends DataClass implements Insertable<CycleDay> {
  final String id;
  final DateTime? updatedAt;
  final DateTime? deletedAt;
  final String syncState;
  final DateTime localUpdatedAt;
  final String cycleId;
  final String date;
  final bool isPeriod;
  final bool isOvulation;
  final double flow;
  final double pain;
  final List<String> tags;
  final String cmq;
  const CycleDay(
      {required this.id,
      this.updatedAt,
      this.deletedAt,
      required this.syncState,
      required this.localUpdatedAt,
      required this.cycleId,
      required this.date,
      required this.isPeriod,
      required this.isOvulation,
      required this.flow,
      required this.pain,
      required this.tags,
      required this.cmq});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['sync_state'] = Variable<String>(syncState);
    map['local_updated_at'] = Variable<DateTime>(localUpdatedAt);
    map['cycle_id'] = Variable<String>(cycleId);
    map['date'] = Variable<String>(date);
    map['is_period'] = Variable<bool>(isPeriod);
    map['is_ovulation'] = Variable<bool>(isOvulation);
    map['flow'] = Variable<double>(flow);
    map['pain'] = Variable<double>(pain);
    {
      map['tags'] =
          Variable<String>($CycleDaysTable.$convertertags.toSql(tags));
    }
    map['cmq'] = Variable<String>(cmq);
    return map;
  }

  CycleDaysCompanion toCompanion(bool nullToAbsent) {
    return CycleDaysCompanion(
      id: Value(id),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncState: Value(syncState),
      localUpdatedAt: Value(localUpdatedAt),
      cycleId: Value(cycleId),
      date: Value(date),
      isPeriod: Value(isPeriod),
      isOvulation: Value(isOvulation),
      flow: Value(flow),
      pain: Value(pain),
      tags: Value(tags),
      cmq: Value(cmq),
    );
  }

  factory CycleDay.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CycleDay(
      id: serializer.fromJson<String>(json['id']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      syncState: serializer.fromJson<String>(json['syncState']),
      localUpdatedAt: serializer.fromJson<DateTime>(json['localUpdatedAt']),
      cycleId: serializer.fromJson<String>(json['cycleId']),
      date: serializer.fromJson<String>(json['date']),
      isPeriod: serializer.fromJson<bool>(json['isPeriod']),
      isOvulation: serializer.fromJson<bool>(json['isOvulation']),
      flow: serializer.fromJson<double>(json['flow']),
      pain: serializer.fromJson<double>(json['pain']),
      tags: serializer.fromJson<List<String>>(json['tags']),
      cmq: serializer.fromJson<String>(json['cmq']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'syncState': serializer.toJson<String>(syncState),
      'localUpdatedAt': serializer.toJson<DateTime>(localUpdatedAt),
      'cycleId': serializer.toJson<String>(cycleId),
      'date': serializer.toJson<String>(date),
      'isPeriod': serializer.toJson<bool>(isPeriod),
      'isOvulation': serializer.toJson<bool>(isOvulation),
      'flow': serializer.toJson<double>(flow),
      'pain': serializer.toJson<double>(pain),
      'tags': serializer.toJson<List<String>>(tags),
      'cmq': serializer.toJson<String>(cmq),
    };
  }

  CycleDay copyWith(
          {String? id,
          Value<DateTime?> updatedAt = const Value.absent(),
          Value<DateTime?> deletedAt = const Value.absent(),
          String? syncState,
          DateTime? localUpdatedAt,
          String? cycleId,
          String? date,
          bool? isPeriod,
          bool? isOvulation,
          double? flow,
          double? pain,
          List<String>? tags,
          String? cmq}) =>
      CycleDay(
        id: id ?? this.id,
        updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        syncState: syncState ?? this.syncState,
        localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
        cycleId: cycleId ?? this.cycleId,
        date: date ?? this.date,
        isPeriod: isPeriod ?? this.isPeriod,
        isOvulation: isOvulation ?? this.isOvulation,
        flow: flow ?? this.flow,
        pain: pain ?? this.pain,
        tags: tags ?? this.tags,
        cmq: cmq ?? this.cmq,
      );
  CycleDay copyWithCompanion(CycleDaysCompanion data) {
    return CycleDay(
      id: data.id.present ? data.id.value : this.id,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
      localUpdatedAt: data.localUpdatedAt.present
          ? data.localUpdatedAt.value
          : this.localUpdatedAt,
      cycleId: data.cycleId.present ? data.cycleId.value : this.cycleId,
      date: data.date.present ? data.date.value : this.date,
      isPeriod: data.isPeriod.present ? data.isPeriod.value : this.isPeriod,
      isOvulation:
          data.isOvulation.present ? data.isOvulation.value : this.isOvulation,
      flow: data.flow.present ? data.flow.value : this.flow,
      pain: data.pain.present ? data.pain.value : this.pain,
      tags: data.tags.present ? data.tags.value : this.tags,
      cmq: data.cmq.present ? data.cmq.value : this.cmq,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CycleDay(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncState: $syncState, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('cycleId: $cycleId, ')
          ..write('date: $date, ')
          ..write('isPeriod: $isPeriod, ')
          ..write('isOvulation: $isOvulation, ')
          ..write('flow: $flow, ')
          ..write('pain: $pain, ')
          ..write('tags: $tags, ')
          ..write('cmq: $cmq')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      updatedAt,
      deletedAt,
      syncState,
      localUpdatedAt,
      cycleId,
      date,
      isPeriod,
      isOvulation,
      flow,
      pain,
      tags,
      cmq);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CycleDay &&
          other.id == this.id &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.syncState == this.syncState &&
          other.localUpdatedAt == this.localUpdatedAt &&
          other.cycleId == this.cycleId &&
          other.date == this.date &&
          other.isPeriod == this.isPeriod &&
          other.isOvulation == this.isOvulation &&
          other.flow == this.flow &&
          other.pain == this.pain &&
          other.tags == this.tags &&
          other.cmq == this.cmq);
}

class CycleDaysCompanion extends UpdateCompanion<CycleDay> {
  final Value<String> id;
  final Value<DateTime?> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> syncState;
  final Value<DateTime> localUpdatedAt;
  final Value<String> cycleId;
  final Value<String> date;
  final Value<bool> isPeriod;
  final Value<bool> isOvulation;
  final Value<double> flow;
  final Value<double> pain;
  final Value<List<String>> tags;
  final Value<String> cmq;
  final Value<int> rowid;
  const CycleDaysCompanion({
    this.id = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    this.localUpdatedAt = const Value.absent(),
    this.cycleId = const Value.absent(),
    this.date = const Value.absent(),
    this.isPeriod = const Value.absent(),
    this.isOvulation = const Value.absent(),
    this.flow = const Value.absent(),
    this.pain = const Value.absent(),
    this.tags = const Value.absent(),
    this.cmq = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CycleDaysCompanion.insert({
    required String id,
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    required DateTime localUpdatedAt,
    required String cycleId,
    required String date,
    this.isPeriod = const Value.absent(),
    this.isOvulation = const Value.absent(),
    this.flow = const Value.absent(),
    this.pain = const Value.absent(),
    this.tags = const Value.absent(),
    this.cmq = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        localUpdatedAt = Value(localUpdatedAt),
        cycleId = Value(cycleId),
        date = Value(date);
  static Insertable<CycleDay> custom({
    Expression<String>? id,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? syncState,
    Expression<DateTime>? localUpdatedAt,
    Expression<String>? cycleId,
    Expression<String>? date,
    Expression<bool>? isPeriod,
    Expression<bool>? isOvulation,
    Expression<double>? flow,
    Expression<double>? pain,
    Expression<String>? tags,
    Expression<String>? cmq,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncState != null) 'sync_state': syncState,
      if (localUpdatedAt != null) 'local_updated_at': localUpdatedAt,
      if (cycleId != null) 'cycle_id': cycleId,
      if (date != null) 'date': date,
      if (isPeriod != null) 'is_period': isPeriod,
      if (isOvulation != null) 'is_ovulation': isOvulation,
      if (flow != null) 'flow': flow,
      if (pain != null) 'pain': pain,
      if (tags != null) 'tags': tags,
      if (cmq != null) 'cmq': cmq,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CycleDaysCompanion copyWith(
      {Value<String>? id,
      Value<DateTime?>? updatedAt,
      Value<DateTime?>? deletedAt,
      Value<String>? syncState,
      Value<DateTime>? localUpdatedAt,
      Value<String>? cycleId,
      Value<String>? date,
      Value<bool>? isPeriod,
      Value<bool>? isOvulation,
      Value<double>? flow,
      Value<double>? pain,
      Value<List<String>>? tags,
      Value<String>? cmq,
      Value<int>? rowid}) {
    return CycleDaysCompanion(
      id: id ?? this.id,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncState: syncState ?? this.syncState,
      localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
      cycleId: cycleId ?? this.cycleId,
      date: date ?? this.date,
      isPeriod: isPeriod ?? this.isPeriod,
      isOvulation: isOvulation ?? this.isOvulation,
      flow: flow ?? this.flow,
      pain: pain ?? this.pain,
      tags: tags ?? this.tags,
      cmq: cmq ?? this.cmq,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(syncState.value);
    }
    if (localUpdatedAt.present) {
      map['local_updated_at'] = Variable<DateTime>(localUpdatedAt.value);
    }
    if (cycleId.present) {
      map['cycle_id'] = Variable<String>(cycleId.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (isPeriod.present) {
      map['is_period'] = Variable<bool>(isPeriod.value);
    }
    if (isOvulation.present) {
      map['is_ovulation'] = Variable<bool>(isOvulation.value);
    }
    if (flow.present) {
      map['flow'] = Variable<double>(flow.value);
    }
    if (pain.present) {
      map['pain'] = Variable<double>(pain.value);
    }
    if (tags.present) {
      map['tags'] =
          Variable<String>($CycleDaysTable.$convertertags.toSql(tags.value));
    }
    if (cmq.present) {
      map['cmq'] = Variable<String>(cmq.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CycleDaysCompanion(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncState: $syncState, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('cycleId: $cycleId, ')
          ..write('date: $date, ')
          ..write('isPeriod: $isPeriod, ')
          ..write('isOvulation: $isOvulation, ')
          ..write('flow: $flow, ')
          ..write('pain: $pain, ')
          ..write('tags: $tags, ')
          ..write('cmq: $cmq, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SmileyEntriesTable extends SmileyEntries
    with TableInfo<$SmileyEntriesTable, SmileyEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SmileyEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _syncStateMeta =
      const VerificationMeta('syncState');
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
      'sync_state', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _localUpdatedAtMeta =
      const VerificationMeta('localUpdatedAt');
  @override
  late final GeneratedColumn<DateTime> localUpdatedAt =
      GeneratedColumn<DateTime>('local_updated_at', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _smileyIdMeta =
      const VerificationMeta('smileyId');
  @override
  late final GeneratedColumn<int> smileyId = GeneratedColumn<int>(
      'smiley_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String> tags =
      GeneratedColumn<String>('tags', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              defaultValue: const Constant('[]'))
          .withConverter<List<String>>($SmileyEntriesTable.$convertertags);
  static const VerificationMeta _grantedAtMeta =
      const VerificationMeta('grantedAt');
  @override
  late final GeneratedColumn<DateTime> grantedAt = GeneratedColumn<DateTime>(
      'granted_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        updatedAt,
        deletedAt,
        syncState,
        localUpdatedAt,
        smileyId,
        tags,
        grantedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'smiley_entries';
  @override
  VerificationContext validateIntegrity(Insertable<SmileyEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    if (data.containsKey('sync_state')) {
      context.handle(_syncStateMeta,
          syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta));
    }
    if (data.containsKey('local_updated_at')) {
      context.handle(
          _localUpdatedAtMeta,
          localUpdatedAt.isAcceptableOrUnknown(
              data['local_updated_at']!, _localUpdatedAtMeta));
    } else if (isInserting) {
      context.missing(_localUpdatedAtMeta);
    }
    if (data.containsKey('smiley_id')) {
      context.handle(_smileyIdMeta,
          smileyId.isAcceptableOrUnknown(data['smiley_id']!, _smileyIdMeta));
    } else if (isInserting) {
      context.missing(_smileyIdMeta);
    }
    if (data.containsKey('granted_at')) {
      context.handle(_grantedAtMeta,
          grantedAt.isAcceptableOrUnknown(data['granted_at']!, _grantedAtMeta));
    } else if (isInserting) {
      context.missing(_grantedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SmileyEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SmileyEntry(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at']),
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
      syncState: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_state'])!,
      localUpdatedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}local_updated_at'])!,
      smileyId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}smiley_id'])!,
      tags: $SmileyEntriesTable.$convertertags.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tags'])!),
      grantedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}granted_at'])!,
    );
  }

  @override
  $SmileyEntriesTable createAlias(String alias) {
    return $SmileyEntriesTable(attachedDatabase, alias);
  }

  static TypeConverter<List<String>, String> $convertertags =
      const StringListConverter();
}

class SmileyEntry extends DataClass implements Insertable<SmileyEntry> {
  final String id;
  final DateTime? updatedAt;
  final DateTime? deletedAt;
  final String syncState;
  final DateTime localUpdatedAt;
  final int smileyId;
  final List<String> tags;
  final DateTime grantedAt;
  const SmileyEntry(
      {required this.id,
      this.updatedAt,
      this.deletedAt,
      required this.syncState,
      required this.localUpdatedAt,
      required this.smileyId,
      required this.tags,
      required this.grantedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['sync_state'] = Variable<String>(syncState);
    map['local_updated_at'] = Variable<DateTime>(localUpdatedAt);
    map['smiley_id'] = Variable<int>(smileyId);
    {
      map['tags'] =
          Variable<String>($SmileyEntriesTable.$convertertags.toSql(tags));
    }
    map['granted_at'] = Variable<DateTime>(grantedAt);
    return map;
  }

  SmileyEntriesCompanion toCompanion(bool nullToAbsent) {
    return SmileyEntriesCompanion(
      id: Value(id),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncState: Value(syncState),
      localUpdatedAt: Value(localUpdatedAt),
      smileyId: Value(smileyId),
      tags: Value(tags),
      grantedAt: Value(grantedAt),
    );
  }

  factory SmileyEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SmileyEntry(
      id: serializer.fromJson<String>(json['id']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      syncState: serializer.fromJson<String>(json['syncState']),
      localUpdatedAt: serializer.fromJson<DateTime>(json['localUpdatedAt']),
      smileyId: serializer.fromJson<int>(json['smileyId']),
      tags: serializer.fromJson<List<String>>(json['tags']),
      grantedAt: serializer.fromJson<DateTime>(json['grantedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'syncState': serializer.toJson<String>(syncState),
      'localUpdatedAt': serializer.toJson<DateTime>(localUpdatedAt),
      'smileyId': serializer.toJson<int>(smileyId),
      'tags': serializer.toJson<List<String>>(tags),
      'grantedAt': serializer.toJson<DateTime>(grantedAt),
    };
  }

  SmileyEntry copyWith(
          {String? id,
          Value<DateTime?> updatedAt = const Value.absent(),
          Value<DateTime?> deletedAt = const Value.absent(),
          String? syncState,
          DateTime? localUpdatedAt,
          int? smileyId,
          List<String>? tags,
          DateTime? grantedAt}) =>
      SmileyEntry(
        id: id ?? this.id,
        updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        syncState: syncState ?? this.syncState,
        localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
        smileyId: smileyId ?? this.smileyId,
        tags: tags ?? this.tags,
        grantedAt: grantedAt ?? this.grantedAt,
      );
  SmileyEntry copyWithCompanion(SmileyEntriesCompanion data) {
    return SmileyEntry(
      id: data.id.present ? data.id.value : this.id,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
      localUpdatedAt: data.localUpdatedAt.present
          ? data.localUpdatedAt.value
          : this.localUpdatedAt,
      smileyId: data.smileyId.present ? data.smileyId.value : this.smileyId,
      tags: data.tags.present ? data.tags.value : this.tags,
      grantedAt: data.grantedAt.present ? data.grantedAt.value : this.grantedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SmileyEntry(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncState: $syncState, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('smileyId: $smileyId, ')
          ..write('tags: $tags, ')
          ..write('grantedAt: $grantedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, updatedAt, deletedAt, syncState,
      localUpdatedAt, smileyId, tags, grantedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SmileyEntry &&
          other.id == this.id &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.syncState == this.syncState &&
          other.localUpdatedAt == this.localUpdatedAt &&
          other.smileyId == this.smileyId &&
          other.tags == this.tags &&
          other.grantedAt == this.grantedAt);
}

class SmileyEntriesCompanion extends UpdateCompanion<SmileyEntry> {
  final Value<String> id;
  final Value<DateTime?> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> syncState;
  final Value<DateTime> localUpdatedAt;
  final Value<int> smileyId;
  final Value<List<String>> tags;
  final Value<DateTime> grantedAt;
  final Value<int> rowid;
  const SmileyEntriesCompanion({
    this.id = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    this.localUpdatedAt = const Value.absent(),
    this.smileyId = const Value.absent(),
    this.tags = const Value.absent(),
    this.grantedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SmileyEntriesCompanion.insert({
    required String id,
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    required DateTime localUpdatedAt,
    required int smileyId,
    this.tags = const Value.absent(),
    required DateTime grantedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        localUpdatedAt = Value(localUpdatedAt),
        smileyId = Value(smileyId),
        grantedAt = Value(grantedAt);
  static Insertable<SmileyEntry> custom({
    Expression<String>? id,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? syncState,
    Expression<DateTime>? localUpdatedAt,
    Expression<int>? smileyId,
    Expression<String>? tags,
    Expression<DateTime>? grantedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncState != null) 'sync_state': syncState,
      if (localUpdatedAt != null) 'local_updated_at': localUpdatedAt,
      if (smileyId != null) 'smiley_id': smileyId,
      if (tags != null) 'tags': tags,
      if (grantedAt != null) 'granted_at': grantedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SmileyEntriesCompanion copyWith(
      {Value<String>? id,
      Value<DateTime?>? updatedAt,
      Value<DateTime?>? deletedAt,
      Value<String>? syncState,
      Value<DateTime>? localUpdatedAt,
      Value<int>? smileyId,
      Value<List<String>>? tags,
      Value<DateTime>? grantedAt,
      Value<int>? rowid}) {
    return SmileyEntriesCompanion(
      id: id ?? this.id,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncState: syncState ?? this.syncState,
      localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
      smileyId: smileyId ?? this.smileyId,
      tags: tags ?? this.tags,
      grantedAt: grantedAt ?? this.grantedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(syncState.value);
    }
    if (localUpdatedAt.present) {
      map['local_updated_at'] = Variable<DateTime>(localUpdatedAt.value);
    }
    if (smileyId.present) {
      map['smiley_id'] = Variable<int>(smileyId.value);
    }
    if (tags.present) {
      map['tags'] = Variable<String>(
          $SmileyEntriesTable.$convertertags.toSql(tags.value));
    }
    if (grantedAt.present) {
      map['granted_at'] = Variable<DateTime>(grantedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SmileyEntriesCompanion(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncState: $syncState, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('smileyId: $smileyId, ')
          ..write('tags: $tags, ')
          ..write('grantedAt: $grantedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PointRecordsTable extends PointRecords
    with TableInfo<$PointRecordsTable, PointRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PointRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _syncStateMeta =
      const VerificationMeta('syncState');
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
      'sync_state', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _localUpdatedAtMeta =
      const VerificationMeta('localUpdatedAt');
  @override
  late final GeneratedColumn<DateTime> localUpdatedAt =
      GeneratedColumn<DateTime>('local_updated_at', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _pointMeta = const VerificationMeta('point');
  @override
  late final GeneratedColumn<int> point = GeneratedColumn<int>(
      'point', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _scopeMeta = const VerificationMeta('scope');
  @override
  late final GeneratedColumn<String> scope = GeneratedColumn<String>(
      'scope', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
      'date', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, updatedAt, deletedAt, syncState, localUpdatedAt, point, scope, date];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'point_records';
  @override
  VerificationContext validateIntegrity(Insertable<PointRecord> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    if (data.containsKey('sync_state')) {
      context.handle(_syncStateMeta,
          syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta));
    }
    if (data.containsKey('local_updated_at')) {
      context.handle(
          _localUpdatedAtMeta,
          localUpdatedAt.isAcceptableOrUnknown(
              data['local_updated_at']!, _localUpdatedAtMeta));
    } else if (isInserting) {
      context.missing(_localUpdatedAtMeta);
    }
    if (data.containsKey('point')) {
      context.handle(
          _pointMeta, point.isAcceptableOrUnknown(data['point']!, _pointMeta));
    } else if (isInserting) {
      context.missing(_pointMeta);
    }
    if (data.containsKey('scope')) {
      context.handle(
          _scopeMeta, scope.isAcceptableOrUnknown(data['scope']!, _scopeMeta));
    } else if (isInserting) {
      context.missing(_scopeMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PointRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PointRecord(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at']),
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
      syncState: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_state'])!,
      localUpdatedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}local_updated_at'])!,
      point: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}point'])!,
      scope: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}scope'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}date'])!,
    );
  }

  @override
  $PointRecordsTable createAlias(String alias) {
    return $PointRecordsTable(attachedDatabase, alias);
  }
}

class PointRecord extends DataClass implements Insertable<PointRecord> {
  final String id;
  final DateTime? updatedAt;
  final DateTime? deletedAt;
  final String syncState;
  final DateTime localUpdatedAt;
  final int point;
  final String scope;
  final String date;
  const PointRecord(
      {required this.id,
      this.updatedAt,
      this.deletedAt,
      required this.syncState,
      required this.localUpdatedAt,
      required this.point,
      required this.scope,
      required this.date});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['sync_state'] = Variable<String>(syncState);
    map['local_updated_at'] = Variable<DateTime>(localUpdatedAt);
    map['point'] = Variable<int>(point);
    map['scope'] = Variable<String>(scope);
    map['date'] = Variable<String>(date);
    return map;
  }

  PointRecordsCompanion toCompanion(bool nullToAbsent) {
    return PointRecordsCompanion(
      id: Value(id),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncState: Value(syncState),
      localUpdatedAt: Value(localUpdatedAt),
      point: Value(point),
      scope: Value(scope),
      date: Value(date),
    );
  }

  factory PointRecord.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PointRecord(
      id: serializer.fromJson<String>(json['id']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      syncState: serializer.fromJson<String>(json['syncState']),
      localUpdatedAt: serializer.fromJson<DateTime>(json['localUpdatedAt']),
      point: serializer.fromJson<int>(json['point']),
      scope: serializer.fromJson<String>(json['scope']),
      date: serializer.fromJson<String>(json['date']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'syncState': serializer.toJson<String>(syncState),
      'localUpdatedAt': serializer.toJson<DateTime>(localUpdatedAt),
      'point': serializer.toJson<int>(point),
      'scope': serializer.toJson<String>(scope),
      'date': serializer.toJson<String>(date),
    };
  }

  PointRecord copyWith(
          {String? id,
          Value<DateTime?> updatedAt = const Value.absent(),
          Value<DateTime?> deletedAt = const Value.absent(),
          String? syncState,
          DateTime? localUpdatedAt,
          int? point,
          String? scope,
          String? date}) =>
      PointRecord(
        id: id ?? this.id,
        updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        syncState: syncState ?? this.syncState,
        localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
        point: point ?? this.point,
        scope: scope ?? this.scope,
        date: date ?? this.date,
      );
  PointRecord copyWithCompanion(PointRecordsCompanion data) {
    return PointRecord(
      id: data.id.present ? data.id.value : this.id,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
      localUpdatedAt: data.localUpdatedAt.present
          ? data.localUpdatedAt.value
          : this.localUpdatedAt,
      point: data.point.present ? data.point.value : this.point,
      scope: data.scope.present ? data.scope.value : this.scope,
      date: data.date.present ? data.date.value : this.date,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PointRecord(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncState: $syncState, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('point: $point, ')
          ..write('scope: $scope, ')
          ..write('date: $date')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, updatedAt, deletedAt, syncState, localUpdatedAt, point, scope, date);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PointRecord &&
          other.id == this.id &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.syncState == this.syncState &&
          other.localUpdatedAt == this.localUpdatedAt &&
          other.point == this.point &&
          other.scope == this.scope &&
          other.date == this.date);
}

class PointRecordsCompanion extends UpdateCompanion<PointRecord> {
  final Value<String> id;
  final Value<DateTime?> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> syncState;
  final Value<DateTime> localUpdatedAt;
  final Value<int> point;
  final Value<String> scope;
  final Value<String> date;
  final Value<int> rowid;
  const PointRecordsCompanion({
    this.id = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    this.localUpdatedAt = const Value.absent(),
    this.point = const Value.absent(),
    this.scope = const Value.absent(),
    this.date = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PointRecordsCompanion.insert({
    required String id,
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    required DateTime localUpdatedAt,
    required int point,
    required String scope,
    required String date,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        localUpdatedAt = Value(localUpdatedAt),
        point = Value(point),
        scope = Value(scope),
        date = Value(date);
  static Insertable<PointRecord> custom({
    Expression<String>? id,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? syncState,
    Expression<DateTime>? localUpdatedAt,
    Expression<int>? point,
    Expression<String>? scope,
    Expression<String>? date,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncState != null) 'sync_state': syncState,
      if (localUpdatedAt != null) 'local_updated_at': localUpdatedAt,
      if (point != null) 'point': point,
      if (scope != null) 'scope': scope,
      if (date != null) 'date': date,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PointRecordsCompanion copyWith(
      {Value<String>? id,
      Value<DateTime?>? updatedAt,
      Value<DateTime?>? deletedAt,
      Value<String>? syncState,
      Value<DateTime>? localUpdatedAt,
      Value<int>? point,
      Value<String>? scope,
      Value<String>? date,
      Value<int>? rowid}) {
    return PointRecordsCompanion(
      id: id ?? this.id,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncState: syncState ?? this.syncState,
      localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
      point: point ?? this.point,
      scope: scope ?? this.scope,
      date: date ?? this.date,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(syncState.value);
    }
    if (localUpdatedAt.present) {
      map['local_updated_at'] = Variable<DateTime>(localUpdatedAt.value);
    }
    if (point.present) {
      map['point'] = Variable<int>(point.value);
    }
    if (scope.present) {
      map['scope'] = Variable<String>(scope.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PointRecordsCompanion(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncState: $syncState, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('point: $point, ')
          ..write('scope: $scope, ')
          ..write('date: $date, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UserTrackedMetricsTable extends UserTrackedMetrics
    with TableInfo<$UserTrackedMetricsTable, UserTrackedMetric> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserTrackedMetricsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _syncStateMeta =
      const VerificationMeta('syncState');
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
      'sync_state', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _localUpdatedAtMeta =
      const VerificationMeta('localUpdatedAt');
  @override
  late final GeneratedColumn<DateTime> localUpdatedAt =
      GeneratedColumn<DateTime>('local_updated_at', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _metricIdMeta =
      const VerificationMeta('metricId');
  @override
  late final GeneratedColumn<int> metricId = GeneratedColumn<int>(
      'metric_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _grantedAtMeta =
      const VerificationMeta('grantedAt');
  @override
  late final GeneratedColumn<DateTime> grantedAt = GeneratedColumn<DateTime>(
      'granted_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        updatedAt,
        deletedAt,
        syncState,
        localUpdatedAt,
        metricId,
        grantedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_tracked_metrics';
  @override
  VerificationContext validateIntegrity(Insertable<UserTrackedMetric> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    if (data.containsKey('sync_state')) {
      context.handle(_syncStateMeta,
          syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta));
    }
    if (data.containsKey('local_updated_at')) {
      context.handle(
          _localUpdatedAtMeta,
          localUpdatedAt.isAcceptableOrUnknown(
              data['local_updated_at']!, _localUpdatedAtMeta));
    } else if (isInserting) {
      context.missing(_localUpdatedAtMeta);
    }
    if (data.containsKey('metric_id')) {
      context.handle(_metricIdMeta,
          metricId.isAcceptableOrUnknown(data['metric_id']!, _metricIdMeta));
    } else if (isInserting) {
      context.missing(_metricIdMeta);
    }
    if (data.containsKey('granted_at')) {
      context.handle(_grantedAtMeta,
          grantedAt.isAcceptableOrUnknown(data['granted_at']!, _grantedAtMeta));
    } else if (isInserting) {
      context.missing(_grantedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserTrackedMetric map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserTrackedMetric(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at']),
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
      syncState: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_state'])!,
      localUpdatedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}local_updated_at'])!,
      metricId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}metric_id'])!,
      grantedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}granted_at'])!,
    );
  }

  @override
  $UserTrackedMetricsTable createAlias(String alias) {
    return $UserTrackedMetricsTable(attachedDatabase, alias);
  }
}

class UserTrackedMetric extends DataClass
    implements Insertable<UserTrackedMetric> {
  final String id;
  final DateTime? updatedAt;
  final DateTime? deletedAt;
  final String syncState;
  final DateTime localUpdatedAt;
  final int metricId;
  final DateTime grantedAt;
  const UserTrackedMetric(
      {required this.id,
      this.updatedAt,
      this.deletedAt,
      required this.syncState,
      required this.localUpdatedAt,
      required this.metricId,
      required this.grantedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['sync_state'] = Variable<String>(syncState);
    map['local_updated_at'] = Variable<DateTime>(localUpdatedAt);
    map['metric_id'] = Variable<int>(metricId);
    map['granted_at'] = Variable<DateTime>(grantedAt);
    return map;
  }

  UserTrackedMetricsCompanion toCompanion(bool nullToAbsent) {
    return UserTrackedMetricsCompanion(
      id: Value(id),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncState: Value(syncState),
      localUpdatedAt: Value(localUpdatedAt),
      metricId: Value(metricId),
      grantedAt: Value(grantedAt),
    );
  }

  factory UserTrackedMetric.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserTrackedMetric(
      id: serializer.fromJson<String>(json['id']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      syncState: serializer.fromJson<String>(json['syncState']),
      localUpdatedAt: serializer.fromJson<DateTime>(json['localUpdatedAt']),
      metricId: serializer.fromJson<int>(json['metricId']),
      grantedAt: serializer.fromJson<DateTime>(json['grantedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'syncState': serializer.toJson<String>(syncState),
      'localUpdatedAt': serializer.toJson<DateTime>(localUpdatedAt),
      'metricId': serializer.toJson<int>(metricId),
      'grantedAt': serializer.toJson<DateTime>(grantedAt),
    };
  }

  UserTrackedMetric copyWith(
          {String? id,
          Value<DateTime?> updatedAt = const Value.absent(),
          Value<DateTime?> deletedAt = const Value.absent(),
          String? syncState,
          DateTime? localUpdatedAt,
          int? metricId,
          DateTime? grantedAt}) =>
      UserTrackedMetric(
        id: id ?? this.id,
        updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        syncState: syncState ?? this.syncState,
        localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
        metricId: metricId ?? this.metricId,
        grantedAt: grantedAt ?? this.grantedAt,
      );
  UserTrackedMetric copyWithCompanion(UserTrackedMetricsCompanion data) {
    return UserTrackedMetric(
      id: data.id.present ? data.id.value : this.id,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
      localUpdatedAt: data.localUpdatedAt.present
          ? data.localUpdatedAt.value
          : this.localUpdatedAt,
      metricId: data.metricId.present ? data.metricId.value : this.metricId,
      grantedAt: data.grantedAt.present ? data.grantedAt.value : this.grantedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserTrackedMetric(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncState: $syncState, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('metricId: $metricId, ')
          ..write('grantedAt: $grantedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, updatedAt, deletedAt, syncState, localUpdatedAt, metricId, grantedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserTrackedMetric &&
          other.id == this.id &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.syncState == this.syncState &&
          other.localUpdatedAt == this.localUpdatedAt &&
          other.metricId == this.metricId &&
          other.grantedAt == this.grantedAt);
}

class UserTrackedMetricsCompanion extends UpdateCompanion<UserTrackedMetric> {
  final Value<String> id;
  final Value<DateTime?> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> syncState;
  final Value<DateTime> localUpdatedAt;
  final Value<int> metricId;
  final Value<DateTime> grantedAt;
  final Value<int> rowid;
  const UserTrackedMetricsCompanion({
    this.id = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    this.localUpdatedAt = const Value.absent(),
    this.metricId = const Value.absent(),
    this.grantedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserTrackedMetricsCompanion.insert({
    required String id,
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    required DateTime localUpdatedAt,
    required int metricId,
    required DateTime grantedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        localUpdatedAt = Value(localUpdatedAt),
        metricId = Value(metricId),
        grantedAt = Value(grantedAt);
  static Insertable<UserTrackedMetric> custom({
    Expression<String>? id,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? syncState,
    Expression<DateTime>? localUpdatedAt,
    Expression<int>? metricId,
    Expression<DateTime>? grantedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncState != null) 'sync_state': syncState,
      if (localUpdatedAt != null) 'local_updated_at': localUpdatedAt,
      if (metricId != null) 'metric_id': metricId,
      if (grantedAt != null) 'granted_at': grantedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserTrackedMetricsCompanion copyWith(
      {Value<String>? id,
      Value<DateTime?>? updatedAt,
      Value<DateTime?>? deletedAt,
      Value<String>? syncState,
      Value<DateTime>? localUpdatedAt,
      Value<int>? metricId,
      Value<DateTime>? grantedAt,
      Value<int>? rowid}) {
    return UserTrackedMetricsCompanion(
      id: id ?? this.id,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncState: syncState ?? this.syncState,
      localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
      metricId: metricId ?? this.metricId,
      grantedAt: grantedAt ?? this.grantedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(syncState.value);
    }
    if (localUpdatedAt.present) {
      map['local_updated_at'] = Variable<DateTime>(localUpdatedAt.value);
    }
    if (metricId.present) {
      map['metric_id'] = Variable<int>(metricId.value);
    }
    if (grantedAt.present) {
      map['granted_at'] = Variable<DateTime>(grantedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserTrackedMetricsCompanion(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncState: $syncState, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('metricId: $metricId, ')
          ..write('grantedAt: $grantedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UserConditionsTable extends UserConditions
    with TableInfo<$UserConditionsTable, UserCondition> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserConditionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _syncStateMeta =
      const VerificationMeta('syncState');
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
      'sync_state', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _localUpdatedAtMeta =
      const VerificationMeta('localUpdatedAt');
  @override
  late final GeneratedColumn<DateTime> localUpdatedAt =
      GeneratedColumn<DateTime>('local_updated_at', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _conditionIdMeta =
      const VerificationMeta('conditionId');
  @override
  late final GeneratedColumn<int> conditionId = GeneratedColumn<int>(
      'condition_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, updatedAt, deletedAt, syncState, localUpdatedAt, conditionId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_conditions';
  @override
  VerificationContext validateIntegrity(Insertable<UserCondition> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    if (data.containsKey('sync_state')) {
      context.handle(_syncStateMeta,
          syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta));
    }
    if (data.containsKey('local_updated_at')) {
      context.handle(
          _localUpdatedAtMeta,
          localUpdatedAt.isAcceptableOrUnknown(
              data['local_updated_at']!, _localUpdatedAtMeta));
    } else if (isInserting) {
      context.missing(_localUpdatedAtMeta);
    }
    if (data.containsKey('condition_id')) {
      context.handle(
          _conditionIdMeta,
          conditionId.isAcceptableOrUnknown(
              data['condition_id']!, _conditionIdMeta));
    } else if (isInserting) {
      context.missing(_conditionIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserCondition map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserCondition(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at']),
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
      syncState: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_state'])!,
      localUpdatedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}local_updated_at'])!,
      conditionId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}condition_id'])!,
    );
  }

  @override
  $UserConditionsTable createAlias(String alias) {
    return $UserConditionsTable(attachedDatabase, alias);
  }
}

class UserCondition extends DataClass implements Insertable<UserCondition> {
  final String id;
  final DateTime? updatedAt;
  final DateTime? deletedAt;
  final String syncState;
  final DateTime localUpdatedAt;
  final int conditionId;
  const UserCondition(
      {required this.id,
      this.updatedAt,
      this.deletedAt,
      required this.syncState,
      required this.localUpdatedAt,
      required this.conditionId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['sync_state'] = Variable<String>(syncState);
    map['local_updated_at'] = Variable<DateTime>(localUpdatedAt);
    map['condition_id'] = Variable<int>(conditionId);
    return map;
  }

  UserConditionsCompanion toCompanion(bool nullToAbsent) {
    return UserConditionsCompanion(
      id: Value(id),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncState: Value(syncState),
      localUpdatedAt: Value(localUpdatedAt),
      conditionId: Value(conditionId),
    );
  }

  factory UserCondition.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserCondition(
      id: serializer.fromJson<String>(json['id']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      syncState: serializer.fromJson<String>(json['syncState']),
      localUpdatedAt: serializer.fromJson<DateTime>(json['localUpdatedAt']),
      conditionId: serializer.fromJson<int>(json['conditionId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'syncState': serializer.toJson<String>(syncState),
      'localUpdatedAt': serializer.toJson<DateTime>(localUpdatedAt),
      'conditionId': serializer.toJson<int>(conditionId),
    };
  }

  UserCondition copyWith(
          {String? id,
          Value<DateTime?> updatedAt = const Value.absent(),
          Value<DateTime?> deletedAt = const Value.absent(),
          String? syncState,
          DateTime? localUpdatedAt,
          int? conditionId}) =>
      UserCondition(
        id: id ?? this.id,
        updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        syncState: syncState ?? this.syncState,
        localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
        conditionId: conditionId ?? this.conditionId,
      );
  UserCondition copyWithCompanion(UserConditionsCompanion data) {
    return UserCondition(
      id: data.id.present ? data.id.value : this.id,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
      localUpdatedAt: data.localUpdatedAt.present
          ? data.localUpdatedAt.value
          : this.localUpdatedAt,
      conditionId:
          data.conditionId.present ? data.conditionId.value : this.conditionId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserCondition(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncState: $syncState, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('conditionId: $conditionId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, updatedAt, deletedAt, syncState, localUpdatedAt, conditionId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserCondition &&
          other.id == this.id &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.syncState == this.syncState &&
          other.localUpdatedAt == this.localUpdatedAt &&
          other.conditionId == this.conditionId);
}

class UserConditionsCompanion extends UpdateCompanion<UserCondition> {
  final Value<String> id;
  final Value<DateTime?> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> syncState;
  final Value<DateTime> localUpdatedAt;
  final Value<int> conditionId;
  final Value<int> rowid;
  const UserConditionsCompanion({
    this.id = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    this.localUpdatedAt = const Value.absent(),
    this.conditionId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserConditionsCompanion.insert({
    required String id,
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    required DateTime localUpdatedAt,
    required int conditionId,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        localUpdatedAt = Value(localUpdatedAt),
        conditionId = Value(conditionId);
  static Insertable<UserCondition> custom({
    Expression<String>? id,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? syncState,
    Expression<DateTime>? localUpdatedAt,
    Expression<int>? conditionId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncState != null) 'sync_state': syncState,
      if (localUpdatedAt != null) 'local_updated_at': localUpdatedAt,
      if (conditionId != null) 'condition_id': conditionId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserConditionsCompanion copyWith(
      {Value<String>? id,
      Value<DateTime?>? updatedAt,
      Value<DateTime?>? deletedAt,
      Value<String>? syncState,
      Value<DateTime>? localUpdatedAt,
      Value<int>? conditionId,
      Value<int>? rowid}) {
    return UserConditionsCompanion(
      id: id ?? this.id,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncState: syncState ?? this.syncState,
      localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
      conditionId: conditionId ?? this.conditionId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(syncState.value);
    }
    if (localUpdatedAt.present) {
      map['local_updated_at'] = Variable<DateTime>(localUpdatedAt.value);
    }
    if (conditionId.present) {
      map['condition_id'] = Variable<int>(conditionId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserConditionsCompanion(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncState: $syncState, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('conditionId: $conditionId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UserSettingsTable extends UserSettings
    with TableInfo<$UserSettingsTable, UserSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _syncStateMeta =
      const VerificationMeta('syncState');
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
      'sync_state', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _localUpdatedAtMeta =
      const VerificationMeta('localUpdatedAt');
  @override
  late final GeneratedColumn<DateTime> localUpdatedAt =
      GeneratedColumn<DateTime>('local_updated_at', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _periodLenMeta =
      const VerificationMeta('periodLen');
  @override
  late final GeneratedColumn<int> periodLen = GeneratedColumn<int>(
      'period_len', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _cycleLenMeta =
      const VerificationMeta('cycleLen');
  @override
  late final GeneratedColumn<int> cycleLen = GeneratedColumn<int>(
      'cycle_len', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _heightMeta = const VerificationMeta('height');
  @override
  late final GeneratedColumn<int> height = GeneratedColumn<int>(
      'height', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _weightMeta = const VerificationMeta('weight');
  @override
  late final GeneratedColumn<int> weight = GeneratedColumn<int>(
      'weight', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        updatedAt,
        deletedAt,
        syncState,
        localUpdatedAt,
        periodLen,
        cycleLen,
        height,
        weight
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_settings';
  @override
  VerificationContext validateIntegrity(Insertable<UserSetting> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    if (data.containsKey('sync_state')) {
      context.handle(_syncStateMeta,
          syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta));
    }
    if (data.containsKey('local_updated_at')) {
      context.handle(
          _localUpdatedAtMeta,
          localUpdatedAt.isAcceptableOrUnknown(
              data['local_updated_at']!, _localUpdatedAtMeta));
    } else if (isInserting) {
      context.missing(_localUpdatedAtMeta);
    }
    if (data.containsKey('period_len')) {
      context.handle(_periodLenMeta,
          periodLen.isAcceptableOrUnknown(data['period_len']!, _periodLenMeta));
    }
    if (data.containsKey('cycle_len')) {
      context.handle(_cycleLenMeta,
          cycleLen.isAcceptableOrUnknown(data['cycle_len']!, _cycleLenMeta));
    }
    if (data.containsKey('height')) {
      context.handle(_heightMeta,
          height.isAcceptableOrUnknown(data['height']!, _heightMeta));
    }
    if (data.containsKey('weight')) {
      context.handle(_weightMeta,
          weight.isAcceptableOrUnknown(data['weight']!, _weightMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserSetting(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at']),
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
      syncState: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_state'])!,
      localUpdatedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}local_updated_at'])!,
      periodLen: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}period_len'])!,
      cycleLen: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}cycle_len'])!,
      height: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}height'])!,
      weight: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}weight'])!,
    );
  }

  @override
  $UserSettingsTable createAlias(String alias) {
    return $UserSettingsTable(attachedDatabase, alias);
  }
}

class UserSetting extends DataClass implements Insertable<UserSetting> {
  final String id;
  final DateTime? updatedAt;
  final DateTime? deletedAt;
  final String syncState;
  final DateTime localUpdatedAt;
  final int periodLen;
  final int cycleLen;
  final int height;
  final int weight;
  const UserSetting(
      {required this.id,
      this.updatedAt,
      this.deletedAt,
      required this.syncState,
      required this.localUpdatedAt,
      required this.periodLen,
      required this.cycleLen,
      required this.height,
      required this.weight});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['sync_state'] = Variable<String>(syncState);
    map['local_updated_at'] = Variable<DateTime>(localUpdatedAt);
    map['period_len'] = Variable<int>(periodLen);
    map['cycle_len'] = Variable<int>(cycleLen);
    map['height'] = Variable<int>(height);
    map['weight'] = Variable<int>(weight);
    return map;
  }

  UserSettingsCompanion toCompanion(bool nullToAbsent) {
    return UserSettingsCompanion(
      id: Value(id),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncState: Value(syncState),
      localUpdatedAt: Value(localUpdatedAt),
      periodLen: Value(periodLen),
      cycleLen: Value(cycleLen),
      height: Value(height),
      weight: Value(weight),
    );
  }

  factory UserSetting.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserSetting(
      id: serializer.fromJson<String>(json['id']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      syncState: serializer.fromJson<String>(json['syncState']),
      localUpdatedAt: serializer.fromJson<DateTime>(json['localUpdatedAt']),
      periodLen: serializer.fromJson<int>(json['periodLen']),
      cycleLen: serializer.fromJson<int>(json['cycleLen']),
      height: serializer.fromJson<int>(json['height']),
      weight: serializer.fromJson<int>(json['weight']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'syncState': serializer.toJson<String>(syncState),
      'localUpdatedAt': serializer.toJson<DateTime>(localUpdatedAt),
      'periodLen': serializer.toJson<int>(periodLen),
      'cycleLen': serializer.toJson<int>(cycleLen),
      'height': serializer.toJson<int>(height),
      'weight': serializer.toJson<int>(weight),
    };
  }

  UserSetting copyWith(
          {String? id,
          Value<DateTime?> updatedAt = const Value.absent(),
          Value<DateTime?> deletedAt = const Value.absent(),
          String? syncState,
          DateTime? localUpdatedAt,
          int? periodLen,
          int? cycleLen,
          int? height,
          int? weight}) =>
      UserSetting(
        id: id ?? this.id,
        updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        syncState: syncState ?? this.syncState,
        localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
        periodLen: periodLen ?? this.periodLen,
        cycleLen: cycleLen ?? this.cycleLen,
        height: height ?? this.height,
        weight: weight ?? this.weight,
      );
  UserSetting copyWithCompanion(UserSettingsCompanion data) {
    return UserSetting(
      id: data.id.present ? data.id.value : this.id,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
      localUpdatedAt: data.localUpdatedAt.present
          ? data.localUpdatedAt.value
          : this.localUpdatedAt,
      periodLen: data.periodLen.present ? data.periodLen.value : this.periodLen,
      cycleLen: data.cycleLen.present ? data.cycleLen.value : this.cycleLen,
      height: data.height.present ? data.height.value : this.height,
      weight: data.weight.present ? data.weight.value : this.weight,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserSetting(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncState: $syncState, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('periodLen: $periodLen, ')
          ..write('cycleLen: $cycleLen, ')
          ..write('height: $height, ')
          ..write('weight: $weight')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, updatedAt, deletedAt, syncState,
      localUpdatedAt, periodLen, cycleLen, height, weight);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserSetting &&
          other.id == this.id &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.syncState == this.syncState &&
          other.localUpdatedAt == this.localUpdatedAt &&
          other.periodLen == this.periodLen &&
          other.cycleLen == this.cycleLen &&
          other.height == this.height &&
          other.weight == this.weight);
}

class UserSettingsCompanion extends UpdateCompanion<UserSetting> {
  final Value<String> id;
  final Value<DateTime?> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> syncState;
  final Value<DateTime> localUpdatedAt;
  final Value<int> periodLen;
  final Value<int> cycleLen;
  final Value<int> height;
  final Value<int> weight;
  final Value<int> rowid;
  const UserSettingsCompanion({
    this.id = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    this.localUpdatedAt = const Value.absent(),
    this.periodLen = const Value.absent(),
    this.cycleLen = const Value.absent(),
    this.height = const Value.absent(),
    this.weight = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserSettingsCompanion.insert({
    required String id,
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    required DateTime localUpdatedAt,
    this.periodLen = const Value.absent(),
    this.cycleLen = const Value.absent(),
    this.height = const Value.absent(),
    this.weight = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        localUpdatedAt = Value(localUpdatedAt);
  static Insertable<UserSetting> custom({
    Expression<String>? id,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? syncState,
    Expression<DateTime>? localUpdatedAt,
    Expression<int>? periodLen,
    Expression<int>? cycleLen,
    Expression<int>? height,
    Expression<int>? weight,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncState != null) 'sync_state': syncState,
      if (localUpdatedAt != null) 'local_updated_at': localUpdatedAt,
      if (periodLen != null) 'period_len': periodLen,
      if (cycleLen != null) 'cycle_len': cycleLen,
      if (height != null) 'height': height,
      if (weight != null) 'weight': weight,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserSettingsCompanion copyWith(
      {Value<String>? id,
      Value<DateTime?>? updatedAt,
      Value<DateTime?>? deletedAt,
      Value<String>? syncState,
      Value<DateTime>? localUpdatedAt,
      Value<int>? periodLen,
      Value<int>? cycleLen,
      Value<int>? height,
      Value<int>? weight,
      Value<int>? rowid}) {
    return UserSettingsCompanion(
      id: id ?? this.id,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncState: syncState ?? this.syncState,
      localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
      periodLen: periodLen ?? this.periodLen,
      cycleLen: cycleLen ?? this.cycleLen,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(syncState.value);
    }
    if (localUpdatedAt.present) {
      map['local_updated_at'] = Variable<DateTime>(localUpdatedAt.value);
    }
    if (periodLen.present) {
      map['period_len'] = Variable<int>(periodLen.value);
    }
    if (cycleLen.present) {
      map['cycle_len'] = Variable<int>(cycleLen.value);
    }
    if (height.present) {
      map['height'] = Variable<int>(height.value);
    }
    if (weight.present) {
      map['weight'] = Variable<int>(weight.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserSettingsCompanion(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncState: $syncState, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('periodLen: $periodLen, ')
          ..write('cycleLen: $cycleLen, ')
          ..write('height: $height, ')
          ..write('weight: $weight, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SymptomsTable extends Symptoms with TableInfo<$SymptomsTable, Symptom> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SymptomsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'symptoms';
  @override
  VerificationContext validateIntegrity(Insertable<Symptom> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Symptom map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Symptom(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
    );
  }

  @override
  $SymptomsTable createAlias(String alias) {
    return $SymptomsTable(attachedDatabase, alias);
  }
}

class Symptom extends DataClass implements Insertable<Symptom> {
  final int id;
  final String name;
  const Symptom({required this.id, required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    return map;
  }

  SymptomsCompanion toCompanion(bool nullToAbsent) {
    return SymptomsCompanion(
      id: Value(id),
      name: Value(name),
    );
  }

  factory Symptom.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Symptom(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
    };
  }

  Symptom copyWith({int? id, String? name}) => Symptom(
        id: id ?? this.id,
        name: name ?? this.name,
      );
  Symptom copyWithCompanion(SymptomsCompanion data) {
    return Symptom(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Symptom(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Symptom && other.id == this.id && other.name == this.name);
}

class SymptomsCompanion extends UpdateCompanion<Symptom> {
  final Value<int> id;
  final Value<String> name;
  const SymptomsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
  });
  SymptomsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
  }) : name = Value(name);
  static Insertable<Symptom> custom({
    Expression<int>? id,
    Expression<String>? name,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
    });
  }

  SymptomsCompanion copyWith({Value<int>? id, Value<String>? name}) {
    return SymptomsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SymptomsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }
}

class $TrackedMetricsCatalogTable extends TrackedMetricsCatalog
    with TableInfo<$TrackedMetricsCatalogTable, TrackedMetricsCatalogData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TrackedMetricsCatalogTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tracked_metrics_catalog';
  @override
  VerificationContext validateIntegrity(
      Insertable<TrackedMetricsCatalogData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TrackedMetricsCatalogData map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TrackedMetricsCatalogData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
    );
  }

  @override
  $TrackedMetricsCatalogTable createAlias(String alias) {
    return $TrackedMetricsCatalogTable(attachedDatabase, alias);
  }
}

class TrackedMetricsCatalogData extends DataClass
    implements Insertable<TrackedMetricsCatalogData> {
  final int id;
  final String name;
  const TrackedMetricsCatalogData({required this.id, required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    return map;
  }

  TrackedMetricsCatalogCompanion toCompanion(bool nullToAbsent) {
    return TrackedMetricsCatalogCompanion(
      id: Value(id),
      name: Value(name),
    );
  }

  factory TrackedMetricsCatalogData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TrackedMetricsCatalogData(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
    };
  }

  TrackedMetricsCatalogData copyWith({int? id, String? name}) =>
      TrackedMetricsCatalogData(
        id: id ?? this.id,
        name: name ?? this.name,
      );
  TrackedMetricsCatalogData copyWithCompanion(
      TrackedMetricsCatalogCompanion data) {
    return TrackedMetricsCatalogData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TrackedMetricsCatalogData(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TrackedMetricsCatalogData &&
          other.id == this.id &&
          other.name == this.name);
}

class TrackedMetricsCatalogCompanion
    extends UpdateCompanion<TrackedMetricsCatalogData> {
  final Value<int> id;
  final Value<String> name;
  const TrackedMetricsCatalogCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
  });
  TrackedMetricsCatalogCompanion.insert({
    this.id = const Value.absent(),
    required String name,
  }) : name = Value(name);
  static Insertable<TrackedMetricsCatalogData> custom({
    Expression<int>? id,
    Expression<String>? name,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
    });
  }

  TrackedMetricsCatalogCompanion copyWith(
      {Value<int>? id, Value<String>? name}) {
    return TrackedMetricsCatalogCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TrackedMetricsCatalogCompanion(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }
}

class $SmileyCatalogTable extends SmileyCatalog
    with TableInfo<$SmileyCatalogTable, SmileyCatalogData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SmileyCatalogTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'smiley_catalog';
  @override
  VerificationContext validateIntegrity(Insertable<SmileyCatalogData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SmileyCatalogData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SmileyCatalogData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
    );
  }

  @override
  $SmileyCatalogTable createAlias(String alias) {
    return $SmileyCatalogTable(attachedDatabase, alias);
  }
}

class SmileyCatalogData extends DataClass
    implements Insertable<SmileyCatalogData> {
  final int id;
  final String name;
  const SmileyCatalogData({required this.id, required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    return map;
  }

  SmileyCatalogCompanion toCompanion(bool nullToAbsent) {
    return SmileyCatalogCompanion(
      id: Value(id),
      name: Value(name),
    );
  }

  factory SmileyCatalogData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SmileyCatalogData(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
    };
  }

  SmileyCatalogData copyWith({int? id, String? name}) => SmileyCatalogData(
        id: id ?? this.id,
        name: name ?? this.name,
      );
  SmileyCatalogData copyWithCompanion(SmileyCatalogCompanion data) {
    return SmileyCatalogData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SmileyCatalogData(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SmileyCatalogData &&
          other.id == this.id &&
          other.name == this.name);
}

class SmileyCatalogCompanion extends UpdateCompanion<SmileyCatalogData> {
  final Value<int> id;
  final Value<String> name;
  const SmileyCatalogCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
  });
  SmileyCatalogCompanion.insert({
    this.id = const Value.absent(),
    required String name,
  }) : name = Value(name);
  static Insertable<SmileyCatalogData> custom({
    Expression<int>? id,
    Expression<String>? name,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
    });
  }

  SmileyCatalogCompanion copyWith({Value<int>? id, Value<String>? name}) {
    return SmileyCatalogCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SmileyCatalogCompanion(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }
}

class $ConditionsTable extends Conditions
    with TableInfo<$ConditionsTable, Condition> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ConditionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'conditions';
  @override
  VerificationContext validateIntegrity(Insertable<Condition> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Condition map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Condition(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
    );
  }

  @override
  $ConditionsTable createAlias(String alias) {
    return $ConditionsTable(attachedDatabase, alias);
  }
}

class Condition extends DataClass implements Insertable<Condition> {
  final int id;
  final String name;
  const Condition({required this.id, required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    return map;
  }

  ConditionsCompanion toCompanion(bool nullToAbsent) {
    return ConditionsCompanion(
      id: Value(id),
      name: Value(name),
    );
  }

  factory Condition.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Condition(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
    };
  }

  Condition copyWith({int? id, String? name}) => Condition(
        id: id ?? this.id,
        name: name ?? this.name,
      );
  Condition copyWithCompanion(ConditionsCompanion data) {
    return Condition(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Condition(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Condition && other.id == this.id && other.name == this.name);
}

class ConditionsCompanion extends UpdateCompanion<Condition> {
  final Value<int> id;
  final Value<String> name;
  const ConditionsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
  });
  ConditionsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
  }) : name = Value(name);
  static Insertable<Condition> custom({
    Expression<int>? id,
    Expression<String>? name,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
    });
  }

  ConditionsCompanion copyWith({Value<int>? id, Value<String>? name}) {
    return ConditionsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ConditionsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }
}

class $SyncMetaTable extends SyncMeta
    with TableInfo<$SyncMetaTable, SyncMetaData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncMetaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
      'key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
      'value', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_meta';
  @override
  VerificationContext validateIntegrity(Insertable<SyncMetaData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
          _keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
          _valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  SyncMetaData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncMetaData(
      key: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      value: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}value']),
    );
  }

  @override
  $SyncMetaTable createAlias(String alias) {
    return $SyncMetaTable(attachedDatabase, alias);
  }
}

class SyncMetaData extends DataClass implements Insertable<SyncMetaData> {
  final String key;
  final String? value;
  const SyncMetaData({required this.key, this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    if (!nullToAbsent || value != null) {
      map['value'] = Variable<String>(value);
    }
    return map;
  }

  SyncMetaCompanion toCompanion(bool nullToAbsent) {
    return SyncMetaCompanion(
      key: Value(key),
      value:
          value == null && nullToAbsent ? const Value.absent() : Value(value),
    );
  }

  factory SyncMetaData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncMetaData(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String?>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String?>(value),
    };
  }

  SyncMetaData copyWith(
          {String? key, Value<String?> value = const Value.absent()}) =>
      SyncMetaData(
        key: key ?? this.key,
        value: value.present ? value.value : this.value,
      );
  SyncMetaData copyWithCompanion(SyncMetaCompanion data) {
    return SyncMetaData(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncMetaData(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncMetaData &&
          other.key == this.key &&
          other.value == this.value);
}

class SyncMetaCompanion extends UpdateCompanion<SyncMetaData> {
  final Value<String> key;
  final Value<String?> value;
  final Value<int> rowid;
  const SyncMetaCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncMetaCompanion.insert({
    required String key,
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : key = Value(key);
  static Insertable<SyncMetaData> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncMetaCompanion copyWith(
      {Value<String>? key, Value<String?>? value, Value<int>? rowid}) {
    return SyncMetaCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncMetaCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SymptomMetricsTable symptomMetrics = $SymptomMetricsTable(this);
  late final $FoodMetricsTable foodMetrics = $FoodMetricsTable(this);
  late final $SleepMetricsTable sleepMetrics = $SleepMetricsTable(this);
  late final $MedicationMetricsTable medicationMetrics =
      $MedicationMetricsTable(this);
  late final $ExerciseMetricsTable exerciseMetrics =
      $ExerciseMetricsTable(this);
  late final $UrineMetricsTable urineMetrics = $UrineMetricsTable(this);
  late final $BowelMetricsTable bowelMetrics = $BowelMetricsTable(this);
  late final $MenstrualCyclesTable menstrualCycles =
      $MenstrualCyclesTable(this);
  late final $CycleDaysTable cycleDays = $CycleDaysTable(this);
  late final $SmileyEntriesTable smileyEntries = $SmileyEntriesTable(this);
  late final $PointRecordsTable pointRecords = $PointRecordsTable(this);
  late final $UserTrackedMetricsTable userTrackedMetrics =
      $UserTrackedMetricsTable(this);
  late final $UserConditionsTable userConditions = $UserConditionsTable(this);
  late final $UserSettingsTable userSettings = $UserSettingsTable(this);
  late final $SymptomsTable symptoms = $SymptomsTable(this);
  late final $TrackedMetricsCatalogTable trackedMetricsCatalog =
      $TrackedMetricsCatalogTable(this);
  late final $SmileyCatalogTable smileyCatalog = $SmileyCatalogTable(this);
  late final $ConditionsTable conditions = $ConditionsTable(this);
  late final $SyncMetaTable syncMeta = $SyncMetaTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        symptomMetrics,
        foodMetrics,
        sleepMetrics,
        medicationMetrics,
        exerciseMetrics,
        urineMetrics,
        bowelMetrics,
        menstrualCycles,
        cycleDays,
        smileyEntries,
        pointRecords,
        userTrackedMetrics,
        userConditions,
        userSettings,
        symptoms,
        trackedMetricsCatalog,
        smileyCatalog,
        conditions,
        syncMeta
      ];
}

typedef $$SymptomMetricsTableCreateCompanionBuilder = SymptomMetricsCompanion
    Function({
  required String id,
  Value<DateTime?> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String> syncState,
  required DateTime localUpdatedAt,
  required int symptomsId,
  required String date,
  Value<double> morningSeverity,
  Value<double> afternoonSeverity,
  Value<double> nightSeverity,
  Value<int> rowid,
});
typedef $$SymptomMetricsTableUpdateCompanionBuilder = SymptomMetricsCompanion
    Function({
  Value<String> id,
  Value<DateTime?> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String> syncState,
  Value<DateTime> localUpdatedAt,
  Value<int> symptomsId,
  Value<String> date,
  Value<double> morningSeverity,
  Value<double> afternoonSeverity,
  Value<double> nightSeverity,
  Value<int> rowid,
});

class $$SymptomMetricsTableFilterComposer
    extends Composer<_$AppDatabase, $SymptomMetricsTable> {
  $$SymptomMetricsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncState => $composableBuilder(
      column: $table.syncState, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get localUpdatedAt => $composableBuilder(
      column: $table.localUpdatedAt,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get symptomsId => $composableBuilder(
      column: $table.symptomsId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get morningSeverity => $composableBuilder(
      column: $table.morningSeverity,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get afternoonSeverity => $composableBuilder(
      column: $table.afternoonSeverity,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get nightSeverity => $composableBuilder(
      column: $table.nightSeverity, builder: (column) => ColumnFilters(column));
}

class $$SymptomMetricsTableOrderingComposer
    extends Composer<_$AppDatabase, $SymptomMetricsTable> {
  $$SymptomMetricsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncState => $composableBuilder(
      column: $table.syncState, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get localUpdatedAt => $composableBuilder(
      column: $table.localUpdatedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get symptomsId => $composableBuilder(
      column: $table.symptomsId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get morningSeverity => $composableBuilder(
      column: $table.morningSeverity,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get afternoonSeverity => $composableBuilder(
      column: $table.afternoonSeverity,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get nightSeverity => $composableBuilder(
      column: $table.nightSeverity,
      builder: (column) => ColumnOrderings(column));
}

class $$SymptomMetricsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SymptomMetricsTable> {
  $$SymptomMetricsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  GeneratedColumn<DateTime> get localUpdatedAt => $composableBuilder(
      column: $table.localUpdatedAt, builder: (column) => column);

  GeneratedColumn<int> get symptomsId => $composableBuilder(
      column: $table.symptomsId, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<double> get morningSeverity => $composableBuilder(
      column: $table.morningSeverity, builder: (column) => column);

  GeneratedColumn<double> get afternoonSeverity => $composableBuilder(
      column: $table.afternoonSeverity, builder: (column) => column);

  GeneratedColumn<double> get nightSeverity => $composableBuilder(
      column: $table.nightSeverity, builder: (column) => column);
}

class $$SymptomMetricsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SymptomMetricsTable,
    SymptomMetric,
    $$SymptomMetricsTableFilterComposer,
    $$SymptomMetricsTableOrderingComposer,
    $$SymptomMetricsTableAnnotationComposer,
    $$SymptomMetricsTableCreateCompanionBuilder,
    $$SymptomMetricsTableUpdateCompanionBuilder,
    (
      SymptomMetric,
      BaseReferences<_$AppDatabase, $SymptomMetricsTable, SymptomMetric>
    ),
    SymptomMetric,
    PrefetchHooks Function()> {
  $$SymptomMetricsTableTableManager(
      _$AppDatabase db, $SymptomMetricsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SymptomMetricsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SymptomMetricsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SymptomMetricsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String> syncState = const Value.absent(),
            Value<DateTime> localUpdatedAt = const Value.absent(),
            Value<int> symptomsId = const Value.absent(),
            Value<String> date = const Value.absent(),
            Value<double> morningSeverity = const Value.absent(),
            Value<double> afternoonSeverity = const Value.absent(),
            Value<double> nightSeverity = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SymptomMetricsCompanion(
            id: id,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            syncState: syncState,
            localUpdatedAt: localUpdatedAt,
            symptomsId: symptomsId,
            date: date,
            morningSeverity: morningSeverity,
            afternoonSeverity: afternoonSeverity,
            nightSeverity: nightSeverity,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String> syncState = const Value.absent(),
            required DateTime localUpdatedAt,
            required int symptomsId,
            required String date,
            Value<double> morningSeverity = const Value.absent(),
            Value<double> afternoonSeverity = const Value.absent(),
            Value<double> nightSeverity = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SymptomMetricsCompanion.insert(
            id: id,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            syncState: syncState,
            localUpdatedAt: localUpdatedAt,
            symptomsId: symptomsId,
            date: date,
            morningSeverity: morningSeverity,
            afternoonSeverity: afternoonSeverity,
            nightSeverity: nightSeverity,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SymptomMetricsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SymptomMetricsTable,
    SymptomMetric,
    $$SymptomMetricsTableFilterComposer,
    $$SymptomMetricsTableOrderingComposer,
    $$SymptomMetricsTableAnnotationComposer,
    $$SymptomMetricsTableCreateCompanionBuilder,
    $$SymptomMetricsTableUpdateCompanionBuilder,
    (
      SymptomMetric,
      BaseReferences<_$AppDatabase, $SymptomMetricsTable, SymptomMetric>
    ),
    SymptomMetric,
    PrefetchHooks Function()>;
typedef $$FoodMetricsTableCreateCompanionBuilder = FoodMetricsCompanion
    Function({
  required String id,
  Value<DateTime?> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String> syncState,
  required DateTime localUpdatedAt,
  required String date,
  Value<String> breakfastMeal,
  Value<String> lunchMeal,
  Value<String> dinnerMeal,
  Value<String> breakfastExtra,
  Value<String> lunchExtra,
  Value<String> dinnerExtra,
  Value<String> breakfastFruit,
  Value<String> lunchFruit,
  Value<String> dinnerFruit,
  Value<List<String>> breakfastTags,
  Value<List<String>> lunchTags,
  Value<List<String>> dinnerTags,
  Value<String> snackName,
  Value<List<String>> snackTags,
  Value<int> glassNo,
  Value<int> rowid,
});
typedef $$FoodMetricsTableUpdateCompanionBuilder = FoodMetricsCompanion
    Function({
  Value<String> id,
  Value<DateTime?> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String> syncState,
  Value<DateTime> localUpdatedAt,
  Value<String> date,
  Value<String> breakfastMeal,
  Value<String> lunchMeal,
  Value<String> dinnerMeal,
  Value<String> breakfastExtra,
  Value<String> lunchExtra,
  Value<String> dinnerExtra,
  Value<String> breakfastFruit,
  Value<String> lunchFruit,
  Value<String> dinnerFruit,
  Value<List<String>> breakfastTags,
  Value<List<String>> lunchTags,
  Value<List<String>> dinnerTags,
  Value<String> snackName,
  Value<List<String>> snackTags,
  Value<int> glassNo,
  Value<int> rowid,
});

class $$FoodMetricsTableFilterComposer
    extends Composer<_$AppDatabase, $FoodMetricsTable> {
  $$FoodMetricsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncState => $composableBuilder(
      column: $table.syncState, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get localUpdatedAt => $composableBuilder(
      column: $table.localUpdatedAt,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get breakfastMeal => $composableBuilder(
      column: $table.breakfastMeal, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lunchMeal => $composableBuilder(
      column: $table.lunchMeal, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get dinnerMeal => $composableBuilder(
      column: $table.dinnerMeal, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get breakfastExtra => $composableBuilder(
      column: $table.breakfastExtra,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lunchExtra => $composableBuilder(
      column: $table.lunchExtra, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get dinnerExtra => $composableBuilder(
      column: $table.dinnerExtra, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get breakfastFruit => $composableBuilder(
      column: $table.breakfastFruit,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lunchFruit => $composableBuilder(
      column: $table.lunchFruit, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get dinnerFruit => $composableBuilder(
      column: $table.dinnerFruit, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<List<String>, List<String>, String>
      get breakfastTags => $composableBuilder(
          column: $table.breakfastTags,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<List<String>, List<String>, String>
      get lunchTags => $composableBuilder(
          column: $table.lunchTags,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<List<String>, List<String>, String>
      get dinnerTags => $composableBuilder(
          column: $table.dinnerTags,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<String> get snackName => $composableBuilder(
      column: $table.snackName, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<List<String>, List<String>, String>
      get snackTags => $composableBuilder(
          column: $table.snackTags,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<int> get glassNo => $composableBuilder(
      column: $table.glassNo, builder: (column) => ColumnFilters(column));
}

class $$FoodMetricsTableOrderingComposer
    extends Composer<_$AppDatabase, $FoodMetricsTable> {
  $$FoodMetricsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncState => $composableBuilder(
      column: $table.syncState, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get localUpdatedAt => $composableBuilder(
      column: $table.localUpdatedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get breakfastMeal => $composableBuilder(
      column: $table.breakfastMeal,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lunchMeal => $composableBuilder(
      column: $table.lunchMeal, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get dinnerMeal => $composableBuilder(
      column: $table.dinnerMeal, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get breakfastExtra => $composableBuilder(
      column: $table.breakfastExtra,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lunchExtra => $composableBuilder(
      column: $table.lunchExtra, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get dinnerExtra => $composableBuilder(
      column: $table.dinnerExtra, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get breakfastFruit => $composableBuilder(
      column: $table.breakfastFruit,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lunchFruit => $composableBuilder(
      column: $table.lunchFruit, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get dinnerFruit => $composableBuilder(
      column: $table.dinnerFruit, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get breakfastTags => $composableBuilder(
      column: $table.breakfastTags,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lunchTags => $composableBuilder(
      column: $table.lunchTags, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get dinnerTags => $composableBuilder(
      column: $table.dinnerTags, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get snackName => $composableBuilder(
      column: $table.snackName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get snackTags => $composableBuilder(
      column: $table.snackTags, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get glassNo => $composableBuilder(
      column: $table.glassNo, builder: (column) => ColumnOrderings(column));
}

class $$FoodMetricsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FoodMetricsTable> {
  $$FoodMetricsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  GeneratedColumn<DateTime> get localUpdatedAt => $composableBuilder(
      column: $table.localUpdatedAt, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get breakfastMeal => $composableBuilder(
      column: $table.breakfastMeal, builder: (column) => column);

  GeneratedColumn<String> get lunchMeal =>
      $composableBuilder(column: $table.lunchMeal, builder: (column) => column);

  GeneratedColumn<String> get dinnerMeal => $composableBuilder(
      column: $table.dinnerMeal, builder: (column) => column);

  GeneratedColumn<String> get breakfastExtra => $composableBuilder(
      column: $table.breakfastExtra, builder: (column) => column);

  GeneratedColumn<String> get lunchExtra => $composableBuilder(
      column: $table.lunchExtra, builder: (column) => column);

  GeneratedColumn<String> get dinnerExtra => $composableBuilder(
      column: $table.dinnerExtra, builder: (column) => column);

  GeneratedColumn<String> get breakfastFruit => $composableBuilder(
      column: $table.breakfastFruit, builder: (column) => column);

  GeneratedColumn<String> get lunchFruit => $composableBuilder(
      column: $table.lunchFruit, builder: (column) => column);

  GeneratedColumn<String> get dinnerFruit => $composableBuilder(
      column: $table.dinnerFruit, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<String>, String> get breakfastTags =>
      $composableBuilder(
          column: $table.breakfastTags, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<String>, String> get lunchTags =>
      $composableBuilder(column: $table.lunchTags, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<String>, String> get dinnerTags =>
      $composableBuilder(
          column: $table.dinnerTags, builder: (column) => column);

  GeneratedColumn<String> get snackName =>
      $composableBuilder(column: $table.snackName, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<String>, String> get snackTags =>
      $composableBuilder(column: $table.snackTags, builder: (column) => column);

  GeneratedColumn<int> get glassNo =>
      $composableBuilder(column: $table.glassNo, builder: (column) => column);
}

class $$FoodMetricsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $FoodMetricsTable,
    FoodMetric,
    $$FoodMetricsTableFilterComposer,
    $$FoodMetricsTableOrderingComposer,
    $$FoodMetricsTableAnnotationComposer,
    $$FoodMetricsTableCreateCompanionBuilder,
    $$FoodMetricsTableUpdateCompanionBuilder,
    (FoodMetric, BaseReferences<_$AppDatabase, $FoodMetricsTable, FoodMetric>),
    FoodMetric,
    PrefetchHooks Function()> {
  $$FoodMetricsTableTableManager(_$AppDatabase db, $FoodMetricsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FoodMetricsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FoodMetricsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FoodMetricsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String> syncState = const Value.absent(),
            Value<DateTime> localUpdatedAt = const Value.absent(),
            Value<String> date = const Value.absent(),
            Value<String> breakfastMeal = const Value.absent(),
            Value<String> lunchMeal = const Value.absent(),
            Value<String> dinnerMeal = const Value.absent(),
            Value<String> breakfastExtra = const Value.absent(),
            Value<String> lunchExtra = const Value.absent(),
            Value<String> dinnerExtra = const Value.absent(),
            Value<String> breakfastFruit = const Value.absent(),
            Value<String> lunchFruit = const Value.absent(),
            Value<String> dinnerFruit = const Value.absent(),
            Value<List<String>> breakfastTags = const Value.absent(),
            Value<List<String>> lunchTags = const Value.absent(),
            Value<List<String>> dinnerTags = const Value.absent(),
            Value<String> snackName = const Value.absent(),
            Value<List<String>> snackTags = const Value.absent(),
            Value<int> glassNo = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              FoodMetricsCompanion(
            id: id,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            syncState: syncState,
            localUpdatedAt: localUpdatedAt,
            date: date,
            breakfastMeal: breakfastMeal,
            lunchMeal: lunchMeal,
            dinnerMeal: dinnerMeal,
            breakfastExtra: breakfastExtra,
            lunchExtra: lunchExtra,
            dinnerExtra: dinnerExtra,
            breakfastFruit: breakfastFruit,
            lunchFruit: lunchFruit,
            dinnerFruit: dinnerFruit,
            breakfastTags: breakfastTags,
            lunchTags: lunchTags,
            dinnerTags: dinnerTags,
            snackName: snackName,
            snackTags: snackTags,
            glassNo: glassNo,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String> syncState = const Value.absent(),
            required DateTime localUpdatedAt,
            required String date,
            Value<String> breakfastMeal = const Value.absent(),
            Value<String> lunchMeal = const Value.absent(),
            Value<String> dinnerMeal = const Value.absent(),
            Value<String> breakfastExtra = const Value.absent(),
            Value<String> lunchExtra = const Value.absent(),
            Value<String> dinnerExtra = const Value.absent(),
            Value<String> breakfastFruit = const Value.absent(),
            Value<String> lunchFruit = const Value.absent(),
            Value<String> dinnerFruit = const Value.absent(),
            Value<List<String>> breakfastTags = const Value.absent(),
            Value<List<String>> lunchTags = const Value.absent(),
            Value<List<String>> dinnerTags = const Value.absent(),
            Value<String> snackName = const Value.absent(),
            Value<List<String>> snackTags = const Value.absent(),
            Value<int> glassNo = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              FoodMetricsCompanion.insert(
            id: id,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            syncState: syncState,
            localUpdatedAt: localUpdatedAt,
            date: date,
            breakfastMeal: breakfastMeal,
            lunchMeal: lunchMeal,
            dinnerMeal: dinnerMeal,
            breakfastExtra: breakfastExtra,
            lunchExtra: lunchExtra,
            dinnerExtra: dinnerExtra,
            breakfastFruit: breakfastFruit,
            lunchFruit: lunchFruit,
            dinnerFruit: dinnerFruit,
            breakfastTags: breakfastTags,
            lunchTags: lunchTags,
            dinnerTags: dinnerTags,
            snackName: snackName,
            snackTags: snackTags,
            glassNo: glassNo,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$FoodMetricsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $FoodMetricsTable,
    FoodMetric,
    $$FoodMetricsTableFilterComposer,
    $$FoodMetricsTableOrderingComposer,
    $$FoodMetricsTableAnnotationComposer,
    $$FoodMetricsTableCreateCompanionBuilder,
    $$FoodMetricsTableUpdateCompanionBuilder,
    (FoodMetric, BaseReferences<_$AppDatabase, $FoodMetricsTable, FoodMetric>),
    FoodMetric,
    PrefetchHooks Function()>;
typedef $$SleepMetricsTableCreateCompanionBuilder = SleepMetricsCompanion
    Function({
  required String id,
  Value<DateTime?> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String> syncState,
  required DateTime localUpdatedAt,
  required String date,
  required bool isNight,
  Value<String> timeSlept,
  Value<String> timeWokeUp,
  Value<List<String>> tags,
  Value<double> severity,
  Value<int> rowid,
});
typedef $$SleepMetricsTableUpdateCompanionBuilder = SleepMetricsCompanion
    Function({
  Value<String> id,
  Value<DateTime?> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String> syncState,
  Value<DateTime> localUpdatedAt,
  Value<String> date,
  Value<bool> isNight,
  Value<String> timeSlept,
  Value<String> timeWokeUp,
  Value<List<String>> tags,
  Value<double> severity,
  Value<int> rowid,
});

class $$SleepMetricsTableFilterComposer
    extends Composer<_$AppDatabase, $SleepMetricsTable> {
  $$SleepMetricsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncState => $composableBuilder(
      column: $table.syncState, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get localUpdatedAt => $composableBuilder(
      column: $table.localUpdatedAt,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isNight => $composableBuilder(
      column: $table.isNight, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get timeSlept => $composableBuilder(
      column: $table.timeSlept, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get timeWokeUp => $composableBuilder(
      column: $table.timeWokeUp, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<List<String>, List<String>, String> get tags =>
      $composableBuilder(
          column: $table.tags,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<double> get severity => $composableBuilder(
      column: $table.severity, builder: (column) => ColumnFilters(column));
}

class $$SleepMetricsTableOrderingComposer
    extends Composer<_$AppDatabase, $SleepMetricsTable> {
  $$SleepMetricsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncState => $composableBuilder(
      column: $table.syncState, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get localUpdatedAt => $composableBuilder(
      column: $table.localUpdatedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isNight => $composableBuilder(
      column: $table.isNight, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get timeSlept => $composableBuilder(
      column: $table.timeSlept, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get timeWokeUp => $composableBuilder(
      column: $table.timeWokeUp, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tags => $composableBuilder(
      column: $table.tags, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get severity => $composableBuilder(
      column: $table.severity, builder: (column) => ColumnOrderings(column));
}

class $$SleepMetricsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SleepMetricsTable> {
  $$SleepMetricsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  GeneratedColumn<DateTime> get localUpdatedAt => $composableBuilder(
      column: $table.localUpdatedAt, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<bool> get isNight =>
      $composableBuilder(column: $table.isNight, builder: (column) => column);

  GeneratedColumn<String> get timeSlept =>
      $composableBuilder(column: $table.timeSlept, builder: (column) => column);

  GeneratedColumn<String> get timeWokeUp => $composableBuilder(
      column: $table.timeWokeUp, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<String>, String> get tags =>
      $composableBuilder(column: $table.tags, builder: (column) => column);

  GeneratedColumn<double> get severity =>
      $composableBuilder(column: $table.severity, builder: (column) => column);
}

class $$SleepMetricsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SleepMetricsTable,
    SleepMetric,
    $$SleepMetricsTableFilterComposer,
    $$SleepMetricsTableOrderingComposer,
    $$SleepMetricsTableAnnotationComposer,
    $$SleepMetricsTableCreateCompanionBuilder,
    $$SleepMetricsTableUpdateCompanionBuilder,
    (
      SleepMetric,
      BaseReferences<_$AppDatabase, $SleepMetricsTable, SleepMetric>
    ),
    SleepMetric,
    PrefetchHooks Function()> {
  $$SleepMetricsTableTableManager(_$AppDatabase db, $SleepMetricsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SleepMetricsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SleepMetricsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SleepMetricsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String> syncState = const Value.absent(),
            Value<DateTime> localUpdatedAt = const Value.absent(),
            Value<String> date = const Value.absent(),
            Value<bool> isNight = const Value.absent(),
            Value<String> timeSlept = const Value.absent(),
            Value<String> timeWokeUp = const Value.absent(),
            Value<List<String>> tags = const Value.absent(),
            Value<double> severity = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SleepMetricsCompanion(
            id: id,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            syncState: syncState,
            localUpdatedAt: localUpdatedAt,
            date: date,
            isNight: isNight,
            timeSlept: timeSlept,
            timeWokeUp: timeWokeUp,
            tags: tags,
            severity: severity,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String> syncState = const Value.absent(),
            required DateTime localUpdatedAt,
            required String date,
            required bool isNight,
            Value<String> timeSlept = const Value.absent(),
            Value<String> timeWokeUp = const Value.absent(),
            Value<List<String>> tags = const Value.absent(),
            Value<double> severity = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SleepMetricsCompanion.insert(
            id: id,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            syncState: syncState,
            localUpdatedAt: localUpdatedAt,
            date: date,
            isNight: isNight,
            timeSlept: timeSlept,
            timeWokeUp: timeWokeUp,
            tags: tags,
            severity: severity,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SleepMetricsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SleepMetricsTable,
    SleepMetric,
    $$SleepMetricsTableFilterComposer,
    $$SleepMetricsTableOrderingComposer,
    $$SleepMetricsTableAnnotationComposer,
    $$SleepMetricsTableCreateCompanionBuilder,
    $$SleepMetricsTableUpdateCompanionBuilder,
    (
      SleepMetric,
      BaseReferences<_$AppDatabase, $SleepMetricsTable, SleepMetric>
    ),
    SleepMetric,
    PrefetchHooks Function()>;
typedef $$MedicationMetricsTableCreateCompanionBuilder
    = MedicationMetricsCompanion Function({
  required String id,
  Value<DateTime?> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String> syncState,
  required DateTime localUpdatedAt,
  required String date,
  Value<String> name,
  Value<int> dosage,
  Value<String> metric,
  Value<int> quantity,
  Value<String> time,
  Value<int> rowid,
});
typedef $$MedicationMetricsTableUpdateCompanionBuilder
    = MedicationMetricsCompanion Function({
  Value<String> id,
  Value<DateTime?> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String> syncState,
  Value<DateTime> localUpdatedAt,
  Value<String> date,
  Value<String> name,
  Value<int> dosage,
  Value<String> metric,
  Value<int> quantity,
  Value<String> time,
  Value<int> rowid,
});

class $$MedicationMetricsTableFilterComposer
    extends Composer<_$AppDatabase, $MedicationMetricsTable> {
  $$MedicationMetricsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncState => $composableBuilder(
      column: $table.syncState, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get localUpdatedAt => $composableBuilder(
      column: $table.localUpdatedAt,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get dosage => $composableBuilder(
      column: $table.dosage, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get metric => $composableBuilder(
      column: $table.metric, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get time => $composableBuilder(
      column: $table.time, builder: (column) => ColumnFilters(column));
}

class $$MedicationMetricsTableOrderingComposer
    extends Composer<_$AppDatabase, $MedicationMetricsTable> {
  $$MedicationMetricsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncState => $composableBuilder(
      column: $table.syncState, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get localUpdatedAt => $composableBuilder(
      column: $table.localUpdatedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get dosage => $composableBuilder(
      column: $table.dosage, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get metric => $composableBuilder(
      column: $table.metric, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get time => $composableBuilder(
      column: $table.time, builder: (column) => ColumnOrderings(column));
}

class $$MedicationMetricsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MedicationMetricsTable> {
  $$MedicationMetricsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  GeneratedColumn<DateTime> get localUpdatedAt => $composableBuilder(
      column: $table.localUpdatedAt, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get dosage =>
      $composableBuilder(column: $table.dosage, builder: (column) => column);

  GeneratedColumn<String> get metric =>
      $composableBuilder(column: $table.metric, builder: (column) => column);

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<String> get time =>
      $composableBuilder(column: $table.time, builder: (column) => column);
}

class $$MedicationMetricsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MedicationMetricsTable,
    MedicationMetric,
    $$MedicationMetricsTableFilterComposer,
    $$MedicationMetricsTableOrderingComposer,
    $$MedicationMetricsTableAnnotationComposer,
    $$MedicationMetricsTableCreateCompanionBuilder,
    $$MedicationMetricsTableUpdateCompanionBuilder,
    (
      MedicationMetric,
      BaseReferences<_$AppDatabase, $MedicationMetricsTable, MedicationMetric>
    ),
    MedicationMetric,
    PrefetchHooks Function()> {
  $$MedicationMetricsTableTableManager(
      _$AppDatabase db, $MedicationMetricsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MedicationMetricsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MedicationMetricsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MedicationMetricsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String> syncState = const Value.absent(),
            Value<DateTime> localUpdatedAt = const Value.absent(),
            Value<String> date = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<int> dosage = const Value.absent(),
            Value<String> metric = const Value.absent(),
            Value<int> quantity = const Value.absent(),
            Value<String> time = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MedicationMetricsCompanion(
            id: id,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            syncState: syncState,
            localUpdatedAt: localUpdatedAt,
            date: date,
            name: name,
            dosage: dosage,
            metric: metric,
            quantity: quantity,
            time: time,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String> syncState = const Value.absent(),
            required DateTime localUpdatedAt,
            required String date,
            Value<String> name = const Value.absent(),
            Value<int> dosage = const Value.absent(),
            Value<String> metric = const Value.absent(),
            Value<int> quantity = const Value.absent(),
            Value<String> time = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MedicationMetricsCompanion.insert(
            id: id,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            syncState: syncState,
            localUpdatedAt: localUpdatedAt,
            date: date,
            name: name,
            dosage: dosage,
            metric: metric,
            quantity: quantity,
            time: time,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$MedicationMetricsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $MedicationMetricsTable,
    MedicationMetric,
    $$MedicationMetricsTableFilterComposer,
    $$MedicationMetricsTableOrderingComposer,
    $$MedicationMetricsTableAnnotationComposer,
    $$MedicationMetricsTableCreateCompanionBuilder,
    $$MedicationMetricsTableUpdateCompanionBuilder,
    (
      MedicationMetric,
      BaseReferences<_$AppDatabase, $MedicationMetricsTable, MedicationMetric>
    ),
    MedicationMetric,
    PrefetchHooks Function()>;
typedef $$ExerciseMetricsTableCreateCompanionBuilder = ExerciseMetricsCompanion
    Function({
  required String id,
  Value<DateTime?> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String> syncState,
  required DateTime localUpdatedAt,
  required String date,
  Value<String> name,
  Value<String> started,
  Value<String> ended,
  Value<List<String>> tags,
  Value<int> noOfTimes,
  Value<int> rowid,
});
typedef $$ExerciseMetricsTableUpdateCompanionBuilder = ExerciseMetricsCompanion
    Function({
  Value<String> id,
  Value<DateTime?> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String> syncState,
  Value<DateTime> localUpdatedAt,
  Value<String> date,
  Value<String> name,
  Value<String> started,
  Value<String> ended,
  Value<List<String>> tags,
  Value<int> noOfTimes,
  Value<int> rowid,
});

class $$ExerciseMetricsTableFilterComposer
    extends Composer<_$AppDatabase, $ExerciseMetricsTable> {
  $$ExerciseMetricsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncState => $composableBuilder(
      column: $table.syncState, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get localUpdatedAt => $composableBuilder(
      column: $table.localUpdatedAt,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get started => $composableBuilder(
      column: $table.started, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ended => $composableBuilder(
      column: $table.ended, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<List<String>, List<String>, String> get tags =>
      $composableBuilder(
          column: $table.tags,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<int> get noOfTimes => $composableBuilder(
      column: $table.noOfTimes, builder: (column) => ColumnFilters(column));
}

class $$ExerciseMetricsTableOrderingComposer
    extends Composer<_$AppDatabase, $ExerciseMetricsTable> {
  $$ExerciseMetricsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncState => $composableBuilder(
      column: $table.syncState, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get localUpdatedAt => $composableBuilder(
      column: $table.localUpdatedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get started => $composableBuilder(
      column: $table.started, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ended => $composableBuilder(
      column: $table.ended, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tags => $composableBuilder(
      column: $table.tags, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get noOfTimes => $composableBuilder(
      column: $table.noOfTimes, builder: (column) => ColumnOrderings(column));
}

class $$ExerciseMetricsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExerciseMetricsTable> {
  $$ExerciseMetricsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  GeneratedColumn<DateTime> get localUpdatedAt => $composableBuilder(
      column: $table.localUpdatedAt, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get started =>
      $composableBuilder(column: $table.started, builder: (column) => column);

  GeneratedColumn<String> get ended =>
      $composableBuilder(column: $table.ended, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<String>, String> get tags =>
      $composableBuilder(column: $table.tags, builder: (column) => column);

  GeneratedColumn<int> get noOfTimes =>
      $composableBuilder(column: $table.noOfTimes, builder: (column) => column);
}

class $$ExerciseMetricsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ExerciseMetricsTable,
    ExerciseMetric,
    $$ExerciseMetricsTableFilterComposer,
    $$ExerciseMetricsTableOrderingComposer,
    $$ExerciseMetricsTableAnnotationComposer,
    $$ExerciseMetricsTableCreateCompanionBuilder,
    $$ExerciseMetricsTableUpdateCompanionBuilder,
    (
      ExerciseMetric,
      BaseReferences<_$AppDatabase, $ExerciseMetricsTable, ExerciseMetric>
    ),
    ExerciseMetric,
    PrefetchHooks Function()> {
  $$ExerciseMetricsTableTableManager(
      _$AppDatabase db, $ExerciseMetricsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExerciseMetricsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExerciseMetricsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExerciseMetricsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String> syncState = const Value.absent(),
            Value<DateTime> localUpdatedAt = const Value.absent(),
            Value<String> date = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> started = const Value.absent(),
            Value<String> ended = const Value.absent(),
            Value<List<String>> tags = const Value.absent(),
            Value<int> noOfTimes = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ExerciseMetricsCompanion(
            id: id,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            syncState: syncState,
            localUpdatedAt: localUpdatedAt,
            date: date,
            name: name,
            started: started,
            ended: ended,
            tags: tags,
            noOfTimes: noOfTimes,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String> syncState = const Value.absent(),
            required DateTime localUpdatedAt,
            required String date,
            Value<String> name = const Value.absent(),
            Value<String> started = const Value.absent(),
            Value<String> ended = const Value.absent(),
            Value<List<String>> tags = const Value.absent(),
            Value<int> noOfTimes = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ExerciseMetricsCompanion.insert(
            id: id,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            syncState: syncState,
            localUpdatedAt: localUpdatedAt,
            date: date,
            name: name,
            started: started,
            ended: ended,
            tags: tags,
            noOfTimes: noOfTimes,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ExerciseMetricsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ExerciseMetricsTable,
    ExerciseMetric,
    $$ExerciseMetricsTableFilterComposer,
    $$ExerciseMetricsTableOrderingComposer,
    $$ExerciseMetricsTableAnnotationComposer,
    $$ExerciseMetricsTableCreateCompanionBuilder,
    $$ExerciseMetricsTableUpdateCompanionBuilder,
    (
      ExerciseMetric,
      BaseReferences<_$AppDatabase, $ExerciseMetricsTable, ExerciseMetric>
    ),
    ExerciseMetric,
    PrefetchHooks Function()>;
typedef $$UrineMetricsTableCreateCompanionBuilder = UrineMetricsCompanion
    Function({
  required String id,
  Value<DateTime?> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String> syncState,
  required DateTime localUpdatedAt,
  required String date,
  Value<int> type,
  Value<double> pain,
  Value<String> time,
  Value<List<String>> tags,
  Value<double> quantity,
  Value<int> rowid,
});
typedef $$UrineMetricsTableUpdateCompanionBuilder = UrineMetricsCompanion
    Function({
  Value<String> id,
  Value<DateTime?> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String> syncState,
  Value<DateTime> localUpdatedAt,
  Value<String> date,
  Value<int> type,
  Value<double> pain,
  Value<String> time,
  Value<List<String>> tags,
  Value<double> quantity,
  Value<int> rowid,
});

class $$UrineMetricsTableFilterComposer
    extends Composer<_$AppDatabase, $UrineMetricsTable> {
  $$UrineMetricsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncState => $composableBuilder(
      column: $table.syncState, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get localUpdatedAt => $composableBuilder(
      column: $table.localUpdatedAt,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get pain => $composableBuilder(
      column: $table.pain, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get time => $composableBuilder(
      column: $table.time, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<List<String>, List<String>, String> get tags =>
      $composableBuilder(
          column: $table.tags,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<double> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnFilters(column));
}

class $$UrineMetricsTableOrderingComposer
    extends Composer<_$AppDatabase, $UrineMetricsTable> {
  $$UrineMetricsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncState => $composableBuilder(
      column: $table.syncState, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get localUpdatedAt => $composableBuilder(
      column: $table.localUpdatedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get pain => $composableBuilder(
      column: $table.pain, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get time => $composableBuilder(
      column: $table.time, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tags => $composableBuilder(
      column: $table.tags, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnOrderings(column));
}

class $$UrineMetricsTableAnnotationComposer
    extends Composer<_$AppDatabase, $UrineMetricsTable> {
  $$UrineMetricsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  GeneratedColumn<DateTime> get localUpdatedAt => $composableBuilder(
      column: $table.localUpdatedAt, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<double> get pain =>
      $composableBuilder(column: $table.pain, builder: (column) => column);

  GeneratedColumn<String> get time =>
      $composableBuilder(column: $table.time, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<String>, String> get tags =>
      $composableBuilder(column: $table.tags, builder: (column) => column);

  GeneratedColumn<double> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);
}

class $$UrineMetricsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $UrineMetricsTable,
    UrineMetric,
    $$UrineMetricsTableFilterComposer,
    $$UrineMetricsTableOrderingComposer,
    $$UrineMetricsTableAnnotationComposer,
    $$UrineMetricsTableCreateCompanionBuilder,
    $$UrineMetricsTableUpdateCompanionBuilder,
    (
      UrineMetric,
      BaseReferences<_$AppDatabase, $UrineMetricsTable, UrineMetric>
    ),
    UrineMetric,
    PrefetchHooks Function()> {
  $$UrineMetricsTableTableManager(_$AppDatabase db, $UrineMetricsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UrineMetricsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UrineMetricsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UrineMetricsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String> syncState = const Value.absent(),
            Value<DateTime> localUpdatedAt = const Value.absent(),
            Value<String> date = const Value.absent(),
            Value<int> type = const Value.absent(),
            Value<double> pain = const Value.absent(),
            Value<String> time = const Value.absent(),
            Value<List<String>> tags = const Value.absent(),
            Value<double> quantity = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UrineMetricsCompanion(
            id: id,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            syncState: syncState,
            localUpdatedAt: localUpdatedAt,
            date: date,
            type: type,
            pain: pain,
            time: time,
            tags: tags,
            quantity: quantity,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String> syncState = const Value.absent(),
            required DateTime localUpdatedAt,
            required String date,
            Value<int> type = const Value.absent(),
            Value<double> pain = const Value.absent(),
            Value<String> time = const Value.absent(),
            Value<List<String>> tags = const Value.absent(),
            Value<double> quantity = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UrineMetricsCompanion.insert(
            id: id,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            syncState: syncState,
            localUpdatedAt: localUpdatedAt,
            date: date,
            type: type,
            pain: pain,
            time: time,
            tags: tags,
            quantity: quantity,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$UrineMetricsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $UrineMetricsTable,
    UrineMetric,
    $$UrineMetricsTableFilterComposer,
    $$UrineMetricsTableOrderingComposer,
    $$UrineMetricsTableAnnotationComposer,
    $$UrineMetricsTableCreateCompanionBuilder,
    $$UrineMetricsTableUpdateCompanionBuilder,
    (
      UrineMetric,
      BaseReferences<_$AppDatabase, $UrineMetricsTable, UrineMetric>
    ),
    UrineMetric,
    PrefetchHooks Function()>;
typedef $$BowelMetricsTableCreateCompanionBuilder = BowelMetricsCompanion
    Function({
  required String id,
  Value<DateTime?> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String> syncState,
  required DateTime localUpdatedAt,
  required String date,
  Value<int> type,
  Value<double> pain,
  Value<String> time,
  Value<List<String>> tags,
  Value<int> rowid,
});
typedef $$BowelMetricsTableUpdateCompanionBuilder = BowelMetricsCompanion
    Function({
  Value<String> id,
  Value<DateTime?> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String> syncState,
  Value<DateTime> localUpdatedAt,
  Value<String> date,
  Value<int> type,
  Value<double> pain,
  Value<String> time,
  Value<List<String>> tags,
  Value<int> rowid,
});

class $$BowelMetricsTableFilterComposer
    extends Composer<_$AppDatabase, $BowelMetricsTable> {
  $$BowelMetricsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncState => $composableBuilder(
      column: $table.syncState, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get localUpdatedAt => $composableBuilder(
      column: $table.localUpdatedAt,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get pain => $composableBuilder(
      column: $table.pain, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get time => $composableBuilder(
      column: $table.time, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<List<String>, List<String>, String> get tags =>
      $composableBuilder(
          column: $table.tags,
          builder: (column) => ColumnWithTypeConverterFilters(column));
}

class $$BowelMetricsTableOrderingComposer
    extends Composer<_$AppDatabase, $BowelMetricsTable> {
  $$BowelMetricsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncState => $composableBuilder(
      column: $table.syncState, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get localUpdatedAt => $composableBuilder(
      column: $table.localUpdatedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get pain => $composableBuilder(
      column: $table.pain, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get time => $composableBuilder(
      column: $table.time, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tags => $composableBuilder(
      column: $table.tags, builder: (column) => ColumnOrderings(column));
}

class $$BowelMetricsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BowelMetricsTable> {
  $$BowelMetricsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  GeneratedColumn<DateTime> get localUpdatedAt => $composableBuilder(
      column: $table.localUpdatedAt, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<double> get pain =>
      $composableBuilder(column: $table.pain, builder: (column) => column);

  GeneratedColumn<String> get time =>
      $composableBuilder(column: $table.time, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<String>, String> get tags =>
      $composableBuilder(column: $table.tags, builder: (column) => column);
}

class $$BowelMetricsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $BowelMetricsTable,
    BowelMetric,
    $$BowelMetricsTableFilterComposer,
    $$BowelMetricsTableOrderingComposer,
    $$BowelMetricsTableAnnotationComposer,
    $$BowelMetricsTableCreateCompanionBuilder,
    $$BowelMetricsTableUpdateCompanionBuilder,
    (
      BowelMetric,
      BaseReferences<_$AppDatabase, $BowelMetricsTable, BowelMetric>
    ),
    BowelMetric,
    PrefetchHooks Function()> {
  $$BowelMetricsTableTableManager(_$AppDatabase db, $BowelMetricsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BowelMetricsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BowelMetricsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BowelMetricsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String> syncState = const Value.absent(),
            Value<DateTime> localUpdatedAt = const Value.absent(),
            Value<String> date = const Value.absent(),
            Value<int> type = const Value.absent(),
            Value<double> pain = const Value.absent(),
            Value<String> time = const Value.absent(),
            Value<List<String>> tags = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              BowelMetricsCompanion(
            id: id,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            syncState: syncState,
            localUpdatedAt: localUpdatedAt,
            date: date,
            type: type,
            pain: pain,
            time: time,
            tags: tags,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String> syncState = const Value.absent(),
            required DateTime localUpdatedAt,
            required String date,
            Value<int> type = const Value.absent(),
            Value<double> pain = const Value.absent(),
            Value<String> time = const Value.absent(),
            Value<List<String>> tags = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              BowelMetricsCompanion.insert(
            id: id,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            syncState: syncState,
            localUpdatedAt: localUpdatedAt,
            date: date,
            type: type,
            pain: pain,
            time: time,
            tags: tags,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$BowelMetricsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $BowelMetricsTable,
    BowelMetric,
    $$BowelMetricsTableFilterComposer,
    $$BowelMetricsTableOrderingComposer,
    $$BowelMetricsTableAnnotationComposer,
    $$BowelMetricsTableCreateCompanionBuilder,
    $$BowelMetricsTableUpdateCompanionBuilder,
    (
      BowelMetric,
      BaseReferences<_$AppDatabase, $BowelMetricsTable, BowelMetric>
    ),
    BowelMetric,
    PrefetchHooks Function()>;
typedef $$MenstrualCyclesTableCreateCompanionBuilder = MenstrualCyclesCompanion
    Function({
  required String id,
  Value<DateTime?> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String> syncState,
  required DateTime localUpdatedAt,
  required String startDate,
  Value<int> cycleLength,
  Value<int> periodLength,
  Value<int> rowid,
});
typedef $$MenstrualCyclesTableUpdateCompanionBuilder = MenstrualCyclesCompanion
    Function({
  Value<String> id,
  Value<DateTime?> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String> syncState,
  Value<DateTime> localUpdatedAt,
  Value<String> startDate,
  Value<int> cycleLength,
  Value<int> periodLength,
  Value<int> rowid,
});

class $$MenstrualCyclesTableFilterComposer
    extends Composer<_$AppDatabase, $MenstrualCyclesTable> {
  $$MenstrualCyclesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncState => $composableBuilder(
      column: $table.syncState, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get localUpdatedAt => $composableBuilder(
      column: $table.localUpdatedAt,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get startDate => $composableBuilder(
      column: $table.startDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get cycleLength => $composableBuilder(
      column: $table.cycleLength, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get periodLength => $composableBuilder(
      column: $table.periodLength, builder: (column) => ColumnFilters(column));
}

class $$MenstrualCyclesTableOrderingComposer
    extends Composer<_$AppDatabase, $MenstrualCyclesTable> {
  $$MenstrualCyclesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncState => $composableBuilder(
      column: $table.syncState, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get localUpdatedAt => $composableBuilder(
      column: $table.localUpdatedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get startDate => $composableBuilder(
      column: $table.startDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get cycleLength => $composableBuilder(
      column: $table.cycleLength, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get periodLength => $composableBuilder(
      column: $table.periodLength,
      builder: (column) => ColumnOrderings(column));
}

class $$MenstrualCyclesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MenstrualCyclesTable> {
  $$MenstrualCyclesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  GeneratedColumn<DateTime> get localUpdatedAt => $composableBuilder(
      column: $table.localUpdatedAt, builder: (column) => column);

  GeneratedColumn<String> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<int> get cycleLength => $composableBuilder(
      column: $table.cycleLength, builder: (column) => column);

  GeneratedColumn<int> get periodLength => $composableBuilder(
      column: $table.periodLength, builder: (column) => column);
}

class $$MenstrualCyclesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MenstrualCyclesTable,
    MenstrualCycle,
    $$MenstrualCyclesTableFilterComposer,
    $$MenstrualCyclesTableOrderingComposer,
    $$MenstrualCyclesTableAnnotationComposer,
    $$MenstrualCyclesTableCreateCompanionBuilder,
    $$MenstrualCyclesTableUpdateCompanionBuilder,
    (
      MenstrualCycle,
      BaseReferences<_$AppDatabase, $MenstrualCyclesTable, MenstrualCycle>
    ),
    MenstrualCycle,
    PrefetchHooks Function()> {
  $$MenstrualCyclesTableTableManager(
      _$AppDatabase db, $MenstrualCyclesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MenstrualCyclesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MenstrualCyclesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MenstrualCyclesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String> syncState = const Value.absent(),
            Value<DateTime> localUpdatedAt = const Value.absent(),
            Value<String> startDate = const Value.absent(),
            Value<int> cycleLength = const Value.absent(),
            Value<int> periodLength = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MenstrualCyclesCompanion(
            id: id,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            syncState: syncState,
            localUpdatedAt: localUpdatedAt,
            startDate: startDate,
            cycleLength: cycleLength,
            periodLength: periodLength,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String> syncState = const Value.absent(),
            required DateTime localUpdatedAt,
            required String startDate,
            Value<int> cycleLength = const Value.absent(),
            Value<int> periodLength = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MenstrualCyclesCompanion.insert(
            id: id,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            syncState: syncState,
            localUpdatedAt: localUpdatedAt,
            startDate: startDate,
            cycleLength: cycleLength,
            periodLength: periodLength,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$MenstrualCyclesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $MenstrualCyclesTable,
    MenstrualCycle,
    $$MenstrualCyclesTableFilterComposer,
    $$MenstrualCyclesTableOrderingComposer,
    $$MenstrualCyclesTableAnnotationComposer,
    $$MenstrualCyclesTableCreateCompanionBuilder,
    $$MenstrualCyclesTableUpdateCompanionBuilder,
    (
      MenstrualCycle,
      BaseReferences<_$AppDatabase, $MenstrualCyclesTable, MenstrualCycle>
    ),
    MenstrualCycle,
    PrefetchHooks Function()>;
typedef $$CycleDaysTableCreateCompanionBuilder = CycleDaysCompanion Function({
  required String id,
  Value<DateTime?> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String> syncState,
  required DateTime localUpdatedAt,
  required String cycleId,
  required String date,
  Value<bool> isPeriod,
  Value<bool> isOvulation,
  Value<double> flow,
  Value<double> pain,
  Value<List<String>> tags,
  Value<String> cmq,
  Value<int> rowid,
});
typedef $$CycleDaysTableUpdateCompanionBuilder = CycleDaysCompanion Function({
  Value<String> id,
  Value<DateTime?> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String> syncState,
  Value<DateTime> localUpdatedAt,
  Value<String> cycleId,
  Value<String> date,
  Value<bool> isPeriod,
  Value<bool> isOvulation,
  Value<double> flow,
  Value<double> pain,
  Value<List<String>> tags,
  Value<String> cmq,
  Value<int> rowid,
});

class $$CycleDaysTableFilterComposer
    extends Composer<_$AppDatabase, $CycleDaysTable> {
  $$CycleDaysTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncState => $composableBuilder(
      column: $table.syncState, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get localUpdatedAt => $composableBuilder(
      column: $table.localUpdatedAt,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get cycleId => $composableBuilder(
      column: $table.cycleId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isPeriod => $composableBuilder(
      column: $table.isPeriod, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isOvulation => $composableBuilder(
      column: $table.isOvulation, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get flow => $composableBuilder(
      column: $table.flow, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get pain => $composableBuilder(
      column: $table.pain, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<List<String>, List<String>, String> get tags =>
      $composableBuilder(
          column: $table.tags,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<String> get cmq => $composableBuilder(
      column: $table.cmq, builder: (column) => ColumnFilters(column));
}

class $$CycleDaysTableOrderingComposer
    extends Composer<_$AppDatabase, $CycleDaysTable> {
  $$CycleDaysTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncState => $composableBuilder(
      column: $table.syncState, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get localUpdatedAt => $composableBuilder(
      column: $table.localUpdatedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get cycleId => $composableBuilder(
      column: $table.cycleId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isPeriod => $composableBuilder(
      column: $table.isPeriod, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isOvulation => $composableBuilder(
      column: $table.isOvulation, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get flow => $composableBuilder(
      column: $table.flow, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get pain => $composableBuilder(
      column: $table.pain, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tags => $composableBuilder(
      column: $table.tags, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get cmq => $composableBuilder(
      column: $table.cmq, builder: (column) => ColumnOrderings(column));
}

class $$CycleDaysTableAnnotationComposer
    extends Composer<_$AppDatabase, $CycleDaysTable> {
  $$CycleDaysTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  GeneratedColumn<DateTime> get localUpdatedAt => $composableBuilder(
      column: $table.localUpdatedAt, builder: (column) => column);

  GeneratedColumn<String> get cycleId =>
      $composableBuilder(column: $table.cycleId, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<bool> get isPeriod =>
      $composableBuilder(column: $table.isPeriod, builder: (column) => column);

  GeneratedColumn<bool> get isOvulation => $composableBuilder(
      column: $table.isOvulation, builder: (column) => column);

  GeneratedColumn<double> get flow =>
      $composableBuilder(column: $table.flow, builder: (column) => column);

  GeneratedColumn<double> get pain =>
      $composableBuilder(column: $table.pain, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<String>, String> get tags =>
      $composableBuilder(column: $table.tags, builder: (column) => column);

  GeneratedColumn<String> get cmq =>
      $composableBuilder(column: $table.cmq, builder: (column) => column);
}

class $$CycleDaysTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CycleDaysTable,
    CycleDay,
    $$CycleDaysTableFilterComposer,
    $$CycleDaysTableOrderingComposer,
    $$CycleDaysTableAnnotationComposer,
    $$CycleDaysTableCreateCompanionBuilder,
    $$CycleDaysTableUpdateCompanionBuilder,
    (CycleDay, BaseReferences<_$AppDatabase, $CycleDaysTable, CycleDay>),
    CycleDay,
    PrefetchHooks Function()> {
  $$CycleDaysTableTableManager(_$AppDatabase db, $CycleDaysTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CycleDaysTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CycleDaysTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CycleDaysTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String> syncState = const Value.absent(),
            Value<DateTime> localUpdatedAt = const Value.absent(),
            Value<String> cycleId = const Value.absent(),
            Value<String> date = const Value.absent(),
            Value<bool> isPeriod = const Value.absent(),
            Value<bool> isOvulation = const Value.absent(),
            Value<double> flow = const Value.absent(),
            Value<double> pain = const Value.absent(),
            Value<List<String>> tags = const Value.absent(),
            Value<String> cmq = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CycleDaysCompanion(
            id: id,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            syncState: syncState,
            localUpdatedAt: localUpdatedAt,
            cycleId: cycleId,
            date: date,
            isPeriod: isPeriod,
            isOvulation: isOvulation,
            flow: flow,
            pain: pain,
            tags: tags,
            cmq: cmq,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String> syncState = const Value.absent(),
            required DateTime localUpdatedAt,
            required String cycleId,
            required String date,
            Value<bool> isPeriod = const Value.absent(),
            Value<bool> isOvulation = const Value.absent(),
            Value<double> flow = const Value.absent(),
            Value<double> pain = const Value.absent(),
            Value<List<String>> tags = const Value.absent(),
            Value<String> cmq = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CycleDaysCompanion.insert(
            id: id,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            syncState: syncState,
            localUpdatedAt: localUpdatedAt,
            cycleId: cycleId,
            date: date,
            isPeriod: isPeriod,
            isOvulation: isOvulation,
            flow: flow,
            pain: pain,
            tags: tags,
            cmq: cmq,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CycleDaysTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CycleDaysTable,
    CycleDay,
    $$CycleDaysTableFilterComposer,
    $$CycleDaysTableOrderingComposer,
    $$CycleDaysTableAnnotationComposer,
    $$CycleDaysTableCreateCompanionBuilder,
    $$CycleDaysTableUpdateCompanionBuilder,
    (CycleDay, BaseReferences<_$AppDatabase, $CycleDaysTable, CycleDay>),
    CycleDay,
    PrefetchHooks Function()>;
typedef $$SmileyEntriesTableCreateCompanionBuilder = SmileyEntriesCompanion
    Function({
  required String id,
  Value<DateTime?> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String> syncState,
  required DateTime localUpdatedAt,
  required int smileyId,
  Value<List<String>> tags,
  required DateTime grantedAt,
  Value<int> rowid,
});
typedef $$SmileyEntriesTableUpdateCompanionBuilder = SmileyEntriesCompanion
    Function({
  Value<String> id,
  Value<DateTime?> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String> syncState,
  Value<DateTime> localUpdatedAt,
  Value<int> smileyId,
  Value<List<String>> tags,
  Value<DateTime> grantedAt,
  Value<int> rowid,
});

class $$SmileyEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $SmileyEntriesTable> {
  $$SmileyEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncState => $composableBuilder(
      column: $table.syncState, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get localUpdatedAt => $composableBuilder(
      column: $table.localUpdatedAt,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get smileyId => $composableBuilder(
      column: $table.smileyId, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<List<String>, List<String>, String> get tags =>
      $composableBuilder(
          column: $table.tags,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<DateTime> get grantedAt => $composableBuilder(
      column: $table.grantedAt, builder: (column) => ColumnFilters(column));
}

class $$SmileyEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $SmileyEntriesTable> {
  $$SmileyEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncState => $composableBuilder(
      column: $table.syncState, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get localUpdatedAt => $composableBuilder(
      column: $table.localUpdatedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get smileyId => $composableBuilder(
      column: $table.smileyId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tags => $composableBuilder(
      column: $table.tags, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get grantedAt => $composableBuilder(
      column: $table.grantedAt, builder: (column) => ColumnOrderings(column));
}

class $$SmileyEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SmileyEntriesTable> {
  $$SmileyEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  GeneratedColumn<DateTime> get localUpdatedAt => $composableBuilder(
      column: $table.localUpdatedAt, builder: (column) => column);

  GeneratedColumn<int> get smileyId =>
      $composableBuilder(column: $table.smileyId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<String>, String> get tags =>
      $composableBuilder(column: $table.tags, builder: (column) => column);

  GeneratedColumn<DateTime> get grantedAt =>
      $composableBuilder(column: $table.grantedAt, builder: (column) => column);
}

class $$SmileyEntriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SmileyEntriesTable,
    SmileyEntry,
    $$SmileyEntriesTableFilterComposer,
    $$SmileyEntriesTableOrderingComposer,
    $$SmileyEntriesTableAnnotationComposer,
    $$SmileyEntriesTableCreateCompanionBuilder,
    $$SmileyEntriesTableUpdateCompanionBuilder,
    (
      SmileyEntry,
      BaseReferences<_$AppDatabase, $SmileyEntriesTable, SmileyEntry>
    ),
    SmileyEntry,
    PrefetchHooks Function()> {
  $$SmileyEntriesTableTableManager(_$AppDatabase db, $SmileyEntriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SmileyEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SmileyEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SmileyEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String> syncState = const Value.absent(),
            Value<DateTime> localUpdatedAt = const Value.absent(),
            Value<int> smileyId = const Value.absent(),
            Value<List<String>> tags = const Value.absent(),
            Value<DateTime> grantedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SmileyEntriesCompanion(
            id: id,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            syncState: syncState,
            localUpdatedAt: localUpdatedAt,
            smileyId: smileyId,
            tags: tags,
            grantedAt: grantedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String> syncState = const Value.absent(),
            required DateTime localUpdatedAt,
            required int smileyId,
            Value<List<String>> tags = const Value.absent(),
            required DateTime grantedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              SmileyEntriesCompanion.insert(
            id: id,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            syncState: syncState,
            localUpdatedAt: localUpdatedAt,
            smileyId: smileyId,
            tags: tags,
            grantedAt: grantedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SmileyEntriesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SmileyEntriesTable,
    SmileyEntry,
    $$SmileyEntriesTableFilterComposer,
    $$SmileyEntriesTableOrderingComposer,
    $$SmileyEntriesTableAnnotationComposer,
    $$SmileyEntriesTableCreateCompanionBuilder,
    $$SmileyEntriesTableUpdateCompanionBuilder,
    (
      SmileyEntry,
      BaseReferences<_$AppDatabase, $SmileyEntriesTable, SmileyEntry>
    ),
    SmileyEntry,
    PrefetchHooks Function()>;
typedef $$PointRecordsTableCreateCompanionBuilder = PointRecordsCompanion
    Function({
  required String id,
  Value<DateTime?> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String> syncState,
  required DateTime localUpdatedAt,
  required int point,
  required String scope,
  required String date,
  Value<int> rowid,
});
typedef $$PointRecordsTableUpdateCompanionBuilder = PointRecordsCompanion
    Function({
  Value<String> id,
  Value<DateTime?> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String> syncState,
  Value<DateTime> localUpdatedAt,
  Value<int> point,
  Value<String> scope,
  Value<String> date,
  Value<int> rowid,
});

class $$PointRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $PointRecordsTable> {
  $$PointRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncState => $composableBuilder(
      column: $table.syncState, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get localUpdatedAt => $composableBuilder(
      column: $table.localUpdatedAt,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get point => $composableBuilder(
      column: $table.point, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get scope => $composableBuilder(
      column: $table.scope, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));
}

class $$PointRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $PointRecordsTable> {
  $$PointRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncState => $composableBuilder(
      column: $table.syncState, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get localUpdatedAt => $composableBuilder(
      column: $table.localUpdatedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get point => $composableBuilder(
      column: $table.point, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get scope => $composableBuilder(
      column: $table.scope, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));
}

class $$PointRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PointRecordsTable> {
  $$PointRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  GeneratedColumn<DateTime> get localUpdatedAt => $composableBuilder(
      column: $table.localUpdatedAt, builder: (column) => column);

  GeneratedColumn<int> get point =>
      $composableBuilder(column: $table.point, builder: (column) => column);

  GeneratedColumn<String> get scope =>
      $composableBuilder(column: $table.scope, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);
}

class $$PointRecordsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PointRecordsTable,
    PointRecord,
    $$PointRecordsTableFilterComposer,
    $$PointRecordsTableOrderingComposer,
    $$PointRecordsTableAnnotationComposer,
    $$PointRecordsTableCreateCompanionBuilder,
    $$PointRecordsTableUpdateCompanionBuilder,
    (
      PointRecord,
      BaseReferences<_$AppDatabase, $PointRecordsTable, PointRecord>
    ),
    PointRecord,
    PrefetchHooks Function()> {
  $$PointRecordsTableTableManager(_$AppDatabase db, $PointRecordsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PointRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PointRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PointRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String> syncState = const Value.absent(),
            Value<DateTime> localUpdatedAt = const Value.absent(),
            Value<int> point = const Value.absent(),
            Value<String> scope = const Value.absent(),
            Value<String> date = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PointRecordsCompanion(
            id: id,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            syncState: syncState,
            localUpdatedAt: localUpdatedAt,
            point: point,
            scope: scope,
            date: date,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String> syncState = const Value.absent(),
            required DateTime localUpdatedAt,
            required int point,
            required String scope,
            required String date,
            Value<int> rowid = const Value.absent(),
          }) =>
              PointRecordsCompanion.insert(
            id: id,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            syncState: syncState,
            localUpdatedAt: localUpdatedAt,
            point: point,
            scope: scope,
            date: date,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PointRecordsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PointRecordsTable,
    PointRecord,
    $$PointRecordsTableFilterComposer,
    $$PointRecordsTableOrderingComposer,
    $$PointRecordsTableAnnotationComposer,
    $$PointRecordsTableCreateCompanionBuilder,
    $$PointRecordsTableUpdateCompanionBuilder,
    (
      PointRecord,
      BaseReferences<_$AppDatabase, $PointRecordsTable, PointRecord>
    ),
    PointRecord,
    PrefetchHooks Function()>;
typedef $$UserTrackedMetricsTableCreateCompanionBuilder
    = UserTrackedMetricsCompanion Function({
  required String id,
  Value<DateTime?> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String> syncState,
  required DateTime localUpdatedAt,
  required int metricId,
  required DateTime grantedAt,
  Value<int> rowid,
});
typedef $$UserTrackedMetricsTableUpdateCompanionBuilder
    = UserTrackedMetricsCompanion Function({
  Value<String> id,
  Value<DateTime?> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String> syncState,
  Value<DateTime> localUpdatedAt,
  Value<int> metricId,
  Value<DateTime> grantedAt,
  Value<int> rowid,
});

class $$UserTrackedMetricsTableFilterComposer
    extends Composer<_$AppDatabase, $UserTrackedMetricsTable> {
  $$UserTrackedMetricsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncState => $composableBuilder(
      column: $table.syncState, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get localUpdatedAt => $composableBuilder(
      column: $table.localUpdatedAt,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get metricId => $composableBuilder(
      column: $table.metricId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get grantedAt => $composableBuilder(
      column: $table.grantedAt, builder: (column) => ColumnFilters(column));
}

class $$UserTrackedMetricsTableOrderingComposer
    extends Composer<_$AppDatabase, $UserTrackedMetricsTable> {
  $$UserTrackedMetricsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncState => $composableBuilder(
      column: $table.syncState, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get localUpdatedAt => $composableBuilder(
      column: $table.localUpdatedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get metricId => $composableBuilder(
      column: $table.metricId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get grantedAt => $composableBuilder(
      column: $table.grantedAt, builder: (column) => ColumnOrderings(column));
}

class $$UserTrackedMetricsTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserTrackedMetricsTable> {
  $$UserTrackedMetricsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  GeneratedColumn<DateTime> get localUpdatedAt => $composableBuilder(
      column: $table.localUpdatedAt, builder: (column) => column);

  GeneratedColumn<int> get metricId =>
      $composableBuilder(column: $table.metricId, builder: (column) => column);

  GeneratedColumn<DateTime> get grantedAt =>
      $composableBuilder(column: $table.grantedAt, builder: (column) => column);
}

class $$UserTrackedMetricsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $UserTrackedMetricsTable,
    UserTrackedMetric,
    $$UserTrackedMetricsTableFilterComposer,
    $$UserTrackedMetricsTableOrderingComposer,
    $$UserTrackedMetricsTableAnnotationComposer,
    $$UserTrackedMetricsTableCreateCompanionBuilder,
    $$UserTrackedMetricsTableUpdateCompanionBuilder,
    (
      UserTrackedMetric,
      BaseReferences<_$AppDatabase, $UserTrackedMetricsTable, UserTrackedMetric>
    ),
    UserTrackedMetric,
    PrefetchHooks Function()> {
  $$UserTrackedMetricsTableTableManager(
      _$AppDatabase db, $UserTrackedMetricsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserTrackedMetricsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserTrackedMetricsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserTrackedMetricsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String> syncState = const Value.absent(),
            Value<DateTime> localUpdatedAt = const Value.absent(),
            Value<int> metricId = const Value.absent(),
            Value<DateTime> grantedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UserTrackedMetricsCompanion(
            id: id,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            syncState: syncState,
            localUpdatedAt: localUpdatedAt,
            metricId: metricId,
            grantedAt: grantedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String> syncState = const Value.absent(),
            required DateTime localUpdatedAt,
            required int metricId,
            required DateTime grantedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              UserTrackedMetricsCompanion.insert(
            id: id,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            syncState: syncState,
            localUpdatedAt: localUpdatedAt,
            metricId: metricId,
            grantedAt: grantedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$UserTrackedMetricsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $UserTrackedMetricsTable,
    UserTrackedMetric,
    $$UserTrackedMetricsTableFilterComposer,
    $$UserTrackedMetricsTableOrderingComposer,
    $$UserTrackedMetricsTableAnnotationComposer,
    $$UserTrackedMetricsTableCreateCompanionBuilder,
    $$UserTrackedMetricsTableUpdateCompanionBuilder,
    (
      UserTrackedMetric,
      BaseReferences<_$AppDatabase, $UserTrackedMetricsTable, UserTrackedMetric>
    ),
    UserTrackedMetric,
    PrefetchHooks Function()>;
typedef $$UserConditionsTableCreateCompanionBuilder = UserConditionsCompanion
    Function({
  required String id,
  Value<DateTime?> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String> syncState,
  required DateTime localUpdatedAt,
  required int conditionId,
  Value<int> rowid,
});
typedef $$UserConditionsTableUpdateCompanionBuilder = UserConditionsCompanion
    Function({
  Value<String> id,
  Value<DateTime?> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String> syncState,
  Value<DateTime> localUpdatedAt,
  Value<int> conditionId,
  Value<int> rowid,
});

class $$UserConditionsTableFilterComposer
    extends Composer<_$AppDatabase, $UserConditionsTable> {
  $$UserConditionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncState => $composableBuilder(
      column: $table.syncState, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get localUpdatedAt => $composableBuilder(
      column: $table.localUpdatedAt,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get conditionId => $composableBuilder(
      column: $table.conditionId, builder: (column) => ColumnFilters(column));
}

class $$UserConditionsTableOrderingComposer
    extends Composer<_$AppDatabase, $UserConditionsTable> {
  $$UserConditionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncState => $composableBuilder(
      column: $table.syncState, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get localUpdatedAt => $composableBuilder(
      column: $table.localUpdatedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get conditionId => $composableBuilder(
      column: $table.conditionId, builder: (column) => ColumnOrderings(column));
}

class $$UserConditionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserConditionsTable> {
  $$UserConditionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  GeneratedColumn<DateTime> get localUpdatedAt => $composableBuilder(
      column: $table.localUpdatedAt, builder: (column) => column);

  GeneratedColumn<int> get conditionId => $composableBuilder(
      column: $table.conditionId, builder: (column) => column);
}

class $$UserConditionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $UserConditionsTable,
    UserCondition,
    $$UserConditionsTableFilterComposer,
    $$UserConditionsTableOrderingComposer,
    $$UserConditionsTableAnnotationComposer,
    $$UserConditionsTableCreateCompanionBuilder,
    $$UserConditionsTableUpdateCompanionBuilder,
    (
      UserCondition,
      BaseReferences<_$AppDatabase, $UserConditionsTable, UserCondition>
    ),
    UserCondition,
    PrefetchHooks Function()> {
  $$UserConditionsTableTableManager(
      _$AppDatabase db, $UserConditionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserConditionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserConditionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserConditionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String> syncState = const Value.absent(),
            Value<DateTime> localUpdatedAt = const Value.absent(),
            Value<int> conditionId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UserConditionsCompanion(
            id: id,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            syncState: syncState,
            localUpdatedAt: localUpdatedAt,
            conditionId: conditionId,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String> syncState = const Value.absent(),
            required DateTime localUpdatedAt,
            required int conditionId,
            Value<int> rowid = const Value.absent(),
          }) =>
              UserConditionsCompanion.insert(
            id: id,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            syncState: syncState,
            localUpdatedAt: localUpdatedAt,
            conditionId: conditionId,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$UserConditionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $UserConditionsTable,
    UserCondition,
    $$UserConditionsTableFilterComposer,
    $$UserConditionsTableOrderingComposer,
    $$UserConditionsTableAnnotationComposer,
    $$UserConditionsTableCreateCompanionBuilder,
    $$UserConditionsTableUpdateCompanionBuilder,
    (
      UserCondition,
      BaseReferences<_$AppDatabase, $UserConditionsTable, UserCondition>
    ),
    UserCondition,
    PrefetchHooks Function()>;
typedef $$UserSettingsTableCreateCompanionBuilder = UserSettingsCompanion
    Function({
  required String id,
  Value<DateTime?> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String> syncState,
  required DateTime localUpdatedAt,
  Value<int> periodLen,
  Value<int> cycleLen,
  Value<int> height,
  Value<int> weight,
  Value<int> rowid,
});
typedef $$UserSettingsTableUpdateCompanionBuilder = UserSettingsCompanion
    Function({
  Value<String> id,
  Value<DateTime?> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String> syncState,
  Value<DateTime> localUpdatedAt,
  Value<int> periodLen,
  Value<int> cycleLen,
  Value<int> height,
  Value<int> weight,
  Value<int> rowid,
});

class $$UserSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $UserSettingsTable> {
  $$UserSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncState => $composableBuilder(
      column: $table.syncState, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get localUpdatedAt => $composableBuilder(
      column: $table.localUpdatedAt,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get periodLen => $composableBuilder(
      column: $table.periodLen, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get cycleLen => $composableBuilder(
      column: $table.cycleLen, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get height => $composableBuilder(
      column: $table.height, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get weight => $composableBuilder(
      column: $table.weight, builder: (column) => ColumnFilters(column));
}

class $$UserSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $UserSettingsTable> {
  $$UserSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncState => $composableBuilder(
      column: $table.syncState, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get localUpdatedAt => $composableBuilder(
      column: $table.localUpdatedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get periodLen => $composableBuilder(
      column: $table.periodLen, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get cycleLen => $composableBuilder(
      column: $table.cycleLen, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get height => $composableBuilder(
      column: $table.height, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get weight => $composableBuilder(
      column: $table.weight, builder: (column) => ColumnOrderings(column));
}

class $$UserSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserSettingsTable> {
  $$UserSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  GeneratedColumn<DateTime> get localUpdatedAt => $composableBuilder(
      column: $table.localUpdatedAt, builder: (column) => column);

  GeneratedColumn<int> get periodLen =>
      $composableBuilder(column: $table.periodLen, builder: (column) => column);

  GeneratedColumn<int> get cycleLen =>
      $composableBuilder(column: $table.cycleLen, builder: (column) => column);

  GeneratedColumn<int> get height =>
      $composableBuilder(column: $table.height, builder: (column) => column);

  GeneratedColumn<int> get weight =>
      $composableBuilder(column: $table.weight, builder: (column) => column);
}

class $$UserSettingsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $UserSettingsTable,
    UserSetting,
    $$UserSettingsTableFilterComposer,
    $$UserSettingsTableOrderingComposer,
    $$UserSettingsTableAnnotationComposer,
    $$UserSettingsTableCreateCompanionBuilder,
    $$UserSettingsTableUpdateCompanionBuilder,
    (
      UserSetting,
      BaseReferences<_$AppDatabase, $UserSettingsTable, UserSetting>
    ),
    UserSetting,
    PrefetchHooks Function()> {
  $$UserSettingsTableTableManager(_$AppDatabase db, $UserSettingsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String> syncState = const Value.absent(),
            Value<DateTime> localUpdatedAt = const Value.absent(),
            Value<int> periodLen = const Value.absent(),
            Value<int> cycleLen = const Value.absent(),
            Value<int> height = const Value.absent(),
            Value<int> weight = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UserSettingsCompanion(
            id: id,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            syncState: syncState,
            localUpdatedAt: localUpdatedAt,
            periodLen: periodLen,
            cycleLen: cycleLen,
            height: height,
            weight: weight,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String> syncState = const Value.absent(),
            required DateTime localUpdatedAt,
            Value<int> periodLen = const Value.absent(),
            Value<int> cycleLen = const Value.absent(),
            Value<int> height = const Value.absent(),
            Value<int> weight = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UserSettingsCompanion.insert(
            id: id,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            syncState: syncState,
            localUpdatedAt: localUpdatedAt,
            periodLen: periodLen,
            cycleLen: cycleLen,
            height: height,
            weight: weight,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$UserSettingsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $UserSettingsTable,
    UserSetting,
    $$UserSettingsTableFilterComposer,
    $$UserSettingsTableOrderingComposer,
    $$UserSettingsTableAnnotationComposer,
    $$UserSettingsTableCreateCompanionBuilder,
    $$UserSettingsTableUpdateCompanionBuilder,
    (
      UserSetting,
      BaseReferences<_$AppDatabase, $UserSettingsTable, UserSetting>
    ),
    UserSetting,
    PrefetchHooks Function()>;
typedef $$SymptomsTableCreateCompanionBuilder = SymptomsCompanion Function({
  Value<int> id,
  required String name,
});
typedef $$SymptomsTableUpdateCompanionBuilder = SymptomsCompanion Function({
  Value<int> id,
  Value<String> name,
});

class $$SymptomsTableFilterComposer
    extends Composer<_$AppDatabase, $SymptomsTable> {
  $$SymptomsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));
}

class $$SymptomsTableOrderingComposer
    extends Composer<_$AppDatabase, $SymptomsTable> {
  $$SymptomsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));
}

class $$SymptomsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SymptomsTable> {
  $$SymptomsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);
}

class $$SymptomsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SymptomsTable,
    Symptom,
    $$SymptomsTableFilterComposer,
    $$SymptomsTableOrderingComposer,
    $$SymptomsTableAnnotationComposer,
    $$SymptomsTableCreateCompanionBuilder,
    $$SymptomsTableUpdateCompanionBuilder,
    (Symptom, BaseReferences<_$AppDatabase, $SymptomsTable, Symptom>),
    Symptom,
    PrefetchHooks Function()> {
  $$SymptomsTableTableManager(_$AppDatabase db, $SymptomsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SymptomsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SymptomsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SymptomsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
          }) =>
              SymptomsCompanion(
            id: id,
            name: name,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
          }) =>
              SymptomsCompanion.insert(
            id: id,
            name: name,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SymptomsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SymptomsTable,
    Symptom,
    $$SymptomsTableFilterComposer,
    $$SymptomsTableOrderingComposer,
    $$SymptomsTableAnnotationComposer,
    $$SymptomsTableCreateCompanionBuilder,
    $$SymptomsTableUpdateCompanionBuilder,
    (Symptom, BaseReferences<_$AppDatabase, $SymptomsTable, Symptom>),
    Symptom,
    PrefetchHooks Function()>;
typedef $$TrackedMetricsCatalogTableCreateCompanionBuilder
    = TrackedMetricsCatalogCompanion Function({
  Value<int> id,
  required String name,
});
typedef $$TrackedMetricsCatalogTableUpdateCompanionBuilder
    = TrackedMetricsCatalogCompanion Function({
  Value<int> id,
  Value<String> name,
});

class $$TrackedMetricsCatalogTableFilterComposer
    extends Composer<_$AppDatabase, $TrackedMetricsCatalogTable> {
  $$TrackedMetricsCatalogTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));
}

class $$TrackedMetricsCatalogTableOrderingComposer
    extends Composer<_$AppDatabase, $TrackedMetricsCatalogTable> {
  $$TrackedMetricsCatalogTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));
}

class $$TrackedMetricsCatalogTableAnnotationComposer
    extends Composer<_$AppDatabase, $TrackedMetricsCatalogTable> {
  $$TrackedMetricsCatalogTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);
}

class $$TrackedMetricsCatalogTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TrackedMetricsCatalogTable,
    TrackedMetricsCatalogData,
    $$TrackedMetricsCatalogTableFilterComposer,
    $$TrackedMetricsCatalogTableOrderingComposer,
    $$TrackedMetricsCatalogTableAnnotationComposer,
    $$TrackedMetricsCatalogTableCreateCompanionBuilder,
    $$TrackedMetricsCatalogTableUpdateCompanionBuilder,
    (
      TrackedMetricsCatalogData,
      BaseReferences<_$AppDatabase, $TrackedMetricsCatalogTable,
          TrackedMetricsCatalogData>
    ),
    TrackedMetricsCatalogData,
    PrefetchHooks Function()> {
  $$TrackedMetricsCatalogTableTableManager(
      _$AppDatabase db, $TrackedMetricsCatalogTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TrackedMetricsCatalogTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$TrackedMetricsCatalogTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TrackedMetricsCatalogTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
          }) =>
              TrackedMetricsCatalogCompanion(
            id: id,
            name: name,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
          }) =>
              TrackedMetricsCatalogCompanion.insert(
            id: id,
            name: name,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$TrackedMetricsCatalogTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $TrackedMetricsCatalogTable,
        TrackedMetricsCatalogData,
        $$TrackedMetricsCatalogTableFilterComposer,
        $$TrackedMetricsCatalogTableOrderingComposer,
        $$TrackedMetricsCatalogTableAnnotationComposer,
        $$TrackedMetricsCatalogTableCreateCompanionBuilder,
        $$TrackedMetricsCatalogTableUpdateCompanionBuilder,
        (
          TrackedMetricsCatalogData,
          BaseReferences<_$AppDatabase, $TrackedMetricsCatalogTable,
              TrackedMetricsCatalogData>
        ),
        TrackedMetricsCatalogData,
        PrefetchHooks Function()>;
typedef $$SmileyCatalogTableCreateCompanionBuilder = SmileyCatalogCompanion
    Function({
  Value<int> id,
  required String name,
});
typedef $$SmileyCatalogTableUpdateCompanionBuilder = SmileyCatalogCompanion
    Function({
  Value<int> id,
  Value<String> name,
});

class $$SmileyCatalogTableFilterComposer
    extends Composer<_$AppDatabase, $SmileyCatalogTable> {
  $$SmileyCatalogTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));
}

class $$SmileyCatalogTableOrderingComposer
    extends Composer<_$AppDatabase, $SmileyCatalogTable> {
  $$SmileyCatalogTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));
}

class $$SmileyCatalogTableAnnotationComposer
    extends Composer<_$AppDatabase, $SmileyCatalogTable> {
  $$SmileyCatalogTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);
}

class $$SmileyCatalogTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SmileyCatalogTable,
    SmileyCatalogData,
    $$SmileyCatalogTableFilterComposer,
    $$SmileyCatalogTableOrderingComposer,
    $$SmileyCatalogTableAnnotationComposer,
    $$SmileyCatalogTableCreateCompanionBuilder,
    $$SmileyCatalogTableUpdateCompanionBuilder,
    (
      SmileyCatalogData,
      BaseReferences<_$AppDatabase, $SmileyCatalogTable, SmileyCatalogData>
    ),
    SmileyCatalogData,
    PrefetchHooks Function()> {
  $$SmileyCatalogTableTableManager(_$AppDatabase db, $SmileyCatalogTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SmileyCatalogTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SmileyCatalogTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SmileyCatalogTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
          }) =>
              SmileyCatalogCompanion(
            id: id,
            name: name,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
          }) =>
              SmileyCatalogCompanion.insert(
            id: id,
            name: name,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SmileyCatalogTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SmileyCatalogTable,
    SmileyCatalogData,
    $$SmileyCatalogTableFilterComposer,
    $$SmileyCatalogTableOrderingComposer,
    $$SmileyCatalogTableAnnotationComposer,
    $$SmileyCatalogTableCreateCompanionBuilder,
    $$SmileyCatalogTableUpdateCompanionBuilder,
    (
      SmileyCatalogData,
      BaseReferences<_$AppDatabase, $SmileyCatalogTable, SmileyCatalogData>
    ),
    SmileyCatalogData,
    PrefetchHooks Function()>;
typedef $$ConditionsTableCreateCompanionBuilder = ConditionsCompanion Function({
  Value<int> id,
  required String name,
});
typedef $$ConditionsTableUpdateCompanionBuilder = ConditionsCompanion Function({
  Value<int> id,
  Value<String> name,
});

class $$ConditionsTableFilterComposer
    extends Composer<_$AppDatabase, $ConditionsTable> {
  $$ConditionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));
}

class $$ConditionsTableOrderingComposer
    extends Composer<_$AppDatabase, $ConditionsTable> {
  $$ConditionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));
}

class $$ConditionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ConditionsTable> {
  $$ConditionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);
}

class $$ConditionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ConditionsTable,
    Condition,
    $$ConditionsTableFilterComposer,
    $$ConditionsTableOrderingComposer,
    $$ConditionsTableAnnotationComposer,
    $$ConditionsTableCreateCompanionBuilder,
    $$ConditionsTableUpdateCompanionBuilder,
    (Condition, BaseReferences<_$AppDatabase, $ConditionsTable, Condition>),
    Condition,
    PrefetchHooks Function()> {
  $$ConditionsTableTableManager(_$AppDatabase db, $ConditionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ConditionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ConditionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ConditionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
          }) =>
              ConditionsCompanion(
            id: id,
            name: name,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
          }) =>
              ConditionsCompanion.insert(
            id: id,
            name: name,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ConditionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ConditionsTable,
    Condition,
    $$ConditionsTableFilterComposer,
    $$ConditionsTableOrderingComposer,
    $$ConditionsTableAnnotationComposer,
    $$ConditionsTableCreateCompanionBuilder,
    $$ConditionsTableUpdateCompanionBuilder,
    (Condition, BaseReferences<_$AppDatabase, $ConditionsTable, Condition>),
    Condition,
    PrefetchHooks Function()>;
typedef $$SyncMetaTableCreateCompanionBuilder = SyncMetaCompanion Function({
  required String key,
  Value<String?> value,
  Value<int> rowid,
});
typedef $$SyncMetaTableUpdateCompanionBuilder = SyncMetaCompanion Function({
  Value<String> key,
  Value<String?> value,
  Value<int> rowid,
});

class $$SyncMetaTableFilterComposer
    extends Composer<_$AppDatabase, $SyncMetaTable> {
  $$SyncMetaTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnFilters(column));
}

class $$SyncMetaTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncMetaTable> {
  $$SyncMetaTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnOrderings(column));
}

class $$SyncMetaTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncMetaTable> {
  $$SyncMetaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$SyncMetaTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SyncMetaTable,
    SyncMetaData,
    $$SyncMetaTableFilterComposer,
    $$SyncMetaTableOrderingComposer,
    $$SyncMetaTableAnnotationComposer,
    $$SyncMetaTableCreateCompanionBuilder,
    $$SyncMetaTableUpdateCompanionBuilder,
    (SyncMetaData, BaseReferences<_$AppDatabase, $SyncMetaTable, SyncMetaData>),
    SyncMetaData,
    PrefetchHooks Function()> {
  $$SyncMetaTableTableManager(_$AppDatabase db, $SyncMetaTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncMetaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncMetaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncMetaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String?> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SyncMetaCompanion(
            key: key,
            value: value,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String key,
            Value<String?> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SyncMetaCompanion.insert(
            key: key,
            value: value,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SyncMetaTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SyncMetaTable,
    SyncMetaData,
    $$SyncMetaTableFilterComposer,
    $$SyncMetaTableOrderingComposer,
    $$SyncMetaTableAnnotationComposer,
    $$SyncMetaTableCreateCompanionBuilder,
    $$SyncMetaTableUpdateCompanionBuilder,
    (SyncMetaData, BaseReferences<_$AppDatabase, $SyncMetaTable, SyncMetaData>),
    SyncMetaData,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SymptomMetricsTableTableManager get symptomMetrics =>
      $$SymptomMetricsTableTableManager(_db, _db.symptomMetrics);
  $$FoodMetricsTableTableManager get foodMetrics =>
      $$FoodMetricsTableTableManager(_db, _db.foodMetrics);
  $$SleepMetricsTableTableManager get sleepMetrics =>
      $$SleepMetricsTableTableManager(_db, _db.sleepMetrics);
  $$MedicationMetricsTableTableManager get medicationMetrics =>
      $$MedicationMetricsTableTableManager(_db, _db.medicationMetrics);
  $$ExerciseMetricsTableTableManager get exerciseMetrics =>
      $$ExerciseMetricsTableTableManager(_db, _db.exerciseMetrics);
  $$UrineMetricsTableTableManager get urineMetrics =>
      $$UrineMetricsTableTableManager(_db, _db.urineMetrics);
  $$BowelMetricsTableTableManager get bowelMetrics =>
      $$BowelMetricsTableTableManager(_db, _db.bowelMetrics);
  $$MenstrualCyclesTableTableManager get menstrualCycles =>
      $$MenstrualCyclesTableTableManager(_db, _db.menstrualCycles);
  $$CycleDaysTableTableManager get cycleDays =>
      $$CycleDaysTableTableManager(_db, _db.cycleDays);
  $$SmileyEntriesTableTableManager get smileyEntries =>
      $$SmileyEntriesTableTableManager(_db, _db.smileyEntries);
  $$PointRecordsTableTableManager get pointRecords =>
      $$PointRecordsTableTableManager(_db, _db.pointRecords);
  $$UserTrackedMetricsTableTableManager get userTrackedMetrics =>
      $$UserTrackedMetricsTableTableManager(_db, _db.userTrackedMetrics);
  $$UserConditionsTableTableManager get userConditions =>
      $$UserConditionsTableTableManager(_db, _db.userConditions);
  $$UserSettingsTableTableManager get userSettings =>
      $$UserSettingsTableTableManager(_db, _db.userSettings);
  $$SymptomsTableTableManager get symptoms =>
      $$SymptomsTableTableManager(_db, _db.symptoms);
  $$TrackedMetricsCatalogTableTableManager get trackedMetricsCatalog =>
      $$TrackedMetricsCatalogTableTableManager(_db, _db.trackedMetricsCatalog);
  $$SmileyCatalogTableTableManager get smileyCatalog =>
      $$SmileyCatalogTableTableManager(_db, _db.smileyCatalog);
  $$ConditionsTableTableManager get conditions =>
      $$ConditionsTableTableManager(_db, _db.conditions);
  $$SyncMetaTableTableManager get syncMeta =>
      $$SyncMetaTableTableManager(_db, _db.syncMeta);
}
