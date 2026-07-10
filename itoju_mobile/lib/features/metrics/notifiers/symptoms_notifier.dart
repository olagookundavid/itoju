import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:itoju_mobile/core/helpers/response_helper/api_response.dart';
import 'package:itoju_mobile/data/models/symptoms_model.dart';
import 'package:itoju_mobile/data/repositories/symptoms_repository.dart';
import 'package:itoju_mobile/features/dashboard/notifiers/get_most_tracked_syms_notifier.dart';
import 'package:itoju_mobile/features/widgets/constants.dart';

export 'package:itoju_mobile/data/models/symptoms_model.dart';

final symsProvider =
    StateNotifierProvider<SymptomsNotifier, SymptomsState>((ref) {
  return SymptomsNotifier(ref, ref.read(symptomsRepositoryProvider));
});

/// Offline-first symptoms notifier. Same public surface; the catalog now comes
/// from the seeded local table and metrics from the local Drift store.
class SymptomsNotifier extends StateNotifier<SymptomsState> {
  SymptomsNotifier(this.ref, this.repo) : super(SymptomsState.initial());
  Ref ref;
  SymptomsRepository repo;

  Future<void> getSymptoms() async {
    state = state.copyWith(getStatus: Loader.loading);
    try {
      final symsModels = await repo.getCatalog();
      state = state.copyWith(
          getStatus: Loader.loaded,
          symsModels: symsModels,
          filteredSymsModel: symsModels);
    } catch (e) {
      state = state.copyWith(
          getStatus: Loader.error, error: 'An unexpected error occurred');
    }
  }

  Future<void> getFilteredSymptoms({String? searchTerm}) async {
    if (searchTerm == null || searchTerm == '') {
      return;
    }
    List<SymptomsModel> filteredSyms = state.symsModels!
        .where((SymptomsModel syms) =>
            syms.name!.toLowerCase().contains(searchTerm.toLowerCase()))
        .toList();
    state = state.copyWith(filteredSymsModel: filteredSyms);
  }

  Future<ApiResponse> createSymsMetric(int symptomId, String date) async {
    state = state.copyWith(postStatus: Loader.loading);
    try {
      final added = await repo.create(symptomId, date);
      state = state.copyWith(postStatus: Loader.loaded);
      if (!added) {
        return ApiResponse(errorMessage: 'Symptom already added for this day');
      }
      getSymMetric(date);
      ref.read(getTrackedSymsProvider.notifier).getGetTrackedSyms();
      return ApiResponse(successMessage: 'Successfully added Symptom');
    } catch (e) {
      state = state.copyWith(
          postStatus: Loader.error, error: 'An unexpected error occurred');
      return ApiResponse(errorMessage: 'An error occurred');
    }
  }

  Future<void> getSymMetric(String date) async {
    state = state.copyWith(getSymsStatus: Loader.loading);
    try {
      final symsMetricModels = await repo.getForDate(date);
      state = state.copyWith(
          getSymsStatus: Loader.loaded, symsMetricModels: symsMetricModels);
    } catch (e) {
      state = state.copyWith(
          getSymsStatus: Loader.error, error: 'An unexpected error occurred');
    }
  }

  Future<ApiResponse> deleteSymsMetric(String id) async {
    state = state.copyWith(delStatus: Loader.loading);
    try {
      await repo.delete(id);
      state = state.copyWith(delStatus: Loader.loaded);
      return ApiResponse(successMessage: 'Symptom Metric successfully deleted');
    } catch (e) {
      state = state.copyWith(
          delStatus: Loader.error, error: 'An unexpected error occurred');
      return ApiResponse(errorMessage: 'An error occurred');
    }
  }

  Future<ApiResponse> updateSymsMetric(String id, double morningSeverity,
      double afternoonSeverity, double nightSeverity, String date) async {
    state = state.copyWith(postSymsStatus: Loader.loading);
    try {
      await repo.update(
          id, morningSeverity, afternoonSeverity, nightSeverity, date);
      state = state.copyWith(postSymsStatus: Loader.loaded);
      return ApiResponse(successMessage: 'Successfully updated Symptom Metric');
    } catch (e) {
      state = state.copyWith(
          postSymsStatus: Loader.error, error: 'An unexpected error occurred');
      return ApiResponse(errorMessage: 'An error occurred');
    }
  }
}

class SymptomsState {
  List<SymptomsModel>? symsModels;
  List<SymptomsModel>? filteredSymsModel;
  List<SymptomsMetricModel>? symsMetricModels;
  Loader? getStatus;
  Loader? getSymsStatus;
  Loader? postSymsStatus;
  Loader? postStatus;
  Loader? delStatus;

  SymptomsState({
    this.symsModels = const [],
    this.symsMetricModels = const [],
    this.filteredSymsModel = const [],
    this.getStatus = Loader.loading,
    this.getSymsStatus = Loader.loaded,
    this.postSymsStatus = Loader.loaded,
    this.postStatus = Loader.loaded,
    this.delStatus = Loader.loaded,
  });
  factory SymptomsState.initial() {
    return SymptomsState();
  }

  SymptomsState copyWith(
      {List<SymptomsModel>? symsModels,
      List<SymptomsModel>? filteredSymsModel,
      List<SymptomsMetricModel>? symsMetricModels,
      Loader? getStatus,
      Loader? getSymsStatus,
      Loader? postSymsStatus,
      String? error,
      Loader? postStatus,
      Loader? delStatus}) {
    return SymptomsState(
        symsModels: symsModels ?? this.symsModels,
        symsMetricModels: symsMetricModels ?? this.symsMetricModels,
        filteredSymsModel: filteredSymsModel ?? this.filteredSymsModel,
        getStatus: getStatus ?? this.getStatus,
        getSymsStatus: getSymsStatus ?? this.getSymsStatus,
        postSymsStatus: postSymsStatus ?? this.postSymsStatus,
        postStatus: postStatus ?? this.postStatus,
        delStatus: delStatus ?? this.delStatus);
  }
}
