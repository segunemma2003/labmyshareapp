import 'package:flutter_app/app/networking/region_api_service.dart';
import 'package:flutter_app/app/models/region.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:flutter_app/config/keys.dart';

class RegionService {
  static final RegionApiService _api = RegionApiService();

  static Future<List<Region>?> getRegions() async {
    try {
      print('RegionService: Fetching regions...'); // Debug log
      final response = await _api.getRegions();
      print('RegionService: API response: $response'); // Debug log
      print(
          'RegionService: Response type: ${response.runtimeType}'); // Debug log

      if (response != null && response is List) {
        final regions = response
            .map((json) => Region.fromJson(json as Map<String, dynamic>))
            .toList();
        print('RegionService: Parsed ${regions.length} regions'); // Debug log
        return regions;
      }

      print(
          'RegionService: No regions returned from API or wrong format'); // Debug log
      return [];
    } catch (e) {
      print('RegionService.getRegions error: $e');
      print('RegionService.getRegions stack trace: ${StackTrace.current}');
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
      print('RegionService.getRegion error: $e');
      return null;
    }
  }

  /// Get the current region from storage
  static Future<Region?> getCurrentRegion() async {
    try {
      final regionCode = await NyStorage.read(Keys.currentRegion);
      if (regionCode != null) {
        return await getRegion(code: regionCode);
      }
      return null;
    } catch (e) {
      print('RegionService.getCurrentRegion error: $e');
      return null;
    }
  }

  /// Get the current region's currency symbol
  static Future<String> getCurrentCurrencySymbol() async {
    try {
      final region = await getCurrentRegion();
      return region?.currencySymbol ?? '£'; // Default to £ if no symbol found
    } catch (e) {
      print('RegionService.getCurrentCurrencySymbol error: $e');
      return '£'; // Default fallback
    }
  }

  /// Format a price with the current region's currency symbol
  static Future<String> formatPrice(dynamic price) async {
    try {
      final symbol = await getCurrentCurrencySymbol();
      final numericPrice = double.tryParse(price.toString()) ?? 0.0;
      return '$symbol${numericPrice.toStringAsFixed(0)}';
    } catch (e) {
      print('RegionService.formatPrice error: $e');
      return '£${price.toString()}'; // Default fallback
    }
  }
}
