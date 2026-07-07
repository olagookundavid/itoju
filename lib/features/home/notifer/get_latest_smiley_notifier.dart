import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:itoju_mobile/features/widgets/constants.dart';
import 'package:itoju_mobile/services/dio_provider.dart';

final latestSmileyProvider =
    StateNotifierProvider<LatestSmileyNotifier, LatestSmileyState>((ref) {
  return LatestSmileyNotifier(ref, ref.read(dioProvider));
});

class LatestSmileyNotifier extends StateNotifier<LatestSmileyState> {
  LatestSmileyNotifier(this.ref, this.dio) : super(LatestSmileyState.initial());
  Ref ref;
  Dio dio;

  Future<void> getLatestSmiley(DateTime dateTime) async {
    state = state.copyWith(status: Loader.loading);
    final Response response;
    final date = DateFormat('yyyy-MM-dd').format(dateTime);
    try {
      response = await dio.get('user/lastestsmileys/$date');

      var body = response.data;
      if (response.statusCode == 200) {
        final latestSmiley = ((body['smileys'] != null)
            ? LatestSmiley.fromMap(body['smileys'])
            : LatestSmiley(id: 0, tags: []));
        state =
            state.copyWith(status: Loader.loaded, latestSmiley: latestSmiley);
      } else {
        state = state.copyWith(status: Loader.error, error: body["error"]);
      }
    } on DioException catch (e) {
      state = state.copyWith(status: Loader.error, error: e.message);
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

class LatestSmiley {
  final int? id;
  final List tags;

  LatestSmiley({
    required this.id,
    required this.tags,
  });

  factory LatestSmiley.fromMap(Map<String, dynamic> data) {
    return LatestSmiley(
      id: data['id'] ?? 0,
      tags: data['tags'] ?? [],
    );
  }
}
