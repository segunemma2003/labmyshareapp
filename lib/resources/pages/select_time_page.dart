import 'package:flutter/material.dart';
import 'package:flutter_app/app/models/professional.dart';
import 'package:flutter_app/app/models/service_item.dart';
import 'package:flutter_app/app/services/professionals_data_service.dart';
import 'package:flutter_app/app/services/auth_service.dart';
import 'package:flutter_app/resources/pages/review_page.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:intl/intl.dart';

class SelectTimePage extends NyStatefulWidget {
  static RouteView path = ("/select-time", (_) => SelectTimePage());

  SelectTimePage({super.key}) : super(child: () => _SelectTimePageState());
}

class _SelectTimePageState extends NyPage<SelectTimePage> {
  Professional? _selectedProfessional;
  List<Professional> _professionals = [];
  List<Service> _selectedServices = [];
  Map<int, List<AddOn>> _serviceAddOns = {};
  DateTime _selectedDate = DateTime.now();
  List<DateTime> _visibleDates = [];
  List<String> _availableTimes = [];
  String? _selectedTime;
  bool _loading = true;
  bool _fullyBooked = false;
  String? _nextAvailableDate;
  double _totalPrice = 0;
  String _durationText = '';
  Set<DateTime> _availableDates = {};
  DateTime _focusedMonth = DateTime(DateTime.now().year, DateTime.now().month);

  @override
  get init => () async {
        final data = widget.data() ?? {};
        _selectedProfessional = data['selectedProfessional'] as Professional?;
        _professionals = data['professionals'] as List<Professional>? ?? [];
        _selectedServices = data['selectedServices'] as List<Service>? ?? [];
        _serviceAddOns =
            (data['serviceAddOns'] as Map<int, List<AddOn>>?) ?? {};
        _selectedDate = DateTime.now();
        _focusedMonth = DateTime(_selectedDate.year, _selectedDate.month);
        _calculateTotals();
        await _fetchAvailableDatesForMonth(_focusedMonth);
        _updateVisibleDates();
        await _fetchSlotsForDate(_selectedDate);
      };

  void _updateVisibleDates() {
    // Rolling 7 days from today
    final today = DateTime.now();
    _visibleDates = List.generate(
        7, (i) => DateTime(today.year, today.month, today.day + i));
    setState(() {});
  }

  void _calculateTotals() {
    _totalPrice =
        _selectedServices.fold(0, (sum, s) => sum + (s.regionalPrice ?? 0));
    _totalPrice += _serviceAddOns.values.expand((list) => list).fold(
        0, (sum, addon) => sum + (double.tryParse(addon.price ?? "0") ?? 0));
    int totalMinutes =
        _selectedServices.fold(0, (sum, s) => sum + (s.durationMinutes ?? 0));
    _durationText = totalMinutes > 0
        ? '${(totalMinutes ~/ 60)} Hours ${(totalMinutes % 60)} mins'
        : '';
  }

  Future<void> _fetchAvailableDatesForMonth(DateTime month) async {
    if (_selectedProfessional?.id == null || _selectedServices.isEmpty) return;
    final serviceId = _selectedServices.first.id;
    final year = month.year;
    final m = month.month;
    final firstDay = DateTime(year, m, 1);
    final lastDay = DateTime(year, m + 1, 0);
    final startDateStr = DateFormat('yyyy-MM-dd').format(firstDay);
    final endDateStr = DateFormat('yyyy-MM-dd').format(lastDay);
    // Get current user's region
    final user = await AuthService.getCurrentUser();
    final regionId = user?.currentRegion?.id;

    // Query all available slots for the month in one call
    final slots = await ProfessionalsDataService.getAvailableSlots(
      professionalId: _selectedProfessional!.id!,
      serviceId: serviceId,
      startDate: startDateStr,
      endDate: endDateStr,
      regionId: regionId,
    );
    Set<DateTime> available = {};
    if (slots != null && slots.isNotEmpty) {
      for (var entry in slots) {
        if (entry is Map &&
            entry.containsKey('date') &&
            entry['slots'] != null &&
            (entry['slots'] as List).isNotEmpty) {
          final date = DateTime.tryParse(entry['date']);
          if (date != null) {
            // Normalize to midnight
            available.add(DateTime(date.year, date.month, date.day));
          }
        }
      }
    }
    setState(() {
      _availableDates = available;
    });
  }

