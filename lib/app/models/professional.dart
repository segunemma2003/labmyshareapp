import 'package:nylo_framework/nylo_framework.dart';

class Professional extends Model {
  static StorageKey key = "professional";

  String? name;
  String? subtitle;
  bool? isAnyProfessional;
  String? imageUrl;

  Professional() : super(key: key);

  Professional.fromJson(data) : super(key: key) {
    name = data['name'];
    subtitle = data['subtitle'];
    isAnyProfessional = data['isAnyProfessional'];
    imageUrl = data['imageUrl'];
  }

  @override
  toJson() {
    return {
      'name': name,
      'subtitle': subtitle,
      'isAnyProfessional': isAnyProfessional,
      'imageUrl': imageUrl,
    };
  }
}
