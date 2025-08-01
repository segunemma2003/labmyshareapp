import 'package:flutter/material.dart';
import 'package:flutter_app/app/models/user.dart';
import 'package:flutter_app/app/networking/dio/interceptors/lab_my_share_auth_interceptor.dart';
import 'package:flutter_app/app/networking/dio/interceptors/region_interceptor.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '/config/decoders.dart';
import 'package:nylo_framework/nylo_framework.dart';

class AuthApiService extends NyApiService {
  /// Get current user profile (for token validation)
  Future<Map<String, dynamic>?> getProfile() async {
    return await network(
      request: (request) => request.get("/auth/profile/"),
    );
  }

  /// Get current user info (for token validation)
  Future<Map<String, dynamic>?> getMe() async {
    return await network(
      request: (request) => request.get("/auth/me/"),
    );
  }

  AuthApiService({BuildContext? buildContext})
      : super(
          buildContext,
          decoders: modelDecoders,
          baseOptions: (BaseOptions baseOptions) {
            return baseOptions
              ..connectTimeout = Duration(seconds: 30)
              ..sendTimeout = Duration(seconds: 30)
              ..receiveTimeout = Duration(seconds: 30);
          },
        );

  @override
  String get baseUrl => getEnv('API_BASE_URL',
      defaultValue: 'https://backend.beautyspabyshea.co.uk/api/v1');

  @override
  get interceptors => {
        if (getEnv('APP_DEBUG') == true) PrettyDioLogger: PrettyDioLogger(),
        LabMyShareAuthInterceptor: LabMyShareAuthInterceptor(),
        RegionInterceptor: RegionInterceptor(),
      };

  Future<Map<String, dynamic>?> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    return await network(
      request: (request) => request.post("/auth/register/", data: {
        "first_name": firstName,
        "last_name": lastName,
        "email": email,
        "password": password,
        "confirm_password": confirmPassword,
      }),
    );
  }

  Future<Map<String, dynamic>?> verifyEmail({
    required String email,
    required String otp,
  }) async {
    return await network(
      request: (request) => request.post("/auth/verify-email/", data: {
        "email": email,
        "otp": otp,
      }),
    );
  }

  Future<Map<String, dynamic>?> resendOtp({
    required String email,
    required String purpose,
  }) async {
    return await network(
      request: (request) => request.post("/auth/resend-otp/", data: {
        "email": email,
        "purpose": purpose,
      }),
    );
  }

  Future<Map<String, dynamic>?> login({
    required String email,
    required String password,
  }) async {
    return await network(
      request: (request) => request.post("/auth/login/", data: {
        "email": email,
        "password": password,
      }),
    );
  }

  Future<Map<String, dynamic>?> socialAuth({
    required String firebaseToken,
    required String provider,
  }) async {
    return await network(
      request: (request) => request.post("/auth/social-auth/", data: {
        "firebase_token": firebaseToken,
        "provider": provider,
      }),
    );
  }

  Future<void> logout() async {
    await network(
      request: (request) => request.post("/auth/logout/"),
    );
  }

  Future<Map<String, dynamic>?> forgotPassword({required String email}) async {
    return await network(
      request: (request) => request.post("/auth/forgot-password/", data: {
        "email": email,
      }),
    );
  }

  Future<Map<String, dynamic>?> verifyResetOtp({
    required String email,
    required String otp,
  }) async {
    return await network(
      request: (request) => request.post("/auth/verify-reset-otp/", data: {
        "email": email,
        "otp": otp,
      }),
    );
  }

  Future<Map<String, dynamic>?> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
    required String confirmPassword,
  }) async {
    return await network(
      request: (request) => request.post("/auth/reset-password/", data: {
        "email": email,
        "otp": otp,
        "new_password": newPassword,
        "confirm_password": confirmPassword,
      }),
    );
  }

  Future<User?> updateProfile({
    required String firstName,
    required String lastName,
    String? phoneNumber,
    String? dateOfBirth,
    String? gender,
  }) async {
    return await network<User>(
      request: (request) => request.put("/auth/profile/update/", data: {
        "first_name": firstName,
        "last_name": lastName,
        if (phoneNumber != null) "phone_number": phoneNumber,
        if (dateOfBirth != null) "date_of_birth": dateOfBirth,
        if (gender != null) "gender": gender,
      }),
    );
  }

  Future<Map<String, dynamic>?> updateProfileImage({
    required String imagePath,
  }) async {
    FormData formData = FormData.fromMap({
      "profile_picture": await MultipartFile.fromFile(
        imagePath,
        filename: imagePath.split('/').last,
      ),
    });

    return await network(
      request: (request) => request.put(
        "/auth/profile/image/",
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      ),
    );
  }

  Future<Map<String, dynamic>?> switchRegion(
      {required String regionCode}) async {
    return await network(
      request: (request) => request.post("/auth/switch-region/", data: {
        "region_code": regionCode,
      }),
    );
  }

  Future<User?> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    return await network<User>(
      request: (request) => request.post("/auth/change-password/", data: {
        "current_password": currentPassword,
        "new_password": newPassword,
        "confirm_password": confirmPassword,
      }),
    );
  }
}
