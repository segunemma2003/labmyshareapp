import 'package:flutter/material.dart';
import 'package:flutter_app/app/services/auth_service.dart';
import 'package:flutter_app/app/services/region_service.dart';
import 'package:flutter_app/app/services/services_data_service.dart';
import 'package:flutter_app/app/models/service_item.dart' show ServiceCategory;
import 'package:flutter_app/app/models/region.dart';
import 'package:nylo_framework/nylo_framework.dart';

class HomeTab extends NyStatefulWidget {
  HomeTab({super.key});

  @override
  createState() => _HomeTabState();
}

class _HomeTabState extends NyState<HomeTab> {
  Region? _selectedRegion;
  List<Region> _regions = [];
  List<ServiceCategory> _categories = [];
  bool _loadingRegions = true;
  bool _loadingCategories = true;
  bool _errorRegions = false;
  bool _errorCategories = false;

  @override
  get init => () async {
        await _loadRegionsAndUser();
      };

  Future<void> _loadRegionsAndUser() async {
    setState(() {
      _loadingRegions = true;
      _errorRegions = false;
    });
    try {
      final user = await AuthService.getCurrentUser();
      final regions = await RegionService.getRegions();
      Region? currentRegion = user?.currentRegion;
      if (regions != null && regions.isNotEmpty) {
        setState(() {
          _regions = regions;
          _selectedRegion = currentRegion ?? regions.first;
          _loadingRegions = false;
        });
        await _loadCategories();
      } else {
        setState(() {
          _loadingRegions = false;
          _errorRegions = true;
        });
      }
    } catch (e) {
      setState(() {
        _loadingRegions = false;
        _errorRegions = true;
      });
    }
  }

  Future<void> _loadCategories() async {
    setState(() {
      _loadingCategories = true;
      _errorCategories = false;
    });
    try {
      final categories = await ServicesDataService.getServiceCategories();
      setState(() {
        _categories = categories;
        _loadingCategories = false;
      });
    } catch (e) {
      setState(() {
        _loadingCategories = false;
        _errorCategories = true;
      });
    }
  }

  Future<void> _onRegionChanged(Region? region) async {
    if (region == null || region.code == _selectedRegion?.code) return;
    setState(() {
      _selectedRegion = region;
      _loadingCategories = true;
    });
    // Switch region in backend and update local storage
    await AuthService.switchRegion(regionCode: region.code!);
    await _loadCategories();
  }

  @override
  Widget view(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Region Dropdown
                  _loadingRegions
                      ? const SizedBox(
                          height: 40,
                          child: Center(child: CircularProgressIndicator()))
                      : _errorRegions
                          ? Row(
                              children: [
                                Icon(Icons.error, color: Colors.red),
                                SizedBox(width: 8),
                                Text('Failed to load regions'),
                              ],
                            )
                          : Row(
                              children: [
                                Icon(Icons.location_city,
                                    color: Colors.brown, size: 20),
                                SizedBox(width: 8),
                                Expanded(
                                  child: DropdownButton<Region>(
                                    isExpanded: true,
                                    value: _selectedRegion,
                                    icon: Icon(Icons.keyboard_arrow_down),
                                    underline: SizedBox(),
                                    items: _regions.map((region) {
                                      return DropdownMenuItem<Region>(
                                        value: region,
                                        child: Row(
                                          children: [
                                            Text(
                                              region.name ?? '',
                                              style: TextStyle(fontSize: 16),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (region) =>
                                        _onRegionChanged(region),
                                  ),
                                ),
                              ],
                            ),
                  SizedBox(height: 16),
                  // Banner Image
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        'home_banner.jpg',
                        width: double.infinity,
                        height: 160,
                        fit: BoxFit.cover,
                      ).localAsset(),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Services",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "All Categories",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: _loadingCategories
                  ? Center(child: CircularProgressIndicator())
                  : _errorCategories
                      ? Center(child: Text('Failed to load categories'))
                      : Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: GridView.builder(
                            itemCount: _categories.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 1.1,
                            ),
                            itemBuilder: (context, index) {
                              final category = _categories[index];
                              return _buildCategoryCard(category);
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(ServiceCategory category) {
    final String title = category.name;
    final String? iconUrl = category.icon;
    return GestureDetector(
      onTap: _loadingCategories
          ? null
          : () {
              if (_categories.isEmpty) {
                print('Navigation blocked: _categories is empty');
                return;
              }

              try {
                print(
                    'Navigating to /select-services with category: ${category.name}');
                routeTo('/select-services', data: {
                  'categories': _categories,
                  'initialCategory': category,
                });
              } catch (e) {
                print('Navigation error: $e');
                // Optionally show a snackbar or dialog to the user
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('Unable to navigate. Please try again.')),
                );
              }
            },
      child: Opacity(
        opacity: _loadingCategories ? 0.5 : 1.0,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                if (iconUrl != null && iconUrl.isNotEmpty)
                  Image.network(
                    iconUrl,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[200],
                      child:
                          Center(child: Icon(Icons.image, color: Colors.grey)),
                    ),
                  )
                else
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: Colors.grey[200],
                    child: Center(child: Icon(Icons.image, color: Colors.grey)),
                  ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 12,
                  left: 12,
                  right: 12,
                  child: Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
