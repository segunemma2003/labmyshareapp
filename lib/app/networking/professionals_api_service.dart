import 'package:flutter/material.dart';
import 'package:flutter_app/app/models/professional.dart';
import 'package:flutter_app/app/networking/dio/interceptors/lab_my_share_auth_interceptor.dart';
import 'package:flutter_app/app/networking/dio/interceptors/region_interceptor.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '/config/decoders.dart';
import 'package:nylo_framework/nylo_framework.dart';

class ProfessionalsApiService extends NyApiService {
  ProfessionalsApiService({BuildContext? buildContext})
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

  Future<List<Professional>?> getProfessionals({
    int? serviceId,
    double? minRating,
    bool? verifiedOnly,
    int? regionId,
    String? search,
    String? ordering,
  }) async {
    Map<String, dynamic> queryParams = {};
    if (serviceId != null) queryParams['service'] = serviceId;
    if (minRating != null) queryParams['min_rating'] = minRating;
    if (verifiedOnly != null) queryParams['verified_only'] = verifiedOnly;
    if (regionId != null) queryParams['region'] = regionId;
    if (search != null) queryParams['search'] = search;
    if (ordering != null) queryParams['ordering'] = ordering;

    String cacheKey = "professionals_${queryParams.hashCode}";

    return await network<List<Professional>>(
      request: (request) =>
          request.get("/professionals/", queryParameters: queryParams),
      cacheKey: cacheKey,
      cacheDuration: const Duration(minutes: 30),
    );
  }

  Future<Professional?> getProfessional({required int id}) async {
    return await network<Professional>(
      request: (request) => request.get("/professionals/$id/"),
      cacheKey: "professional_$id",
      cacheDuration: const Duration(minutes: 30),
    );
  }

  Future<List<Professional>?> searchProfessionals({
    int? serviceId,
    String? date,
    String? time,
    double? minRating,
    double? maxPrice,
    bool? verifiedOnly,
  }) async {
    Map<String, dynamic> queryParams = {};
    if (serviceId != null) queryParams['service_id'] = serviceId;
    if (date != null) queryParams['date'] = date;
    if (time != null) queryParams['time'] = time;
    if (minRating != null) queryParams['min_rating'] = minRating;
    if (maxPrice != null) queryParams['max_price'] = maxPrice;
    if (verifiedOnly != null) queryParams['verified_only'] = verifiedOnly;

    return await network<List<Professional>>(
      request: (request) =>
          request.get("/professionals/search/", queryParameters: queryParams),
    );
  }

  Future<List<Professional>?> getTopRatedProfessionals() async {
    return await network<List<Professional>>(
      request: (request) => request.get("/professionals/top-rated/"),
      cacheKey: "top_rated_professionals",
      cacheDuration: const Duration(hours: 1),
    );
  }

  Future<List<dynamic>?> getAvailableSlots({
    required int professionalId,
    required int serviceId,
    required String date,
  }) async {
    return await network(
      request: (request) =>
          request.get("/professionals/available-slots/", queryParameters: {
        "professional_id": professionalId,
        "service_id": serviceId,
        "date": date,
      }),
      cacheKey: "slots_${professionalId}_${serviceId}_$date",
      cacheDuration: const Duration(minutes: 5), // Short cache for availability
    );
  }
}
