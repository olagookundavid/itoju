import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:itoju_mobile/core/helpers/response_helper/api_response.dart';
import 'package:itoju_mobile/data/repositories/smiley_repository.dart';
import 'package:itoju_mobile/features/widgets/constants.dart';

final addSmileyProvider =
    StateNotifierProvider<AddSmileyNotifier, AddSmileyState>((ref) {
  return AddSmileyNotifier(ref);
});

class AddSmileyNotifier extends StateNotifier<AddSmileyState> {
  AddSmileyNotifier(this.ref) : super(AddSmileyState.initial());

  Ref ref;

  Future<ApiResponse> addSmiley(int id, List tags, DateTime dateTime) async {
    state = state.copyWith(loadStatus: Loader.loading);

    try {
      final date = DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
      await ref
          .read(smileyRepositoryProvider)
          .addSmiley(id, List<String>.from(tags), date);
      state = state.copyWith(loadStatus: Loader.loaded);
      return ApiResponse(successMessage: 'Smiley added');
    } catch (e) {
      state = state.copyWith(loadStatus: Loader.error);
      return ApiResponse(errorMessage: 'An unexpected error occurred');
    }
  }
}

class AddSmileyState {
  AddSmileyState({
    this.loadStatus,
  });

  Loader? loadStatus;

  factory AddSmileyState.initial() {
    return AddSmileyState();
  }

  AddSmileyState copyWith({
    Loader? loadStatus,
  }) {
    return AddSmileyState(
      loadStatus: loadStatus ?? this.loadStatus,
    );
  }
}
