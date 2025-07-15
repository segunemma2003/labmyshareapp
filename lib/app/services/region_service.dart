import 'package:flutter_app/app/networking/region_api_service.dart';
import 'package:flutter_app/app/models/region.dart';

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
}
