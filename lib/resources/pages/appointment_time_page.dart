import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';

class AppointmentTimePage extends NyStatefulWidget {
  static RouteView path = ("/appointment-time", (_) => AppointmentTimePage());

  AppointmentTimePage({super.key})
      : super(child: () => _AppointmentTimePageState());
}

class _AppointmentTimePageState extends NyPage<AppointmentTimePage> {
  String selectedProfessional = "Sheilla";
  DateTime selectedDate = DateTime(2025, 1, 19);
  DateTime currentMonth = DateTime(2025, 1, 1);
  String? selectedTimeSlot;
  bool showTimeSlots = false;

  final List<String> professionals = [
    "Sheilla",
    "Alexis",
    "Sanchez",
    "Grace",
    "Shequanda"
  ];

  // Generate time slots every 15 minutes from 9:00 AM to 6:00 PM
  List<String> get timeSlots {
    List<String> slots = [];
    for (int hour = 9; hour < 18; hour++) {
      for (int minute = 0; minute < 60; minute += 15) {
        final timeString = _formatTime(hour, minute);
        slots.add(timeString);
      }
    }
    return slots;
  }

  String _formatTime(int hour, int minute) {
    final period = hour >= 12 ? 'pm' : 'am';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    final minuteString = minute.toString().padLeft(2, '0');
    return '$displayHour:$minuteString $period';
  }

  // Simulated unavailable dates for demo
  final List<DateTime> unavailableDates = [
    DateTime(2025, 1, 19),
    DateTime(2025, 1, 20),
    DateTime(2025, 1, 21),
    DateTime(2025, 1, 22),
    DateTime(2025, 1, 23),
  ];

  @override
  get init => () {};

  void _previousMonth() {
    setState(() {
      currentMonth = DateTime(currentMonth.year, currentMonth.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      currentMonth = DateTime(currentMonth.year, currentMonth.month + 1, 1);
    });
  }

  String _getMonthName(int month) {
    const monthNames = [
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return monthNames[month];
  }

  int _getDaysInMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0).day;
  }

  int _getFirstDayOfWeek(DateTime date) {
    return DateTime(date.year, date.month, 1).weekday % 7;
  }

  bool isDateAvailable(DateTime date) {
    return !unavailableDates.any((unavailable) =>
        date.year == unavailable.year &&
        date.month == unavailable.month &&
        date.day == unavailable.day);
  }

  DateTime getNextAvailableDate() {
    DateTime checkDate = DateTime.now();
    while (!isDateAvailable(checkDate)) {
      checkDate = checkDate.add(const Duration(days: 1));
    }
    return checkDate;
  }

