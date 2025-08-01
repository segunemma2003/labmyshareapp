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

  void _navigateToBookingDetail(Booking booking) {
    routeTo("/booking-detail", data: {'bookingId': booking.bookingId});
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
    // Extract a short reference from the booking ID
    return bookingId.length > 8
        ? bookingId.substring(0, 8).toUpperCase()
        : bookingId.toUpperCase();
  }

  bool _hasPictures(Booking booking) {
    final beforeCount = booking.beforePictures?.length ?? 0;
    final afterCount = booking.afterPictures?.length ?? 0;
    return beforeCount > 0 || afterCount > 0;
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
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToBookingDetail(booking),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
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
                const SizedBox(height: 8),

                // Service details and booking reference
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${booking.serviceName ?? 'Service'} | Booking Ref: ${_getBookingReference(booking.bookingId)}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        // Show picture indicator if booking has pictures
                        if (_hasPictures(booking))
                          Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFC8AD87)
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.photo_library,
                                  size: 12,
                                  color: const Color(0xFFC8AD87),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Photos',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFFC8AD87),
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
                  ],
                ),

                const SizedBox(height: 12),

                // Status indicator
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: BookingService.getStatusColor(
                                booking.status ?? 'pending')
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        BookingService.getStatusDisplayText(
                            booking.status ?? 'pending'),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: BookingService.getStatusColor(
                              booking.status ?? 'pending'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: BookingService.getPaymentStatusColor(
                                booking.paymentStatus ?? 'pending')
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        BookingService.getPaymentStatusDisplayText(
                            booking.paymentStatus ?? 'pending'),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: BookingService.getPaymentStatusColor(
                              booking.paymentStatus ?? 'pending'),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
