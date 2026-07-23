import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itoju_mobile/data/account_service.dart';
import 'package:itoju_mobile/data/db/app_database.dart';
import 'package:itoju_mobile/data/models/food_model.dart';
import 'package:itoju_mobile/data/repositories/food_repository.dart';

class _FakeAccountService extends AccountService {
  @override
  Future<String> deterministicNamespaceId() async => 'test-account';
}

void main() {
  late AppDatabase db;
  late FoodRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = FoodRepository(db, _FakeAccountService());
  });
  tearDown(() => db.close());

  test('upsert merges per-section saves instead of overwriting the whole day',
      () async {
    const date = '2026-05-01';

    // The Meal/Snack/Water widgets each save only the fields they own —
    // saving breakfast must not touch lunch/dinner/snack/water.
    await repo.upsert(
        date,
        FoodMetricModel(
          id: null,
          breakfastMeal: 'Oats',
          breakfastExtra: 'Honey',
          breakfastFruit: 'Banana',
          breakfastTags: const ['Sugar'],
        ));

    // Saving water alone must not wipe breakfast back to blank.
    await repo.upsert(date, FoodMetricModel(id: null, glassNo: 3));

    var row = await repo.getForDate(date);
    expect(row, isNotNull);
    expect(row!.breakfastMeal, 'Oats');
    expect(row.breakfastExtra, 'Honey');
    expect(row.breakfastFruit, 'Banana');
    expect(row.breakfastTags, ['Sugar']);
    expect(row.glassNo, 3);

    // Saving snack alone must preserve breakfast + water too.
    await repo.upsert(
        date,
        FoodMetricModel(
          id: null,
          snackName: 'Chips',
          snackTags: const ['Salty'],
        ));

    row = await repo.getForDate(date);
    expect(row!.breakfastMeal, 'Oats');
    expect(row.glassNo, 3);
    expect(row.snackName, 'Chips');
    expect(row.snackTags, ['Salty']);

    // An explicit (non-null) empty value IS a real edit and overwrites —
    // only an omitted (null) field is treated as "untouched".
    await repo.upsert(date, FoodMetricModel(id: null, breakfastMeal: ''));
    row = await repo.getForDate(date);
    expect(row!.breakfastMeal, '');
    expect(row.glassNo, 3);
    expect(row.snackName, 'Chips');
  });
}
