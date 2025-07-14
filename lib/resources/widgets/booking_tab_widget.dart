import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';

class BookingTab extends StatefulWidget {
  const BookingTab({super.key});

  @override
  createState() => _BookingTabState();
}

class _BookingTabState extends NyState<BookingTab>
    with TickerProviderStateMixin {
  late TabController _tabController;

  // Sample data - replace with actual data from your backend
  final List<AppointmentModel> openAppointments = [
    // AppointmentModel(
    //   date: "Thursday, 23 January 2025.",
    //   time: "9:30am - 4:00pm",
    //   duration: "6 hours",
    //   price: 349,
    //   paymentStatus: "Deposit",
    //   servicesCount: 2,
    //   bookingRef: "AB78IX55G",
    // ),
    // AppointmentModel(
    //   date: "Friday, 24 January 2025.",
    //   time: "9:30am - 4:00pm",
    //   duration: "6 hours",
    //   price: 520,
    //   paymentStatus: "Full payment",
    //   servicesCount: 2,
    //   bookingRef: "AB78IX55G",
    // ),
  ];

  final List<AppointmentModel> pendingAppointments = [
    AppointmentModel(
      date: "Thursday, 23 January 2025.",
      time: "9:30am - 4:00pm",
      duration: "6 hours",
      price: 349,
      paymentStatus: "Deposit",
      servicesCount: 2,
      bookingRef: "AB78IX55G",
    ),
  ];

  final List<AppointmentModel> closedAppointments = List.generate(
    5,
    (index) => AppointmentModel(
      date: "Thursday, 23 January 2025.",
      time: "9:30am - 4:00pm",
      duration: "6 hours",
      price: 349,
      paymentStatus: "Cleared",
      servicesCount: 2,
      bookingRef: "AB78IX55G",
    ),
  );

  @override
  get init => () {
        _tabController = TabController(length: 3, vsync: this);
      };

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
            color: Color(0xFF8B4513),
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
          tabs: const [
            Tab(text: "Open"),
            Tab(text: "Pending"),
            Tab(text: "Closed"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAppointmentsList(openAppointments, "upcoming"),
          _buildAppointmentsList(pendingAppointments, "pending"),
          _buildAppointmentsList(closedAppointments, "closed"),
        ],
      ),
    );
  }

  Widget _buildAppointmentsList(
      List<AppointmentModel> appointments, String type) {
    if (appointments.isEmpty) {
      return _buildEmptyState(type);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        return _buildAppointmentCard(appointments[index]);
      },
    );
  }

  Widget _buildEmptyState(String type) {
    String title;
    IconData iconData;

    switch (type) {
      case "pending":
        title = "You have no pending\nappointments.";
        iconData = Icons.schedule;
        break;
      case "closed":
        title = "You have no closed appointments\nnow.";
        iconData = Icons.close;
        break;
      default:
        title = "You have no upcoming\nappointments.";
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
                color: const Color(0xFF8B4513).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                iconData,
                size: 40,
                color: const Color(0xFF8B4513).withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
                height: 1.3,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            OutlinedButton(
              onPressed: () {
                // Navigate to booking flow
                Navigator.pushNamed(context, "/select-professional");
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
                "Book now",
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

  Widget _buildAppointmentCard(AppointmentModel appointment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with date and price
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointment.date,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${appointment.time} • ${appointment.duration}",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                "£${appointment.price}",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Payment status and booking details
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getPaymentStatusColor(appointment.paymentStatus),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  appointment.paymentStatus,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "${appointment.servicesCount} services",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  Text(
                    "Booking Ref: ${appointment.bookingRef}",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getPaymentStatusColor(String status) {
    switch (status.toLowerCase()) {
      case "deposit":
        return Colors.orange;
      case "full payment":
        return Colors.green;
      case "cleared":
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }
}

class AppointmentModel {
  final String date;
  final String time;
  final String duration;
  final int price;
  final String paymentStatus;
  final int servicesCount;
  final String bookingRef;

  AppointmentModel({
    required this.date,
    required this.time,
    required this.duration,
    required this.price,
    required this.paymentStatus,
    required this.servicesCount,
    required this.bookingRef,
  });
}
