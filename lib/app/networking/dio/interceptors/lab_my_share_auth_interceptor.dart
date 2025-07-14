import 'package:flutter_app/config/keys.dart';
import 'package:nylo_framework/nylo_framework.dart';

class LabMyShareAuthInterceptor extends Interceptor {
  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    String? token = await Keys.auth.read();
    if (token != null) {
      options.headers["Authorization"] = "Token $token";
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
