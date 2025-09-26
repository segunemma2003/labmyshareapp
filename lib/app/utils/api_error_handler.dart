import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';

class ApiErrorHandler {
  static void handleError(dynamic error, {BuildContext? context}) {
    String message = 'An unexpected error occurred';

    if (error is DioException) {
      switch (error.response?.statusCode) {
        case 400:
          // Check if it's a validation error with details
          if (error.response?.data != null &&
              error.response?.data is Map &&
              error.response?.data['details'] != null) {
            final details =
                error.response?.data['details'] as Map<String, dynamic>;
            final firstError = details.values.first;
            if (firstError is List && firstError.isNotEmpty) {
              message = firstError.first.toString();
            } else {
              message = firstError.toString();
            }
          } else if (error.response?.data != null &&
              error.response?.data['error'] != null) {
            message = error.response!.data['error'].toString();
          } else {
            message = 'Invalid request. Please check your input.';
          }
          break;
        case 401:
          message = 'Authentication failed. Please login again.';
          // Only auto logout if this is not a login attempt (check via request path)
          // This prevents logout during failed login attempts
          if (error.requestOptions.path.contains('/login/')) {
            // This is a login attempt failure, show error but don't logout
            message = 'Invalid email or password. Please try again.';
          } else {
            // Auto logout on 401 for authenticated requests
            Auth.logout();
          }
          break;
        case 403:
          message = 'You don\'t have permission to perform this action.';
          break;
        case 404:
          message = 'The requested resource was not found.';
          break;
        case 422:
          if (error.response?.data != null &&
              error.response?.data['details'] != null) {
            final details =
                error.response?.data['details'] as Map<String, dynamic>;
            final firstError = details.values.first;
            if (firstError is List && firstError.isNotEmpty) {
              message = firstError.first.toString();
            }
          } else {
            message = 'Validation error. Please check your input.';
          }
          break;
        case 429:
          message = 'Too many requests. Please try again later.';
          break;
        case 500:
          message = 'Server error. Please try again later.';
          break;
        default:
          message =
              error.response?.data?['message'] ?? 'Network error occurred';
      }
    } else if (error is Exception) {
      message = error.toString().replaceFirst('Exception: ', '');
    }

    if (context != null) {
      showToastNotification(context,
          style: ToastNotificationStyleType.danger,
          title: "Error",
          description: message);
    } else {
      print('API Error: $message');
    }
  }

  static String getErrorMessage(dynamic error) {
    if (error is DioException) {
      if (error.response?.data != null &&
          error.response?.data['message'] != null) {
        return error.response?.data['message'];
      }

      switch (error.response?.statusCode) {
        case 400:
          return 'Invalid request';
        case 401:
          return 'Authentication failed';
        case 403:
          return 'Permission denied';
        case 404:
          return 'Resource not found';
        case 422:
          return 'Validation error';
        case 429:
          return 'Rate limit exceeded';
        case 500:
          return 'Server error';
        default:
          return 'Network error';
      }
    }
    return 'An unexpected error occurred';
  }
}
