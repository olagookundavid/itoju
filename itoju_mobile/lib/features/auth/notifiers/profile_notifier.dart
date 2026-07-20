// ignore_for_file: non_constant_identifier_names

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:itoju_mobile/core/Storage/storage_class.dart';
import 'package:itoju_mobile/core/auth/session.dart';
import 'package:itoju_mobile/core/helpers/response_helper/api_response.dart';
import 'package:itoju_mobile/features/widgets/constants.dart';
import 'package:itoju_mobile/services/dio_provider.dart';

final profileProvider =
    StateNotifierProvider.autoDispose<ProfileNotifier, ProfileState>((ref) {
  return ProfileNotifier(ref, ref.read(dioProvider));
});

class ProfileNotifier extends StateNotifier<ProfileState> {
  ProfileNotifier(this.ref, this.dio) : super(ProfileState.initial());
  Ref ref;
  Dio dio;

  /// Loads the profile cache-first, then refreshes from the server.
  ///
  /// Greetings and the profile screen must render offline: the last-fetched
  /// profile is shown from local cache immediately, and a network refresh
  /// (when reachable) updates it. A failed refresh never wipes the cache —
  /// the error state only appears when there is nothing cached to show.
  Future<void> getProfile() async {
    final cached = _readCache();
    if (cached != null) {
      state = state.copyWith(status: Loader.loaded, userModel: cached);
    } else {
      state = state.copyWith(status: Loader.loading);
    }

    try {
      final response = await dio.get('users/profile');
      var body = response.data;
      if (response.statusCode == 200) {
        final userModel = UserModel.fromMap(body['user']);
        await HiveStorage.put(
            HiveKeys.profileCache, jsonEncode(body['user']));
        state = state.copyWith(status: Loader.loaded, userModel: userModel);
      } else if (cached == null) {
        state = state.copyWith(status: Loader.error, error: body["error"]);
      }
    } on DioException catch (e) {
      if (cached == null) {
        state = state.copyWith(status: Loader.error, error: e.message);
      }
    } catch (e) {
      if (cached == null) {
        state = state.copyWith(
            status: Loader.error, error: 'An unexpected error occurred');
      }
    }
  }

  UserModel? _readCache() {
    final raw = HiveStorage.get(HiveKeys.profileCache) as String?;
    if (raw == null) return null;
    try {
      return UserModel.fromMap(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  /// Saves the onboarding display name to the account (best-effort — callers
  /// fire-and-forget so an offline save never blocks the flow).
  Future<void> updateAlias(String alias) async {
    try {
      await dio.put('users/alias', data: {"alias": alias});
    } catch (_) {
      // Offline or unauthorized — the name is already stored locally.
    }
  }

  /// Saves the chosen avatar locally first (works fully offline/anonymous),
  /// then best-effort pushes it to the server when signed in. A network
  /// failure never blocks or errors the local change — the avatar has already
  /// "saved" from the user's perspective.
  Future<ApiResponse> updateProfilePic(int picNo) async {
    await HiveStorage.put(HiveKeys.avatarPicNo, picNo);
    final current = state.userModel;
    if (current != null) {
      state = state.copyWith(
        userModel: UserModel(
          id: current.id,
          firstName: current.firstName,
          lastName: current.lastName,
          dob: current.dob,
          email: current.email,
          activated: current.activated,
          isAdmin: current.isAdmin,
          pic_no: picNo,
          alias: current.alias,
        ),
        pic_status: Loader.loaded,
      );
    } else {
      state = state.copyWith(pic_status: Loader.loaded);
    }

    if (await Session.hasToken()) {
      try {
        await dio.put('users/profile_pic', data: {"pic_no": picNo});
      } catch (_) {
        // Offline or server error — the avatar is already saved locally; the
        // next successful sync/profile fetch will reconcile the server copy.
      }
    }
    return ApiResponse(successMessage: 'Avatar updated');
  }

  /// The avatar to display: the account's server value when signed in and
  /// loaded, otherwise the locally-saved choice (anonymous/offline users).
  int currentAvatar() =>
      state.userModel?.pic_no ?? (HiveStorage.get(HiveKeys.avatarPicNo) as int? ?? 0);
}

class ProfileState {
  UserModel? userModel;
  Loader? status;
  Loader? pic_status;

  ProfileState(
      {this.userModel,
      this.status = Loader.loading,
      this.pic_status = Loader.loaded});
  factory ProfileState.initial() {
    return ProfileState();
  }

  ProfileState copyWith(
      {UserModel? userModel,
      Loader? status,
      Loader? pic_status,
      String? error}) {
    return ProfileState(
        userModel: userModel ?? this.userModel,
        status: status ?? this.status,
        pic_status: pic_status ?? this.pic_status);
  }
}

class UserModel {
  final String? id;
  final String? firstName;
  final String? lastName;
  final String? dob;
  final String? email;
  final bool? activated;
  final bool? isAdmin;
  final int? pic_no;

  /// Display name chosen on the onboarding name step; roams with the account.
  final String? alias;

  UserModel(
      {required this.id,
      required this.firstName,
      required this.lastName,
      required this.dob,
      required this.email,
      required this.activated,
      required this.isAdmin,
      required this.pic_no,
      this.alias});

  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
        id: data['id'] ?? '',
        firstName: data['first_name'] ?? '',
        lastName: data['last_name'] ?? '',
        dob: data['dob'] ?? '',
        email: data['email'] ?? '',
        activated: data['activated'] ?? false,
        isAdmin: data['isAdmin'] ?? false,
        pic_no: data['pic_no'] ?? 0,
        alias: data['alias'] ?? '');
  }
}
