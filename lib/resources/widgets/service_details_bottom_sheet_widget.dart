import 'package:flutter/material.dart';
import 'package:flutter_app/app/models/service_item.dart';
import 'package:flutter_app/app/services/region_service.dart';

class ServiceDetailsBottomSheet extends StatefulWidget {
  final Service service;
  final List<AddOn> availableAddOns;
  final List<AddOn> initiallySelectedAddOns;
  final Function(Service, List<AddOn>) onAddToBooking;

  const ServiceDetailsBottomSheet({
    Key? key,
    required this.service,
    required this.availableAddOns,
    required this.onAddToBooking,
    this.initiallySelectedAddOns = const [],
  }) : super(key: key);

  @override
  State<ServiceDetailsBottomSheet> createState() =>
      _ServiceDetailsBottomSheetState();
}

class _ServiceDetailsBottomSheetState extends State<ServiceDetailsBottomSheet> {
  late List<AddOn> _selectedAddOns;
  String _currencySymbol = '£'; // Default currency symbol

  @override
  void initState() {
    super.initState();
    _selectedAddOns = List<AddOn>.from(widget.initiallySelectedAddOns);
    _loadCurrencySymbol();
  }

  Future<void> _loadCurrencySymbol() async {
    try {
      _currencySymbol = await RegionService.getCurrentCurrencySymbol();
      if (mounted) setState(() {});
    } catch (e) {
      print('Error loading currency symbol: $e');
      _currencySymbol = '£'; // Default fallback
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: Color(0xFFFFFFFF),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFE0E0E0))),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back, color: Color(0xFF000000)),
                  onPressed: () => Navigator.pop(context),
                ),
                Expanded(
                  child: Text(
                    "Select Services",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF000000),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: Color(0xFF000000)),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Service Title
                  Text(
                    widget.service.name,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF000000),
                    ),
                  ),
                  SizedBox(height: 8),

                  // Duration and Price
                  Text(
                    widget.service.durationMinutes != null
                        ? "${widget.service.durationMinutes} min"
                        : "",
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF666666),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    widget.service.regionalPrice != null
                        ? "From $_currencySymbol${widget.service.regionalPrice!.toStringAsFixed(2)}"
                        : "",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF000000),
                    ),
                  ),

                  SizedBox(height: 24),

                  // Description
                  if (widget.service.description != null &&
                      widget.service.description!.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Text(
                        widget.service.description!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF666666),
                        ),
                      ),
                    ),

                  SizedBox(height: 32),

                  // Add to appointment section
                  Text(
                    "Add to appointment",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF000000),
                    ),
                  ),
                  SizedBox(height: 16),

                  // Add-on services
                  ...widget.availableAddOns.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final addon = entry.value;
                    return Column(
                      children: [
                        _buildAddOnItem(addon),
                        if (idx != widget.availableAddOns.length - 1) ...[
                          SizedBox(height: 8),
                          Divider(height: 1, color: Color(0xFFE0E0E0)),
                          SizedBox(height: 8),
                        ],
                      ],
                    );
                  }).toList(),
                ],
              ),
            ),
          ),

          // Add to booking button
          Container(
            padding: EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  widget.onAddToBooking(widget.service, _selectedAddOns);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF000000),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  "Add to booking",
                  style: TextStyle(
                    color: Color(0xFFFFFFFF),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddOnItem(AddOn addon) {
    final isSelected = _selectedAddOns.any((a) => a.id == addon.id);
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedAddOns.removeWhere((a) => a.id == addon.id);
          } else {
            _selectedAddOns.add(addon);
          }
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFFF5F5F5) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isSelected ? Color(0xFF985F5F) : Colors.transparent,
                border: Border.all(
                  color: Color(0xFF985F5F),
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: isSelected
                  ? Icon(Icons.check, color: Color(0xFFFFFFFF), size: 16)
                  : null,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    addon.name,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF000000),
                    ),
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      if (addon.durationMinutes != null)
                        Text(
                          "${addon.durationMinutes} Minutes",
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF666666),
                          ),
                        ),
                      if (addon.durationMinutes != null) SizedBox(width: 12),
                      if (addon.price != null)
                        Text(
                          "$_currencySymbol${addon.price}",
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF666666),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
