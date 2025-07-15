import 'package:nylo_framework/nylo_framework.dart';

// Service Model (matches /services/ and /services/{id}/ responses)
class Service extends Model {
  final int id;
  final String name;
  final String? description;
  final String? basePrice;
  final double? regionalPrice;
  final double? promotionalPrice;
  final int? durationMinutes;
  final int? preparationTime;
  final int? cleanupTime;
  final String? categoryName;
  final ServiceCategory? category;
  final bool? isFeatured;
  final String? primaryImage;
  final int? sortOrder;
  final List<AddOn>? addons;
  final List<ServiceImage>? images;
  final ReviewSummary? reviewsSummary;
  final int? professionalsCount;
  final String? slug;

  static StorageKey key = "service";

  Service({
    required this.id,
    required this.name,
    this.description,
    this.basePrice,
    this.regionalPrice,
    this.promotionalPrice,
    this.durationMinutes,
    this.preparationTime,
    this.cleanupTime,
    this.categoryName,
    this.category,
    this.isFeatured,
    this.primaryImage,
    this.sortOrder,
    this.addons,
    this.images,
    this.reviewsSummary,
    this.professionalsCount,
    this.slug,
  }) : super(key: key);

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'],
      basePrice: json['base_price'],
      regionalPrice: (json['regional_price'] is String)
          ? double.tryParse(json['regional_price'])
          : (json['regional_price']?.toDouble()),
      promotionalPrice: (json['promotional_price'] is String)
          ? double.tryParse(json['promotional_price'])
          : (json['promotional_price']?.toDouble()),
      durationMinutes: json['duration_minutes'],
      preparationTime: json['preparation_time'],
      cleanupTime: json['cleanup_time'],
      categoryName: json['category_name'],
      category: json['category'] != null
          ? ServiceCategory.fromJson(json['category'])
          : null,
      isFeatured: json['is_featured'],
      primaryImage: json['primary_image'],
      sortOrder: json['sort_order'],
      addons: json['addons'] != null
          ? (json['addons'] as List).map((a) => AddOn.fromJson(a)).toList()
          : null,
      images: json['images'] != null
          ? (json['images'] as List)
              .map((i) => ServiceImage.fromJson(i))
              .toList()
          : null,
      reviewsSummary: json['reviews_summary'] != null
          ? ReviewSummary.fromJson(json['reviews_summary'])
          : null,
      professionalsCount: json['professionals_count'],
      slug: json['slug'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'base_price': basePrice,
      'regional_price': regionalPrice,
      'promotional_price': promotionalPrice,
      'duration_minutes': durationMinutes,
      'preparation_time': preparationTime,
      'cleanup_time': cleanupTime,
      'category_name': categoryName,
      'category': category?.toJson(),
      'is_featured': isFeatured,
      'primary_image': primaryImage,
      'sort_order': sortOrder,
      'addons': addons?.map((a) => a.toJson()).toList(),
      'images': images?.map((i) => i.toJson()).toList(),
      'reviews_summary': reviewsSummary?.toJson(),
      'professionals_count': professionalsCount,
      'slug': slug,
    };
  }
}

// AddOn Model (matches /services/{id}/addons/ and /services/categories/{category_id}/addons/)
class AddOn extends Model {
  final int id;
  final String name;
  final String? description;
  final String? price;
  final int? durationMinutes;
  final int? maxQuantity;

  AddOn({
    required this.id,
    required this.name,
    this.description,
    this.price,
    this.durationMinutes,
    this.maxQuantity,
  });

  factory AddOn.fromJson(Map<String, dynamic> json) {
    return AddOn(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'],
      price: json['price'],
      durationMinutes: json['duration_minutes'],
      maxQuantity: json['max_quantity'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'price': price,
        'duration_minutes': durationMinutes,
        'max_quantity': maxQuantity,
      };
}

// ServiceImage Model (matches /services/{id}/images/)
class ServiceImage extends Model {
  final int id;
  final String image;
  final String? altText;
  final bool? isPrimary;
  final int? sortOrder;

  ServiceImage({
    required this.id,
    required this.image,
    this.altText,
    this.isPrimary,
    this.sortOrder,
  });

  factory ServiceImage.fromJson(Map<String, dynamic> json) {
    return ServiceImage(
      id: json['id'],
      image: json['image'],
      altText: json['alt_text'],
      isPrimary: json['is_primary'],
      sortOrder: json['sort_order'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'image': image,
        'alt_text': altText,
        'is_primary': isPrimary,
        'sort_order': sortOrder,
      };
}

// ReviewSummary Model (matches /services/{id}/reviews_summary/)
class ReviewSummary extends Model {
  final double? averageRating;
  final int? totalReviews;
  final Map<String, int>? ratingDistribution;

  ReviewSummary({
    this.averageRating,
    this.totalReviews,
    this.ratingDistribution,
  });

  factory ReviewSummary.fromJson(Map<String, dynamic> json) {
    return ReviewSummary(
      averageRating: (json['average_rating'] is String)
          ? double.tryParse(json['average_rating'])
          : (json['average_rating']?.toDouble()),
      totalReviews: json['total_reviews'],
      ratingDistribution: json['rating_distribution'] != null
          ? Map<String, int>.from(json['rating_distribution'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'average_rating': averageRating,
        'total_reviews': totalReviews,
        'rating_distribution': ratingDistribution,
      };
}

// ServiceCategory Model (already present, ensure it matches nested structure)
class ServiceCategory extends Model {
  final int id;
  final String name;
  final String? description;
  final String? icon;
  final int? sortOrder;
  final int? servicesCount;
  final String? slug;

  static StorageKey key = "service_category";

  ServiceCategory({
    required this.id,
    required this.name,
    this.description,
    this.icon,
    this.sortOrder,
    this.servicesCount,
    this.slug,
  }) : super(key: key);

  factory ServiceCategory.fromJson(Map<String, dynamic> json) {
    return ServiceCategory(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
      icon: json['icon'],
      sortOrder: json['sort_order'],
      servicesCount: json['services_count'],
      slug: json['slug'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'sort_order': sortOrder,
      'services_count': servicesCount,
      'slug': slug,
    };
  }
}

// Helper function for list comparison
bool listEquals<T>(List<T>? a, List<T>? b) {
  if (a == null) return b == null;
  if (b == null || a.length != b.length) return false;
  if (identical(a, b)) return true;
  for (int index = 0; index < a.length; index += 1) {
    if (a[index] != b[index]) return false;
  }
  return true;
}
