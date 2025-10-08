import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import '../../app/services/booking_service.dart';
import '../../app/models/booking.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io' show Platform;
import 'package:flutter_stripe/flutter_stripe.dart';

class BookingDetailsPage extends NyStatefulWidget {
  static RouteView path = ("/booking-details", (_) => BookingDetailsPage());

  BookingDetailsPage({super.key})
      : super(child: () => _BookingDetailsPageState());
}

class _BookingDetailsPageState extends NyState<BookingDetailsPage> {
  Booking? booking;
  String? errorMessage;

  @override
  get init => () async {
        await _loadBookingDetails();
      };

  Future<void> _loadBookingDetails() async {
    try {
      // Get booking ID from route data
      final String? bookingId = widget.data()['bookingId'];

      if (bookingId == null) {
        setState(() {
          errorMessage = 'Booking ID not provided';
        });
        return;
      }

      final result =
          await BookingService.getBookingDetails(bookingId: bookingId);

      setState(() {
        booking = result;
        if (result == null) {
          errorMessage = 'Booking not found';
        }
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load booking details: $e';
      });
    }
  }

  String _formatDate(String? date) {
    if (date == null) return '';
    try {
      final dt = DateTime.parse(date);
      return DateFormat('EEEE, d MMMM, yyyy.').format(dt);
    } catch (_) {
      return date;
    }
  }

  String _formatTime(String? time) {
    if (time == null) return '';
    try {
      final parts = time.split(':');
      if (parts.length >= 2) {
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        final period = hour >= 12 ? 'pm' : 'am';
        final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
        return '$displayHour:${minute.toString().padLeft(2, '0')}$period';
      }
    } catch (e) {
      // Fall back to original string
    }
    return time;
  }

  String _calculateEndTime(String? startTime, int? durationMinutes) {
    if (startTime == null || durationMinutes == null) return '';

    try {
      final parts = startTime.split(':');
      if (parts.length >= 2) {
        final startHour = int.parse(parts[0]);
        final startMinute = int.parse(parts[1]);

        final totalMinutes = startHour * 60 + startMinute + durationMinutes;
        final endHour = (totalMinutes ~/ 60) % 24;
        final endMinute = totalMinutes % 60;

        final period = endHour >= 12 ? 'pm' : 'am';
        final displayHour =
            endHour > 12 ? endHour - 12 : (endHour == 0 ? 12 : endHour);
        return '$displayHour:${endMinute.toString().padLeft(2, '0')}$period';
      }
    } catch (e) {
      // Fall back
    }
    return '';
  }

  String _formatDuration(int? minutes) {
    if (minutes == null) return '';

    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;

    if (hours > 0 && remainingMinutes > 0) {
      return '$hours hours $remainingMinutes minutes';
    } else if (hours > 0) {
      return '$hours hour${hours > 1 ? 's' : ''}';
    } else {
      return '$remainingMinutes minutes';
    }
  }

  String _formatBookingRef(String? bookingId) {
    if (bookingId == null) return '';
    // Take first 8 characters and make uppercase
    return bookingId.length > 8
        ? bookingId.substring(0, 8).toUpperCase()
        : bookingId.toUpperCase();
  }

