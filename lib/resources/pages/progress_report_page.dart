import 'package:flutter/material.dart';
import 'package:flutter_app/app/services/booking_service.dart';
import 'package:flutter_app/app/models/booking.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:intl/intl.dart';

class ProgressReportPage extends NyStatefulWidget {
  static RouteView path = ("/progress-report", (_) => ProgressReportPage());

  ProgressReportPage({super.key})
      : super(child: () => _ProgressReportPageState());
}

class _ProgressReportPageState extends NyPage<ProgressReportPage> {
  List<Booking> _bookings = [];
  bool _loading = true;
  String? _error;

  @override
  get init => () async {
        await _loadBookings();
      };

  Future<void> _loadBookings() async {
    try {
      setState(() {
        _loading = true;
        _error = null;
      });

      // Load all bookings for the user
      final bookings = await BookingService.getBookings();

      // Sort by scheduled date (most recent first)
      bookings.sort((a, b) {
        if (a.scheduledDate == null && b.scheduledDate == null) return 0;
        if (a.scheduledDate == null) return 1;
        if (b.scheduledDate == null) return -1;

        final dateA = DateTime.tryParse(a.scheduledDate!);
        final dateB = DateTime.tryParse(b.scheduledDate!);

        if (dateA == null && dateB == null) return 0;
        if (dateA == null) return 1;
        if (dateB == null) return -1;

        return dateB.compareTo(dateA);
      });

      setState(() {
        _bookings = bookings;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load bookings: $e';
        _loading = false;
      });
      print('Error loading bookings: $e');
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Date not available';

    try {
      final date = DateTime.parse(dateString);
      return DateFormat('EEEE, d MMMM yyyy', 'en_US').format(date);
    } catch (e) {
      return dateString;
    }
  }

  String _getBookingReference(String? bookingId) {
    if (bookingId == null) return 'N/A';
    return bookingId.length > 8
        ? bookingId.substring(0, 8).toUpperCase()
        : bookingId.toUpperCase();
  }

  void _navigateToBookingDetails(Booking booking) {
    routeTo("/progress-report-details", data: {'bookingId': booking.bookingId});
  }

  @override
  Widget view(BuildContext context) {
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
          'Progress Report',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFC8AD87)),
              ),
            )
          : _error != null
              ? _buildErrorState()
              : _bookings.isEmpty
                  ? _buildEmptyState()
                  : _buildBookingsList(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 48,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            _error ?? 'An error occurred',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.red,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
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
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No bookings found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your booking history will appear here',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingsList() {
    return RefreshIndicator(
      onRefresh: _loadBookings,
      color: const Color(0xFFC8AD87),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _bookings.length,
        itemBuilder: (context, index) {
          final booking = _bookings[index];
          return _buildBookingItem(booking);
        },
      ),
    );
  }

  Widget _buildBookingItem(Booking booking) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToBookingDetails(booking),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Date
                      Text(
                        _formatDate(booking.scheduledDate),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Service details and booking reference
                      Text(
                        '${booking.serviceName ?? 'Service'} | Booking Ref: ${_getBookingReference(booking.bookingId)}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey.shade400,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
