import 'package:flutter_app/app/networking/services_api_service.dart';
import 'package:nylo_framework/nylo_framework.dart';
import '/app/networking/api_service.dart';
import '/app/models/service_item.dart';
import '/app/models/add_on_service.dart';

class ServicesDataService {
  static final ServicesApiService _api = ServicesApiService();

  static Future<List<dynamic>?> getServiceCategories() async {
    try {
      return await _api.getServiceCategories();
    } catch (e) {
      print('Get service categories error: $e');
      return null;
    }
  }

  static Future<List<ServiceItem>?> getServices({
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

  static Future<ServiceItem?> getService({required int id}) async {
    try {
      return await _api.getService(id: id);
    } catch (e) {
      print('Get service error: $e');
      return null;
    }
  }

  static Future<List<ServiceItem>?> getFeaturedServices() async {
    try {
      return await _api.getFeaturedServices();
    } catch (e) {
      print('Get featured services error: $e');
      return null;
    }
  }

  static Future<List<ServiceItem>?> searchServices({
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

  static Future<List<ServiceItem>?> getCategoryServices(
      {required int categoryId}) async {
    try {
      return await _api.getCategoryServices(categoryId: categoryId);
    } catch (e) {
      print('Get category services error: $e');
      return null;
    }
  }

  static Future<List<AddOnService>?> getCategoryAddons(
      {required int categoryId}) async {
    try {
      return await _api.getCategoryAddons(categoryId: categoryId);
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
