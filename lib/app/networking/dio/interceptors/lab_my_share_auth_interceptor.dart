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
      bool isPublic =
          publicEndpoints.any((endpoint) => path.endsWith(endpoint));
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
      // List of endpoints that should not trigger logout/redirect
      // (these are login/registration endpoints where 401 is expected for invalid credentials)
      final publicEndpoints = [
        "/auth/verify-email/",
        "/auth/register/",
        "/auth/login/",
        "/auth/resend-otp/",
        "/auth/forgot-password/",
        "/auth/verify-reset-otp/",
        "/auth/reset-password/",
        "/auth/social-auth/"
      ];

      final path = err.requestOptions.path;
      bool isPublicEndpoint =
          publicEndpoints.any((endpoint) => path.endsWith(endpoint));

      // Only logout and redirect for authenticated requests, not for login attempts
      if (!isPublicEndpoint) {
        // Token expired or invalid for authenticated request, logout user
        Auth.logout();
        // Navigate to login page
        routeToInitial();
      }
    }
    handler.next(err);
  }
}
