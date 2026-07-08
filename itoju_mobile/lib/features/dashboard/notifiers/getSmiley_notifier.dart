// ignore_for_file: public_member_api_docs, sort_constructors_first, file_names
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:itoju_mobile/features/widgets/constants.dart';
import 'package:itoju_mobile/services/dio_provider.dart';

final getSmileyProvider =
    StateNotifierProvider<GetSmileyNotifier, GetSmileyState>((ref) {
  return GetSmileyNotifier(ref, ref.read(dioProvider));
});

class GetSmileyNotifier extends StateNotifier<GetSmileyState> {
  GetSmileyNotifier(this.ref, this.dio) : super(GetSmileyState.initial());
  Ref ref;
  Dio dio;

  Future<void> getGetSmiley() async {
    state = state.copyWith(status: Loader.loading);
    final Response response;
    try {
      response = await dio.get('user/smileys_count/30');

      var body = response.data;
      if (response.statusCode == 200) {
        List<SmileyModel> smileyModel = List<SmileyModel>.from(
            body['smileys'].map((e) => SmileyModel.fromMap(e)));
        final int totalCount = body['total_count'] ?? 1;
        state = state.copyWith(
            status: Loader.loaded,
            smileyModel: smileyModel,
            totalCount: totalCount);
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

class SmileyModel {
  final int? id;
  final String? name;
  final int? count;

  SmileyModel({
    required this.id,
    required this.name,
    required this.count,
  });

  factory SmileyModel.fromMap(Map<String, dynamic> data) {
    return SmileyModel(
      id: data['id'] ?? 0,
      name: data['name'] ?? '',
      count: data['count'] ?? 0,
    );
  }

  @override
  String toString() => 'SmileyModel(id: $id, name: $name, count: $count)';
}
