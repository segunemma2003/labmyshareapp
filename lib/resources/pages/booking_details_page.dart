import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import '../../app/services/booking_service.dart';
import '../../app/models/booking.dart';
import 'package:intl/intl.dart';

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
        /// Uncomment the code below to fetch the number of stars for the Nylo repository
        // Map<String, dynamic>? githubResponse = await api<ApiService>(
        //         (request) => request.githubInfo(),
        // );
        // _stars = githubResponse?["stargazers_count"];
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

              // Action buttons
              _buildActionButton(
                icon: Icons.calendar_today,
                title: 'Add to your Calendar',
                subtitle: 'Get personal reminders',
                onTap: () {
                  showToast(
                    title: "Calendar Integration",
                    description: "This feature will be available soon",
                    style: ToastNotificationStyleType.info,
                  );
                },
              ),
              const SizedBox(height: 16),

              _buildActionButton(
                icon: Icons.tune,
                title: 'Manage appointment',
                subtitle: 'Get personal reminders',
                onTap: () {
                  showToast(
                    title: "Appointment Management",
                    description: "This feature will be available soon",
                    style: ToastNotificationStyleType.info,
                  );
                },
              ),
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
              const SizedBox(height: 60),

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
            color: const Color(0xFF8B4513),
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
