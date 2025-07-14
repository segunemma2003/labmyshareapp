import 'package:nylo_framework/nylo_framework.dart';

class User extends Model {
  String? id;
  String? uid;
  String? email;
  String? firstName;
  String? lastName;
  String? fullName;
  String? userType;
  Map<String, dynamic>? currentRegion;
  bool? isVerified;
  bool? profileCompleted;
  String? phoneNumber;
  String? dateOfBirth;
  String? gender;
  String? createdAt;

  static StorageKey key = 'user';

  User() : super(key: key);

  User.fromJson(dynamic data) : super(key: key) {
    id = data['id']?.toString();
    uid = data['uid'];
    email = data['email'];
    firstName = data['first_name'];
    lastName = data['last_name'];
    fullName = data['full_name'];
    userType = data['user_type'];
    currentRegion = data['current_region'];
    isVerified = data['is_verified'];
    profileCompleted = data['profile_completed'];
    phoneNumber = data['phone_number'];
    dateOfBirth = data['date_of_birth'];
    gender = data['gender'];
    createdAt = data['created_at'];
  }

  @override
  toJson() => {
        "id": id,
        "uid": uid,
        "email": email,
        "first_name": firstName,
        "last_name": lastName,
        "full_name": fullName,
        "user_type": userType,
        "current_region": currentRegion,
        "is_verified": isVerified,
        "profile_completed": profileCompleted,
        "phone_number": phoneNumber,
        "date_of_birth": dateOfBirth,
        "gender": gender,
        "created_at": createdAt,
      };

  String get name => fullName ?? "$firstName $lastName";
}
