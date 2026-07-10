// ignore_for_file: public_member_api_docs, sort_constructors_first, file_names
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:itoju_mobile/data/models/smiley_model.dart';
import 'package:itoju_mobile/data/repositories/smiley_repository.dart';
import 'package:itoju_mobile/features/widgets/constants.dart';

export 'package:itoju_mobile/data/models/smiley_model.dart';

final getSmileyProvider =
    StateNotifierProvider<GetSmileyNotifier, GetSmileyState>((ref) {
  return GetSmileyNotifier(ref);
});

class GetSmileyNotifier extends StateNotifier<GetSmileyState> {
  GetSmileyNotifier(this.ref) : super(GetSmileyState.initial());
  Ref ref;

  Future<void> getGetSmiley() async {
    state = state.copyWith(status: Loader.loading);
    try {
      final counts =
          await ref.read(smileyRepositoryProvider).countsForLastDays(30);
      state = state.copyWith(
          status: Loader.loaded,
          smileyModel: counts.smileys,
          totalCount: counts.totalCount);
    } catch (e) {
      state = state.copyWith(
          status: Loader.error, error: 'An unexpected error occurred');
    }
  }
}

class GetSmileyState {
  List<SmileyModel>? smileyModel;
  Loader? status;
  String? error;
  int? totalCount;
  GetSmileyState(
      {this.smileyModel,
      this.status = Loader.loading,
      this.error,
      this.totalCount = 0});
  factory GetSmileyState.initial() {
    return GetSmileyState();
  }

  GetSmileyState copyWith(
      {List<SmileyModel>? smileyModel,
      Loader? status,
      String? error,
      int? totalCount}) {
    return GetSmileyState(
        smileyModel: smileyModel ?? this.smileyModel,
        status: status ?? this.status,
        error: error ?? this.error,
        totalCount: totalCount ?? this.totalCount);
  }
}
