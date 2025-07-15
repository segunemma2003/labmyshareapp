import 'package:flutter_app/app/models/region.dart';

class User {
  final int? id;
  final String? uid;
  final String? email;
  final String? firstName;
  final String? lastName;
  final String? fullName;
  final String? phoneNumber;
  final String? profilePicture;
  final String? dateOfBirth;
  final String? gender;
  final String? userType;
  final Region? currentRegion;
  final bool? profileCompleted;
  final bool? isVerified;
  final String? createdAt;

  User({
    this.id,
    this.uid,
    this.email,
    this.firstName,
    this.lastName,
    this.fullName,
    this.phoneNumber,
    this.profilePicture,
    this.dateOfBirth,
    this.gender,
    this.userType,
    this.currentRegion,
    this.profileCompleted,
    this.isVerified,
    this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    try {
      return User(
        id: json['id'],
        uid: json['uid']?.toString(),
        email: json['email']?.toString(),
        firstName: json['first_name']?.toString(),
        lastName: json['last_name']?.toString(),
        fullName: json['full_name']?.toString(),
        phoneNumber: json['phone_number']?.toString(),
        profilePicture: json['profile_picture']?.toString(),
        dateOfBirth: json['date_of_birth']?.toString(),
        gender: (json['gender']?.toString().isEmpty ?? true)
            ? null
            : json['gender'].toString(),
        userType: json['user_type']?.toString(),
        currentRegion: json['current_region'] != null
            ? Region.fromJson(json['current_region'])
            : null,
        profileCompleted: json['profile_completed'] ?? false,
        isVerified: json['is_verified'] ?? false,
        createdAt: json['created_at']?.toString(),
      );
    } catch (e) {
      print('User.fromJson error: $e');
      print('Problematic JSON: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uid': uid,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'full_name': fullName,
      'phone_number': phoneNumber,
      'profile_picture': profilePicture,
      'date_of_birth': dateOfBirth,
      'gender': gender,
      'user_type': userType,
      'current_region': currentRegion?.toJson(),
      'profile_completed': profileCompleted,
      'is_verified': isVerified,
      'created_at': createdAt,
    };
  }
}
