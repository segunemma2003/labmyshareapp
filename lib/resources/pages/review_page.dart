import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:intl/intl.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_app/app/services/booking_service.dart';
import 'dart:convert';

class ReviewPage extends NyStatefulWidget {
  static RouteView path = ("/review", (_) => ReviewPage());

  ReviewPage({super.key}) : super(child: () => _ReviewPageState());
}

class _ReviewPageState extends NyPage<ReviewPage> {
  final TextEditingController _noteController = TextEditingController();
  String selectedPaymentOption = "deposit"; // "full" or "deposit"
  bool showSuccessPage = false;

  // Remove dummy data, use real booking data
  List<dynamic> services = [];
  Map<int, List<dynamic>> serviceAddOns = {};
  dynamic selectedProfessional;
  DateTime? selectedDate;
  String? selectedTime;
  double totalPrice = 0;
  String durationText = '';

  Map<String, String?> _friendDetails = {};

  @override
  get init => () async {
        final data = widget.data() ?? {};
        services = data['selectedServices'] ?? [];
        serviceAddOns =
            Map<int, List<dynamic>>.from(data['serviceAddOns'] ?? {});
        selectedProfessional = data['selectedProfessional'];
        selectedDate = data['selectedDate'];
        selectedTime = data['selectedTime'];
        totalPrice = (data['totalPrice'] ?? 0).toDouble();
        durationText = data['durationText'] ?? '';
        setState(() {});
      };

  int get depositAmount => (totalPrice * 0.5).roundToDouble().toInt();
  int get balanceAmount => totalPrice.toInt() - depositAmount;

