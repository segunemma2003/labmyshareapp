import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';

class ServicesTab extends StatefulWidget {
  const ServicesTab({super.key});

  @override
  createState() => _ServicesTabState();
}

class _ServicesTabState extends NyState<ServicesTab> {
  // All service categories
  final List<ServiceCategory> _allCategories = [
    ServiceCategory(title: 'Braids', image: 'category1.jpg'),
    ServiceCategory(title: 'Cut and Coloring', image: 'category2.png'),
    ServiceCategory(title: 'Scalp Treatment', image: 'category3.png'),
    ServiceCategory(title: 'Wig Service', image: 'category4.jpg'),
    ServiceCategory(title: 'Hair Smoothing', image: 'category5.png'),
    ServiceCategory(title: 'Clip ins & Treatments', image: 'category6.png'),
    ServiceCategory(title: 'Mini Twist Packages', image: 'category7.jpg'),
    ServiceCategory(title: 'Hair Maintenance', image: 'category8.png'),
  ];

  // Team members
  final List<TeamMember> _teamMembers = [
    TeamMember(name: 'Professional 1', image: 'user1.png'),
    TeamMember(name: 'Professional 2', image: 'user1.png'),
    TeamMember(name: 'Professional 3', image: 'user1.png'),
    TeamMember(name: 'Professional 4', image: 'user1.png'),
  ];

  @override
  get init => () {
        // Initialize any data here
      };

  @override
  Widget view(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      body: SafeArea(
        child: Column(
          children: [
            // Header Section
            Container(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Location Dropdown
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Color(0xFFE0E0E0)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // UK Flag
                        Container(
                          width: 20,
                          height: 14,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: CustomPaint(
                            painter: UKFlagPainter(),
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          "Beckenham, England, United kingdom",
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF666666),
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(
                          Icons.keyboard_arrow_down,
                          size: 16,
                          color: Color(0xFF666666),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),

                  // Services Title
                  Text(
                    "Services",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF000000),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // All Categories Section
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        "All Categories",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF000000),
                        ),
                      ),
                    ),

                    SizedBox(height: 16),

                    // Categories Grid
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1.2,
                        ),
                        itemCount: _allCategories.length,
                        itemBuilder: (context, index) {
                          return _buildCategoryCard(_allCategories[index]);
                        },
                      ),
                    ),

                    SizedBox(height: 32),

                    // Our Team Section
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        "Our Team of Professionals",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF000000),
                        ),
                      ),
                    ),

                    SizedBox(height: 16),

                    // Team Members Row
                    Container(
                      height: 100,
                      child: ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        scrollDirection: Axis.horizontal,
                        itemCount: _teamMembers.length,
                        itemBuilder: (context, index) {
                          return _buildTeamMemberCard(
                              _teamMembers[index], index);
                        },
                      ),
                    ),

                    SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(ServiceCategory category) {
    return GestureDetector(
      onTap: () {
        // Navigate to category details
        print('Selected category: ${category.title}');
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
                category.image,
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
                  category.title,
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

// Data models
class ServiceCategory {
  final String title;
  final String image;

  ServiceCategory({
    required this.title,
    required this.image,
  });
}

class TeamMember {
  final String name;
  final String image;

  TeamMember({
    required this.name,
    required this.image,
  });
}
