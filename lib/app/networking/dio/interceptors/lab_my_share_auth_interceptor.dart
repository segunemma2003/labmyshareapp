import 'package:flutter_app/config/keys.dart';
import 'package:nylo_framework/nylo_framework.dart';

class LabMyShareAuthInterceptor extends Interceptor {
  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    try {
      final tokenData = await Keys.auth.read();
      String? token;

      if (tokenData != null) {
        // Ensure token is always a string
        token = tokenData.toString();
      }

      if (token != null && token.isNotEmpty) {
        options.headers["Authorization"] = "Token $token";
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
