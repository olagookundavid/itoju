import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:itoju_mobile/core/helpers/response_helper/api_response.dart';
import 'package:itoju_mobile/features/widgets/constants.dart';
import 'package:itoju_mobile/services/app_exception.dart';
import 'package:itoju_mobile/services/dio_provider.dart';

final resourcesProvider =
    StateNotifierProvider.autoDispose<ResourcesNotifier, ResourcesState>((ref) {
  return ResourcesNotifier(ref, ref.read(dioProvider));
});

class ResourcesNotifier extends StateNotifier<ResourcesState> {
  ResourcesNotifier(this.ref, this.dio) : super(ResourcesState.initial());
  Ref ref;
  Dio dio;

  Future<void> getResources() async {
    state = state.copyWith(getStatus: Loader.loading);
    final Response response;
    try {
      response = await dio.get('resources');

      var body = response.data;
      if (response.statusCode == 200) {
        List<ResourcesModel> resourcesModel = List<ResourcesModel>.from(
            body['resources'].map((e) => ResourcesModel.fromMap(e)));
        state = state.copyWith(
            getStatus: Loader.loaded, resourcesModel: resourcesModel);
      } else {
        state = state.copyWith(getStatus: Loader.error, error: body["error"]);
      }
    } on DioException catch (e) {
      state = state.copyWith(getStatus: Loader.error, error: e.message);
    } catch (e) {
      state = state.copyWith(
          getStatus: Loader.error, error: 'An unexpected error occurred');
    }
  }

  Future<ApiResponse> updateResources(
      String name, String imageUrl, String link, List tags, int id) async {
    state = state.copyWith(getStatus: Loader.loading);
    final Response response;
    try {
      response = await dio.put('resources/$id', data: {
        "name": name,
        "image_url": imageUrl,
        "link": link,
        "tags": tags,
      });

      var body = response.data;
      if (response.statusCode == 200) {
        state = state.copyWith(postStatus: Loader.loaded);
        getResources();
        return ApiResponse(successMessage: body['message']);
      } else {
        state = state.copyWith(postStatus: Loader.error, error: body["error"]);
        return ApiResponse(
            errorMessage: body['error'], statusCode: response.statusCode);
      }
    } on DioException catch (e) {
      state = state.copyWith(postStatus: Loader.error);
      return AppException.handleError(e);
    } catch (e) {
      state = state.copyWith(
          postStatus: Loader.error, error: 'An unexpected error occurred');
      return ApiResponse(errorMessage: 'An error occurred');
    }
  }

  Future<ApiResponse> createResources(
      String name, String imageUrl, String link, List tags) async {
    state = state.copyWith(postStatus: Loader.loading);
    final Response response;
    try {
      response = await dio.post('resources', data: {
        "name": name,
        "image_url": imageUrl,
        "link": link,
        "tags": tags,
      });

      var body = response.data;
      if (response.statusCode == 200) {
        state = state.copyWith(postStatus: Loader.loaded);
        getResources();
        return ApiResponse(successMessage: body['message']);
      } else {
        state = state.copyWith(postStatus: Loader.error, error: body["error"]);
        return ApiResponse(
            errorMessage: body['error'], statusCode: response.statusCode);
      }
    } on DioException catch (e) {
      state = state.copyWith(postStatus: Loader.error, error: e.message);
      return AppException.handleError(e);
    } catch (e) {
      state = state.copyWith(
          postStatus: Loader.error, error: 'An unexpected error occurred');
      return ApiResponse(errorMessage: 'An error occurred');
    }
  }

  Future<ApiResponse> deleteResources(int id) async {
    state = state.copyWith(delStatus: Loader.loading);
    final Response response;
    try {
      response = await dio.delete(
        'resources/$id',
      );

      var body = response.data;
      if (response.statusCode == 200) {
        state = state.copyWith(delStatus: Loader.loaded);
        getResources();
        return ApiResponse(successMessage: body['message']);
      } else {
        state = state.copyWith(delStatus: Loader.error, error: body["error"]);
        return ApiResponse(
            errorMessage: body['error'], statusCode: response.statusCode);
      }
    } on DioException catch (e) {
      state = state.copyWith(delStatus: Loader.error, error: e.message);
      return AppException.handleError(e);
    } catch (e) {
      state = state.copyWith(
          delStatus: Loader.error, error: 'An unexpected error occurred');
      return ApiResponse(errorMessage: 'An error occurred');
    }
  }
}

class ResourcesState {
  List<ResourcesModel>? resourcesModel;
  Loader? getStatus;
  Loader? postStatus;
  Loader? delStatus;

  ResourcesState(
      {this.resourcesModel,
      this.getStatus = Loader.loading,
      this.postStatus = Loader.loaded,
      this.delStatus = Loader.loaded});
  factory ResourcesState.initial() {
    return ResourcesState();
  }

  ResourcesState copyWith(
      {List<ResourcesModel>? resourcesModel,
      Loader? getStatus,
      String? error,
      Loader? postStatus,
      Loader? delStatus}) {
    return ResourcesState(
        resourcesModel: resourcesModel ?? this.resourcesModel,
        getStatus: getStatus ?? this.getStatus,
        postStatus: postStatus ?? this.postStatus,
        delStatus: delStatus ?? this.delStatus);
  }
}

class ResourcesModel {
  final int? id;
  final String? name;
  final String? imgUrl;
  final String? link;
  final List? tags;

  ResourcesModel(
    this.id,
    this.name,
    this.imgUrl,
    this.link,
    this.tags,
  );

  factory ResourcesModel.fromMap(Map<String, dynamic> data) {
    return ResourcesModel(
      data['id'] ?? 0,
      data['name'] ?? '',
      data['image_url'] ?? '',
      data['link'] ?? '',
      data['tags'] ?? [],
    );
  }
}
