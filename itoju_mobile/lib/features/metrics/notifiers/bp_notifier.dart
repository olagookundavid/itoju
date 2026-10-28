import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:itoju_mobile/core/helpers/response_helper/api_response.dart';
import 'package:itoju_mobile/data/models/bp_model.dart';
import 'package:itoju_mobile/data/repositories/bp_repository.dart';
import 'package:itoju_mobile/features/widgets/constants.dart';

export 'package:itoju_mobile/data/models/bp_model.dart';

final bpProvider = StateNotifierProvider<BpNotifier, BpState>((ref) {
  return BpNotifier(ref, ref.read(bpRepositoryProvider));
});

/// Daily-average readings for the last [days] days (including today), feeding
/// the trend chart. Invalidated by [BpNotifier] after every write.
final bpTrendProvider =
    FutureProvider.autoDispose.family<List<BpDayPoint>, int>((ref, days) {
  final today = DateTime.now();
  final from = DateTime(today.year, today.month, today.day)
      .subtract(Duration(days: days - 1));
  return ref.read(bpRepositoryProvider).dailyAverages(from, today);
});

/// The most recent reading of any day, for the Home block.
final bpLatestProvider = FutureProvider.autoDispose<BpModel?>(
    (ref) => ref.read(bpRepositoryProvider).latest());

class BpNotifier extends StateNotifier<BpState> {
  BpNotifier(this.ref, this.repo) : super(BpState.initial());
  final Ref ref;
  final BpRepository repo;

  Future<void> getForDate(String date) async {
    state = state.copyWith(status: Loader.loading);
    try {
      final models = await repo.getForDate(date);
      if (!mounted) return;
      state = state.copyWith(status: Loader.loaded, readings: models);
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(status: Loader.error);
    }
  }

  void _changed() {
    ref.invalidate(bpTrendProvider);
    ref.invalidate(bpLatestProvider);
  }

  Future<ApiResponse> create(String date, BpModel model) =>
      _write(() => repo.create(date, model), 'Reading saved');

  Future<ApiResponse> update(BpModel model) =>
      _write(() => repo.update(model), 'Reading updated');

  Future<ApiResponse> delete(String id) =>
      _write(() => repo.delete(id), 'Reading deleted');

  Future<ApiResponse> _write(Future<void> Function() op, String ok) async {
    state = state.copyWith(busy: true);
    try {
      await op();
      _changed();
      return ApiResponse(successMessage: ok);
    } on ArgumentError catch (e) {
      // A validation message meant for the person, not an error to hide.
      return ApiResponse(responseMessage: e.message.toString());
    } catch (e) {
      return ApiResponse(errorMessage: 'An error occurred');
    } finally {
      if (mounted) state = state.copyWith(busy: false);
    }
  }
}

class BpState {
  final List<BpModel> readings;
  final Loader status;
  final bool busy;

  const BpState({
    this.readings = const [],
    this.status = Loader.loading,
    this.busy = false,
  });
  factory BpState.initial() => const BpState();

  BpState copyWith({List<BpModel>? readings, Loader? status, bool? busy}) =>
      BpState(
        readings: readings ?? this.readings,
        status: status ?? this.status,
        busy: busy ?? this.busy,
      );
}
