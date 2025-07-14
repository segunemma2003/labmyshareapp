import 'package:nylo_framework/nylo_framework.dart';

enum AddOnType {
  optional,
  recommended,
}

class AddOnService extends Model {
  final String title;
  final String duration;
  final double price;
  final String? priceType;
  final AddOnType type;

  static StorageKey key = "add_on_service";

  AddOnService({
    required this.title,
    required this.duration,
    required this.price,
    this.priceType,
    required this.type,
  }) : super(key: key);

  AddOnService.fromJson(Map<String, dynamic> data)
      : title = data['title'] ?? '',
        duration = data['duration'] ?? '',
        price = (data['price'] ?? 0).toDouble(),
        priceType = data['priceType'],
        type = AddOnType.values.firstWhere(
          (e) => e.toString() == 'AddOnType.${data['type']}',
          orElse: () => AddOnType.optional,
        ),
        super(key: key);

  @override
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'duration': duration,
      'price': price,
      'priceType': priceType,
      'type': type.toString().split('.').last,
    };
  }

  // Helper methods
  String get formattedPrice {
    return "${priceType ?? 'From'} £${price.toInt()}";
  }

  bool get isRecommended {
    return type == AddOnType.recommended;
  }

  // Create a copy with modifications
  AddOnService copyWith({
    String? title,
    String? duration,
    double? price,
    String? priceType,
    AddOnType? type,
  }) {
    return AddOnService(
      title: title ?? this.title,
      duration: duration ?? this.duration,
      price: price ?? this.price,
      priceType: priceType ?? this.priceType,
      type: type ?? this.type,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AddOnService &&
        other.title == title &&
        other.duration == duration &&
        other.price == price &&
        other.priceType == priceType &&
        other.type == type;
  }

  @override
  int get hashCode {
    return title.hashCode ^
        duration.hashCode ^
        price.hashCode ^
        priceType.hashCode ^
        type.hashCode;
  }
}
