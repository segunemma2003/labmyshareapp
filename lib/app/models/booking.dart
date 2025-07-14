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
    totalAmount = data['total_amount']?.toDouble();
    status = data['status'];
    paymentStatus = data['payment_status'];
    isUpcoming = data['is_upcoming'];
    canBeCancelled = data['can_be_cancelled'];
    createdAt = data['created_at'];
    customer = data['customer'];
    professional = data['professional'];
    service = data['service'];
    selectedAddons = data['selected_addons'];
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
