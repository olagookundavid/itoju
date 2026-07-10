import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:itoju_mobile/data/repositories/dashboard_repository.dart';
import 'package:itoju_mobile/features/widgets/constants.dart';

// SymsModel now lives with the repository; re-export so existing consumers
// (dashboard) that import this notifier keep compiling unchanged.
export 'package:itoju_mobile/data/repositories/dashboard_repository.dart'
    show SymsModel;

final getTrackedSymsProvider = StateNotifierProvider.autoDispose<
    GetTrackedSymsNotifier, GetTrackedSymsState>((ref) {
  return GetTrackedSymsNotifier(ref, ref.read(dashboardRepositoryProvider));
});

class GetTrackedSymsNotifier extends StateNotifier<GetTrackedSymsState> {
  GetTrackedSymsNotifier(this.ref, this.repository)
      : super(GetTrackedSymsState.initial());
  Ref ref;
  DashboardRepository repository;

  Future<void> getGetTrackedSyms() async {
    state = state.copyWith(status: Loader.loading);
    try {
      final symsModels = await repository.getTopSyms();
      state = state.copyWith(status: Loader.loaded, symsModel: symsModels);
    } catch (e) {
      state = state.copyWith(
          status: Loader.error, error: 'An unexpected error occurred');
    }
  }
}

class GetTrackedSymsState {
  List<SymsModel>? symsModel;
  Loader? status;

  GetTrackedSymsState({this.symsModel, this.status = Loader.loading});
  factory GetTrackedSymsState.initial() {
    return GetTrackedSymsState();
  }

  GetTrackedSymsState copyWith(
      {List<SymsModel>? symsModel, Loader? status, String? error}) {
    return GetTrackedSymsState(
        symsModel: symsModel ?? this.symsModel, status: status ?? this.status);
  }
}
