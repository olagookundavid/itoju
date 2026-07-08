import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:itoju_mobile/features/widgets/constants.dart';
import 'package:itoju_mobile/services/dio_provider.dart';

final homeDateProvider =
    StateNotifierProvider<HomeDateNotifier, HomeDateState>((ref) {
  return HomeDateNotifier(ref, ref.read(dioProvider));
});

class HomeDateNotifier extends StateNotifier<HomeDateState> {
  HomeDateNotifier(this.ref, this.dio) : super(HomeDateState.initial()) {
    actionGetPreviousWeek();
    // actionGetThisWeek();
    actionGetNextWeek();
  }
  Ref ref;
  Dio dio;
  DateTime today = DateTime.now();

  List<DateTime> _getWeekRangeFromDateTime(DateTime date) {
    // Find the first day of the current week
    DateTime firstDayOfWeek = date.subtract(Duration(days: date.weekday));

    // Find the last day of the current week
    DateTime lastDayOfWeek =
        date.add(Duration(days: DateTime.daysPerWeek - date.weekday - 1));

    // Create a list to store the date range
    List<DateTime> weekRange = [];

    // Populate the list with dates from the first day to the last day of the week
    for (DateTime date = firstDayOfWeek;
        date.isBefore(lastDayOfWeek.add(const Duration(days: 1)));
        date = date.add(const Duration(days: 1))) {
      weekRange.add(date);
    }
    return weekRange;
  }

  void actionGetThisWeek() {
    final weekDateRange = _getWeekRangeFromDateTime(today);
    List<DateTime> stateDateRange = [
      ...state.weekDateRange ?? [],
      ...weekDateRange
    ];
    stateDateRange.sort();
    state =
        state.copyWith(status: Loader.loaded, weekDateRange: stateDateRange);
  }

  void actionGetNextWeek() {
    final dayInNextWeek =
        today.add(Duration(days: (DateTime.daysPerWeek + 1) - today.weekday));
    today = dayInNextWeek;
    actionGetThisWeek();
  }

  void actionGetPreviousWeek() {
    final dayInPrevWeek = today.subtract(Duration(days: today.weekday));
    today = dayInPrevWeek;
    actionGetThisWeek();
  }

  void captureSelctedDate(DateTime? dateTime) {
    state = state.copyWith(status: Loader.loaded, selectedDate: dateTime);
  }
}

class HomeDateState {
  Loader? status;
  List<DateTime>? weekDateRange;
  DateTime? selectedDate;

  HomeDateState(
      {this.status = Loader.loading, this.weekDateRange, this.selectedDate});
  factory HomeDateState.initial() {
    return HomeDateState(weekDateRange: [], selectedDate: DateTime.now());
  }

  HomeDateState copyWith({
    Loader? status,
    List<DateTime>? weekDateRange,
    DateTime? selectedDate,
  }) {
    return HomeDateState(
      status: status ?? this.status,
      weekDateRange: weekDateRange ?? this.weekDateRange,
      selectedDate: selectedDate ?? this.selectedDate,
    );
  }
}
