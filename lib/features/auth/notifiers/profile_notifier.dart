// ignore_for_file: non_constant_identifier_names

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:itoju_mobile/core/helpers/response_helper/api_response.dart';
import 'package:itoju_mobile/features/widgets/constants.dart';
import 'package:itoju_mobile/services/app_exception.dart';
import 'package:itoju_mobile/services/dio_provider.dart';

final profileProvider =
    StateNotifierProvider.autoDispose<ProfileNotifier, ProfileState>((ref) {
  return ProfileNotifier(ref, ref.read(dioProvider));
});

class ProfileNotifier extends StateNotifier<ProfileState> {
  ProfileNotifier(this.ref, this.dio) : super(ProfileState.initial());
  Ref ref;
  Dio dio;

  Future<void> getProfile() async {
    state = state.copyWith(status: Loader.loading);
    final Response response;
    try {
      response = await dio.get('users/profile');

      var body = response.data;
      if (response.statusCode == 200) {
        final userModel = UserModel.fromMap(body['user']);
        state = state.copyWith(status: Loader.loaded, userModel: userModel);
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

  Future<ApiResponse> updateProfilePic(int picNo) async {
    state = state.copyWith(status: Loader.loading);
    final Response response;
    try {
      response = await dio.put('users/profile_pic', data: {"pic_no": picNo});
      var body = response.data;
      if (response.statusCode == 200) {
        state = state.copyWith(pic_status: Loader.loaded);
        return ApiResponse(successMessage: body['message']);
      } else {
        state = state.copyWith(pic_status: Loader.error);
        return ApiResponse(
            errorMessage: body['error'], statusCode: response.statusCode);
      }
    } on DioException catch (e) {
      state = state.copyWith(pic_status: Loader.error, error: e.message);
      return AppException.handleError(e);
    } catch (e) {
      state = state.copyWith(
          pic_status: Loader.error, error: 'An unexpected error occurred');
      return ApiResponse(errorMessage: 'An error occurred');
    }
  }
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
        pic_status: this.pic_status);
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

  UserModel(
      {required this.id,
      required this.firstName,
      required this.lastName,
      required this.dob,
      required this.email,
      required this.activated,
      required this.isAdmin,
      required this.pic_no});

  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
        id: data['id'] ?? '',
        firstName: data['first_name'] ?? '',
        lastName: data['last_name'] ?? '',
        dob: data['dob'] ?? '',
        email: data['email'] ?? '',
        activated: data['activated'] ?? false,
        isAdmin: data['isAdmin'] ?? false,
        pic_no: data['pic_no'] ?? 0);
  }
}
