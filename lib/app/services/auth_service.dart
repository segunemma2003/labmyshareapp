import 'dart:convert';
import 'package:flutter_app/app/networking/auth_api_service.dart';
import 'package:flutter_app/app/networking/notification_api_service.dart';
import 'package:flutter_app/app/networking/services_api_service.dart';
import 'package:nylo_framework/nylo_framework.dart';
import '/app/models/user.dart';
import '/config/keys.dart';

class AuthService {
  static final AuthApiService _api = AuthApiService();
  static final NotificationApiService _notificationApi =
      NotificationApiService();

  /// Flush all NyStorage and cache before authentication
  static Future<void> flushAllStorageAndCache() async {
    // Preserve hasOpenedApp flag
    final hasOpenedApp = await Keys.hasOpenedApp.read();
    await NyStorage.clear(""); // Clear all NyStorage keys
    if (hasOpenedApp == true) {
      await Keys.hasOpenedApp.save(true);
    }
    await cache().flush(); // Flush Nylo cache
  }

  static Future<Map<String, dynamic>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      // Flush all NyStorage and cache before registration
      await AuthService.flushAllStorageAndCache();
      // Flush old/corrupt token before registration
      await flushAuthToken();
      final response = await _api.register(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
        confirmPassword: confirmPassword,
      );

