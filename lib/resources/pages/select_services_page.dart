import 'package:flutter/material.dart';
import 'package:flutter_app/app/models/service_item.dart';
import 'package:flutter_app/app/services/services_data_service.dart';
import 'package:flutter_app/resources/widgets/service_details_bottom_sheet_widget.dart'
    show ServiceDetailsBottomSheet;
import 'package:nylo_framework/nylo_framework.dart';

class SelectServicesPage extends NyStatefulWidget {
  static RouteView path = ("/select-services", (_) => SelectServicesPage());

  SelectServicesPage({super.key})
      : super(child: () => _SelectServicesPageState());
}

class _SelectServicesPageState extends NyPage<SelectServicesPage> {
  List<ServiceCategory> _categories = [];
  List<Service> _services = [];
  List<Service> _selectedServices = [];
  Map<int, List<AddOn>> _serviceAddOns = {};
  ServiceCategory? _selectedCategory;
  List<AddOn> _categoryAddOns = [];
  bool _loadingCategories = true;
  bool _loadingServices = true;
  bool _errorCategories = false;
  bool _errorServices = false;

  @override
  get init => () async {
        await _loadCategories();
      };

  Future<void> _loadCategories() async {
    setState(() {
      _loadingCategories = true;
      _errorCategories = false;
    });
    try {
      final categories = await ServicesDataService.getServiceCategories();
      setState(() {
        _categories = categories;
        _selectedCategory = categories.isNotEmpty ? categories.first : null;
        _loadingCategories = false;
      });
      if (_selectedCategory != null) {
        await _loadServices(_selectedCategory!.id);
        await _loadCategoryAddOns(_selectedCategory!.id);
      }
    } catch (e) {
      setState(() {
        _loadingCategories = false;
        _errorCategories = true;
      });
    }
  }

  Future<void> _loadCategoryAddOns(int categoryId) async {
    final addOns =
        await ServicesDataService.getCategoryAddons(categoryId: categoryId);
    setState(() {
      _categoryAddOns = addOns ?? [];
    });
  }

  Future<void> _loadServices(dynamic categoryId) async {
    setState(() {
      _loadingServices = true;
      _errorServices = false;
    });
    try {
      // Ensure categoryId is always int
      final int intCategoryId =
          categoryId is int ? categoryId : int.parse(categoryId.toString());
      final services = await ServicesDataService.getCategoryServices(
          categoryId: intCategoryId);
      setState(() {
        _services = services ?? [];
        _loadingServices = false;
      });
    } catch (e) {
      setState(() {
        _loadingServices = false;
        _errorServices = true;
      });
    }
  }

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
            _loadingCategories
                ? SizedBox(
                    height: 50,
                    child: Center(child: CircularProgressIndicator()))
                : _errorCategories
                    ? Center(child: Text('Failed to load categories'))
                    : Container(
                        height: 50,
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _categories.length,
                          itemBuilder: (context, index) {
                            final category = _categories[index];
                            final isSelected =
                                _selectedCategory?.id == category.id;
                            return GestureDetector(
                              onTap: () async {
                                setState(() {
                                  _selectedCategory = category;
                                });
                                await _loadServices(category.id);
                                await _loadCategoryAddOns(category.id);
                              },
                              child: Container(
                                margin: EdgeInsets.only(right: 16),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Color(0xFF000000)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isSelected
                                        ? Color(0xFF000000)
                                        : Color(0xFFE0E0E0),
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    category.name,
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
              child: _loadingServices
                  ? Center(child: CircularProgressIndicator())
                  : _errorServices
                      ? Center(child: Text('Failed to load services'))
                      : SingleChildScrollView(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (_selectedCategory != null) ...[
                                Text(
                                  _selectedCategory!.name,
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF000000),
                                  ),
                                ),
                                if (_selectedCategory!.description != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      _selectedCategory!.description!,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF666666),
                                        height: 1.5,
                                      ),
                                    ),
                                  ),
                              ],
                              SizedBox(height: 24),
                              ..._services
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

  Widget _buildServiceItem(Service service) {
    final isSelected = _selectedServices.any((s) => s.id == service.id);
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
                  service.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF000000),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  service.durationMinutes != null
                      ? "${service.durationMinutes} min"
                      : "",
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF666666),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  service.regionalPrice != null
                      ? "From £${service.regionalPrice!.toStringAsFixed(2)}"
                      : "",
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
    double totalPrice = _selectedServices.fold(
        0, (sum, service) => sum + (service.regionalPrice ?? 0));
    totalPrice += _serviceAddOns.values.expand((list) => list).fold(
        0, (sum, addon) => sum + (double.tryParse(addon.price ?? "0") ?? 0));
    String totalDuration = ""; // You can calculate total duration if needed
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
                  "£${totalPrice.toStringAsFixed(2)}",
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
            onPressed: () async {
              // Navigate to SelectProfessionalPage, passing selected services and add-ons
              routeTo('/select-professional', data: {
                'selectedServices': _selectedServices,
                'serviceAddOns': _serviceAddOns,
              });
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

  void _showServiceDetails(Service service) {
    // Merge category add-ons and service add-ons, avoiding duplicates by id
    final allAddOns = [
      ..._categoryAddOns,
      ...(service.addons ?? [])
          .where((a) => !_categoryAddOns.any((c) => c.id == a.id)),
    ];
    final initialSelectedAddOns = _serviceAddOns[service.id] ?? [];
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ServiceDetailsBottomSheet(
        service: service,
        availableAddOns: allAddOns,
        initiallySelectedAddOns: initialSelectedAddOns,
        onAddToBooking: (service, selectedAddOns) {
          setState(() {
            if (!_selectedServices.any((s) => s.id == service.id)) {
              _selectedServices.add(service);
            }
            _serviceAddOns[service.id] = selectedAddOns;
          });
        },
      ),
    );
  }
}
