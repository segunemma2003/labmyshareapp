import 'package:flutter/material.dart';
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

  Future<List<dynamic>?> getServiceCategories({bool? isFeatured}) async {
    Map<String, dynamic> queryParams = {};
    if (isFeatured != null) queryParams['is_featured'] = isFeatured;

    final response = await network(
      request: (request) =>
          request.get("/services/categories/", queryParameters: queryParams),
      cacheKey: "service_categories${isFeatured != null ? '_featured' : ''}",
      cacheDuration: const Duration(hours: 6),
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

  Future<List<Service>?> getServices({
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

    String cacheKey = "services_ {queryParams.hashCode}";

    return await network<List<Service>>(
      request: (request) =>
          request.get("/services/", queryParameters: queryParams),
      cacheKey: cacheKey,
      cacheDuration: const Duration(hours: 2),
    );
  }

  Future<Service?> getService({required int id}) async {
    return await network<Service>(
      request: (request) => request.get("/services/$id/"),
      cacheKey: "service_$id",
      cacheDuration: const Duration(hours: 1),
    );
  }

  Future<List<Service>?> getFeaturedServices() async {
    return await network<List<Service>>(
      request: (request) => request.get("/services/featured/"),
      cacheKey: "featured_services",
      cacheDuration: const Duration(minutes: 30),
    );
  }

  Future<List<dynamic>?> getFeaturedCategories() async {
    final response = await network(
      request: (request) => request.get("/services/categories/featured/"),
      cacheKey: "featured_categories",
      cacheDuration: const Duration(hours: 1),
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

  Future<List<Service>?> searchServices({
    required String query,
    int? categoryId,
  }) async {
    Map<String, dynamic> queryParams = {"q": query};
    if (categoryId != null) queryParams['category'] = categoryId;

    return await network<List<Service>>(
      request: (request) =>
          request.get("/services/search/", queryParameters: queryParams),
    );
  }

  Future<List<Service>?> getCategoryServices({required int categoryId}) async {
    final response = await network(
      request: (request) =>
          request.get("/services/categories/$categoryId/services/"),
      cacheKey: "category_${categoryId}_services",
      cacheDuration: const Duration(hours: 1),
    );

    // Handle Django REST framework response structure
    if (response is Map<String, dynamic> && response.containsKey('results')) {
      return (response['results'] as List)
          .map((item) => Service.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    // If it's already a list, return as is
    if (response is List) {
      return response
          .map((item) => Service.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    // Fallback
    return null;
  }

  Future<List<AddOn>?> getCategoryAddons({
    required int categoryId,
    int? page,
    int? pageSize,
  }) async {
    Map<String, dynamic> queryParams = {};
    if (page != null) queryParams['page'] = page;
    if (pageSize != null) queryParams['page_size'] = pageSize;

    final response = await network(
      request: (request) => request.get(
          "/services/categories/$categoryId/addons/",
          queryParameters: queryParams),
      cacheKey:
          "category_${categoryId}_addons_page_${page ?? 1}_size_${pageSize ?? 10}",
      cacheDuration: const Duration(hours: 2),
    );

    // Handle Django REST framework response structure
    if (response is Map<String, dynamic> && response.containsKey('results')) {
      return (response['results'] as List)
          .map((item) => AddOn.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    // If it's already a list, return as is
    if (response is List) {
      return response
          .map((item) => AddOn.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    // Fallback
    return null;
  }

  Future<List<dynamic>?> getServiceReviews({required int serviceId}) async {
    return await network(
      request: (request) => request.get("/services/$serviceId/reviews/"),
      cacheKey: "service_${serviceId}_reviews",
      cacheDuration: const Duration(minutes: 15),
    );
  }

  Future<void> clearCache() async {
    // Remove all region-dependent caches (services, add-ons, etc.)
    final keys = [
      'service_categories',
      'featured_services',
    ];
    // Remove known keys
    for (String key in keys) {
      await NyStorage.delete(key);
    }
    // Remove dynamic category/services keys
    // This will clear all keys that start with 'category_' or 'services_'
    await NyStorage.clear('category_');
    await NyStorage.clear('services_');
  }
}