      bool success = false;
      bool isNewUser = false;
      if (response != null && response['token'] != null) {
        // Always save the token as a String
        final cleanToken = response['token'].toString().trim();
        await Keys.auth.save(cleanToken);
        await NyStorage.save('token', cleanToken);

        // Save login state for persistent login
        await Keys.isLoggedIn.save(true);
        await Keys.loginTimestamp.save(DateTime.now().millisecondsSinceEpoch);

        if (response['user'] != null) {
          final userData = Map<String, dynamic>.from(response['user']);
          await _saveUserData(userData);
          await Auth.authenticate(data: userData);
        }
        success = true;
        if (response['is_new_user'] != null) {
          isNewUser = response['is_new_user'] == true;
        }
      }
      return {'success': success, 'isNewUser': isNewUser};
    } catch (e) {
      print('Register error: $e');
      return {'success': false, 'isNewUser': false};
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
          await _saveUserData(user.toJson());
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
      // Re-throw the error to be handled by ApiErrorHandler in the UI
      rethrow;
    }
  }

  static Future<void> flushAuthToken() async {
    await Keys.auth.flush();
  }

  static Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      // Flush all NyStorage and cache before login
      await AuthService.flushAllStorageAndCache();
      // Flush old/corrupt token before login
      await flushAuthToken();
      final response = await _api.login(
        email: email,
        password: password,
      );

      if (response != null && response['token'] != null) {
        // Save the token as a String in Keys.auth and NyStorage
        final cleanToken = response['token'].toString().trim();
        await Keys.auth.save(cleanToken);
        await NyStorage.save('token', cleanToken);

        // Save login state for persistent login
        await Keys.isLoggedIn.save(true);
        await Keys.loginTimestamp.save(DateTime.now().millisecondsSinceEpoch);

        if (response['user'] != null) {
          final userData = Map<String, dynamic>.from(response['user']);
          await _saveUserData(userData);
          await Auth.authenticate(data: userData);
        }
        return true;
      }
      return false;
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  static Future<Map<String, dynamic>> socialAuth({
    required String firebaseToken,
    required String provider,
  }) async {
    try {
      // Flush all NyStorage and cache before social auth
      await AuthService.flushAllStorageAndCache();
      // Flush old/corrupt token before social auth
      await flushAuthToken();
      final response = await _api.socialAuth(
        firebaseToken: firebaseToken,
        provider: provider,
      );

      bool success = false;
      bool isNewUser = false;
      if (response != null && response['token'] != null) {
        // Save the token as a String in Keys.auth and NyStorage
        final cleanToken = response['token'].toString().trim();
        await Keys.auth.save(cleanToken);
        await NyStorage.save('token', cleanToken);

        // Save login state for persistent login
        await Keys.isLoggedIn.save(true);
        await Keys.loginTimestamp.save(DateTime.now().millisecondsSinceEpoch);

        if (response['user'] != null) {
          User user = User.fromJson(response['user']);
          await _saveUserData(user.toJson());
          await Auth.authenticate(data: user.toJson());

          // Save current region if available
          if (response['user']['current_region'] != null) {
            await Keys.currentRegion
                .save(response['user']['current_region']['code']);
          }
        }
        success = true;
        if (response['is_new_user'] != null) {
          isNewUser = response['is_new_user'] == true;
        }
      }
      return {'success': success, 'isNewUser': isNewUser};
    } catch (e) {
      print('Social auth error: $e');
      return {'success': false, 'isNewUser': false};
    }
  }

  static Future<void> logout() async {
    try {
      await _api.logout();
    } catch (e) {
      print('Logout error: $e');
    } finally {
      // Clear local storage regardless of API response
      await Auth.logout();
      await Keys.auth.flush();
      await NyStorage.delete('token');
      await Keys.userProfile.flush();
      await Keys.selectedServices.flush();
      await Keys.selectedProfessional.flush();
      await Keys.bookingDraft.flush();
      await Keys.currentRegion.flush();

      // Clear persistent login state
      await Keys.isLoggedIn.flush();
      await Keys.loginTimestamp.flush();

      await _notificationApi.clearUserSpecificCache();
    }
  }

  static Future<bool> isAuthenticated() async {
    // Use Nylo's Auth.isAuthenticated() which checks the auth key
    return await Auth.isAuthenticated();
  }

  /// Check if user is persistently logged in
  static Future<bool> isPersistentlyLoggedIn() async {
    try {
      final isLoggedIn = await Keys.isLoggedIn.read();
      final loginTimestamp = await Keys.loginTimestamp.read();

      // Check if persistent login state exists
      if (isLoggedIn != true || loginTimestamp == null) {
        return false;
      }

      // Check if Nylo Auth is also authenticated (has valid token)
      final isNyloAuthenticated = await Auth.isAuthenticated();
      if (!isNyloAuthenticated) {
        return false;
      }

      // Optional: Check if login is not too old (e.g., 30 days)
      final loginTime = DateTime.fromMillisecondsSinceEpoch(loginTimestamp);
      final now = DateTime.now();
      final daysSinceLogin = now.difference(loginTime).inDays;

      // If login is older than 30 days, consider it expired
      if (daysSinceLogin > 30) {
        await _clearPersistentLoginState();
        return false;
      }

      return true;
    } catch (e) {
      print('Error checking persistent login: $e');
      return false;
    }
  }

  /// Clear persistent login state
  static Future<void> _clearPersistentLoginState() async {
    await Keys.isLoggedIn.flush();
    await Keys.loginTimestamp.flush();
  }

  static Future<void> _saveUserData(Map<String, dynamic> userData) async {
    // Always save as JSON string for consistency
    await Keys.userProfile.save(jsonEncode(userData));
  }

  static Future<User?> getCurrentUser() async {
    try {
      final userData = await Keys.userProfile.read();
      if (userData != null) {
        print('Raw user data: $userData');
        print('User data type: ${userData.runtimeType}');

        Map<String, dynamic>? userMap;

        if (userData is Map) {
          // Data is already a Map
          userMap = Map<String, dynamic>.from(userData);
          print('User data is a Map');
        } else if (userData is String) {
          // Data is a string, try to parse it
          try {
            // Try JSON decode first
            userMap = Map<String, dynamic>.from(jsonDecode(userData));
            print('Successfully parsed JSON string');
          } catch (e) {
            print('Failed to parse as JSON: $e');
            // If JSON parsing fails, the data might be corrupted
            // Clear the corrupted data and return null
            print('Clearing corrupted user data...');
            await Keys.userProfile.flush();
            return null;
          }
        } else {
          print('Unexpected user data type: ${userData.runtimeType}');
          return null;
        }

        // Handle empty gender field
        if (userMap['gender'] == '') {
          userMap['gender'] = null;
        }

        print('Parsing user data...');
        return User.fromJson(userMap);
      }
      return null;
    } catch (e) {
      print('Get current user error details: $e');
      print('Stack trace: ${StackTrace.current}');
      // Clear potentially corrupted data
      await Keys.userProfile.flush();
      return null;
    }
  }

  static Future<bool> forgotPassword({required String email}) async {
    try {
      final response = await _api.forgotPassword(email: email);
      return response != null;
    } catch (e) {
      print('Forgot password error: $e');
      // Re-throw the error to be handled by ApiErrorHandler in the UI
      rethrow;
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
      // Re-throw the error to be handled by ApiErrorHandler in the UI
      rethrow;
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
      // Re-throw the error to be handled by ApiErrorHandler in the UI
      rethrow;
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
        await _saveUserData(user.toJson());
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
          Map<String, dynamic> userMap;

          if (userData is Map) {
            // Data is already a Map
            userMap = Map<String, dynamic>.from(userData);
          } else if (userData is String) {
            // Data is a string, try to parse it
            try {
              userMap = Map<String, dynamic>.from(jsonDecode(userData));
            } catch (e) {
              print('Failed to parse user data in updateProfileImage: $e');
              return false;
            }
          } else {
            print(
                'Unexpected user data type in updateProfileImage: ${userData.runtimeType}');
            return false;
          }

          // Update the profile picture
          userMap['profile_picture'] = response['profile_picture'];
          await _saveUserData(userMap);
        }
        return true;
      }
      return false;
    } catch (e) {
      print('Update profile image error: $e');
      return false;
    }
  }

  static Future<void> clearRegionServiceCaches() async {
    // Clear main service categories
    await NyStorage.delete('service_categories');
    // Example: clear for first 10 categories (adjust as needed)
    for (int i = 1; i <= 10; i++) {
      await NyStorage.delete('category_${i}_services');
      await NyStorage.delete('category_${i}_addons');
    }
    cache().flush();
    // Add more keys as needed for your app
  }

  static Future<bool> switchRegion({required String regionCode}) async {
    try {
      final response = await _api.switchRegion(regionCode: regionCode);
      if (response != null) {
        await Keys.currentRegion.save(regionCode);

        // Update user profile with new region if returned
        if (response['user'] != null) {
          User user = User.fromJson(response['user']);
          await _saveUserData(user.toJson());
        }

        // Clear region/service/add-on caches
        await clearRegionServiceCaches();
        await _notificationApi.clearServiceCache();
        await _notificationApi.clearProfessionalsCache();
        await ServicesApiService().clearCache();
        await cache().flush();
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
        await _saveUserData(user.toJson());
        return true;
      }
      return false;
    } catch (e) {
      print('Change password error: $e');
      return false;
    }
  }

  /// Sign in with Google using Firebase Auth, then authenticate with backend
  /// Returns the backend response (token, user, is_new_user) or null on failure.
  // static Future<Map<String, dynamic>?> loginWithGoogle() async {
  //   try {
  //     final String? firebaseToken =
  //         await FirebaseAuthService.signInWithGoogle();
  //     if (firebaseToken == null) {
  //       print('Google sign-in failed or cancelled');
  //       return null;
  //     }
  //     return await _api.socialAuth(
  //         firebaseToken: firebaseToken, provider: 'google');
  //   } catch (e) {
  //     print('loginWithGoogle error: $e');
  //     return null;
  //   }
  // }

  /// Sign in with Apple using Firebase Auth, then authenticate with backend
  /// Returns the backend response (token, user, is_new_user) or null on failure.
  // static Future<Map<String, dynamic>?> loginWithApple() async {
  //   try {
  //     final String? firebaseToken = await FirebaseAuthService.signInWithApple();
  //     if (firebaseToken == null) {
  //       print('Apple sign-in failed or cancelled');
  //       return null;
  //     }
  //     return await _api.socialAuth(
  //         firebaseToken: firebaseToken, provider: 'apple');
  //   } catch (e) {
  //     print('loginWithApple error: $e');
  //     return null;
  //   }
  // }

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
