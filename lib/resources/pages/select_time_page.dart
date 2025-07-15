import 'package:flutter/material.dart';
import 'package:flutter_app/app/models/professional.dart';
import 'package:flutter_app/app/models/service_item.dart';
import 'package:flutter_app/app/services/professionals_data_service.dart';
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

  @override
  get init => () async {
        final data = widget.data() ?? {};
        _selectedProfessional = data['selectedProfessional'] as Professional?;
        _professionals = data['professionals'] as List<Professional>? ?? [];
        _selectedServices = data['selectedServices'] as List<Service>? ?? [];
        _serviceAddOns =
            (data['serviceAddOns'] as Map<int, List<AddOn>>?) ?? {};
        _selectedDate = DateTime.now();
        _calculateTotals();
        await _loadAvailableTimes();
        _generateVisibleDates();
      };

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

  void _generateVisibleDates() {
    // Show 7 days strip for the current week
    final start =
        _selectedDate.subtract(Duration(days: _selectedDate.weekday - 1));
    _visibleDates = List.generate(7, (i) => start.add(Duration(days: i)));
  }

  Future<void> _loadAvailableTimes() async {
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
    // For simplicity, use the first service
    final serviceId = _selectedServices.first.id;
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final slots = await ProfessionalsDataService.getAvailableSlots(
      professionalId: _selectedProfessional!.id!,
      serviceId: serviceId,
      date: dateStr,
    );
    if (slots == null || slots.isEmpty) {
      // Simulate next available date (in real app, get from API)
      setState(() {
        _fullyBooked = true;
        _nextAvailableDate = DateFormat('EEEE, d MMMM')
            .format(_selectedDate.add(Duration(days: 5)));
        _loading = false;
      });
    } else {
      setState(() {
        _availableTimes = List<String>.from(slots.map((s) => s.toString()));
        _fullyBooked = false;
        _loading = false;
      });
    }
  }

  void _onDateSelected(DateTime date) async {
    setState(() {
      _selectedDate = date;
      _selectedTime = null;
    });
    await _loadAvailableTimes();
    _generateVisibleDates();
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
                                backgroundImage: AssetImage(p.imageUrl!),
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
                      _loadAvailableTimes();
                    },
                  ),
                ),
                SizedBox(width: 12),
                // Month/Year picker
                DropdownButton<String>(
                  value: DateFormat('MMMM yyyy').format(_selectedDate),
                  items: [
                    DateFormat('MMMM yyyy').format(_selectedDate),
                  ]
                      .map((str) => DropdownMenuItem<String>(
                            value: str,
                            child: Text(str),
                          ))
                      .toList(),
                  onChanged: (_) {}, // For now, static
                ),
              ],
            ),
          ),
          // Horizontal date strip
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
                return GestureDetector(
                  onTap: () => _onDateSelected(date),
                  child: Container(
                    width: 56,
                    margin: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                    decoration: BoxDecoration(
                      color:
                          isSelected ? Color(0xFFE8C6B6) : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
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
                                isSelected ? Color(0xFF8B4513) : Colors.black,
                          ),
                        ),
                        Text(
                          DateFormat('E').format(date),
                          style: TextStyle(
                            fontSize: 12,
                            color: isSelected ? Color(0xFF8B4513) : Colors.grey,
                          ),
                        ),
                      ],
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
          if (_selectedProfessional?.imageUrl != null)
            CircleAvatar(
              backgroundImage: AssetImage(_selectedProfessional!.imageUrl!),
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
              _loadAvailableTimes();
              _generateVisibleDates();
            },
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Color(0xFF8B4513)),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Go to nearest available date',
                    style: TextStyle(color: Color(0xFF8B4513))),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward, color: Color(0xFF8B4513)),
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
                color: isSelected ? Color(0xFF8B4513) : Color(0xFFE0E0E0),
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              time,
              style: TextStyle(
                fontSize: 16,
                color: isSelected ? Color(0xFF8B4513) : Colors.black,
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
          ElevatedButton(
            onPressed: _selectedTime != null
                ? () {
                    // Continue to next step
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF000000),
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
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
        ],
      ),
    );
  }
}
