import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:itoju_mobile/data/models/smiley_model.dart';
import 'package:itoju_mobile/data/repositories/smiley_repository.dart';
import 'package:itoju_mobile/features/widgets/constants.dart';

export 'package:itoju_mobile/data/models/smiley_model.dart';

final latestSmileyProvider =
    StateNotifierProvider<LatestSmileyNotifier, LatestSmileyState>((ref) {
  return LatestSmileyNotifier(ref);
});

class LatestSmileyNotifier extends StateNotifier<LatestSmileyState> {
  LatestSmileyNotifier(this.ref) : super(LatestSmileyState.initial());
  Ref ref;

  Future<void> getLatestSmiley(DateTime dateTime) async {
    state = state.copyWith(status: Loader.loading);
    final date = DateFormat('yyyy-MM-dd').format(dateTime);
    try {
      final latestSmiley =
          await ref.read(smileyRepositoryProvider).getLatestForDate(date) ??
              LatestSmiley(id: 0, tags: []);
      state =
          state.copyWith(status: Loader.loaded, latestSmiley: latestSmiley);
    } catch (e) {
      state = state.copyWith(
          status: Loader.error, error: 'An unexpected error occurred');
    }
  }
}

class LatestSmileyState {
  LatestSmiley? latestSmiley;
  Loader? status;

  LatestSmileyState({this.latestSmiley, this.status = Loader.loading});
  factory LatestSmileyState.initial() {
    return LatestSmileyState();
  }

  LatestSmileyState copyWith(
      {LatestSmiley? latestSmiley, Loader? status, String? error}) {
    return LatestSmileyState(
        latestSmiley: latestSmiley ?? this.latestSmiley,
        status: status ?? this.status);
  }
}