  void _showPaymentModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildPaymentModal(),
    );
  }

  void _confirmBooking() {
    Navigator.pop(context); // Close payment modal
    setState(() {
      showSuccessPage = true;
    });
  }

  Widget _buildPaymentModal() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: StatefulBuilder(
        builder: (context, setModalState) => Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Confirm payment",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const SizedBox(height: 24),

                    // Payment options
                    _buildPaymentOption(
                      context: context,
                      setModalState: setModalState,
                      title: "Make full payment",
                      subtitle: "Balance £0 at the venue",
                      amount: totalPrice.toInt(),
                      value: "full",
                      isSelected: selectedPaymentOption == "full",
                    ),

                    const SizedBox(height: 16),

                    _buildPaymentOption(
                      context: context,
                      setModalState: setModalState,
                      title: "Make 50% deposit",
                      subtitle: "Balance £$balanceAmount at the venue",
                      amount: depositAmount,
                      value: "deposit",
                      isSelected: selectedPaymentOption == "deposit",
                    ),

                    const SizedBox(height: 32),

                    // Confirm button
                    Container(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: isLocked('booking')
                            ? null
                            : () => _handleBookingAndPayment(setModalState),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: isLocked('booking')
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                "Confirm Booking",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Deposit policy
                    Container(
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Deposit policy",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Labs by Shea requires 50% deposit to be paid upfront",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "Additional terms and conditions",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Deposits are non-refundable, you can reschedule your appointment and your deposit will be transferred over to your future booking. If you are unable to reschedule, please contact us at least 48 hours before your appointment.",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption({
    required BuildContext context,
    required StateSetter setModalState,
    required String title,
    required String subtitle,
    required int amount,
    required String value,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        setModalState(() {
          selectedPaymentOption = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.black : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: isSelected ? Colors.brown.shade600 : Colors.transparent,
                border: Border.all(
                  color:
                      isSelected ? Colors.brown.shade600 : Colors.grey.shade400,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              "£$amount",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessPage() {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          "Review and confirm",
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close, color: Colors.black),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Success icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.calendar_today,
                  size: 60,
                  color: Colors.green.shade600,
                ),
              ),

              const SizedBox(height: 40),

              // Success message
              const Text(
                "You have successfully booked an appointment.",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 60),

              // Go to appointment button
              Container(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: () {
                    // Navigate to appointment details or calendar
                    Navigator.of(context).pop();
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.black),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Go to appointment",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate() {
    if (selectedDate == null) return '';
    return DateFormat('EEEE, d MMMM, yyyy').format(selectedDate!);
  }

  String _formatTime() {
    if (selectedTime == null) return '';
    return selectedTime!;
  }

  // Helper to ensure time is in hh:mm format
  String _formatScheduledTime(String? time) {
    if (time == null) return '';
    // If already in hh:mm or hh:mm:ss, return hh:mm part
    final timeRegExp =
        RegExp(r'^(\d{2}):(\d{2})(?::\d{2})?(?:\s*[APMapm]{2})?');
    if (timeRegExp.hasMatch(time)) {
      // If it's like 14:30 or 14:30:00, return first 5 chars
      return time.substring(0, 5);
    }
    // Try parsing as 2:30 PM etc.
    try {
      final dt = DateFormat.jm().parse(time);
      return DateFormat('HH:mm').format(dt);
    } catch (_) {
      // Fallback: return as is
      return time;
    }
  }

  void _showBookForFriendSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final nameController =
            TextEditingController(text: _friendDetails['name'] ?? '');
        final phoneController =
            TextEditingController(text: _friendDetails['phone'] ?? '');
        final emailController =
            TextEditingController(text: _friendDetails['email'] ?? '');
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    'Book for a friend',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 24),
                Text('Who is booking it?',
                    style: TextStyle(fontWeight: FontWeight.w500)),
                SizedBox(height: 8),
                TextField(
                  enabled: false,
                  decoration: InputDecoration(
                    labelText: 'Name*',
                    hintText: 'Your name',
                    border: OutlineInputBorder(),
                  ),
                  controller: TextEditingController(
                      text: 'Cassandra'), // Replace with actual user name
                ),
                SizedBox(height: 24),
                Divider(),
                SizedBox(height: 16),
                Text('Who are you booking for?',
                    style: TextStyle(fontWeight: FontWeight.w500)),
                SizedBox(height: 8),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Name*',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: phoneController,
                  decoration: InputDecoration(
                    labelText: 'Phone number*',
                    prefixText: '+44  ',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    hintText: 'example@email.com',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _friendDetails = {
                          'name': nameController.text,
                          'phone': phoneController.text,
                          'email': emailController.text,
                        };
                      });
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Save',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  double safeDouble(num? value) =>
      (value == null || value.isNaN) ? 0 : value.toDouble();
  int safeInt(num? value) => (value == null || value.isNaN) ? 0 : value.toInt();

  // Update _handleBookingAndPayment to accept setModalState and use lockRelease
  Future<void> _handleBookingAndPayment([StateSetter? setModalState]) async {
    // Update both the modal state and widget state to show loading
    setModalState?.call(() {}); // Refresh modal to show loading
    setState(() {}); // Refresh main widget state

    await lockRelease('booking', perform: () async {
      try {
        // Gather booking data
        final bookingForSelf =
            _friendDetails.isEmpty || (_friendDetails['name']?.isEmpty ?? true);
        final selectedAddons = <Map<String, dynamic>>[];
        for (final service in services) {
          for (final addOn in serviceAddOns[service.id] ?? []) {
            selectedAddons.add({
              "addon_id": addOn.id,
              "quantity": 1,
            });
          }
        }
        final bookingData = {
          "professional": selectedProfessional.id,
          "service": services.first.id,
          "scheduledDate": DateFormat('yyyy-MM-dd').format(selectedDate!),
          "scheduledTime": _formatScheduledTime(selectedTime),
          "bookingForSelf": bookingForSelf,
          if (!bookingForSelf) ...{
            "recipientName": _friendDetails['name'],
            "recipientPhone": _friendDetails['phone'],
            "recipientEmail": _friendDetails['email'],
          },
          "customerNotes": _noteController.text,
          "selectedAddons": selectedAddons,
        };

        print('Booking request body:');
        print({
          ...bookingData,
          "paymentType": selectedPaymentOption == "full" ? "full" : "partial"
        });

        // Call booking API
        final response = await BookingService.createBooking(
          professional: bookingData["professional"],
          service: bookingData["service"],
          scheduledDate: bookingData["scheduledDate"],
          scheduledTime: bookingData["scheduledTime"],
          bookingForSelf: bookingData["bookingForSelf"],
          recipientName: bookingData["recipientName"],
          recipientPhone: bookingData["recipientPhone"],
          recipientEmail: bookingData["recipientEmail"],
          addressLine1: '', // Use empty string instead of null
          addressLine2: '',
          city: '',
          postalCode: '',
          locationNotes: null,
          customerNotes: bookingData["customerNotes"],
          selectedAddons: selectedAddons,
          paymentType: selectedPaymentOption == "full" ? "full" : "partial",
        );

        print("Booking API response: $response");
        print(response?["stripe_payment_intent_id"]);
        print(response?["stripe_client_secret"]);

        if (response != null &&
            response["stripe_payment_intent_id"] != null &&
            response["stripe_client_secret"] != null) {
          final clientSecret = response["stripe_client_secret"];
          await _presentStripePaymentSheet(clientSecret);
          Navigator.pop(context); // Close payment modal
          setState(() {
            showSuccessPage = true;
          });
        } else {
          // Handle error (show error message)
          showToast(title: "Booking failed.", description: "Please try again.");
        }
      } catch (e) {
        // Handle any errors
        showToast(title: "Booking failed.", description: "Please try again.");
        print(e.toString());
      } finally {
        // Update both states when done
        setModalState?.call(() {}); // Refresh modal state
        setState(() {}); // Refresh main widget state
      }
    });
  }

  Future<void> _presentStripePaymentSheet(String clientSecret) async {
    try {
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'Labs by Shea',
        ),
      );
      await Stripe.instance.presentPaymentSheet();
    } catch (e) {
      showToast(title: "Payment cancelled or failed.", description: "");
    }
  }

  @override
  Widget view(BuildContext context) {
    if (showSuccessPage) {
      return _buildSuccessPage();
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          "Review and confirm",
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date and time info
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.calendar_today,
                                size: 20, color: Colors.grey.shade600),
                            const SizedBox(width: 8),
                            Text(
                              _formatDate(),
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.access_time,
                                size: 20, color: Colors.grey.shade600),
                            const SizedBox(width: 8),
                            Text(
                              _formatTime(),
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Show friend details if provided
                  if (_friendDetails.isNotEmpty &&
                      (_friendDetails['name']?.isNotEmpty ?? false))
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.person, color: Colors.black),
                              SizedBox(width: 8),
                              Text('Booking for: ',
                                  style:
                                      TextStyle(fontWeight: FontWeight.w600)),
                              Text(_friendDetails['name'] ?? '',
                                  style:
                                      TextStyle(fontWeight: FontWeight.w600)),
                            ],
                          ),
                          if ((_friendDetails['phone']?.isNotEmpty ?? false))
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text('Phone: ${_friendDetails['phone']}'),
                            ),
                          if ((_friendDetails['email']?.isNotEmpty ?? false))
                            Padding(
                              padding: const EdgeInsets.only(top: 2.0),
                              child: Text('Email: ${_friendDetails['email']}'),
                            ),
                        ],
                      ),
                    ),

                  // Services list with add-ons
                  ...services.asMap().entries.map((entry) {
                    final index = entry.key;
                    final service = entry.value;
                    final addOns = serviceAddOns[service.id] ?? [];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Service name and price
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  service.name ?? '',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Text(
                                "£${service.regionalPrice?.toStringAsFixed(0) ?? '0'}",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Service details
                          if (service.description?.isNotEmpty ?? false)
                            Text(
                              service.description ?? '',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          const SizedBox(height: 4),

                          // Duration
                          if (service.durationMinutes != null)
                            Text(
                              '${service.durationMinutes} minutes',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),

                          // Add-ons for this service
                          if (addOns.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            ...addOns.map((addOn) {
                              return Padding(
                                padding:
                                    const EdgeInsets.only(left: 16, bottom: 8),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        addOn.name ?? '',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey.shade700,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      "£${double.tryParse(addOn.price ?? '0')?.toStringAsFixed(0) ?? '0'}",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade700,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ],
                        ],
                      ),
                    );
                  }).toList(),

                  const SizedBox(height: 16),
                  Divider(color: Colors.grey.shade300),
                  const SizedBox(height: 16),

                  // Total and payment breakdown
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Total",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "£${totalPrice.toStringAsFixed(0)}",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Pay deposit now",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          Text(
                            "£$depositAmount",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Balance at Venue",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          Text(
                            "£$balanceAmount",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Book for a friend section
                  GestureDetector(
                    onTap: _showBookForFriendSheet,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.person_add,
                              size: 20,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Book for a friend',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Colors.grey.shade600,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Deposit policy
                  const Text(
                    "Deposit policy",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Labs by Shea requires 50% deposit to be paid upfront",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Additional terms
                  const Text(
                    "Additional terms and conditions",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Deposits are non-refundable, you can reschedule your appointment and your deposit will be transferred over to your future booking. If you are unable to reschedule, please contact us at least 48 hours before your appointment.",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Additional note
                  const Text(
                    "Additional note",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _noteController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText:
                          "Include comments or requests about your booking",
                      hintStyle: TextStyle(color: Colors.grey.shade500),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.black),
                      ),
                    ),
                  ),

                  const SizedBox(height: 100), // Extra space for bottom section
                ],
              ),
            ),
          ),

          // Bottom section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        "£${totalPrice.toStringAsFixed(0)}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Container(
                      width: 120,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _showPaymentModal,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          "Continue",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            overflow: TextOverflow.ellipsis,
                          ),
                          maxLines: 1,
                          softWrap: false,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      "${services.length} service${services.length != 1 ? 's' : ''} • $durationText",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
