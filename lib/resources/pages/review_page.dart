import 'package:flutter/material.dart';
import 'package:flutter_app/resources/pages/base_navigation_hub.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:intl/intl.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_app/app/services/booking_service.dart';
import 'package:flutter_app/app/services/region_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'dart:io' show Platform;

class ReviewPage extends NyStatefulWidget {
  static RouteView path = ("/review", (_) => ReviewPage());

  ReviewPage({super.key}) : super(child: () => _ReviewPageState());
}

class _ReviewPageState extends NyPage<ReviewPage> {
  final TextEditingController _noteController = TextEditingController();
  String selectedPaymentOption = "deposit"; // "full" or "deposit"
  bool showSuccessPage = false;
  bool calendarAdded = false; // Track if calendar has been added

  bool isStripeInitialized = false;
  // Remove dummy data, use real booking data
  List<dynamic> services = [];
  Map<int, List<dynamic>> serviceAddOns = {};
  dynamic selectedProfessional;
  DateTime? selectedDate;
  String? selectedTime;
  double totalPrice = 0;
  String durationText = '';

  Map<String, String?> _friendDetails = {};
  String _currencySymbol = '£'; // Default currency symbol
  bool _hasRefreshedCurrency = false;

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

        await _initializeStripe();
        await _loadCurrencySymbol();
        setState(() {});
      };

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Only refresh currency symbol if we haven't already done so recently
    if (!_hasRefreshedCurrency) {
      _refreshCurrencySymbol();
    }
  }

  void _refreshCurrencySymbol() async {
    try {
      final newCurrencySymbol = await RegionService.getCurrentCurrencySymbol();
      if (newCurrencySymbol != _currencySymbol) {
        setState(() {
          _currencySymbol = newCurrencySymbol;
          _hasRefreshedCurrency = true;
        });
        // Reset the flag after a short delay to allow future refreshes
        Future.delayed(Duration(seconds: 2), () {
          _hasRefreshedCurrency = false;
        });
      }
    } catch (e) {
      print('Error refreshing currency symbol: $e');
    }
  }

  int get depositAmount => (totalPrice * 0.5).roundToDouble().toInt();
  int get balanceAmount => totalPrice.toInt() - depositAmount;

  Future<void> _loadCurrencySymbol() async {
    try {
      _currencySymbol = await RegionService.getCurrentCurrencySymbol();
    } catch (e) {
      print('Error loading currency symbol: $e');
      _currencySymbol = '£'; // Default fallback
    }
  }

  Future<void> _initializeStripe() async {
    try {
      print("Initializing Stripe...");

      // Get the Stripe publishable key from .env file using Nylo's getEnv
      final String stripePublishableKey =
          getEnv('STRIPE_PUBLISHABLE_KEY', defaultValue: '');

      if (stripePublishableKey.isEmpty) {
        throw Exception('STRIPE_PUBLISHABLE_KEY not found in .env file');
      }

      if (!stripePublishableKey.startsWith('pk_')) {
        throw Exception(
            'Invalid Stripe publishable key format. Must start with pk_test_ or pk_live_');
      }

      // Initialize Stripe
      Stripe.publishableKey = stripePublishableKey;

      // Optional: Set additional Stripe configuration
      Stripe.merchantIdentifier =
          'com.beautyspabyshea.com'; // Your Apple Pay merchant ID (optional)
      Stripe.urlScheme = 'flutterstripe'; // For handling redirects (optional)

      isStripeInitialized = true;
      print("Stripe initialized successfully");
      // ignore: unnecessary_null_comparison
      print("Publishable Key Set: ${Stripe.publishableKey != null}");
      print(
          "Key type: ${stripePublishableKey.startsWith('pk_test_') ? 'TEST' : 'LIVE'}");
      print("Key starts with: ${stripePublishableKey.substring(0, 7)}");
    } catch (e) {
      print("Failed to initialize Stripe: $e");
      isStripeInitialized = false;

      String errorMessage = "Payment system could not be initialized.";

      if (e.toString().contains('not found in .env')) {
        errorMessage =
            "STRIPE_PUBLISHABLE_KEY not found in environment configuration.";
      } else if (e.toString().contains('Invalid Stripe publishable key')) {
        errorMessage = "Invalid Stripe key configuration.";
      }

      // Show error to user
      showToast(
        title: "Initialization Error",
        description: errorMessage,
      );
    }
  }

  void _showPaymentModal() {
    if (!isStripeInitialized) {
      showToast(
        title: "Not ready",
        description:
            "Payment system is still loading. Please wait a moment and try again.",
      );
      return;
    }

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
      height: MediaQuery.of(context).size.height * 0.95,
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
                      subtitle: "Balance $_currencySymbol 0 at the venue",
                      amount: totalPrice.toInt(),
                      value: "full",
                      isSelected: selectedPaymentOption == "full",
                    ),

                    const SizedBox(height: 16),

                    _buildPaymentOption(
                      context: context,
                      setModalState: setModalState,
                      title: "Make 50% deposit",
                      subtitle:
                          "Balance $_currencySymbol$balanceAmount at the venue",
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
              "$_currencySymbol$amount",
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
          "Booking Confirmed",
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
                  Icons.check_circle,
                  size: 60,
                  color: Colors.green.shade600,
                ),
              ),

              const SizedBox(height: 40),

              // Success message
              const Text(
                "Booking Confirmed!",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              Text(
                "Your appointment has been successfully booked.",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // Add to Calendar button (only show if not already added)
              // if (!calendarAdded) ...[
              //   Container(
              //     width: double.infinity,
              //     height: 56,
              //     child: ElevatedButton(
              //       onPressed: _addToCalendar,
              //       style: ElevatedButton.styleFrom(
              //         backgroundColor: Colors.black,
              //         shape: RoundedRectangleBorder(
              //           borderRadius: BorderRadius.circular(8),
              //         ),
              //       ),
              //       child: Row(
              //         mainAxisAlignment: MainAxisAlignment.center,
              //         children: [
              //           Icon(Icons.calendar_today,
              //               color: Colors.white, size: 20),
              //           SizedBox(width: 8),
              //           Text(
              //             "Add to Calendar",
              //             style: TextStyle(
              //               color: Colors.white,
              //               fontSize: 16,
              //               fontWeight: FontWeight.w600,
              //             ),
              //           ),
              //         ],
              //       ),
              //     ),
              //   ),
              //   const SizedBox(height: 16),
              // ] else ...[
              //   // Show success message when calendar is added
              //   Container(
              //     width: double.infinity,
              //     padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              //     decoration: BoxDecoration(
              //       color: Colors.green.shade50,
              //       borderRadius: BorderRadius.circular(8),
              //       border: Border.all(color: Colors.green.shade200),
              //     ),
              //     child: Row(
              //       mainAxisAlignment: MainAxisAlignment.center,
              //       children: [
              //         Icon(Icons.check_circle,
              //             color: Colors.green.shade600, size: 20),
              //         SizedBox(width: 8),
              //         Text(
              //           "Added to Calendar",
              //           style: TextStyle(
              //             color: Colors.green.shade700,
              //             fontSize: 16,
              //             fontWeight: FontWeight.w600,
              //           ),
              //         ),
              //       ],
              //     ),
              //   ),

              //   const SizedBox(height: 16),
              // ],

              // Go to appointment button
              Container(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: () {
                    // Navigate to appointment details or calendar
                    Navigator.of(context).pop();
                    routeTo(BaseNavigationHub.path, tabIndex: 2);
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.black),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "View My Bookings",
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

  Future<void> _addToCalendar() async {
    if (selectedDate == null || selectedTime == null) {
      showToast(
        title: "Error",
        description: "Booking details not available",
        style: ToastNotificationStyleType.danger,
      );
      return;
    }

    try {
      // Parse the time to get hours and minutes
      final timeParts = _formatScheduledTime(selectedTime).split(':');
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      // Create start and end times
      final startTime = DateTime(
        selectedDate!.year,
        selectedDate!.month,
        selectedDate!.day,
        hour,
        minute,
      );

      // Calculate end time based on service duration
      int totalDuration = 60; // Default 1 hour
      if (services.isNotEmpty && services.first.durationMinutes != null) {
        totalDuration = services.first.durationMinutes!;
      }
      final endTime = startTime.add(Duration(minutes: totalDuration));

      // Format dates for calendar URLs
      final startDateStr = DateFormat('yyyyMMddTHHmmss').format(startTime);
      final endDateStr = DateFormat('yyyyMMddTHHmmss').format(endTime);

      final title = Uri.encodeComponent('Beauty Spa Appointment');
      final description = Uri.encodeComponent(_buildCalendarDescription());
      final location = Uri.encodeComponent('Labs by Shea');

      String calendarUrl;

      if (Platform.isAndroid) {
        // Google Calendar URL for Android
        calendarUrl =
            'https://calendar.google.com/calendar/render?action=TEMPLATE'
            '&text=$title'
            '&dates=$startDateStr/$endDateStr'
            '&details=$description'
            '&location=$location';
      } else {
        // iOS Calendar URL
        calendarUrl = 'calshow:'
            '&title=$title'
            '&startdate=$startDateStr'
            '&enddate=$endDateStr'
            '&notes=$description'
            '&location=$location';
      }

      final Uri uri = Uri.parse(calendarUrl);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);

        // Mark calendar as added
        setState(() {
          calendarAdded = true;
        });

        showToast(
          title: "Success",
          description: "Opening calendar with your appointment",
          style: ToastNotificationStyleType.success,
        );
      } else {
        throw Exception('Could not launch calendar URL');
      }
    } catch (e) {
      print('Error adding to calendar: $e');
      showToast(
        title: "Error",
        description: "Could not add to calendar. Please try again.",
        style: ToastNotificationStyleType.danger,
      );
    }
  }

  String _buildCalendarDescription() {
    final serviceNames = services.map((s) => s.name ?? '').join(', ');
    final professionalName = selectedProfessional?.name ?? 'Professional';

    String description = 'Appointment with $professionalName\n';
    description += 'Services: $serviceNames\n';

    if (_friendDetails.isNotEmpty &&
        (_friendDetails['name']?.isNotEmpty ?? false)) {
      description += 'Booking for: ${_friendDetails['name']}\n';
    }

    if (_noteController.text.isNotEmpty) {
      description += 'Notes: ${_noteController.text}';
    }

    return description;
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

  void _showBookForFriendSheet() async {
    // Create text controllers outside the builder to persist them
    final nameController =
        TextEditingController(text: _friendDetails['name'] ?? '');
    final phoneController =
        TextEditingController(text: _friendDetails['phone'] ?? '');
    final emailController =
        TextEditingController(text: _friendDetails['email'] ?? '');

    // Validation state
    String? nameError;
    String? phoneError;
    String? emailError;

    try {
      final result = await showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        enableDrag: true,
        isDismissible: true,
        useSafeArea: true,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (BuildContext modalContext) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
              void validateAndSave() {
                // Reset errors
                nameError = null;
                phoneError = null;
                emailError = null;

                // Validate name
                if (nameController.text.trim().isEmpty) {
                  nameError = 'Name is required';
                }

                // Validate phone
                final phoneText = phoneController.text.trim();
                if (phoneText.isEmpty) {
                  phoneError = 'Phone number is required';
                } else if (phoneText.length < 8) {
                  phoneError =
                      'Please enter a valid phone number (minimum 8 digits)';
                } else if (!RegExp(r'^[0-9\s\-\(\)]+$').hasMatch(phoneText)) {
                  phoneError =
                      'Please enter only numbers, spaces, hyphens, and parentheses';
                }

                // Validate email (optional but if provided, must be valid)
                final emailText = emailController.text.trim();
                if (emailText.isNotEmpty) {
                  final emailRegex =
                      RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                  if (!emailRegex.hasMatch(emailText)) {
                    emailError = 'Please enter a valid email address';
                  }
                }

                // If no errors, save and close
                if (nameError == null &&
                    phoneError == null &&
                    emailError == null) {
                  // Close the modal with success result
                  Navigator.of(modalContext).pop(true);
                } else {
                  setModalState(() {}); // Refresh modal to show errors
                }
              }

              return Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.7,
                ),
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
                      const Center(
                        child: Text(
                          'Book for a friend',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text('Who is booking it?',
                          style: TextStyle(fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      TextField(
                        enabled: false,
                        decoration: InputDecoration(
                          labelText: 'Name*',
                          hintText: 'Your name',
                          border: const OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                        ),
                        controller: TextEditingController(text: 'Cassandra'),
                      ),
                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 16),
                      const Text('Who are you booking for?',
                          style: TextStyle(fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: 'Name*',
                          border: const OutlineInputBorder(),
                          errorText: nameError,
                          errorBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.red),
                          ),
                        ),
                        onChanged: (value) {
                          if (nameError != null) {
                            nameError = null;
                            setModalState(() {});
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: phoneController,
                        decoration: InputDecoration(
                          labelText: 'Phone number*',
                          prefixText: '+',
                          border: const OutlineInputBorder(),
                          errorText: phoneError,
                          errorBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.red),
                          ),
                          hintText:
                              'Country code and number (e.g., 44 7XXX XXX XXX)',
                        ),
                        keyboardType: TextInputType.phone,
                        onChanged: (value) {
                          if (phoneError != null) {
                            phoneError = null;
                            setModalState(() {});
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                          labelText: 'Email (optional)',
                          hintText: 'example@email.com',
                          border: const OutlineInputBorder(),
                          errorText: emailError,
                          errorBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.red),
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (value) {
                          if (emailError != null) {
                            emailError = null;
                            setModalState(() {});
                          }
                        },
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: validateAndSave,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
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
        },
      );

      // Handle the result after modal is closed
      if (result == true) {
        // Save the data
        setState(() {
          _friendDetails = {
            'name': nameController.text.trim(),
            'phone': phoneController.text.trim(),
            'email': emailController.text.trim(),
          };
        });

        // Show success message after a small delay to ensure modal is fully closed
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            showToast(
              title: "Success",
              description: "Friend details saved successfully",
              style: ToastNotificationStyleType.success,
            );
          }
        });
      }
    } catch (e) {
      print('Error in friend booking sheet: $e');
    } finally {
      // Dispose controllers after modal is fully closed
      Future.delayed(const Duration(milliseconds: 100), () {
        nameController.dispose();
        phoneController.dispose();
        emailController.dispose();
      });
    }
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

        // Create the payload that will be sent to the backend
        final bookingPayload = {
          "professional": selectedProfessional.id,
          "service": services.first.id,
          "scheduled_date": DateFormat('yyyy-MM-dd').format(selectedDate!),
          "scheduled_time": _formatScheduledTime(selectedTime),
          "booking_for_self": bookingForSelf,
          if (!bookingForSelf) ...{
            "recipient_name": _friendDetails['name'],
            "recipient_phone": _friendDetails['phone'],
            "recipient_email": _friendDetails['email'],
          },
          "address_line1": '', // Use empty string instead of null
          "address_line2": '',
          "city": '',
          "postal_code": '',
          "location_notes": null,
          "customer_notes":
              _noteController.text.isNotEmpty ? _noteController.text : null,
          "selected_addons": selectedAddons.isNotEmpty ? selectedAddons : null,
          "payment_type": selectedPaymentOption == "full" ? "full" : "partial"
        };

        // Print detailed booking payload
        print('🔵 ===== BOOKING PAYLOAD SENT TO BACKEND =====');
        print(
            '📅 Date: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now())}');
        print('🌐 Endpoint: POST /bookings/create/');
        print('📦 Payload:');
        print(JsonEncoder.withIndent('  ').convert(bookingPayload));
        print('🔵 ===== END BOOKING PAYLOAD =====');

        // Call booking API
        final response = await BookingService.createBooking(
          professional: selectedProfessional.id,
          service: services.first.id,
          scheduledDate: DateFormat('yyyy-MM-dd').format(selectedDate!),
          scheduledTime: _formatScheduledTime(selectedTime),
          bookingForSelf: bookingForSelf,
          recipientName: bookingForSelf ? null : _friendDetails['name'],
          recipientPhone: bookingForSelf ? null : _friendDetails['phone'],
          recipientEmail: bookingForSelf ? null : _friendDetails['email'],
          addressLine1: '', // Use empty string instead of null
          addressLine2: '',
          city: '',
          postalCode: '',
          locationNotes: null,
          customerNotes:
              _noteController.text.isNotEmpty ? _noteController.text : null,
          selectedAddons: selectedAddons.isNotEmpty ? selectedAddons : null,
          paymentType: selectedPaymentOption == "full" ? "full" : "partial",
        );

        // Print API response
        print('🟢 ===== BOOKING API RESPONSE =====');
        print(
            '📅 Date: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now())}');
        print('📦 Response:');
        if (response != null) {
          print(JsonEncoder.withIndent('  ').convert(response));
        } else {
          print('  null (No response received)');
        }
        print('🟢 ===== END BOOKING API RESPONSE =====');

        // Check if booking creation was successful
        if (response == null) {
          print("Booking creation failed - response is null");
          showToast(
            title: "Booking failed",
            description: "Could not create booking. Please try again.",
          );
          return; // Exit early, don't attempt payment
        }

        // Check if response contains necessary payment data
        final stripeClientSecret = response["stripe_client_secret"];
        final stripePaymentIntentId = response["stripe_payment_intent_id"];

        if (stripeClientSecret == null || stripePaymentIntentId == null) {
          print(
              "Booking created but payment setup failed - missing Stripe data");
          showToast(
            title: "Payment setup failed",
            description:
                "Booking was created but payment could not be processed. Please contact support.",
          );
          return; // Exit early, don't attempt payment
        }

        print("Payment Intent ID: $stripePaymentIntentId");
        print("Client Secret: $stripeClientSecret");

        // Process Stripe payment
        final paymentSuccess = await _processStripePayment(stripeClientSecret);

        if (paymentSuccess) {
          // Payment succeeded - show success page
          Navigator.pop(context); // Close payment modal
          setState(() {
            showSuccessPage = true;
          });

          // Show success toast using Nylo's showToast
          showToast(
            title: "Booking confirmed!",
            description: "Your appointment has been booked successfully.",
          );
        } else {
          // Payment failed - show error but don't navigate to success
          // The _processStripePayment method will handle showing specific error messages
          print("Payment failed - staying on current page");
        }
      } catch (e) {
        // Handle any errors during booking creation or payment processing
        print("Error in booking/payment: $e");

        // Show appropriate error message based on the type of error using Nylo's showToast
        String errorTitle = "Booking failed";
        String errorDescription = "An error occurred. Please try again.";

        // Check if it's a network/API error
        if (e.toString().contains('DioException') ||
            e.toString().contains('400') ||
            e.toString().contains('500')) {
          errorTitle = "Server error";
          errorDescription =
              "There was a problem with the server. Please try again later.";
        } else if (e.toString().contains('Stripe') ||
            e.toString().contains('payment')) {
          errorTitle = "Payment error";
          errorDescription =
              "There was a problem processing your payment. Please try again.";
        }

        showToast(
          title: errorTitle,
          description: errorDescription,
        );
      } finally {
        // Update both states when done
        setModalState?.call(() {}); // Refresh modal state
        setState(() {}); // Refresh main widget state
      }
    });
  }

