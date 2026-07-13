import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:itoju_mobile/core/Storage/storage_class.dart';
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

  /// Loads resources cache-first, then refreshes from the server when online.
  ///
  /// Resources are free public content, so a user must be able to browse them
  /// even fully offline: the last-fetched list is shown from local cache
  /// immediately, and a network refresh (when reachable) updates it. A failed
  /// refresh never wipes the cache — the error screen only appears when there
  /// is nothing cached to show.
  ///
  /// Returns `true` when a fresh copy was pulled from the server, `false` when
  /// the refresh could not complete (offline/error). Callers that expose a
  /// manual "sync" control use this to tell the user they're seeing saved data.
  Future<bool> getResources() async {
    // 1. Cache-first: render saved resources instantly (works fully offline).
    final cached = _readCache();
    if (cached != null && cached.isNotEmpty) {
      state = state.copyWith(
          getStatus: Loader.loaded, resourcesModel: cached, syncing: true);
    } else {
      state = state.copyWith(getStatus: Loader.loading, syncing: true);
    }

    // 2. Refresh from the server; keep the cache intact on any failure.
    try {
      final response = await dio.get('resources');
      final body = response.data;
      if (response.statusCode == 200) {
        final fresh = List<ResourcesModel>.from(
            body['resources'].map((e) => ResourcesModel.fromMap(e)));
        await _writeCache(fresh);
        state = state.copyWith(
            getStatus: Loader.loaded, resourcesModel: fresh, syncing: false);
        return true;
      }
      state = _afterFailedRefresh(cached, body["error"]);
      return false;
    } on DioException catch (e) {
      state = _afterFailedRefresh(cached, e.message);
      return false;
    } catch (_) {
      state = _afterFailedRefresh(cached, 'An unexpected error occurred');
      return false;
    }
  }

  /// After a refresh fails: keep showing cached resources if we have any (so an
  /// offline user still sees the list); only fall back to the error screen when
  /// the cache is empty.
  ResourcesState _afterFailedRefresh(
      List<ResourcesModel>? cached, String? error) {
    if (cached != null && cached.isNotEmpty) {
      return state.copyWith(
          getStatus: Loader.loaded, resourcesModel: cached, syncing: false);
    }
    return state.copyWith(
        getStatus: Loader.error, error: error, syncing: false);
  }

  List<ResourcesModel>? _readCache() {
    final raw = HiveStorage.get(HiveKeys.resourcesCache) as String?;
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw) as List;
      return decoded
          .map((e) => ResourcesModel.fromMap(Map<String, dynamic>.from(e)))
          .toList();
    } catch (_) {
      return null;
    }
  }

  Future<void> _writeCache(List<ResourcesModel> list) async {
    await HiveStorage.put(
      HiveKeys.resourcesCache,
      jsonEncode(list.map((e) => e.toMap()).toList()),
    );
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

  /// True while a background refresh is in flight (cached data may already be
  /// on screen). Drives the spinner on the manual sync button.
  bool syncing;

  ResourcesState(
      {this.resourcesModel,
      this.getStatus = Loader.loading,
      this.postStatus = Loader.loaded,
      this.delStatus = Loader.loaded,
      this.syncing = false});
  factory ResourcesState.initial() {
    return ResourcesState();
  }

  ResourcesState copyWith(
      {List<ResourcesModel>? resourcesModel,
      Loader? getStatus,
      String? error,
      Loader? postStatus,
      Loader? delStatus,
      bool? syncing}) {
    return ResourcesState(
        resourcesModel: resourcesModel ?? this.resourcesModel,
        getStatus: getStatus ?? this.getStatus,
        postStatus: postStatus ?? this.postStatus,
        delStatus: delStatus ?? this.delStatus,
        syncing: syncing ?? this.syncing);
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

  /// Uses the same keys as the server payload so the local cache round-trips
  /// straight back through [fromMap].
  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'image_url': imgUrl,
        'link': link,
        'tags': tags,
      };
}
