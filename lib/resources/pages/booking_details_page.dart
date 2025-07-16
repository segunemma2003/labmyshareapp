import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';

class BookingDetailsPage extends NyStatefulWidget {
  static RouteView path =
      ("/booking-details", (_) => BookingDetailsPage(bookingId: null));

  final String? bookingId;
  BookingDetailsPage({super.key, required this.bookingId})
      : super(child: () => _BookingDetailsPageState());
}

class _BookingDetailsPageState extends NyPage<BookingDetailsPage> {
  @override
  get init => () {
        // You can use widget.bookingId here
      };

  @override
  Widget view(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Booking Details")),
      body: SafeArea(
        child: Container(),
      ),
    );
  }
}