// Separate method to handle Stripe payment with proper error handling
  // Enhanced Stripe payment processing with better error handling
  Future<bool> _processStripePayment(String clientSecret) async {
    // Check if Stripe is initialized
    if (!isStripeInitialized ||
        Stripe.publishableKey == null ||
        Stripe.publishableKey!.isEmpty) {
      print("Stripe not properly initialized");
      showToast(
        title: "Configuration error",
        description: "Payment system is not ready. Please try again.",
      );
      return false;
    }

    try {
      print(
          "Starting Stripe payment process with client secret: ${clientSecret.substring(0, 20)}...");

      // Initialize payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'Labs by Shea',
          style: ThemeMode.system,
          appearance: PaymentSheetAppearance(
            colors: PaymentSheetAppearanceColors(
              primary: Colors.black,
            ),
          ),
          allowsDelayedPaymentMethods: true,
          billingDetailsCollectionConfiguration:
              const BillingDetailsCollectionConfiguration(
            name: CollectionMode.always,
            email: CollectionMode.always,
          ),
        ),
      );

      print("Payment sheet initialized successfully");

      // Present payment sheet
      await Stripe.instance.presentPaymentSheet();

      // If we reach here, payment was successful
      print("Payment completed successfully");
      return true;
    } on StripeException catch (e) {
      print("Stripe error: ${e.error.localizedMessage}");

      // Handle specific Stripe errors
      switch (e.error.code) {
        case FailureCode.Canceled:
          showToast(
            title: "Payment cancelled",
            description:
                "You cancelled the payment. Your booking was not completed.",
          );
          break;
        case FailureCode.Failed:
          showToast(
            title: "Payment failed",
            description:
                "Your payment could not be processed. Please check your payment method and try again.",
          );
          break;
        default:
          showToast(
            title: "Payment error",
            description: e.error.localizedMessage ??
                "An error occurred during payment. Please try again.",
          );
      }
      return false;
    } catch (e) {
      print("General payment error: $e");

      // Handle configuration errors specifically
      if (e.toString().contains('StripeConfigException') ||
          e.toString().contains('not initialized')) {
        showToast(
          title: "Configuration error",
          description:
              "Payment system is not properly configured. Please try restarting the app.",
        );
      } else if (e.toString().contains('network') ||
          e.toString().contains('connection')) {
        showToast(
          title: "Network error",
          description: "Please check your internet connection and try again.",
        );
      } else if (e.toString().contains('timeout')) {
        showToast(
          title: "Timeout error",
          description: "Payment timed out. Please try again.",
        );
      } else {
        showToast(
          title: "Payment error",
          description:
              "An unexpected error occurred during payment. Please try again.",
        );
      }
      return false;
    }
  }

  // Helper method to show better toast messages
  void showToasts({required String title, required String description}) {
    // Use your app's toast/snackbar implementation
    // This is a placeholder - replace with your actual toast implementation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            if (description.isNotEmpty)
              Text(
                description,
                style: TextStyle(color: Colors.white),
              ),
          ],
        ),
        backgroundColor: title.toLowerCase().contains('success') ||
                title.toLowerCase().contains('confirmed')
            ? Colors.green
            : Colors.red,
        duration: Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
      ),
    );
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
                                "$_currencySymbol${service.regionalPrice?.toStringAsFixed(0) ?? '0'}",
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
                                      "$_currencySymbol${double.tryParse(addOn.price ?? '0')?.toStringAsFixed(0) ?? '0'}",
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
                            "$_currencySymbol${totalPrice.toStringAsFixed(0)}",
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
                            "$_currencySymbol$depositAmount",
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
                            "$_currencySymbol$balanceAmount",
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
                        border: Border.all(
                          color: _friendDetails.isNotEmpty
                              ? Colors.green.shade300
                              : Colors.grey.shade300,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        color: _friendDetails.isNotEmpty
                            ? Colors.green.shade50
                            : Colors.white,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: _friendDetails.isNotEmpty
                                  ? Colors.green.shade100
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              _friendDetails.isNotEmpty
                                  ? Icons.person
                                  : Icons.person_add,
                              size: 20,
                              color: _friendDetails.isNotEmpty
                                  ? Colors.green.shade700
                                  : Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _friendDetails.isNotEmpty
                                      ? 'Book for a friend'
                                      : 'Book for a friend',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: _friendDetails.isNotEmpty
                                        ? Colors.green.shade700
                                        : Colors.black,
                                  ),
                                ),
                                if (_friendDetails.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    '${_friendDetails['name']} • ${_friendDetails['phone']}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.green.shade600,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: _friendDetails.isNotEmpty
                                ? Colors.green.shade600
                                : Colors.grey.shade600,
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
                        "$_currencySymbol${totalPrice.toStringAsFixed(0)}",
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
