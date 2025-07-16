import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:flutter_app/app/services/services_data_service.dart';
import 'package:flutter_app/app/models/service_item.dart';
import 'package:flutter_app/resources/pages/select_services_page.dart';

class ServicesTab extends StatefulWidget {
  const ServicesTab({super.key});

  @override
  createState() => _ServicesTabState();
}

class _ServicesTabState extends NyState<ServicesTab> {
  List<ServiceCategory> _allCategories = [];
  ServiceCategory? _selectedCategory;
  bool _loading = true;

  // Team members
  final List<TeamMember> _teamMembers = [
    TeamMember(name: 'Professional 1', image: 'user1.png'),
    TeamMember(name: 'Professional 2', image: 'user1.png'),
    TeamMember(name: 'Professional 3', image: 'user1.png'),
    TeamMember(name: 'Professional 4', image: 'user1.png'),
  ];

  @override
  get init => () async {
        _allCategories = await ServicesDataService.getServiceCategories();
        if (_allCategories.isNotEmpty) {
          _selectedCategory = _allCategories.first;
        }
        setState(() {
          _loading = false;
        });
      };

  @override
  Widget view(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      body: SafeArea(
        child: _loading
            ? Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  // Dropdown for categories
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: DropdownButton<ServiceCategory>(
                      value: _selectedCategory,
                      isExpanded: true,
                      hint: Text('Select a category'),
                      items: _allCategories.map((cat) {
                        return DropdownMenuItem<ServiceCategory>(
                          value: cat,
                          child: Text(cat.name),
                        );
                      }).toList(),
                      onChanged: (cat) {
                        if (cat != null) {
                          setState(() => _selectedCategory = cat);
                          // Navigate to SelectServicesPage with selected category
                          routeTo(SelectServicesPage.path, data: {
                            'activeCategory': cat,
                          });
                        }
                      },
                    ),
                  ),
                  // Optionally, show the grid below or just the dropdown
                  // ... existing code for grid or other UI ...
                ],
              ),
      ),
    );
  }

  Widget _buildCategoryCard(ServiceCategory category) {
    return GestureDetector(
      onTap: () {
        // Navigate to category details
        print('Selected category: ${category.name}');
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              // Image placeholder
              // Container(
              //   width: double.infinity,
              //   height: double.infinity,
              //   color: Color(0xFFF5F5F5),
              //   child: Center(
              //     child: Column(
              //       mainAxisAlignment: MainAxisAlignment.center,
              //       children: [
              //         Icon(
              //           Icons.image,
              //           size: 32,
              //           color: Color(0xFFBDBDBD),
              //         ),
              //         SizedBox(height: 4),
              //         Text(
              //           category.image,
              //           style: TextStyle(
              //             color: Color(0xFFBDBDBD),
              //             fontSize: 10,
              //           ),
              //         ),
              //       ],
              //     ),
              //   ),
              // ),
              // Uncomment and replace with your actual image:
              Image.asset(
                "public/images/category_placeholder.png",
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ).localAsset(),

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
                  category.name,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
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
                    // Image placeholder
                    // Container(
                    //   width: 70,
                    //   height: 70,
                    //   color: Color(0xFFF5F5F5),
                    //   child: Center(
                    //     child: Column(
                    //       mainAxisAlignment: MainAxisAlignment.center,
                    //       children: [
                    //         Icon(
                    //           Icons.person,
                    //           size: 24,
                    //           color: Color(0xFFBDBDBD),
                    //         ),
                    //         Text(
                    //           member.image,
                    //           style: TextStyle(
                    //             color: Color(0xFFBDBDBD),
                    //             fontSize: 8,
                    //           ),
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    // ),
                    // Uncomment and replace with your actual image:
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

            // Team member name (optional)
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

// UK Flag Painter (reusing from previous implementation)
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

// 1. Re-add TeamMember class at the bottom if not imported from elsewhere
class TeamMember {
  final String name;
  final String image;
  TeamMember({required this.name, required this.image});
}
