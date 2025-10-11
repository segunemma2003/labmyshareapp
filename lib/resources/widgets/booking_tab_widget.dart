import 'package:flutter/material.dart';
import 'package:flutter_app/resources/pages/booking_details_page.dart';
import 'package:flutter_app/resources/pages/select_services_page.dart';
import 'package:nylo_framework/nylo_framework.dart';
import '../../app/services/booking_service.dart';
import '../../app/models/booking.dart';
import '../../app/services/region_service.dart';

class BookingTab extends StatefulWidget {
  const BookingTab({super.key});

  @override
  createState() => _BookingTabState();
}

class _BookingTabState extends NyState<BookingTab>
    with TickerProviderStateMixin {
  late TabController _tabController;

  List<Booking> openAppointments = [];
  List<Booking> pendingAppointments = [];
  List<Booking> closedAppointments = [];
  bool loading = true;
  String? error;
  String _currencySymbol = '£'; // Default currency symbol
  bool _hasRefreshedCurrency = false;

  @override
  get init => () async {
        _tabController = TabController(length: 3, vsync: this);
        await _loadCurrencySymbol();
        await _loadBookings();
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

  Future<void> _loadCurrencySymbol() async {
    try {
      _currencySymbol = await RegionService.getCurrentCurrencySymbol();
    } catch (e) {
      print('Error loading currency symbol: $e');
      _currencySymbol = '£'; // Default fallback
    }
  }

  Future<void> _loadBookings() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      // Load bookings using the correct API endpoints
      final futures = await Future.wait([
        BookingService.getBookings(
            status: "confirmed"), // Open: Full payment completed
        BookingService.getBookings(status: "pending"), // Pending: Part payment
        BookingService.getBookings(
            status: "completed"), // Completed: Service completed
        BookingService.getBookings(status: "cancelled"), // Cancelled bookings
      ]);

      // Filter out cancelled bookings from open appointments (they should be in completed)
      final openBookings = futures[0];
      // .where((booking) => booking.status == 'confirmed').toList();

      // Get cancelled bookings that are fully paid
      // final cancelledFullyPaid = futures[3]
      //     .where((booking) =>
      //         booking.status == 'cancelled' &&
      //         booking.paymentStatus == 'fully_paid')
      //     .toList();

      // Combine completed and cancelled fully paid bookings
      final allCompleted = [...futures[2], ...futures[3]];

      setState(() {
        openAppointments = openBookings;
        pendingAppointments = futures[1];
        closedAppointments = allCompleted;
        loading = false;
      });

      print(
          'Loaded ${openAppointments.length} open appointments (fully_paid, not cancelled)');
      print(
          'Loaded ${pendingAppointments.length} pending appointments (deposit_paid)');
      print(
          'Loaded ${closedAppointments.length} completed/cancelled appointments (${futures[2].length} completed + ${futures[3].length} cancelled fully paid)');
    } catch (e) {
      setState(() {
        error = 'Failed to load bookings: $e';
        loading = false;
      });
      print('Error loading bookings: $e');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget view(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          "Appointments",
          style: TextStyle(
            color: Color(0xFFC8AD87),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey.shade400,
          indicatorColor: Colors.black,
          indicatorWeight: 2,
          labelStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.normal,
          ),
          tabs: [
            Tab(text: "Open (${openAppointments.length})"),
            Tab(text: "Pending (${pendingAppointments.length})"),
            Tab(text: "Completed/Cancelled (${closedAppointments.length})"),
          ],
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? _buildErrorState()
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildAppointmentsList(openAppointments, "upcoming"),
                    _buildAppointmentsList(pendingAppointments, "pending"),
                    _buildAppointmentsList(closedAppointments, "closed"),
                  ],
                ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              error ?? 'Something went wrong',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadBookings,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC8AD87),
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentsList(List<Booking> appointments, String type) {
    if (appointments.isEmpty) {
      return _buildEmptyState(type);
    }
    return RefreshIndicator(
      onRefresh: _loadBookings,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: appointments.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              _navigateToBookingDetails(appointments[index]);
            },
            child: _buildAppointmentCard(appointments[index]),
          );
        },
      ),
    );
  }

  void _navigateToBookingDetails(Booking booking) {
    if (booking.bookingId != null) {
      routeTo(BookingDetailsPage.path, data: {"bookingId": booking.bookingId!});
    } else {
      // Show error snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot open booking details - missing booking ID'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildEmptyState(String type) {
    String title;
    String subtitle;
    IconData iconData;

    switch (type) {
      case "pending":
        title = "No Pending Appointments";
        subtitle = "You have no appointments with partial payments.";
        iconData = Icons.schedule;
        break;
      case "closed":
        title = "No Completed/Cancelled Appointments";
        subtitle = "You have no completed or cancelled appointments yet.";
        iconData = Icons.check_circle_outline;
        break;
      default:
        title = "No Open Appointments";
        subtitle = "You have no appointments with full payment completed.";
        iconData = Icons.event_available;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFC8AD87).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                iconData,
                size: 40,
                color: const Color(0xFFC8AD87).withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                height: 1.3,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            OutlinedButton(
              onPressed: () {
                // Navigate to booking flow
                routeTo(SelectServicesPage.path);
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.black),
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "Book Appointment",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentCard(Booking booking) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with service name and price
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.serviceName ?? 'Unknown Service',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (booking.professionalName?.isNotEmpty == true)
                      Text(
                        "with ${booking.professionalName}",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "$_currencySymbol${booking.totalAmount?.toStringAsFixed(0) ?? '0'}",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  if (booking.paymentStatus != null)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: BookingService.getPaymentStatusColor(
                            booking.paymentStatus!),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        BookingService.getPaymentStatusDisplayText(
                            booking.paymentStatus!),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Date and time information
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 16,
                color: Colors.grey.shade600,
              ),
              const SizedBox(width: 8),
              Text(
                _formatDate(booking.scheduledDate),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.access_time,
                size: 16,
                color: Colors.grey.shade600,
              ),
              const SizedBox(width: 8),
              Text(
                "${_formatTime(booking.scheduledTime)} • ${booking.durationMinutes ?? 0} min",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Status and booking reference
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (booking.status != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: BookingService.getStatusColor(booking.status!)
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: BookingService.getStatusColor(booking.status!),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    BookingService.getStatusDisplayText(booking.status!),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: BookingService.getStatusColor(booking.status!),
                    ),
                  ),
                ),
              Text(
                "Ref: ${_formatBookingRef(booking.bookingId)}",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(String? date) {
    if (date == null) return 'No date';
    try {
      final parsedDate = DateTime.parse(date);
      final now = DateTime.now();
      final difference = parsedDate.difference(now).inDays;

      if (difference == 0) {
        return 'Today';
      } else if (difference == 1) {
        return 'Tomorrow';
      } else if (difference == -1) {
        return 'Yesterday';
      } else {
        final weekday = [
          'Mon',
          'Tue',
          'Wed',
          'Thu',
          'Fri',
          'Sat',
          'Sun'
        ][parsedDate.weekday - 1];
        final month = [
          'Jan',
          'Feb',
          'Mar',
          'Apr',
          'May',
          'Jun',
          'Jul',
          'Aug',
          'Sep',
          'Oct',
          'Nov',
          'Dec'
        ][parsedDate.month - 1];
        return '$weekday, $month ${parsedDate.day}';
      }
    } catch (e) {
      return date;
    }
  }

  String _formatTime(String? time) {
    if (time == null) return 'No time';
    try {
      final parts = time.split(':');
      if (parts.length >= 2) {
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        final period = hour >= 12 ? 'PM' : 'AM';
        final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
        return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
      }
    } catch (e) {
      // Fall back to original string
    }
    return time;
  }

  String _formatBookingRef(String? bookingId) {
    if (bookingId == null) return 'N/A';
    // Show only the first 8 characters of the UUID
    return bookingId.length > 8
        ? bookingId.substring(0, 8).toUpperCase()
        : bookingId.toUpperCase();
  }
}
