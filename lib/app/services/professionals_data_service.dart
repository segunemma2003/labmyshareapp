import 'package:flutter_app/app/networking/professionals_api_service.dart';
import '/app/models/professional.dart';

class ProfessionalsDataService {
  static final ProfessionalsApiService _api = ProfessionalsApiService();

  static Future<List<Professional>?> getProfessionals({
    int? serviceId,
    double? minRating,
    bool? verifiedOnly,
    int? regionId,
    String? search,
    String? ordering,
  }) async {
    try {
      return await _api.getProfessionals(
        serviceId: serviceId,
        minRating: minRating,
        verifiedOnly: verifiedOnly,
        regionId: regionId,
        search: search,
        ordering: ordering,
      );
    } catch (e) {
      print('Get professionals error: $e');
      return null;
    }
  }

  static Future<Professional?> getProfessional({required int id}) async {
    try {
      return await _api.getProfessional(id: id);
    } catch (e) {
      print('Get professional error: $e');
      return null;
    }
  }

  static Future<List<Professional>?> searchProfessionals({
    int? serviceId,
    String? date,
    String? time,
    double? minRating,
    double? maxPrice,
    bool? verifiedOnly,
  }) async {
    try {
      return await _api.searchProfessionals(
        serviceId: serviceId,
        date: date,
        time: time,
        minRating: minRating,
        maxPrice: maxPrice,
        verifiedOnly: verifiedOnly,
      );
    } catch (e) {
      print('Search professionals error: $e');
      return null;
    }
  }

  static Future<List<Professional>?> getTopRatedProfessionals() async {
    try {
      return await _api.getTopRatedProfessionals();
    } catch (e) {
      print('Get top rated professionals error: $e');
      return null;
    }
  }

  static Future<List<dynamic>?> getAvailableSlots({
    required int professionalId,
    required int serviceId,
    String? date,
    String? startDate,
    String? endDate,
    int? regionId,
  }) async {
    try {
      return await _api.getAvailableSlots(
        professionalId: professionalId,
        serviceId: serviceId,
        date: date,
        startDate: startDate,
        endDate: endDate,
        regionId: regionId,
      );
    } catch (e) {
      print('Get available slots error: $e');
      return null;
    }
  }

  static Future<List<dynamic>?> getUnavailability({
    required int professionalId,
    int? serviceId,
    String? date,
    String? startDate,
    String? endDate,
    int? regionId,
  }) async {
    try {
      return await _api.getUnavailability(
        professionalId: professionalId,
        serviceId: serviceId,
        date: date,
        startDate: startDate,
        endDate: endDate,
        regionId: regionId,
      );
    } catch (e) {
      print('Get unavailability error: $e');
      return null;
    }
  }
}
