import 'package:flutter/material.dart';
import 'package:flutter_app/app/models/add_on_service.dart' show AddOnService;
import 'package:flutter_app/app/models/service_item.dart';
import 'package:flutter_app/app/networking/dio/interceptors/lab_my_share_auth_interceptor.dart';
import 'package:flutter_app/app/networking/dio/interceptors/region_interceptor.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '/config/decoders.dart';
import 'package:nylo_framework/nylo_framework.dart';

class ServicesApiService extends NyApiService {
  ServicesApiService({BuildContext? buildContext})
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

  Future<List<dynamic>?> getServiceCategories() async {
    return await network(
      request: (request) => request.get("/services/categories/"),
      cacheKey: "service_categories",
      cacheDuration: const Duration(hours: 6),
    );
  }

  Future<List<ServiceItem>?> getServices({
    int? categoryId,
    bool? isFeatured,
    String? search,
    String? ordering,
  }) async {
    Map<String, dynamic> queryParams = {};
    if (categoryId != null) queryParams['category'] = categoryId;
    if (isFeatured != null) queryParams['is_featured'] = isFeatured;
    if (search != null) queryParams['search'] = search;
    if (ordering != null) queryParams['ordering'] = ordering;

    String cacheKey = "services_${queryParams.hashCode}";

    return await network<List<ServiceItem>>(
      request: (request) =>
          request.get("/services/", queryParameters: queryParams),
      cacheKey: cacheKey,
      cacheDuration: const Duration(hours: 2),
    );
  }

  Future<ServiceItem?> getService({required int id}) async {
    return await network<ServiceItem>(
      request: (request) => request.get("/services/$id/"),
      cacheKey: "service_$id",
      cacheDuration: const Duration(hours: 1),
    );
  }

  Future<List<ServiceItem>?> getFeaturedServices() async {
    return await network<List<ServiceItem>>(
      request: (request) => request.get("/services/featured/"),
      cacheKey: "featured_services",
      cacheDuration: const Duration(minutes: 30),
    );
  }

  Future<List<ServiceItem>?> searchServices({
    required String query,
    int? categoryId,
  }) async {
    Map<String, dynamic> queryParams = {"q": query};
    if (categoryId != null) queryParams['category'] = categoryId;

    return await network<List<ServiceItem>>(
      request: (request) =>
          request.get("/services/search/", queryParameters: queryParams),
    );
  }

  Future<List<ServiceItem>?> getCategoryServices(
      {required int categoryId}) async {
    return await network<List<ServiceItem>>(
      request: (request) =>
          request.get("/services/categories/$categoryId/services/"),
      cacheKey: "category_${categoryId}_services",
      cacheDuration: const Duration(hours: 1),
    );
  }

  Future<List<AddOnService>?> getCategoryAddons(
      {required int categoryId}) async {
    return await network<List<AddOnService>>(
      request: (request) =>
          request.get("/services/categories/$categoryId/addons/"),
      cacheKey: "category_${categoryId}_addons",
      cacheDuration: const Duration(hours: 2),
    );
  }

  Future<List<dynamic>?> getServiceReviews({required int serviceId}) async {
    return await network(
      request: (request) => request.get("/services/$serviceId/reviews/"),
      cacheKey: "service_${serviceId}_reviews",
      cacheDuration: const Duration(minutes: 15),
    );
  }
}
