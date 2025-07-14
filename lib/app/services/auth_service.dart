import 'package:nylo_framework/nylo_framework.dart';
import '/app/networking/api_service.dart';
import '/app/models/user.dart';
import '/config/keys.dart';

class AuthService {
  static final AuthService _api = AuthService();

  static Future<bool> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String confirmPassword,
    required int currentRegion,
  }) async {
    try {
      final response = await _api.register(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
        confirmPassword: confirmPassword,
        currentRegion: currentRegion,
      );

      if (response != null && response['token'] != null) {
        await Keys.auth.save(response['token']);
        if (response['user'] != null) {
          User user = User.fromJson(response['user']);
          await Keys.userProfile.save(user.toJson());
        }
        return true;
      }
      return false;
    } catch (e) {
      print('Register error: $e');
      return false;
    }
  }

  static Future<bool> login({
    required String email,
    required String password,
    required String regionCode,
  }) async {
    try {
      final response = await _api.login(
        email: email,
        password: password,
        regionCode: regionCode,
      );

      if (response != null && response['token'] != null) {
        await Keys.auth.save(response['token']);
        if (response['user'] != null) {
          User user = User.fromJson(response['user']);
          await Keys.userProfile.save(user.toJson());

          // Save current region
          if (response['user']['current_region'] != null) {
            await Keys.currentRegion
                .save(response['user']['current_region']['code']);
          }
        }
        return true;
      }
      return false;
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  static Future<bool> socialAuth({
    required String firebaseToken,
    required String provider,
    required int currentRegion,
  }) async {
    try {
      final response = await _api.socialAuth(
        firebaseToken: firebaseToken,
        provider: provider,
        currentRegion: currentRegion,
      );

      if (response != null && response['token'] != null) {
        await Keys.auth.save(response['token']);
        if (response['user'] != null) {
          User user = User.fromJson(response['user']);
          await Keys.userProfile.save(user.toJson());
        }
        return true;
      }
      return false;
    } catch (e) {
      print('Social auth error: $e');
      return false;
    }
  }

  static Future<void> logout() async {
    try {
      await _api.logout();
    } catch (e) {
      print('Logout error: $e');
    } finally {
      // Clear local storage regardless of API response
      await Keys.auth.delete();
      await Keys.userProfile.delete();
      await Keys.selectedServices.delete();
      await Keys.selectedProfessional.delete();
      await Keys.bookingDraft.delete();
      await _api.clearUserSpecificCache();
    }
  }

  static Future<bool> isAuthenticated() async {
    String? token = await Keys.auth.read();
    return token != null && token.isNotEmpty;
  }

  static Future<User?> getCurrentUser() async {
    try {
      final userData = await Keys.userProfile.read();
      if (userData != null) {
        return User.fromJson(userData);
      }
      return null;
    } catch (e) {
      print('Get current user error: $e');
      return null;
    }
  }

  static Future<bool> forgotPassword({required String email}) async {
    try {
      final response = await _api.forgotPassword(email: email);
      return response != null;
    } catch (e) {
      print('Forgot password error: $e');
      return false;
    }
  }

  static Future<bool> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final response = await _api.resetPassword(
        email: email,
        otp: otp,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );
      return response != null;
    } catch (e) {
      print('Reset password error: $e');
      return false;
    }
  }

  static Future<bool> updateProfile({
    required String firstName,
    required String lastName,
    String? phoneNumber,
    String? dateOfBirth,
    String? gender,
  }) async {
    try {
      final user = await _api.updateProfile(
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        dateOfBirth: dateOfBirth,
        gender: gender,
      );

      if (user != null) {
        await Keys.userProfile.save(user.toJson());
        return true;
      }
      return false;
    } catch (e) {
      print('Update profile error: $e');
      return false;
    }
  }

  static Future<bool> switchRegion({required String regionCode}) async {
    try {
      final response = await _api.switchRegion(regionCode: regionCode);
      if (response != null) {
        await Keys.currentRegion.save(regionCode);
        // Clear region-specific caches
        await _api.clearServiceCache();
        await _api.clearProfessionalsCache();
        return true;
      }
      return false;
    } catch (e) {
      print('Switch region error: $e');
      return false;
    }
  }
}