  Future<void> _fetchSlotsForDate(DateTime date) async {
    setState(() {
      _loading = true;
      _fullyBooked = false;
      _availableTimes = [];
      _nextAvailableDate = null;
    });
    if (_selectedProfessional == null || _selectedServices.isEmpty) {
      setState(() {
        _loading = false;
      });
      return;
    }
    final serviceId = _selectedServices.first.id;
    final dateStr = DateFormat('yyyy-MM-dd').format(date);

    // Get current user's region
    final user = await AuthService.getCurrentUser();
    final regionId = user?.currentRegion?.id;

    final slots = await ProfessionalsDataService.getAvailableSlots(
      professionalId: _selectedProfessional!.id!,
      serviceId: serviceId,
      date: dateStr,
      regionId: regionId,
    );
    if (slots == null || slots.isEmpty) {
      setState(() {
        _fullyBooked = true;
        _loading = false;
      });
    } else {
      // Extract and format start_time for display
      final times = <String>[];
      for (var slot in slots) {
        if (slot is Map &&
            slot['is_available'] == true &&
            slot['start_time'] != null) {
          final startTime = slot['start_time'];
          // Format as e.g. 06:00 AM
          final formatted = _formatTime(startTime);
          times.add(formatted);
        }
      }
      setState(() {
        _availableTimes = times;
        _fullyBooked = false;
        _loading = false;
      });
    }
  }

  String _formatTime(String timeStr) {
    try {
      final t = DateFormat('HH:mm:ss').parse(timeStr);
      return DateFormat('hh:mm a').format(t);
    } catch (_) {
      return timeStr;
    }
  }

