import 'package:flutter_app/app/networking/auth_api_service.dart';
import 'package:flutter_app/app/networking/notification_api_service.dart';
import 'package:flutter_app/app/networking/services_api_service.dart';
import 'package:nylo_framework/nylo_framework.dart';
import '/app/networking/api_service.dart';
import '/app/models/user.dart';
import '/config/keys.dart';

class AuthService {
  static final AuthApiService _api = AuthApiService();
  static final NotificationApiService _notificationApi =
      NotificationApiService();

  static Future<bool> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      final response = await _api.register(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
        confirmPassword: confirmPassword,
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

  static Future<bool> verifyEmail({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await _api.verifyEmail(
        email: email,
        otp: otp,
      );

      if (response != null) {
        // Update user profile with verified status
        if (response['user'] != null) {
          User user = User.fromJson(response['user']);
          await Keys.userProfile.save(user.toJson());
        }
        return true;
      }
      return false;
    } catch (e) {
      print('Verify email error: $e');
      return false;
    }
  }

  static Future<bool> resendOtp({
    required String email,
    required String purpose,
  }) async {
    try {
      final response = await _api.resendOtp(
        email: email,
        purpose: purpose,
      );
      return response != null;
    } catch (e) {
      print('Resend OTP error: $e');
      return false;
    }
  }

  static Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _api.login(
        email: email,
        password: password,
      );

      if (response != null && response['token'] != null) {
        await Keys.auth.save(response['token']);
        if (response['user'] != null) {
          try {
            // Clean the user data before parsing
            final userData = Map<String, dynamic>.from(response['user']);

            // Handle empty gender
            if (userData['gender'] == '') {
              userData['gender'] = null;
            }

            print('Cleaned user data: $userData'); // Debug log

            User user = User.fromJson(userData);
            await Keys.userProfile.save(user.toJson());

            // Save current region
            if (userData['current_region'] != null) {
              await Keys.currentRegion.save(userData['current_region']['code']);
            }
          } catch (parseError) {
            print('User parsing error: $parseError');
            // Still save the token even if user parsing fails
            return true;
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
  }) async {
    try {
      final response = await _api.socialAuth(
        firebaseToken: firebaseToken,
        provider: provider,
      );

      if (response != null && response['token'] != null) {
        await Keys.auth.save(response['token']);
        if (response['user'] != null) {
          User user = User.fromJson(response['user']);
          await Keys.userProfile.save(user.toJson());

          // Check if this is a new user
          bool isNewUser = response['is_new_user'] ?? false;

          // Save current region if available
          if (response['user']['current_region'] != null) {
            await Keys.currentRegion
                .save(response['user']['current_region']['code']);
          }
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
      await Keys.auth.flush();
      await Keys.userProfile.flush();
      await Keys.selectedServices.flush();
      await Keys.selectedProfessional.flush();
      await Keys.bookingDraft.flush();
      await Keys.currentRegion.flush();
      await _notificationApi.clearUserSpecificCache();
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
        print('Raw user data: $userData'); // Debug log

        // Add null checks for problematic fields
        if (userData is Map<String, dynamic>) {
          // Handle empty string gender
          if (userData['gender'] == '') {
            userData['gender'] = null;
          }

          // Handle any other potential string index issues
          print('Parsing user data...');
          return User.fromJson(userData);
        }
      }
      return null;
    } catch (e) {
      print('Get current user error details: $e');
      print('Stack trace: ${StackTrace.current}');
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

  static Future<bool> verifyResetOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await _api.verifyResetOtp(
        email: email,
        otp: otp,
      );
      return response != null && response['verified'] == true;
    } catch (e) {
      print('Verify reset OTP error: $e');
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

  static Future<bool> updateProfileImage({required String imagePath}) async {
    try {
      final response = await _api.updateProfileImage(imagePath: imagePath);

      if (response != null && response['profile_picture'] != null) {
        // Update the saved user profile with new image URL
        final userData = await Keys.userProfile.read();
        if (userData != null) {
          userData['profile_picture'] = response['profile_picture'];
          await Keys.userProfile.save(userData);
        }
        return true;
      }
      return false;
    } catch (e) {
      print('Update profile image error: $e');
      return false;
    }
  }

  static Future<bool> switchRegion({required String regionCode}) async {
    try {
      final response = await _api.switchRegion(regionCode: regionCode);
      if (response != null) {
        await Keys.currentRegion.save(regionCode);

        // Update user profile with new region if returned
        if (response['user'] != null) {
          User user = User.fromJson(response['user']);
          await Keys.userProfile.save(user.toJson());
        }

        // Clear region-specific caches
        await _notificationApi.clearServiceCache();
        await _notificationApi.clearProfessionalsCache();
        // Clear all services/add-ons cache
        await ServicesApiService().clearCache();
        return true;
      }
      return false;
    } catch (e) {
      print('Switch region error: $e');
      return false;
    }
  }

  static Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final user = await _api.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );

      if (user != null) {
        await Keys.userProfile.save(user.toJson());
        return true;
      }
      return false;
    } catch (e) {
      print('Change password error: $e');
      return false;
    }
  }

  // Helper method to check if user needs to select a region
  static Future<bool> needsRegionSelection() async {
    final user = await getCurrentUser();
    return user != null && user.currentRegion == null;
  }

  // Helper method to check if user's profile is completed
  static Future<bool> isProfileCompleted() async {
    final user = await getCurrentUser();
    return user?.profileCompleted ?? false;
  }

  // Helper method to get gender code from display text
  static String? getGenderCode(String displayText) {
    switch (displayText) {
      case 'Male':
        return 'M';
      case 'Female':
        return 'F';
      case 'Other':
        return 'O';
      case 'Prefer not to say':
        return 'P';
      default:
        return null;
    }
  }

  // Helper method to get display text from gender code
  static String getGenderDisplayText(String? code) {
    switch (code) {
      case 'M':
        return 'Male';
      case 'F':
        return 'Female';
      case 'O':
        return 'Other';
      case 'P':
        return 'Prefer not to say';
      default:
        return '';
    }
  }
}
