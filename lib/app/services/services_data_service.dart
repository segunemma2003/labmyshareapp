import 'package:flutter_app/app/networking/services_api_service.dart';
import 'package:nylo_framework/nylo_framework.dart';
import '/app/networking/api_service.dart';
import '/app/models/service_item.dart';
import '/app/models/service_item.dart' show ServiceCategory, AddOn;

class ServicesDataService {
  static final ServicesApiService _api = ServicesApiService();

  static Future<List<ServiceCategory>> getServiceCategories(
      {bool? isFeatured}) async {
    try {
      final response = await _api.getServiceCategories(isFeatured: isFeatured);
      if (response != null) {
        return response
            .map((item) =>
                ServiceCategory.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      print('Get service categories error: $e');
      return [];
    }
  }

  static Future<List<ServiceCategory>> getFeaturedCategories() async {
    try {
      final response = await _api.getFeaturedCategories();
      if (response != null) {
        return response
            .map((item) =>
                ServiceCategory.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      print('Get featured categories error: $e');
      return [];
    }
  }

  static Future<List<Service>?> getServices({
    int? categoryId,
    bool? isFeatured,
    String? search,
    String? ordering,
  }) async {
    try {
      return await _api.getServices(
        categoryId: categoryId,
        isFeatured: isFeatured,
        search: search,
        ordering: ordering,
      );
    } catch (e) {
      print('Get services error: $e');
      return null;
    }
  }

  static Future<Service?> getService({required int id}) async {
    try {
      return await _api.getService(id: id);
    } catch (e) {
      print('Get service error: $e');
      return null;
    }
  }

  static Future<List<Service>?> getFeaturedServices() async {
    try {
      return await _api.getFeaturedServices();
    } catch (e) {
      print('Get featured services error: $e');
      return null;
    }
  }

  static Future<List<Service>?> searchServices({
    required String query,
    int? categoryId,
  }) async {
    try {
      return await _api.searchServices(query: query, categoryId: categoryId);
    } catch (e) {
      print('Search services error: $e');
      return null;
    }
  }

  static Future<List<Service>?> getCategoryServices(
      {required int categoryId}) async {
    try {
      return await _api.getCategoryServices(categoryId: categoryId);
    } catch (e) {
      print('Get category services error: $e');
      return null;
    }
  }

  static Future<List<AddOn>?> getCategoryAddons({
    required int categoryId,
    int? page,
    int? pageSize,
  }) async {
    try {
      return await _api.getCategoryAddons(
        categoryId: categoryId,
        page: page,
        pageSize: pageSize,
      );
    } catch (e) {
      print('Get category addons error: $e');
      return null;
    }
  }

  static Future<List<dynamic>?> getServiceReviews(
      {required int serviceId}) async {
    try {
      return await _api.getServiceReviews(serviceId: serviceId);
    } catch (e) {
      print('Get service reviews error: $e');
      return null;
    }
  }
}