  Future<void> _addToCalendar() async {
    print('📅 Adding booking to calendar...');
    print('📅 Platform: ${Platform.isAndroid ? 'Android' : 'iOS'}');
    print('📅 Booking ID: ${booking?.bookingId}');
    print('📅 Date: ${booking?.scheduledDate}');
    print('📅 Time: ${booking?.scheduledTime}');

    if (booking == null ||
        booking!.scheduledDate == null ||
        booking!.scheduledTime == null) {
      showToast(
        title: "Error",
        description: "Booking details not available",
        style: ToastNotificationStyleType.danger,
      );
      return;
    }

    try {
      // Parse the date and time
      final date = DateTime.parse(booking!.scheduledDate!);
      final timeParts = booking!.scheduledTime!.split(':');
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      // Create start time
      final startTime = DateTime(
        date.year,
        date.month,
        date.day,
        hour,
        minute,
      );

      // Calculate end time based on duration
      final durationMinutes = booking!.durationMinutes ?? 60; // Default 1 hour
      final endTime = startTime.add(Duration(minutes: durationMinutes));

      // Format dates for calendar URLs
      final startDateStr = DateFormat('yyyyMMddTHHmmss').format(startTime);
      final endDateStr = DateFormat('yyyyMMddTHHmmss').format(endTime);

      final title = Uri.encodeComponent(
          'Beauty Spa Appointment - ${booking!.serviceName ?? 'Service'}');
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

      print('📅 Opening calendar URL: $calendarUrl');

      final Uri uri = Uri.parse(calendarUrl);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);

        showToast(
          title: "Success",
          description: "Opening calendar with your appointment",
          style: ToastNotificationStyleType.success,
        );
      } else {
        throw Exception('Could not launch calendar URL');
      }
    } catch (e) {
      print('❌ Error adding to calendar: $e');
      print('❌ Platform: ${Platform.isAndroid ? 'Android' : 'iOS'}');

      String errorMessage = "Could not open calendar. Please try again.";

      // Platform-specific error messages
      if (Platform.isAndroid) {
        errorMessage =
            "Could not open Android calendar. Please check if you have a calendar app installed.";
      } else if (Platform.isIOS) {
        errorMessage =
            "Could not open iOS calendar. Please check your calendar settings.";
      }

      showToast(
        title: "Error",
        description: errorMessage,
        style: ToastNotificationStyleType.danger,
      );
    }
  }

  String _buildCalendarDescription() {
    if (booking == null) return 'Beauty Spa Appointment';

    String description = '';

    // Professional info
    if (booking!.professionalName != null) {
      description += 'Professional: ${booking!.professionalName}\n';
    }

    // Service info
    if (booking!.serviceName != null) {
      description += 'Service: ${booking!.serviceName}\n';
    }

    // Duration
    if (booking!.durationMinutes != null) {
      description += 'Duration: ${_formatDuration(booking!.durationMinutes)}\n';
    }

    // Customer info
    if (booking!.customerName != null && booking!.customerName!.isNotEmpty) {
      description += 'Customer: ${booking!.customerName}\n';
    }

    // Booking reference
    if (booking!.bookingId != null) {
      description += 'Booking Ref: ${_formatBookingRef(booking!.bookingId)}\n';
    }

    // Customer notes
    if (booking!.customerNotes != null && booking!.customerNotes!.isNotEmpty) {
      description += 'Notes: ${booking!.customerNotes}';
    }

    return description;
  }

  /// Shows platform-specific information about calendar integration
  void _showCalendarInfo() {
    String platformInfo = '';
    String tipMessage = '';

    if (Platform.isAndroid) {
      platformInfo = 'Android Calendar';
      tipMessage =
          'This will open your default Android calendar app (Google Calendar, Samsung Calendar, etc.)';
    } else if (Platform.isIOS) {
      platformInfo = 'iOS Calendar';
      tipMessage =
          'This will open your iOS Calendar app with the appointment details pre-filled';
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add to $platformInfo'),
        content: Text(tipMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _addToCalendar();
            },
            child: const Text('Add to Calendar'),
          ),
        ],
      ),
    );
  }

  void _showManageAppointmentSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildManageAppointmentSheet(),
    );
  }

  Widget _buildManageAppointmentSheet() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Manage Appointment',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Appointment details
          Text(
            _formatDate(booking!.scheduledDate),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${_formatTime(booking!.scheduledTime)} - ${_calculateEndTime(booking!.scheduledTime, booking!.durationMinutes)}   •   ${_formatDuration(booking!.durationMinutes)}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),

          // Add to Calendar option
          _buildManageOption(
            icon: Icons.calendar_today,
            title: 'Add to Calendar',
            onTap: () {
              Navigator.pop(context);
              _addToCalendar();
            },
          ),
          const SizedBox(height: 16),

          // Reschedule option
          _buildManageOption(
            icon: Icons.schedule,
            title: 'Reschedule appointment',
            onTap: () {
              Navigator.pop(context);
              _handleReschedule();
            },
          ),
          const SizedBox(height: 16),

          // Cancel option
          _buildManageOption(
            icon: Icons.cancel_outlined,
            title: 'Cancel Appointment',
            onTap: () {
              Navigator.pop(context);
              _showCancelConfirmation();
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildManageOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
        child: Row(
          children: [
            Icon(
              icon,
              size: 24,
              color: Colors.black87,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  void _showCancelConfirmation() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildCancelConfirmationSheet(),
    );
  }

  Widget _buildCancelConfirmationSheet() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Cancel Appointment',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.red,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Appointment details
          Text(
            _formatDate(booking!.scheduledDate),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${_formatTime(booking!.scheduledTime)} - ${_calculateEndTime(booking!.scheduledTime, booking!.durationMinutes)}   •   ${_formatDuration(booking!.durationMinutes)}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),

          // Warning text
          const Text(
            'You can reschedule your appointment if you wish to change the time.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          const Text(
            'Are you sure you want to cancel your appointment?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 32),

          // Cancel button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _handleCancel();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Cancel Appointment',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Future<void> _handleCancel() async {
    if (booking?.bookingId == null) return;

    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      final success = await BookingService.cancelBooking(
        bookingId: booking!.bookingId!,
        reason: 'Cancelled by customer',
      );

      // Hide loading
      Navigator.pop(context);

      if (success) {
        _showSuccessPage('cancelled');
      } else {
        showToast(
          title: "Error",
          description: "Failed to cancel appointment. Please try again.",
          style: ToastNotificationStyleType.danger,
        );
      }
    } catch (e) {
      // Hide loading
      Navigator.pop(context);
      showToast(
        title: "Error",
        description: "Failed to cancel appointment: $e",
        style: ToastNotificationStyleType.danger,
      );
    }
  }

  Future<void> _handleReschedule() async {
    if (booking?.bookingId == null) return;

    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Submit reschedule request
      final success = await BookingService.rescheduleBooking(
        bookingId: booking!.bookingId!,
        reason: 'Rescheduled by customer',
      );

      // Hide loading
      Navigator.pop(context);

      if (success) {
        _showSuccessPage('rescheduled');
      } else {
        showToast(
          title: "Error",
          description: "Failed to reschedule appointment. Please try again.",
          style: ToastNotificationStyleType.danger,
        );
      }
    } catch (e) {
      // Hide loading
      Navigator.pop(context);
      showToast(
        title: "Error",
        description: "Failed to reschedule appointment: $e",
        style: ToastNotificationStyleType.danger,
      );
    }
  }

  void _showSuccessPage(String action) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Success icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.event_available,
                  size: 48,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 24),

              // Success message
              Text(
                'You have successfully ${action} your appointment.',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Go to appointments button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    Navigator.pop(context); // Go back to appointments
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.black),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Go to appointments',
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

  @override
  Widget view(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: Colors.white,
      floatingActionButton: _buildFloatingActionButton(),
      body: afterLoad(child: () {
        if (errorMessage != null) {
          return _buildErrorState();
        }
        return _buildBookingDetails();
      }),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              errorMessage ?? 'Something went wrong',
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  errorMessage = null;
                });
                reboot();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingDetails() {
    if (booking == null) {
      return Center(
        child: Text(
          'No booking data available',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
          ),
        ),
      );
    }

    final startTime = _formatTime(booking!.scheduledTime);
    final endTime =
        _calculateEndTime(booking!.scheduledTime, booking!.durationMinutes);
    final duration = _formatDuration(booking!.durationMinutes);

    // Calculate financial details
    final totalAmount = booking!.totalAmount ?? 0.0;
    final depositAmount = booking!.depositAmount ?? 0.0;
    final balanceAmount = totalAmount - depositAmount;

    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date
              Text(
                _formatDate(booking!.scheduledDate),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),

              // Time and duration
              Text(
                '$startTime - $endTime   •   $duration',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade500,
                ),
              ),
              const SizedBox(height: 32),

              // Action buttons based on booking status
              _buildStatusBasedActions(),
              const SizedBox(height: 32),

              // Overview section
              const Text(
                'Overview',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 16),

              // Service details
              _buildServiceBlock(
                serviceName: booking!.serviceName ?? 'Unknown Service',
                price: booking!.baseAmount ?? totalAmount,
                addons: booking!.selectedAddons,
                duration: booking!.durationMinutes,
              ),
              const SizedBox(height: 24),

              // Total section
              const Text(
                'Total',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),

              // Deposit
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Deposit',
                    style: TextStyle(color: Colors.orange),
                  ),
                  Text(
                    '£${depositAmount.toStringAsFixed(0)}',
                    style: const TextStyle(color: Colors.orange),
                  ),
                ],
              ),
              const SizedBox(height: 4),

              // Balance at venue
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Balance at Venue'),
                  Text('£${balanceAmount.toStringAsFixed(0)}'),
                ],
              ),
              const SizedBox(height: 16),

              // Divider
              const Divider(),
              const SizedBox(height: 16),

              // Total
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    '£${totalAmount.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Booking reference
              Text(
                'Booking Ref: ${_formatBookingRef(booking!.bookingId)}',
                style: const TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget? _buildFloatingActionButton() {
    if (booking == null) return null;

    // Check booking status and payment status
    final isPending = booking!.paymentStatus == 'deposit_paid' ||
        booking!.paymentStatus == 'pending';
    final isCompleted = booking!.status == 'completed';
    final isCancelled = booking!.status == 'cancelled';
    final isFullyPaid = booking!.paymentStatus == 'fully_paid';

    if (isPending && !isFullyPaid) {
      // Show payment button for pending bookings
      return FloatingActionButton.extended(
        onPressed: _showPaymentSheet,
        backgroundColor: const Color(0xFFC8AD87),
        icon: const Icon(Icons.payment, color: Colors.white),
        label: const Text(
          'Pay Balance',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      );
    } else if (isCompleted && !isCancelled) {
      // Show review button for completed bookings (not cancelled)
      return FloatingActionButton.extended(
        onPressed: _showReviewSheet,
        backgroundColor: const Color(0xFFC8AD87),
        icon: const Icon(Icons.rate_review, color: Colors.white),
        label: const Text(
          'Write Review',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      );
    } else if (isCancelled) {
      // Show cancelled info for cancelled bookings
      return FloatingActionButton.extended(
        onPressed: () {
          showToast(
            title: "Cancelled Booking",
            description:
                "This booking has been cancelled and cannot be reviewed.",
            style: ToastNotificationStyleType.info,
          );
        },
        backgroundColor: Colors.grey,
        icon: const Icon(Icons.cancel_outlined, color: Colors.white),
        label: const Text(
          'Cancelled',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      );
    } else {
      // Show calendar button for other statuses
      return FloatingActionButton.extended(
        onPressed: _showCalendarInfo,
        backgroundColor: const Color(0xFFC8AD87),
        icon: const Icon(Icons.calendar_today, color: Colors.white),
        label: const Text(
          'Add to Calendar',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      );
    }
  }

  Widget _buildStatusBasedActions() {
    // Check booking status and payment status
    final isPending = booking!.paymentStatus == 'deposit_paid' ||
        booking!.paymentStatus == 'pending';
    final isCompleted = booking!.status == 'completed';
    final isCancelled = booking!.status == 'cancelled';
    final isFullyPaid = booking!.paymentStatus == 'fully_paid';

    return Column(
      children: [
        // Calendar button (always available)
        _buildActionButton(
          icon: Icons.calendar_today,
          title: 'Add to your Calendar',
          subtitle: 'Get personal reminders',
          onTap: _addToCalendar,
        ),
        const SizedBox(height: 16),

        // Status-specific actions
        if (isPending && !isFullyPaid) ...[
          // Payment button for pending bookings
          _buildActionButton(
            icon: Icons.payment,
            title: 'Complete Payment',
            subtitle: 'Pay remaining balance',
            onTap: _showPaymentSheet,
          ),
          const SizedBox(height: 16),
        ] else if (isCompleted && !isCancelled) ...[
          // Review button for completed bookings (not cancelled)
          _buildActionButton(
            icon: Icons.rate_review,
            title: 'Write Review',
            subtitle: 'Share your experience',
            onTap: _showReviewSheet,
          ),
          const SizedBox(height: 16),
        ] else if (isCancelled) ...[
          // Cancelled booking - show cancellation info
          _buildActionButton(
            icon: Icons.cancel_outlined,
            title: 'Booking Cancelled',
            subtitle: 'This appointment has been cancelled',
            onTap: () {
              showToast(
                title: "Cancelled Booking",
                description:
                    "This booking has been cancelled and cannot be reviewed.",
                style: ToastNotificationStyleType.info,
              );
            },
          ),
          const SizedBox(height: 16),
        ] else ...[
          // Manage appointment for other statuses
          _buildActionButton(
            icon: Icons.tune,
            title: 'Manage appointment',
            subtitle: 'Reschedule or cancel',
            onTap: () {
              _showManageAppointmentSheet();
            },
          ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  void _showPaymentSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildPaymentSheet(),
    );
  }

  Widget _buildPaymentSheet() {
    final balanceAmount =
        (booking!.totalAmount ?? 0) - (booking!.depositAmount ?? 0);

    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Confirm payment',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Payment method
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.credit_card, color: Colors.blue),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Visa XXX-2824',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'Exp: 05/26',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const Text(
                  'VISA',
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Balance and amount
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFFC8AD87),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Balance service payment',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'Balance £0 at the venue',
                      style: TextStyle(
                        color: Colors.green.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '£${balanceAmount.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Pay button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () => _processPayment(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Pay £${balanceAmount.toStringAsFixed(0)} balance',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Policy information
          const Text(
            'Deposit policy',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Labs by Shea requires 50% deposit to be paid upfront.',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),

          const Text(
            'Additional terms and conditions',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Deposits are non-refundable, you can reschedule your appointment and your deposit will be transferred over to your future booking. If you are unable to reschedule, please contact us at least 48 hours before your appointment.',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  void _showReviewSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildReviewSheet(),
    );
  }

  Widget _buildReviewSheet() {
    int rating = 0;
    final titleController = TextEditingController();
    final reviewController = TextEditingController();

    return StatefulBuilder(
      builder: (context, setState) {
        return Container(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Write a review',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Rating
              Row(
                children: [
                  const Text(
                    'Tap to rate:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 16),
                  ...List.generate(5, (index) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          rating = index + 1;
                        });
                      },
                      child: Icon(
                        index < rating ? Icons.star : Icons.star_border,
                        color: index < rating ? Colors.amber : Colors.grey,
                        size: 32,
                      ),
                    );
                  }),
                ],
              ),
              const SizedBox(height: 24),

              // Title field
              const Text(
                'Title',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  hintText: 'Optional',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Review field
              const Text(
                'Review',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: reviewController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Optional',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Submit button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: rating > 0
                      ? () => _submitReview(
                            rating,
                            titleController.text,
                            reviewController.text,
                          )
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Submit',
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
        );
      },
    );
  }

  Future<void> _processPayment() async {
    if (booking?.bookingId == null) return;

    try {
      Navigator.pop(context); // Close payment sheet

      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Complete payment (get payment intent)
      final result = await BookingService.completePayment(
        bookingId: booking!.bookingId!,
        paymentType: 'remaining',
      );

      // Hide loading
      Navigator.pop(context);

      if (result != null && result['success'] == true) {
        final stripeClientSecret =
            result["client_secret"] ?? result["stripe_client_secret"];
        final stripePaymentIntentId =
            result["payment_intent_id"] ?? result["stripe_payment_intent_id"];

        if (stripeClientSecret == null || stripePaymentIntentId == null) {
          showToast(
            title: "Payment setup failed",
            description: "Could not initialize payment. Please try again.",
            style: ToastNotificationStyleType.danger,
          );
          return;
        }

        // Initialize Stripe if needed
        await _initializeStripe();

        // Present Stripe payment sheet
        final paymentSuccess = await _processStripePayment(stripeClientSecret);

        if (paymentSuccess) {
          _showPaymentSuccessSheet();
        } else {
          showToast(
            title: "Payment Failed",
            description: "Could not complete payment. Please try again.",
            style: ToastNotificationStyleType.danger,
          );
        }
      } else {
        showToast(
          title: "Payment Failed",
          description: "Could not complete payment. Please try again.",
          style: ToastNotificationStyleType.danger,
        );
      }
    } catch (e) {
      // Hide loading
      Navigator.pop(context);
      showToast(
        title: "Payment Error",
        description: "An error occurred during payment: $e",
        style: ToastNotificationStyleType.danger,
      );
    }
  }

  // Stripe initialization (copied from review_page.dart)
  bool isStripeInitialized = false;
  Future<void> _initializeStripe() async {
    if (isStripeInitialized) return;
    try {
      final String stripePublishableKey =
          getEnv('STRIPE_PUBLISHABLE_KEY', defaultValue: '');
      if (stripePublishableKey.isEmpty) {
        throw Exception('STRIPE_PUBLISHABLE_KEY not found in .env file');
      }
      Stripe.publishableKey = stripePublishableKey;
      Stripe.merchantIdentifier = 'merchant.com.labsbyshea';
      Stripe.urlScheme = 'flutterstripe';
      isStripeInitialized = true;
    } catch (e) {
      isStripeInitialized = false;
      print('Failed to initialize Stripe: $e');
    }
  }

  // Stripe payment sheet logic (copied from review_page.dart)
  Future<bool> _processStripePayment(String clientSecret) async {
    if (!isStripeInitialized ||
        Stripe.publishableKey == null ||
        Stripe.publishableKey!.isEmpty) {
      showToast(
        title: "Configuration error",
        description: "Payment system is not ready. Please try again.",
      );
      return false;
    }
    try {
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
      await Stripe.instance.presentPaymentSheet();
      return true;
    } on StripeException catch (e) {
      showToast(
        title: "Payment error",
        description: e.error.localizedMessage ??
            "An error occurred during payment. Please try again.",
      );
      return false;
    } catch (e) {
      showToast(
        title: "Payment error",
        description:
            "An unexpected error occurred during payment. Please try again.",
      );
      return false;
    }
  }

  void _showPaymentSuccessSheet() {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildPaymentSuccessSheet(),
    );
  }

  Widget _buildPaymentSuccessSheet() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Success icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(40),
            ),
            child: Icon(
              Icons.check,
              color: Colors.green.shade600,
              size: 40,
            ),
          ),
          const SizedBox(height: 24),

          // Success message
          const Text(
            'You have successfully paid your outstanding balance.',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // Review prompt
          const Text(
            'How was our service?',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),

          // Review button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              onPressed: () {
                Navigator.pop(context);
                _showReviewSheet();
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.grey.shade300),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Review now',
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
    );
  }

  Future<void> _submitReview(int rating, String title, String review) async {
    if (booking?.bookingId == null) return;

    try {
      Navigator.pop(context); // Close review sheet

      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Submit review
      final success = await BookingService.reviewBooking(
        bookingId: booking!.bookingId!,
        overallRating: rating,
        serviceRating: rating,
        professionalRating: rating,
        valueRating: rating,
        comment: review.isNotEmpty
            ? review
            : (title.isNotEmpty ? title : 'Great service!'),
        wouldRecommend: true,
      );

      // Hide loading
      Navigator.pop(context);

      if (success) {
        showToast(
          title: "Review Submitted",
          description: "Thank you for your review!",
          style: ToastNotificationStyleType.success,
        );
        // Refresh booking details to update UI
        await _loadBookingDetails();
      } else {
        showToast(
          title: "Review Failed",
          description: "Could not submit review. Please try again.",
          style: ToastNotificationStyleType.danger,
        );
      }
    } catch (e) {
      // Hide loading
      Navigator.pop(context);
      showToast(
        title: "Review Error",
        description: "An error occurred while submitting review: $e",
        style: ToastNotificationStyleType.danger,
      );
    }
  }

  Widget _buildActionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(
            icon,
            color: const Color(0xFFC8AD87),
            size: 24,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildServiceBlock({
    required String serviceName,
    required double price,
    List<dynamic>? addons,
    int? duration,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main service
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                serviceName,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
            Text(
              '£${price.toStringAsFixed(0)}',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),

        // Addons
        if (addons != null && addons.isNotEmpty)
          ...addons.map((addon) {
            final addonName =
                addon['name'] ?? addon['addon']?['name'] ?? 'Unknown addon';
            final addonPrice = addon['price'] ?? addon['addon']?['price'] ?? 0;

            return Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '+  $addonName',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  Text(
                    '£$addonPrice',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            );
          }).toList(),

        // Duration
        if (duration != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              _formatDuration(duration),
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ),
      ],
    );
  }
}
