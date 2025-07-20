class Region {
  final int? id;
  final String? code;
  final String? name;
  final String? description;
  final bool? isActive;
  final String? currency;
  final String? currencySymbol;
  final String? timezone;
  final String? createdAt;
  final String? updatedAt;

  Region({
    this.id,
    this.code,
    this.name,
    this.description,
    this.isActive,
    this.currency,
    this.currencySymbol,
    this.timezone,
    this.createdAt,
    this.updatedAt,
  });

  factory Region.fromJson(Map<String, dynamic> json) {
    try {
      return Region(
        id: json['id'],
        code: json['code']?.toString(),
        name: json['name']?.toString(),
        description: json['description']?.toString(),
        isActive: json['is_active'] ?? true,
        currency: json['currency']?.toString(),
        currencySymbol: json['currency_symbol']?.toString(),
        timezone: json['timezone']?.toString(),
        createdAt: json['created_at']?.toString(),
        updatedAt: json['updated_at']?.toString(),
      );
    } catch (e) {
      print('Region.fromJson error: $e');
      print('Problematic JSON: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'description': description,
      'is_active': isActive,
      'currency': currency,
      'currency_symbol': currencySymbol,
      'timezone': timezone,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
