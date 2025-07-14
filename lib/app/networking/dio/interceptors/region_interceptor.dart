import 'package:nylo_framework/nylo_framework.dart';

import '../../../../config/keys.dart';

class RegionInterceptor extends Interceptor {
  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    // Add region header if available
    String? currentRegion = await Keys.currentRegion.read();
    if (currentRegion != null) {
      options.headers["X-Region"] = currentRegion;
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    handler.next(err);
  }
}
