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
      getPeriodList();
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
