import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:flutter_app/app/services/auth_service.dart';
import 'package:flutter_app/app/services/region_service.dart';
import 'package:flutter_app/app/services/services_data_service.dart';
import 'package:flutter_app/app/models/service_item.dart';
import 'package:flutter_app/app/models/region.dart';
import 'package:flutter_app/resources/pages/select_services_page.dart';

class ServicesTab extends StatefulWidget {
  const ServicesTab({super.key});

  @override
  createState() => _ServicesTabState();
}

class _ServicesTabState extends NyState<ServicesTab> {
  // Region and category management
  Region? _selectedRegion;
  List<Region> _regions = [];
  List<ServiceCategory> _allCategories = [];
  ServiceCategory? _selectedCategory;

  // Loading and error states
  bool _loadingRegions = true;
  bool _loadingCategories = true;
  bool _errorRegions = false;
  bool _errorCategories = false;

  // Team members (keep your existing team members)
  final List<TeamMember> _teamMembers = [
    TeamMember(name: 'Professional 1', image: 'user1.png'),
    TeamMember(name: 'Professional 2', image: 'user1.png'),
    TeamMember(name: 'Professional 3', image: 'user1.png'),
    TeamMember(name: 'Professional 4', image: 'user1.png'),
  ];

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
      print('Error loading regions: $e');
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
        _allCategories = categories;
        _selectedCategory = categories.isNotEmpty ? categories.first : null;
        _loadingCategories = false;
      });
    } catch (e) {
      print('Error loading categories: $e');
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

  void _onCategoryChanged(ServiceCategory? category) {
    if (category != null) {
      setState(() => _selectedCategory = category);

      // Navigate to SelectServicesPage with selected category
      try {
        print('Navigating to select-services with category: ${category.name}');
        routeTo(SelectServicesPage.path, data: {
          'categories': _allCategories,
          'initialCategory': category,
          'activeCategory': category, // For backward compatibility
        });
      } catch (e) {
        print('Navigation error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to navigate. Please try again.')),
        );
      }
    }
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
                                SizedBox(width: 8),
                                TextButton(
                                  onPressed: _loadRegionsAndUser,
                                  child: Text('Retry'),
                                ),
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
                                    onChanged: _onRegionChanged,
                                  ),
                                ),
                              ],
                            ),

                  SizedBox(height: 16),

                  // Page Title
                  Text(
                    "Services",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),

                  SizedBox(height: 16),

                  // Category Dropdown
                  _loadingCategories
                      ? const SizedBox(
                          height: 56,
                          child: Center(child: CircularProgressIndicator()))
                      : _errorCategories
                          ? Container(
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.red.shade300),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.error, color: Colors.red),
                                  SizedBox(width: 8),
                                  Expanded(
                                      child: Text('Failed to load categories')),
                                  TextButton(
                                    onPressed: _loadCategories,
                                    child: Text('Retry'),
                                  ),
                                ],
                              ),
                            )
                          : Container(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: DropdownButton<ServiceCategory>(
                                value: _selectedCategory,
                                isExpanded: true,
                                hint: Text('Select a category'),
                                underline: SizedBox(),
                                icon: Icon(Icons.keyboard_arrow_down),
                                items: _allCategories.map((cat) {
                                  return DropdownMenuItem<ServiceCategory>(
                                    value: cat,
                                    child: Text(
                                      cat.name,
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  );
                                }).toList(),
                                onChanged: _onCategoryChanged,
                              ),
                            ),
                ],
              ),
            ),

            SizedBox(height: 16),

            // Categories Grid
            Expanded(
              child: _loadingCategories
                  ? Center(child: CircularProgressIndicator())
                  : _errorCategories
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error_outline,
                                  size: 64, color: Colors.grey),
                              SizedBox(height: 16),
                              Text('Failed to load categories'),
                              SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: _loadCategories,
                                child: Text('Try Again'),
                              ),
                            ],
                          ),
                        )
                      : _allCategories.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.category_outlined,
                                      size: 64, color: Colors.grey),
                                  SizedBox(height: 16),
                                  Text(
                                    'No categories available',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: GridView.builder(
                                itemCount: _allCategories.length,
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                  childAspectRatio: 1.1,
                                ),
                                itemBuilder: (context, index) {
                                  final category = _allCategories[index];
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
              if (_allCategories.isEmpty) {
                print('Navigation blocked: _allCategories is empty');
                return;
              }

              try {
                print(
                    'Navigating to select-services with category: ${category.name}');
                routeTo(SelectServicesPage.path, data: {
                  'categories': _allCategories,
                  'initialCategory': category,
                  'activeCategory': category, // For backward compatibility
                });
              } catch (e) {
                print('Navigation error: $e');
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
                // Category Image
                if (iconUrl != null && iconUrl.isNotEmpty)
                  Image.network(
                    iconUrl,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[200],
                      child: Center(
                        child: Icon(Icons.image, color: Colors.grey, size: 32),
                      ),
                    ),
                  )
                else
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: Colors.grey[200],
                    child: Center(
                      child: Icon(Icons.image, color: Colors.grey, size: 32),
                    ),
                  ),

                // Gradient overlay
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

                // Category title
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

  Widget _buildTeamMemberCard(TeamMember member, int index) {
    return GestureDetector(
      onTap: () {
        // Navigate to team member profile
        print('Selected team member: ${member.name}');
      },
      child: Container(
        margin:
            EdgeInsets.only(right: index < _teamMembers.length - 1 ? 16 : 0),
        child: Column(
          children: [
            // Profile Image
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFF5F5F5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: ClipOval(
                child: Stack(
                  children: [
                    // Use your existing image implementation
                    Image.asset(
                      member.image,
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                    ).localAsset(),
                  ],
                ),
              ),
            ),
            SizedBox(height: 8),

            // Team member name
            Text(
              member.name,
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF666666),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// UK Flag Painter (keeping your existing implementation)
class UKFlagPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Blue background
    final bluePaint = Paint()..color = Color(0xFF012169);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bluePaint);

    // White diagonals
    final whitePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = size.height * 0.3;

    canvas.drawLine(Offset(0, 0), Offset(size.width, size.height), whitePaint);
    canvas.drawLine(Offset(size.width, 0), Offset(0, size.height), whitePaint);

    // White cross
    final whiteCrossPaint = Paint()..color = Colors.white;
    canvas.drawRect(
        Rect.fromLTWH(0, size.height * 0.4, size.width, size.height * 0.2),
        whiteCrossPaint);
    canvas.drawRect(
        Rect.fromLTWH(size.width * 0.4, 0, size.width * 0.2, size.height),
        whiteCrossPaint);

    // Red diagonals
    final redPaint = Paint()
      ..color = Color(0xFFC8102E)
      ..strokeWidth = size.height * 0.15;

    canvas.drawLine(Offset(0, 0), Offset(size.width, size.height), redPaint);
    canvas.drawLine(Offset(size.width, 0), Offset(0, size.height), redPaint);

    // Red cross
    final redCrossPaint = Paint()..color = Color(0xFFC8102E);
    canvas.drawRect(
        Rect.fromLTWH(0, size.height * 0.42, size.width, size.height * 0.16),
        redCrossPaint);
    canvas.drawRect(
        Rect.fromLTWH(size.width * 0.42, 0, size.width * 0.16, size.height),
        redCrossPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// TeamMember class (keeping your existing implementation)
class TeamMember {
  final String name;
  final String image;
  TeamMember({required this.name, required this.image});
}
