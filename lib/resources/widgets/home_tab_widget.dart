import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  createState() => _HomeTabState();
}

class _HomeTabState extends NyState<HomeTab> {
  PageController _pageController = PageController();
  int _currentSlide = 0;

  // Sample slider images - replace with your actual images
  final List<String> _sliderImages = [
    'home_banner.jpg',
    'home_banner.jpg',
  ];

  // Categories data
  final List<CategoryItem> _categories = [
    CategoryItem(title: 'Braids', image: 'category1.jpg'),
    CategoryItem(title: 'Cut and Coloring', image: 'category2.png'),
    CategoryItem(title: 'Scalp Treatment', image: 'category3.png'),
    CategoryItem(title: 'Wig Service', image: 'category4.jpg'),
    CategoryItem(title: 'Hair Smoothing', image: 'category5.png'),
    CategoryItem(title: 'Clip ins & Treatments', image: 'category6.png'),
  ];

  @override
  get init => () {
        // Initialize any data here
      };

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

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
                  // Greeting
                  Text(
                    "Hello Cassandra",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF8B4513),
                    ),
                  ),
                  SizedBox(height: 8),

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
                        Icon(
                          Icons.location_on,
                          size: 16,
                          color: Color(0xFF666666),
                        ),
                        SizedBox(width: 4),
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
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Image Slider Section
                    Container(
                      height: 200,
                      margin: EdgeInsets.symmetric(horizontal: 16),
                      child: Stack(
                        children: [
                          // PageView for slider
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Color(0xFFF5F5F5),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: PageView.builder(
                                controller: _pageController,
                                onPageChanged: (index) {
                                  setState(() {
                                    _currentSlide = index;
                                  });
                                },
                                itemCount: _sliderImages.length,
                                itemBuilder: (context, index) {
                                  return Container(
                                    width: double.infinity,
                                    height: 200,
                                    child: Stack(
                                      children: [
                                        // Image placeholder
                                        // Container(
                                        //   width: double.infinity,
                                        //   height: double.infinity,
                                        //   color: Color(0xFFF5F5F5),
                                        //   child: Center(
                                        //     child: Column(
                                        //       mainAxisAlignment:
                                        //           MainAxisAlignment.center,
                                        //       children: [
                                        //         Icon(
                                        //           Icons.image,
                                        //           size: 48,
                                        //           color: Color(0xFFBDBDBD),
                                        //         ),
                                        //         SizedBox(height: 8),
                                        //         Text(
                                        //           "Slider Image ${index + 1}",
                                        //           style: TextStyle(
                                        //             color: Color(0xFFBDBDBD),
                                        //             fontSize: 14,
                                        //           ),
                                        //         ),
                                        //         Text(
                                        //           _sliderImages[index],
                                        //           style: TextStyle(
                                        //             color: Color(0xFFBDBDBD),
                                        //             fontSize: 12,
                                        //           ),
                                        //         ),
                                        //       ],
                                        //     ),
                                        //   ),
                                        // ),
                                        // Uncomment and replace with your actual image:
                                        Image.asset(
                                          _sliderImages[index],
                                          width: double.infinity,
                                          height: double.infinity,
                                          fit: BoxFit.cover,
                                        ).localAsset(),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),

                          // Slide indicators
                          Positioned(
                            bottom: 16,
                            left: 0,
                            right: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                _sliderImages.length,
                                (index) => Container(
                                  margin: EdgeInsets.symmetric(horizontal: 4),
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _currentSlide == index
                                        ? Colors.white
                                        : Colors.white.withOpacity(0.5),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 32),

                    // Recent Categories Section
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Recent Categories",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF000000),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              // Navigate to all services
                            },
                            child: Text(
                              "All Services",
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF8B4513),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
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
                        itemCount: _categories.length,
                        itemBuilder: (context, index) {
                          return _buildCategoryCard(_categories[index]);
                        },
                      ),
                    ),

                    SizedBox(height: 32),

                    // Book Now Button
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 16),
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          // Navigate to booking
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF000000),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          "Book Now",
                          style: TextStyle(
                            color: Color(0xFFFFFFFF),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
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

  Widget _buildCategoryCard(CategoryItem category) {
    return GestureDetector(
      onTap: () {
        // Navigate to category details
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
}

class CategoryItem {
  final String title;
  final String image;

  CategoryItem({
    required this.title,
    required this.image,
  });
}
