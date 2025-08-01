import 'package:flutter_app/config/keys.dart';
import 'package:nylo_framework/nylo_framework.dart';

class LabMyShareAuthInterceptor extends Interceptor {
  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    try {
      final tokenData = await NyStorage.read('token');
      String? token;

      if (tokenData != null) {
        // Ensure token is always a string
        token = tokenData.toString();
      }

      // List of endpoints that should NOT have Authorization header
      final publicEndpoints = [
        "/auth/verify-email/",
        "/auth/register/",
        "/auth/login/",
        "/auth/resend-otp/"
      ];
      final path = options.path;
      bool isPublic = publicEndpoints.any((endpoint) => path.endsWith(endpoint));
      if (!isPublic && token != null && token.isNotEmpty) {
        final authHeader = "Token ${token.trim()}";
        options.headers["Authorization"] = authHeader;
        print('[DEBUG] Sending Authorization header: $authHeader');
      }
    } catch (e) {
      print('Error reading auth token: $e');
    }

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    handler.next(response);
  }

  @override //
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      // Token expired or invalid, logout user
      Auth.logout();
      // Navigate to login page
      routeToInitial();
    }
    handler.next(err);
  }
}
