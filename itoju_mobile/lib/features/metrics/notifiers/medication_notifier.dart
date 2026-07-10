// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:itoju_mobile/core/helpers/response_helper/api_response.dart';
import 'package:itoju_mobile/data/models/medication_model.dart';
import 'package:itoju_mobile/data/repositories/medication_repository.dart';
import 'package:itoju_mobile/features/widgets/constants.dart';

// Re-exported so existing `import '.../medication_notifier.dart'` users keep
// seeing MedicationModel after it moved to the shared data layer.
export 'package:itoju_mobile/data/models/medication_model.dart';

final medicationProvider =
    StateNotifierProvider<MedicationNotifier, MedicationState>((ref) {
  return MedicationNotifier(ref, ref.read(medicationRepositoryProvider));
});

/// Offline-first medication notifier. Same public surface as before, but
/// reads/writes the local Drift store through MedicationRepository instead of
/// calling the API.
class MedicationNotifier extends StateNotifier<MedicationState> {
  MedicationNotifier(this.ref, this.repo) : super(MedicationState.initial());
  Ref ref;
  MedicationRepository repo;

  Future<void> getMedicationList(String date) async {
    state = state.copyWith(status: Loader.loading);
    try {
      final models = await repo.getForDate(date);
      state = state.copyWith(status: Loader.loaded, medicationModels: models);
    } catch (e) {
      state = state.copyWith(
          status: Loader.error, error: 'An unexpected error occurred');
    }
  }

  Future<ApiResponse> createMedicationMetric(
      String date, MedicationModel model) async {
    state = state.copyWith(postStatus: Loader.loading);
    try {
      await repo.create(date, model);
      state = state.copyWith(postStatus: Loader.loaded);
      return ApiResponse(successMessage: 'Successfully added Medication');
    } catch (e) {
      state = state.copyWith(
          postStatus: Loader.error, error: 'An unexpected error occurred');
      return ApiResponse(errorMessage: 'An error occurred');
    }
  }

  Future<ApiResponse> updateMedicationMetric(MedicationModel model) async {
    state = state.copyWith(updateStatus: Loader.loading);
    try {
      await repo.update(model);
      state = state.copyWith(updateStatus: Loader.loaded);
      return ApiResponse(successMessage: 'Successfully updated Medication');
    } catch (e) {
      state = state.copyWith(
          updateStatus: Loader.error, error: 'An unexpected error occurred');
      return ApiResponse(errorMessage: 'An error occurred');
    }
  }

  Future<ApiResponse> deleteSymsMetric(String id) async {
    state = state.copyWith(delStatus: Loader.loading);
    try {
      await repo.delete(id);
      state = state.copyWith(delStatus: Loader.loaded);
      return ApiResponse(successMessage: 'Medication successfully deleted');
    } catch (e) {
      state = state.copyWith(
          delStatus: Loader.error, error: 'An unexpected error occurred');
      return ApiResponse(errorMessage: 'An error occurred');
    }
  }
}

class MedicationState {
  List<MedicationModel>? medicationModels;
  Loader? status;
  Loader? delStatus;
  Loader? updateStatus;
  Loader? postStatus;

  MedicationState({
    this.medicationModels,
    this.status = Loader.loading,
    this.delStatus = Loader.loaded,
    this.updateStatus = Loader.loaded,
    this.postStatus = Loader.loaded,
  });
  factory MedicationState.initial() {
    return MedicationState();
  }

  MedicationState copyWith(
      {List<MedicationModel>? medicationModels,
      Loader? status,
      Loader? delStatus,
      Loader? updateStatus,
      Loader? postStatus,
      String? error}) {
    return MedicationState(
        medicationModels: medicationModels ?? this.medicationModels,
        status: status ?? this.status,
        delStatus: delStatus ?? this.delStatus,
        updateStatus: updateStatus ?? this.updateStatus,
        postStatus: postStatus ?? this.postStatus);
  }
}
