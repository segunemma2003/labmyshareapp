import 'package:flutter/material.dart';
import 'package:flutter_app/app/models/service_item.dart';

class ServiceDetailsBottomSheet extends StatefulWidget {
  final Service service;
  final List<AddOn> availableAddOns;
  final Function(Service, List<AddOn>) onAddToBooking;

  const ServiceDetailsBottomSheet({
    Key? key,
    required this.service,
    required this.availableAddOns,
    required this.onAddToBooking,
  }) : super(key: key);

  @override
  State<ServiceDetailsBottomSheet> createState() =>
      _ServiceDetailsBottomSheetState();
}

class _ServiceDetailsBottomSheetState extends State<ServiceDetailsBottomSheet> {
  List<AddOn> _selectedAddOns = [];

  @override
  void initState() {
    super.initState();
    // Pre-select recommended add-ons (if you have a way to mark them)
    // For now, just leave empty or implement your own logic
    _selectedAddOns = [];
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
                        ? "From £${widget.service.regionalPrice!.toStringAsFixed(2)}"
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
                  ...widget.availableAddOns
                      .map((addon) => _buildAddOnItem(addon))
                      .toList(),
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

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          GestureDetector(
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
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isSelected ? Color(0xFF8B4513) : Colors.transparent,
                border: Border.all(
                  color: Color(0xFF8B4513),
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: isSelected
                  ? Icon(Icons.check, color: Color(0xFFFFFFFF), size: 16)
                  : null,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  addon.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF000000),
                  ),
                ),
                Text(
                  addon.durationMinutes != null && addon.price != null
                      ? "${addon.durationMinutes} min • £${addon.price}"
                      : addon.price != null
                          ? "£${addon.price}"
                          : addon.durationMinutes != null
                              ? "${addon.durationMinutes} min"
                              : "",
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF666666),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