  void _showCalendarSheet() async {
    final picked = await showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          padding: EdgeInsets.only(
              top: 24,
              left: 16,
              right: 16,
              bottom: 16 + MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Select date',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              Expanded(
                child: TableCalendar(
                  firstDay: DateTime.now().subtract(Duration(days: 365)),
                  lastDay: DateTime.now().add(Duration(days: 365)),
                  focusedDay: _focusedMonth,
                  selectedDayPredicate: (day) => isSameDay(day, _selectedDate),
                  onDaySelected: (selected, focused) async {
                    if (_availableDates.contains(selected)) {
                      Navigator.pop(context, selected);
                    }
                  },
                  enabledDayPredicate: (day) => _availableDates.any((d) =>
                      d.year == day.year &&
                      d.month == day.month &&
                      d.day == day.day),
                  calendarFormat: CalendarFormat.month,
                  headerVisible: true,
                  onPageChanged: (focusedDay) async {
                    _focusedMonth = DateTime(focusedDay.year, focusedDay.month);
                    await _fetchAvailableDatesForMonth(_focusedMonth);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
      await _fetchSlotsForDate(_selectedDate);
    }
  }

  void _onDateSelected(DateTime date) async {
    setState(() {
      _selectedDate = date;
      _selectedTime = null;
    });
    await _fetchSlotsForDate(_selectedDate);
    // If date is not in visibleDates, update visibleDates to include it (centered if possible)
    if (!_visibleDates.any((d) =>
        d.year == date.year && d.month == date.month && d.day == date.day)) {
      final idx = 3; // center selected date
      _visibleDates = List.generate(
          7, (i) => DateTime(date.year, date.month, date.day - idx + i));
      setState(() {});
    }
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
          "Select Appointment Time",
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          // Professional and Month/Year selectors
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                // Professional dropdown
                Expanded(
                  child: DropdownButton<Professional>(
                    value: _selectedProfessional,
                    isExpanded: true,
                    icon: Icon(Icons.keyboard_arrow_down),
                    underline: SizedBox(),
                    items: _professionals.map((p) {
                      return DropdownMenuItem<Professional>(
                        value: p,
                        child: Row(
                          children: [
                            if (p.imageUrl != null)
                              CircleAvatar(
                                backgroundImage: NetworkImage(p.imageUrl!),
                                radius: 14,
                              ),
                            if (p.imageUrl != null) SizedBox(width: 8),
                            Text(p.name ?? ''),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (p) {
                      setState(() {
                        _selectedProfessional = p;
                      });
                      // Fetch available dates and slots for the new professional
                      _fetchAvailableDatesForMonth(_focusedMonth);
                      _fetchSlotsForDate(_selectedDate);
                    },
                  ),
                ),
                SizedBox(width: 12),
                // Calendar button
                GestureDetector(
                  onTap: _showCalendarSheet,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today, size: 18),
                        SizedBox(width: 6),
                        Text(DateFormat('MMM d').format(_selectedDate)),
                        Icon(Icons.keyboard_arrow_down),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Horizontal date strip (rolling 7 days)
          SizedBox(
            height: 64,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _visibleDates.length,
              itemBuilder: (context, idx) {
                final date = _visibleDates[idx];
                final isSelected = date.day == _selectedDate.day &&
                    date.month == _selectedDate.month &&
                    date.year == _selectedDate.year;
                final isEnabled = _availableDates.any((d) =>
                    d.year == date.year &&
                    d.month == date.month &&
                    d.day == date.day);
                return GestureDetector(
                  onTap: isEnabled ? () => _onDateSelected(date) : null,
                  child: Opacity(
                    opacity: isEnabled ? 1.0 : 0.4,
                    child: Container(
                      width: 56,
                      margin: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                      decoration: BoxDecoration(
                        color:
                            isSelected ? Color(0xFFE8C6B6) : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: isSelected
                            ? Border.all(color: Color(0xFFC8AD87), width: 2)
                            : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            DateFormat('d').format(date),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color:
                                  isSelected ? Color(0xFFC8AD87) : Colors.black,
                            ),
                          ),
                          Text(
                            DateFormat('E').format(date),
                            style: TextStyle(
                              fontSize: 12,
                              color:
                                  isSelected ? Color(0xFFC8AD87) : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Main content
          Expanded(
            child: _loading
                ? Center(child: CircularProgressIndicator())
                : _fullyBooked
                    ? _buildFullyBooked()
                    : _buildAvailableTimes(),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildFullyBooked() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_selectedProfessional?.profileImageUrl != null)
            CircleAvatar(
              backgroundImage:
                  NetworkImage(_selectedProfessional!.profileImageUrl!),
              radius: 32,
            ),
          SizedBox(height: 16),
          Text(
            '${_selectedProfessional?.name ?? "Professional"} is fully booked on this date',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          if (_nextAvailableDate != null)
            Text(
              'Available next from $_nextAvailableDate',
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          SizedBox(height: 24),
          OutlinedButton(
            onPressed: () {
              // Go to nearest available date (simulate)
              setState(() {
                _selectedDate = _selectedDate.add(Duration(days: 5));
              });
              _fetchSlotsForDate(_selectedDate);
            },
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Color(0xFFC8AD87)),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Go to nearest available date',
                    style: TextStyle(color: Color(0xFFC8AD87))),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward, color: Color(0xFFC8AD87)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailableTimes() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemCount: _availableTimes.length,
      itemBuilder: (context, idx) {
        final time = _availableTimes[idx];
        final isSelected = time == _selectedTime;
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedTime = time;
            });
          },
          child: Container(
            margin: EdgeInsets.only(bottom: 12),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            decoration: BoxDecoration(
              color: isSelected ? Color(0xFFF5E6DE) : Colors.white,
              border: Border.all(
                color: isSelected ? Color(0xFFC8AD87) : Color(0xFFE0E0E0),
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              time,
              style: TextStyle(
                fontSize: 16,
                color: isSelected ? Color(0xFFC8AD87) : Colors.black,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFFFFFFFF),
        border: Border(top: BorderSide(color: Color(0xFFE0E0E0))),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '£${_totalPrice.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF000000),
                  ),
                ),
                Text(
                  '${_selectedServices.length} service${_selectedServices.length != 1 ? 's' : ''}  •  $_durationText',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF666666),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 16),
          SizedBox(
            width: 140,
            height: 54,
            child: ElevatedButton(
              onPressed: _selectedTime != null
                  ? () {
                      // Continue to ReviewPage
                      routeTo(
                        ReviewPage.path,
                        data: {
                          'selectedProfessional': _selectedProfessional,
                          'professionals': _professionals,
                          'selectedServices': _selectedServices,
                          'serviceAddOns': _serviceAddOns,
                          'selectedDate': _selectedDate,
                          'selectedTime': _selectedTime,
                          'totalPrice': _totalPrice,
                          'durationText': _durationText,
                        },
                      );
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _selectedTime != null
                    ? Color(0xFF000000)
                    : Color(0xFF9E9E9E),
                disabledBackgroundColor: Color(0xFF9E9E9E),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.zero,
                elevation: 0,
              ),
              child: Text(
                "Continue",
                style: TextStyle(
                  color: Color(0xFFFFFFFF),
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
}

class _WeekdayAvailability {
  final int weekday; // 1=Mon, 7=Sun
  final String? startTime;
  final String? endTime;
  _WeekdayAvailability({required this.weekday, this.startTime, this.endTime});
}

class _PartialUnavailability {
  final DateTime date;
  final String startTime;
  final String endTime;
  _PartialUnavailability(
      {required this.date, required this.startTime, required this.endTime});
}
