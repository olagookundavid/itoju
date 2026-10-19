import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:itoju_mobile/core/helpers/response_helper/api_response.dart';
import 'package:itoju_mobile/data/models/period_model.dart';
import 'package:itoju_mobile/data/repositories/menses_repository.dart';
import 'package:itoju_mobile/features/widgets/constants.dart';

export 'package:itoju_mobile/data/models/period_model.dart';

final periodProvider =
    StateNotifierProvider<PeriodNotifier, PeriodState>((ref) {
  return PeriodNotifier(ref, ref.read(mensesRepositoryProvider));
});

/// Offline-first menses notifier. Same public surface; reads/writes local cycles
/// and their generated day rows via MensesRepository.
class PeriodNotifier extends StateNotifier<PeriodState> {
  PeriodNotifier(this.ref, this.repo) : super(PeriodState.initial());
  Ref ref;
  MensesRepository repo;

  Future<void> getPeriodList() async {
    state = state.copyWith(status: Loader.loading);
    try {
      final periodModels = await repo.getRecentDays();
      final Map<String, List<PeriodModel>> periodEvent = {};
      for (var period in periodModels) {
        periodEvent[period.date] = [period];
      }
      state = state.copyWith(
          status: Loader.loaded,
          periodModels: periodModels,
          period: periodEvent);
    } catch (e) {
      state = state.copyWith(
          status: Loader.error, error: 'An unexpected error occurred');
    }
  }

  /// Loads the cycle days for a visible calendar range and MERGES them into the
  /// event map, so paging through months accumulates data instead of replacing
  /// it. Re-querying a range first drops its existing keys, so edits and deletes
  /// within it are reflected (a deleted day disappears; an edited day updates).
  /// Only the first-ever load flips to the full-screen loader — later loads keep
  /// the calendar on screen so paging doesn't flicker.
  Future<void> loadRange(String fromIso, String toIso) async {
    final firstLoad = state.period == null;
    if (firstLoad) state = state.copyWith(status: Loader.loading);
    try {
      final days = await repo.getDaysInRange(fromIso, toIso);
      final merged = Map<String, List<PeriodModel>>.from(state.period ?? {});
      merged.removeWhere((date, _) =>
          date.compareTo(fromIso) >= 0 && date.compareTo(toIso) <= 0);
      for (final d in days) {
        merged[d.date] = [d];
      }
      state = state.copyWith(status: Loader.loaded, period: merged);
    } catch (e) {
      if (firstLoad) {
        state = state.copyWith(
            status: Loader.error, error: 'An unexpected error occurred');
      }
      // On later loads keep showing what's already on screen.
    }
  }

  Future<ApiResponse> createPeriodMetric(
      String date, int cycleLen, int periodLen) async {
    state = state.copyWith(postStatus: Loader.loading);
    try {
      final created = await repo.createCycle(date, cycleLen, periodLen);
      state = state.copyWith(postStatus: Loader.loaded);
      if (!created) {
        return ApiResponse(errorMessage: 'A cycle already exists for that date');
      }
      return ApiResponse(successMessage: 'Successfully added cycle');
    } catch (e) {
      state = state.copyWith(
          postStatus: Loader.error, error: 'An unexpected error occurred');
      return ApiResponse(errorMessage: 'An error occurred');
    }
  }

  Future<ApiResponse> updatePeriodMetric(PeriodModel model) async {
    state = state.copyWith(updateStatus: Loader.loading);
    try {
      await repo.updateDay(model);
      state = state.copyWith(updateStatus: Loader.loaded);
      return ApiResponse(successMessage: 'Successfully updated cycle day');
    } catch (e) {
      state = state.copyWith(
          updateStatus: Loader.error, error: 'An unexpected error occurred');
      return ApiResponse(errorMessage: 'An error occurred');
    }
  }

  Future<ApiResponse> deletePeriodMetric(String id) async {
    state = state.copyWith(delStatus: Loader.loading);
    try {
      await repo.deleteCycle(id);
      state = state.copyWith(delStatus: Loader.loaded);
      return ApiResponse(successMessage: 'Successfully deleted cycle');
    } catch (e) {
      state = state.copyWith(
          delStatus: Loader.error, error: 'An unexpected error occurred');
      return ApiResponse(errorMessage: 'An error occurred');
    }
  }
}

class PeriodState {
  List<PeriodModel>? periodModels;
  Map<String, List<PeriodModel>>? period;
  Loader? status;
  Loader? delStatus;
  Loader? updateStatus;
  Loader? postStatus;

  PeriodState(
      {this.periodModels,
      this.period,
      this.status = Loader.loading,
      this.delStatus = Loader.loaded,
      this.updateStatus = Loader.loaded,
      this.postStatus = Loader.loaded});

  factory PeriodState.initial() {
    return PeriodState();
  }

  PeriodState copyWith(
      {List<PeriodModel>? periodModels,
      Map<String, List<PeriodModel>>? period,
      Loader? status,
      Loader? delStatus,
      Loader? updateStatus,
      Loader? postStatus,
      String? error}) {
    return PeriodState(
        periodModels: periodModels ?? this.periodModels,
        period: period ?? this.period,
        status: status ?? this.status,
        delStatus: delStatus ?? this.delStatus,
        updateStatus: updateStatus ?? this.updateStatus,
        postStatus: postStatus ?? this.postStatus);
  }
}
