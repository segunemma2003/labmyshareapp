import 'package:nylo_framework/nylo_framework.dart';

class Booking extends Model {
  static StorageKey key = "booking";

  String? bookingId;
  String? customerName;
  String? professionalName;
  String? serviceName;
  String? regionName;
  String? scheduledDate;
  String? scheduledTime;
  int? durationMinutes;
  double? totalAmount;
  String? status;
  String? paymentStatus;
  bool? isUpcoming;
  bool? canBeCancelled;
  String? createdAt;
  Map<String, dynamic>? customer;
  Map<String, dynamic>? professional;
  Map<String, dynamic>? service;
  String? addressLine1;
  String? addressLine2;
  String? city;
  String? postalCode;
  String? locationNotes;
  double? baseAmount;
  double? addonAmount;
  double? discountAmount;
  double? taxAmount;
  double? depositAmount;
  double? depositPercentage;
  bool? depositRequired;
  String? customerNotes;
  String? professionalNotes;
  String? confirmedAt;
  List<dynamic>? selectedAddons;

  Booking() : super(key: key);

  Booking.fromJson(data) : super(key: key) {
    bookingId = data['booking_id'];
    customerName = data['customer_name'];
    professionalName = data['professional_name'];
    serviceName = data['service_name'];
    regionName = data['region_name'];
    scheduledDate = data['scheduled_date'];
    scheduledTime = data['scheduled_time'];
    durationMinutes = data['duration_minutes'];
    totalAmount = _toDouble(data['total_amount']);
    status = data['status'];
    paymentStatus = data['payment_status'];
    isUpcoming = data['is_upcoming'];
    canBeCancelled = data['can_be_cancelled'];
    createdAt = data['created_at'];
    customer = data['customer'];
    professional = data['professional'];
    service = data['service'];
    addressLine1 = data['address_line1'];
    addressLine2 = data['address_line2'];
    city = data['city'];
    postalCode = data['postal_code'];
    locationNotes = data['location_notes'];
    baseAmount = _toDouble(data['base_amount']);
    addonAmount = _toDouble(data['addon_amount']);
    discountAmount = _toDouble(data['discount_amount']);
    taxAmount = _toDouble(data['tax_amount']);
    depositAmount = _toDouble(data['deposit_amount']);
    depositPercentage = _toDouble(data['deposit_percentage']);
    depositRequired = data['deposit_required'];
    customerNotes = data['customer_notes'];
    professionalNotes = data['professional_notes'];
    confirmedAt = data['confirmed_at'];
    selectedAddons = data['selected_addons'];
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  @override
  toJson() {
    return {
      'booking_id': bookingId,
      'customer_name': customerName,
      'professional_name': professionalName,
      'service_name': serviceName,
      'region_name': regionName,
      'scheduled_date': scheduledDate,
      'scheduled_time': scheduledTime,
      'duration_minutes': durationMinutes,
      'total_amount': totalAmount,
      'status': status,
      'payment_status': paymentStatus,
      'is_upcoming': isUpcoming,
      'can_be_cancelled': canBeCancelled,
      'created_at': createdAt,
      'customer': customer,
      'professional': professional,
      'service': service,
      'address_line1': addressLine1,
      'address_line2': addressLine2,
      'city': city,
      'postal_code': postalCode,
      'location_notes': locationNotes,
      'base_amount': baseAmount,
      'addon_amount': addonAmount,
      'discount_amount': discountAmount,
      'tax_amount': taxAmount,
      'deposit_amount': depositAmount,
      'deposit_percentage': depositPercentage,
      'deposit_required': depositRequired,
      'customer_notes': customerNotes,
      'professional_notes': professionalNotes,
      'confirmed_at': confirmedAt,
      'selected_addons': selectedAddons,
    };
  }

  bool get isPending => status == 'pending';
  bool get isConfirmed => status == 'confirmed';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';

  bool get isFullyPaid => paymentStatus == 'fully_paid';
  bool get isDepositPaid => paymentStatus == 'deposit_paid';
  bool get isPaymentPending => paymentStatus == 'pending';
}
