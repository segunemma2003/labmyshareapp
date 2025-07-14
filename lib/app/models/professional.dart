import 'package:nylo_framework/nylo_framework.dart';

class Professional extends Model {
  static StorageKey key = "professional";

  int? id;
  Map<String, dynamic>? user;
  String? bio;
  int? experienceYears;
  String? rating;
  int? totalReviews;
  bool? isVerified;
  int? servicesCount;
  List<dynamic>? regionsServed;
  int? travelRadiusKm;
  int? minBookingNoticeHours;
  String? cancellationPolicy;
  List<dynamic>? services;
  List<dynamic>? availability;
  Map<String, dynamic>? reviewsSummary;
  bool? profileCompleted;
  String? createdAt;

  // Legacy fields for backward compatibility
  String? name;
  String? subtitle;
  bool? isAnyProfessional;
  String? imageUrl;

  Professional() : super(key: key);

  Professional.fromJson(data) : super(key: key) {
    id = data['id'];
    user = data['user'];
    bio = data['bio'];
    experienceYears = data['experience_years'];
    rating = data['rating'];
    totalReviews = data['total_reviews'];
    isVerified = data['is_verified'];
    servicesCount = data['services_count'];
    regionsServed = data['regions_served'];
    travelRadiusKm = data['travel_radius_km'];
    minBookingNoticeHours = data['min_booking_notice_hours'];
    cancellationPolicy = data['cancellation_policy'];
    services = data['services'];
    availability = data['availability'];
    reviewsSummary = data['reviews_summary'];
    profileCompleted = data['profile_completed'];
    createdAt = data['created_at'];

    // Legacy compatibility
    name = data['name'] ??
        (user != null ? "${user!['first_name']} ${user!['last_name']}" : null);
    subtitle = data['subtitle'] ?? bio;
    isAnyProfessional = data['isAnyProfessional'];
    imageUrl = data['imageUrl'];
  }

  @override
  toJson() {
    return {
      'id': id,
      'user': user,
      'bio': bio,
      'experience_years': experienceYears,
      'rating': rating,
      'total_reviews': totalReviews,
      'is_verified': isVerified,
      'services_count': servicesCount,
      'regions_served': regionsServed,
      'travel_radius_km': travelRadiusKm,
      'min_booking_notice_hours': minBookingNoticeHours,
      'cancellation_policy': cancellationPolicy,
      'services': services,
      'availability': availability,
      'reviews_summary': reviewsSummary,
      'profile_completed': profileCompleted,
      'created_at': createdAt,
      // Legacy fields
      'name': name,
      'subtitle': subtitle,
      'isAnyProfessional': isAnyProfessional,
      'imageUrl': imageUrl,
    };
  }

  String get displayName =>
      name ??
      (user != null
          ? "${user!['first_name']} ${user!['last_name']}"
          : "Unknown");
  double get ratingDouble => double.tryParse(rating ?? '0') ?? 0.0;
}
