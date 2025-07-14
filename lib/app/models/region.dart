import 'package:nylo_framework/nylo_framework.dart';

class Region extends Model {
  static StorageKey key = "region";

  int? id;
  String? code;
  String? name;
  String? currency;
  String? currencySymbol;
  String? timezone;
  String? countryCode;
  String? businessStartTime;
  String? businessEndTime;
  String? supportEmail;
  String? supportPhone;
  bool? isActive;

  Region() : super(key: key);

  Region.fromJson(data) : super(key: key) {
    id = data['id'];
    code = data['code'];
    name = data['name'];
    currency = data['currency'];
    currencySymbol = data['currency_symbol'];
    timezone = data['timezone'];
    countryCode = data['country_code'];
    businessStartTime = data['business_start_time'];
    businessEndTime = data['business_end_time'];
    supportEmail = data['support_email'];
    supportPhone = data['support_phone'];
    isActive = data['is_active'];
  }

  @override
  toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'currency': currency,
      'currency_symbol': currencySymbol,
      'timezone': timezone,
      'country_code': countryCode,
      'business_start_time': businessStartTime,
      'business_end_time': businessEndTime,
      'support_email': supportEmail,
      'support_phone': supportPhone,
      'is_active': isActive,
    };
  }
}
