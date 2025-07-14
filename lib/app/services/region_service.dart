import 'package:flutter_app/app/networking/notification_api_service.dart';
import 'package:flutter_app/app/networking/region_api_service.dart';
import 'package:nylo_framework/nylo_framework.dart';
import '/app/networking/api_service.dart';
import '/app/models/region.dart';
import '/config/keys.dart';

class RegionService {
  static final RegionApiService _api = RegionApiService();
  static final NotificationApiService _notificationApi =
      NotificationApiService();

  static Future<List<Region>?> getRegions() async {
    try {
      final response = await _api.getRegions();
      if (response != null) {
        // The API returns a list directly, not wrapped in a 'results' key
        return (response as List).map((data) => Region.fromJson(data)).toList();
      }
      return null;
    } catch (e) {
      print('Get regions error: $e');
      return null;
    }
  }

  static Future<Region?> getRegion({required String code}) async {
    try {
      final response = await _api.getRegion(code: code);
      if (response != null) {
        return Region.fromJson(response);
      }
      return null;
    } catch (e) {
      print('Get region error: $e');
      return null;
    }
  }

  static Future<String?> getCurrentRegionCode() async {
    return await Keys.currentRegion.read();
  }

  static Future<Region?> getCurrentRegion() async {
    final regionCode = await getCurrentRegionCode();
    if (regionCode != null) {
      return await getRegion(code: regionCode);
    }
    return null;
  }

  static Future<bool> setCurrentRegion(String regionCode) async {
    try {
      await Keys.currentRegion.save(regionCode);
      // Clear region-specific caches
      await _notificationApi.clearServiceCache();
      await _notificationApi.clearProfessionalsCache();
      return true;
    } catch (e) {
      print('Set current region error: $e');
      return false;
    }
  }
}