  void _showDatePicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildDatePickerBottomSheet(),
    );
  }

  void _showProfessionalPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildProfessionalBottomSheet(),
    );
  }

  Widget _buildDatePickerBottomSheet() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
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
                  "Select date",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),

          // Month/Year Navigation
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: _previousMonth,
                  icon: const Icon(Icons.chevron_left),
                ),
                Text(
                  "${_getMonthName(currentMonth.month)} ${currentMonth.year}",
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
                IconButton(
                  onPressed: _nextMonth,
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
          ),

          // Calendar
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _buildCalendarGrid(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfessionalBottomSheet() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Select Professional",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          ...professionals.map(
            (professional) => ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.grey.shade300,
                child: Text(professional[0]),
              ),
              title: Text(professional),
              onTap: () {
                setState(() {
                  selectedProfessional = professional;
                  showTimeSlots = false;
                });
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final daysInMonth = _getDaysInMonth(currentMonth);
    final firstDayOfWeek = _getFirstDayOfWeek(currentMonth);
    final totalCells = ((daysInMonth + firstDayOfWeek - 1) / 7).ceil() * 7;

    return Column(
      children: [
        // Days of week header
        Row(
          children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
              .map((day) => Expanded(
                    child: Center(
                      child: Text(
                        day,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 8),

        // Calendar days
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
            ),
            itemCount: totalCells,
            itemBuilder: (context, index) {
              if (index < firstDayOfWeek) {
                // Empty cell before first day of month
                return Container();
              }

              final day = index - firstDayOfWeek + 1;
              if (day > daysInMonth) {
                // Empty cell after last day of month
                return Container();
              }

              final date = DateTime(currentMonth.year, currentMonth.month, day);
              final isSelected = date.year == selectedDate.year &&
                  date.month == selectedDate.month &&
                  date.day == selectedDate.day;
              final isAvailable = isDateAvailable(date);

              return GestureDetector(
                onTap: isAvailable
                    ? () {
                        setState(() {
                          selectedDate = date;
                          showTimeSlots = true;
                        });
                        Navigator.pop(context);
                      }
                    : null,
                child: Container(
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFB8860B)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      day.toString(),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: !isAvailable
                            ? Colors.grey.shade400
                            : isSelected
                                ? Colors.white
                                : Colors.black,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHorizontalDatePicker() {
    final startDate = DateTime(2025, 1, 19);
    return SizedBox(
      height: 100, // Increased height to accommodate day names below
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 7,
        itemBuilder: (context, index) {
          final date = startDate.add(Duration(days: index));
          final isSelected = date.day == selectedDate.day &&
              date.month == selectedDate.month &&
              date.year == selectedDate.year;
          final isAvailable = isDateAvailable(date);
          final dayNames = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

          return GestureDetector(
            onTap: isAvailable
                ? () {
                    setState(() {
                      selectedDate = date;
                      showTimeSlots = isAvailable;
                    });
                  }
                : null,
            child: Container(
              width: 60,
              margin: const EdgeInsets.only(right: 12),
              child: Column(
                children: [
                  // Date box
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color:
                          isSelected ? const Color(0xFFB8860B) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFFB8860B)
                            : Colors.grey.shade300,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        date.day.toString(),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: !isAvailable
                              ? Colors.grey.shade400
                              : isSelected
                                  ? Colors.white
                                  : Colors.black,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Day name below the box
                  Text(
                    dayNames[date.weekday % 7],
                    style: TextStyle(
                      fontSize: 12,
                      color: !isAvailable
                          ? Colors.grey.shade400
                          : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildUnavailableMessage() {
    final nextAvailable = getNextAvailableDate();
    final dayNames = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    final monthNames = [
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];

    return Column(
      children: [
        const SizedBox(height: 40),
        CircleAvatar(
          radius: 40,
          backgroundColor: Colors.grey.shade200,
          child: const Icon(Icons.person, size: 40),
        ),
        const SizedBox(height: 16),
        Text(
          "$selectedProfessional is fully booked on this date",
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          "Available next from ${dayNames[nextAvailable.weekday % 7]}, ${nextAvailable.day}${_getOrdinalSuffix(nextAvailable.day)} ${monthNames[nextAvailable.month]}",
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        OutlinedButton.icon(
          onPressed: () {
            setState(() {
              selectedDate = nextAvailable;
              showTimeSlots = true;
            });
          },
          icon: const Icon(Icons.arrow_forward),
          label: const Text("Go to nearest available date"),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
      ],
    );
  }

  String _getOrdinalSuffix(int day) {
    if (day >= 11 && day <= 13) return 'th';
    switch (day % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }

  @override
  Widget view(BuildContext context) {
    final isCurrentDateAvailable = isDateAvailable(selectedDate);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          showTimeSlots ? "Select Appointment Time" : "Select Time",
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          // Top controls
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Professional selector
                GestureDetector(
                  onTap: _showProfessionalPicker,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.grey.shade300,
                          child: const Icon(Icons.person, size: 16),
                        ),
                        const SizedBox(width: 8),
                        Text(selectedProfessional),
                        const SizedBox(width: 8),
                        const Icon(Icons.keyboard_arrow_down, size: 20),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Month/Year selector
                GestureDetector(
                  onTap: _showDatePicker,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.calendar_today, size: 16),
                        const SizedBox(width: 8),
                        Text(
                            "${_getMonthName(currentMonth.month)} ${currentMonth.year}"),
                        const SizedBox(width: 8),
                        const Icon(Icons.keyboard_arrow_down, size: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Horizontal date picker
          _buildHorizontalDatePicker(),

          // Main content
          Expanded(
            child: showTimeSlots && isCurrentDateAvailable
                ? _buildTimeSlotsList()
                : _buildUnavailableMessage(),
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
                    const Text(
                      "£520",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Container(
                      width: 120,
                      height: 48,
                      decoration: BoxDecoration(
                        color: (showTimeSlots && selectedTimeSlot != null)
                            ? Colors.black
                            : Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: (showTimeSlots && selectedTimeSlot != null)
                              ? () {
                                  print(
                                      "Continue with appointment: $selectedProfessional on ${selectedDate.day}/${selectedDate.month}/${selectedDate.year} at $selectedTimeSlot");
                                }
                              : null,
                          child: const Center(
                            child: Text(
                              "Continue",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      "1 service",
                      style:
                          TextStyle(fontSize: 14, color: Colors.grey.shade600),
                    ),
                    Container(
                      width: 4,
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade600,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Text(
                      "8 Hours 30 mins - 9 Hours",
                      style:
                          TextStyle(fontSize: 14, color: Colors.grey.shade600),
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

  Widget _buildTimeSlotsList() {
    final availableTimeSlots = timeSlots;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: availableTimeSlots.length,
              itemBuilder: (context, index) {
                final timeSlot = availableTimeSlots[index];
                final isSelected = selectedTimeSlot == timeSlot;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedTimeSlot = timeSlot;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFFB8860B)
                            : Colors.grey.shade300,
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white,
                    ),
                    child: Text(
                      timeSlot,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                        color: Colors.black,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
