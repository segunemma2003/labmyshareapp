import 'package:flutter/material.dart';
import 'package:flutter_app/app/models/add_on_service.dart';
import 'package:flutter_app/app/models/service_item.dart';
import 'package:flutter_app/resources/widgets/service_details_bottom_sheet_widget.dart'
    show ServiceDetailsBottomSheet;
import 'package:nylo_framework/nylo_framework.dart';

class SelectServicesPage extends NyStatefulWidget {
  static RouteView path = ("/select-services", (_) => SelectServicesPage());

  SelectServicesPage({super.key})
      : super(child: () => _SelectServicesPageState());
}

class _SelectServicesPageState extends NyPage<SelectServicesPage> {
  String _selectedCategory = 'Braids';
  List<ServiceItem> _selectedServices = [];
  List<AddOnService> _selectedAddOns = [];

  final List<String> _categories = [
    'Braids',
    'Cut & coloring',
    'Scalp treatment',
    'Wig services'
  ];

  final List<ServiceItem> _braidServices = [
    ServiceItem(
      title: 'Small knotless braids (waist length)',
      duration: '8 hours 30 minutes',
      price: 160,
      instructions: [
        'Please ensure your hair is washed and tangle free',
        'Mid Back Length',
        'Please bring 3 packs of Impressions or Xpressions Pre stretched hair.'
      ],
    ),
    ServiceItem(
      title: 'Medium knotless braids (waist length)',
      duration: '8 hours',
      price: 150,
    ),
    ServiceItem(
      title: 'Fulani knotless braids (waist length)',
      duration: '7 Hours 30 minutes',
      price: 130,
    ),
    ServiceItem(
      title: 'Freestyle Fulani braids (waist length)',
      duration: '8 hours',
      price: 140,
    ),
    ServiceItem(
      title: 'Large knotless braids (waist length)',
      duration: '6 hours',
      price: 10,
    ),
    ServiceItem(
      title: 'Knotless Braids (Children)',
      duration: '4 hours',
      price: 80,
    ),
  ];

  final List<AddOnService> _availableAddOns = [
    AddOnService(
      title: '9am premium slot charge',
      duration: '10 Minutes',
      price: 20,
      type: AddOnType.optional,
    ),
    AddOnService(
      title: 'Blow dry (standard comb attachment blow dry)',
      duration: '1 Hour',
      price: 20,
      type: AddOnType.optional,
    ),
    AddOnService(
      title: 'Deep Cleanse Hair Detox',
      duration: '1 Hours',
      price: 60,
      type: AddOnType.recommended,
    ),
    AddOnService(
      title: 'Knotless braids take down',
      duration: '10 Minutes',
      price: 20,
      priceType: 'From',
      type: AddOnType.recommended,
    ),
    AddOnService(
      title: 'Premium slot',
      duration: '10 Minutes',
      price: 20,
      type: AddOnType.optional,
    ),
    AddOnService(
      title: 'Take down (cornrows/Braids)',
      duration: '45 Minutes',
      price: 20,
      type: AddOnType.optional,
    ),
  ];

  @override
  get init => () {
        // Initialize any data here
      };

  @override
  Widget view(BuildContext context) {
    return Theme(
      data: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.grey,
        primaryColor: Color(0xFF000000),
        colorScheme: ColorScheme.light(
          primary: Color(0xFF000000),
          secondary: Color(0xFF000000),
          surface: Color(0xFFFFFFFF),
          background: Color(0xFFFFFFFF),
        ),
      ),
      child: Scaffold(
        backgroundColor: Color(0xFFFFFFFF),
        appBar: AppBar(
          backgroundColor: Color(0xFFFFFFFF),
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Color(0xFF000000)),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            "Select Services",
            style: TextStyle(
              color: Color(0xFF000000),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: Column(
          children: [
            // Category Tabs
            Container(
              height: 50,
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final isSelected = _selectedCategory == category;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.only(right: 16),
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color:
                            isSelected ? Color(0xFF000000) : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? Color(0xFF000000)
                              : Color(0xFFE0E0E0),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          category,
                          style: TextStyle(
                            color: isSelected
                                ? Color(0xFFFFFFFF)
                                : Color(0xFF666666),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            SizedBox(height: 16),

            // Services Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category Title and Description
                    Text(
                      _selectedCategory,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF000000),
                      ),
                    ),
                    SizedBox(height: 8),

                    if (_selectedCategory == 'Braids')
                      Text(
                        "From classic styles to intricate designs, we offer a range of braid services tailored to suit your taste and occasion. Whether you're looking for box braids, cornrows, twists, or any trending style.",
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF666666),
                          height: 1.5,
                        ),
                      ),

                    SizedBox(height: 24),

                    // Services List
                    if (_selectedCategory == 'Braids')
                      ..._braidServices
                          .map((service) => _buildServiceItem(service))
                          .toList(),

                    SizedBox(height: 100), // Space for bottom bar
                  ],
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar:
            _selectedServices.isNotEmpty ? _buildBottomBar() : null,
      ),
    );
  }

  Widget _buildServiceItem(ServiceItem service) {
    final isSelected = _selectedServices.any((s) => s.title == service.title);

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Color(0xFFE0E0E0)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF000000),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  service.duration,
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF666666),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "From £${service.price}",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF000000),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _showServiceDetails(service),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? Color(0xFF8B4513) : Color(0xFFFFFFFF),
                border: Border.all(
                  color: isSelected ? Color(0xFF8B4513) : Color(0xFFE0E0E0),
                ),
              ),
              child: Icon(
                isSelected ? Icons.check : Icons.add,
                color: isSelected ? Color(0xFFFFFFFF) : Color(0xFF666666),
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    double totalPrice =
        _selectedServices.fold(0, (sum, service) => sum + service.price);
    totalPrice += _selectedAddOns.fold(0, (sum, addon) => sum + addon.price);

    String totalDuration =
        "8 Hours 30 mins - 9 Hours"; // Calculate actual duration

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
                  "£${totalPrice.toInt()}",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF000000),
                  ),
                ),
                Text(
                  "${_selectedServices.length} service${_selectedServices.length != 1 ? 's' : ''} • $totalDuration",
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
            onPressed: () {
              // Navigate to next step
            },
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

  void _showServiceDetails(ServiceItem service) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ServiceDetailsBottomSheet(
        service: service,
        availableAddOns: _availableAddOns,
        onAddToBooking: (service, selectedAddOns) {
          setState(() {
            if (!_selectedServices.any((s) => s.title == service.title)) {
              _selectedServices.add(service);
            }
            _selectedAddOns.addAll(selectedAddOns);
          });
        },
      ),
    );
  }
}
