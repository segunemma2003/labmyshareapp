import 'package:flutter/material.dart';
import 'package:flutter_app/app/services/auth_service.dart';
import 'package:flutter_app/app/services/region_service.dart';
import 'package:flutter_app/app/services/services_data_service.dart';
import 'package:flutter_app/app/models/service_item.dart' show ServiceCategory;
import 'package:flutter_app/app/models/region.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
  String? _userFirstName;

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

      // Extract user's first name
      if (user != null) {
        _userFirstName =
            user.firstName ?? user.email?.split('@').first ?? 'User';
      }

      if (regions != null && regions.isNotEmpty) {
        setState(() {
          _regions = regions;
          // Find the matching region from the API list using the code
          if (user?.currentRegion?.code != null) {
            _selectedRegion = _regions.firstWhere(
              (region) => region.code == user!.currentRegion!.code,
              orElse: () => regions.first,
            );
          } else {
            _selectedRegion = regions.first;
          }
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
      print('Error loading regions and user: $e');
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
      final categories = await ServicesDataService.getFeaturedCategories();
      setState(() {
        _categories = categories;
        _loadingCategories = false;
      });
    } catch (e) {
      print('Error loading featured categories: $e');
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
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Section
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Greeting
                        Text(
                          "Hello ${_userFirstName ?? 'User'}",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFC8AD87), // Light brown color
                          ),
                        ),
                        SizedBox(height: 8),

                        // Location with building icon
                        Row(
                          children: [
                            Icon(
                              Icons.location_city,
                              color: Colors.black,
                              size: 16,
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: _loadingRegions
                                  ? Text(
                                      'Loading...',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    )
                                  : _errorRegions
                                      ? Text(
                                          'Failed to load regions',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.red,
                                          ),
                                        )
                                      : DropdownButton<Region>(
                                          isExpanded: true,
                                          value: _selectedRegion,
                                          icon: Icon(Icons.keyboard_arrow_down,
                                              size: 16),
                                          underline: SizedBox(),
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.black,
                                          ),
                                          items: _regions.map((region) {
                                            return DropdownMenuItem<Region>(
                                              value: region,
                                              child: Text(
                                                region.name ?? '',
                                                style: TextStyle(fontSize: 14),
                                              ),
                                            );
                                          }).toList(),
                                          onChanged: (region) =>
                                              _onRegionChanged(region),
                                        ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24),

                  // Main Promotional Banner
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      height: 250,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Stack(
                          children: [
                            // Background Image
                            Image.asset(
                              'home_tab_cover.png',
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                            ).localAsset(),
                            // Text Overlay
                            Positioned(
                              bottom: 20,
                              left: 20,
                              right: 20,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ShaderMask(
                                    shaderCallback: (bounds) => LinearGradient(
                                      colors: [
                                        Color(0xFFFFFFFF), // #FFFFFF
                                        Color(0xFFF3D4A9), // #F3D4A9
                                      ],
                                    ).createShader(bounds),
                                    child: Text(
                                      'Welcome To The',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 26,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  ShaderMask(
                                    shaderCallback: (bounds) => LinearGradient(
                                      colors: [
                                        Color(0xFFFFFFFF), // #FFFFFF
                                        Color(0xFFF3D4A9), // #F3D4A9
                                      ],
                                    ).createShader(bounds),
                                    child: Text(
                                      'Beauty Spa By Shea',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 32),

                  // Recent Categories Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Featured Categories",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            // Navigate to all services
                            routeTo('/select-services', data: {
                              'categories': _categories,
                            });
                          },
                          child: Text(
                            "All Services",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFFC8AD87),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 16),

                  // Featured Categories - 1 on top (full width), 2 below (side by side)
                  if (!_loadingCategories &&
                      !_errorCategories &&
                      _categories.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          // First row - 1 category full width
                          _buildFeaturedCategoryCard(_categories[0]),
                          SizedBox(height: 16),
                          // Second row - 2 categories side by side
                          if (_categories.length > 1)
                            Row(
                              children: [
                                Expanded(
                                  child: _buildFeaturedCategoryCard(
                                      _categories[1]),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: _categories.length > 2
                                      ? _buildFeaturedCategoryCard(
                                          _categories[2])
                                      : SizedBox(),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),

                  SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ));
  }

  Widget _buildFeaturedCategoryCard(ServiceCategory category) {
    final String title = category.name;
    final String? iconUrl = category.icon;

    return GestureDetector(
      onTap: () {
        routeTo('/select-services', data: {
          'categories': _categories,
          'initialCategory': category,
        });
      },
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
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
                    child: Center(child: Icon(Icons.image, color: Colors.grey)),
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
                      Colors.black.withValues(alpha: 0.7),
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
                    fontSize: 14,
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
    );
  }
}
