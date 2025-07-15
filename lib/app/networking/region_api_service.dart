import 'package:flutter/material.dart';
import 'package:flutter_app/app/networking/dio/interceptors/lab_my_share_auth_interceptor.dart';
import 'package:flutter_app/app/networking/dio/interceptors/region_interceptor.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '/config/decoders.dart';
import 'package:nylo_framework/nylo_framework.dart';

class RegionApiService extends NyApiService {
  RegionApiService({BuildContext? buildContext})
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

  Future<List<dynamic>?> getRegions() async {
    final response = await network(
      request: (request) => request.get("/regions/"),
      // cacheKey: "regions_list",
      // cacheDuration: const Duration(seconds: 10), // Cache regions for 24 hours
    );

    // Handle Django REST framework response structure
    if (response is Map<String, dynamic> && response.containsKey('results')) {
      return response['results'] as List<dynamic>?;
    }

    // If it's already a list, return as is
    if (response is List) {
      return response;
    }

    // Fallback
    return null;
  }

  Future<Map<String, dynamic>?> getRegion({required String code}) async {
    return await network(
      request: (request) => request.get("/regions/$code/"),
      cacheKey: "region_$code",
      cacheDuration: const Duration(hours: 12),
    );
  }
}
