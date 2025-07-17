import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import '../../app/services/booking_service.dart';
import '../../app/models/booking.dart';
import 'package:intl/intl.dart';

class BookingDetailsPage extends NyStatefulWidget {
  static RouteView path =
      ("/booking-details", (_) => BookingDetailsPage(bookingId: null));

  final String? bookingId;
  BookingDetailsPage({super.key, required this.bookingId})
      : super(child: () => _BookingDetailsPageState());
}

class _BookingDetailsPageState extends NyPage<BookingDetailsPage> {
  Booking? booking;
  bool loading = true;
  bool error = false;

  @override
  get init => () async {
        if (widget.bookingId != null) {
          final result = await BookingService.getBookingDetails(
              bookingId: widget.bookingId!);
          setState(() {
            booking = result;
            loading = false;
            error = result == null;
          });
        } else {
          setState(() {
            loading = false;
            error = true;
          });
        }
      };

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
    // If already in hh:mm or hh:mm:ss, return hh:mm part
    final timeRegExp =
        RegExp(r'^(\d{2}):(\d{2})(?::\d{2})?(?:\s*[APMapm]{2})?');
    if (timeRegExp.hasMatch(time)) {
      return time.substring(0, 5);
    }
    return time;
  }

  @override
  Widget view(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (error || booking == null) {
      return Scaffold(
        appBar: AppBar(title: Text("Booking Details")),
        body: const Center(child: Text("Booking not found.")),
      );
    }
    // Calculate total, deposit, balance
    final total = booking!.totalAmount ?? 0;
    final deposit = booking!.depositAmount ?? 0;
    final balance = total - deposit;
    // Duration formatting
    String durationText = '';
    if (booking!.durationMinutes != null) {
      final hours = booking!.durationMinutes! ~/ 60;
      final minutes = booking!.durationMinutes! % 60;
      durationText = hours > 0
          ? (minutes > 0 ? '$hours hours $minutes minutes' : '$hours hours')
          : '$minutes minutes';
    }
    // Add-ons and services
    List<Widget> serviceWidgets = [];
    if (booking!.serviceName != null) {
      serviceWidgets.add(_serviceBlock(
        booking!.serviceName!,
        booking!.baseAmount ?? 0,
        booking!.selectedAddons,
        booking!.durationMinutes,
      ));
    }
    // If there are multiple services, you can extend this logic
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: BackButton(color: Colors.black),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(
                  _formatDate(booking!.scheduledDate),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${_formatTime(booking!.scheduledTime)}am - 4:00pm   •   $durationText',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Icon(Icons.calendar_today, color: Color(0xFF8B4513)),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Add to your Calendar',
                            style: TextStyle(fontWeight: FontWeight.w600)),
                        Text('Get personal reminders',
                            style: TextStyle(fontSize: 13, color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(Icons.tune, color: Color(0xFF8B4513)),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Manage appointment',
                            style: TextStyle(fontWeight: FontWeight.w600)),
                        Text('Get personal reminders',
                            style: TextStyle(fontSize: 13, color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Divider(),
                const SizedBox(height: 8),
                const Text('Overview',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 16),
                ...serviceWidgets,
                const SizedBox(height: 24),
                const Text('Total',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Deposit',
                        style: TextStyle(color: Colors.orange)),
                    Text('£${deposit.toStringAsFixed(0)}',
                        style: const TextStyle(color: Colors.orange)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Balance at Venue'),
                    Text('£${balance.toStringAsFixed(0)}'),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18)),
                    Text('£${total.toStringAsFixed(0)}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18)),
                  ],
                ),
                const SizedBox(height: 32),
                Text('Booking Ref: ${booking!.bookingId ?? ''}',
                    style: const TextStyle(
                        color: Colors.grey, fontWeight: FontWeight.w600)),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _serviceBlock(
      String name, double price, List<dynamic>? addons, int? duration) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(name,
                style:
                    const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            Text('£${price.toStringAsFixed(0)}',
                style:
                    const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
          ],
        ),
        if (addons != null)
          ...addons.map((addon) {
            final addonName = addon['addon']?['name'] ?? '';
            final addonPrice = addon['addon']?['price'] ?? '';
            return Padding(
              padding: const EdgeInsets.only(left: 16, top: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('+  $addonName', style: const TextStyle(fontSize: 14)),
                  Text('£$addonPrice', style: const TextStyle(fontSize: 14)),
                ],
              ),
            );
          }).toList(),
        if (duration != null)
          Padding(
            padding: const EdgeInsets.only(left: 0, top: 4),
            child: Text(
              duration >= 60
                  ? '${duration ~/ 60} hours${duration % 60 > 0 ? ' ${duration % 60} minutes' : ''}'
                  : '$duration minutes',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            ),
          ),
        const SizedBox(height: 12),
      ],
    );
  }
}
