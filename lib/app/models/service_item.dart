import 'package:nylo_framework/nylo_framework.dart';

class ServiceItem extends Model {
  final String title;
  final String duration;
  final double price;
  final List<String>? instructions;

  static StorageKey key = "service_item";

  ServiceItem({
    required this.title,
    required this.duration,
    required this.price,
    this.instructions,
  }) : super(key: key);

  ServiceItem.fromJson(Map<String, dynamic> data)
      : title = data['title'] ?? '',
        duration = data['duration'] ?? '',
        price = (data['price'] ?? 0).toDouble(),
        instructions = data['instructions'] != null
            ? List<String>.from(data['instructions'])
            : null,
        super(key: key);

  @override
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'duration': duration,
      'price': price,
      'instructions': instructions,
    };
  }

  // Helper methods
  String get formattedPrice {
    return "From £${price.toInt()}";
  }

  String get formattedDuration {
    return duration;
  }

  bool get hasInstructions {
    return instructions != null && instructions!.isNotEmpty;
  }

  // Create a copy with modifications
  ServiceItem copyWith({
    String? title,
    String? duration,
    double? price,
    List<String>? instructions,
  }) {
    return ServiceItem(
      title: title ?? this.title,
      duration: duration ?? this.duration,
      price: price ?? this.price,
      instructions: instructions ?? this.instructions,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ServiceItem &&
        other.title == title &&
        other.duration == duration &&
        other.price == price &&
        listEquals(other.instructions, instructions);
  }

  @override
  int get hashCode {
    return title.hashCode ^
        duration.hashCode ^
        price.hashCode ^
        instructions.hashCode;
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
