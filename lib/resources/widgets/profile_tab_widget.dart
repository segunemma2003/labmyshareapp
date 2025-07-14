import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  createState() => _ProfileTabState();
}

class _ProfileTabState extends NyState<ProfileTab> {
  @override
  get init => () {};

  void _editProfilePicture() {
    print("Edit profile picture pressed");
    // Implement image picker functionality
  }

  void _navigateToProfileDetails() {
    print("Profile details pressed");
    // Navigate to profile details page
  }

  void _navigateToLocation() {
    print("Location pressed");
    // Navigate to location settings
  }

  void _navigateToPaymentDetails() {
    print("Payment details pressed");
    // Navigate to payment methods page
  }

  void _navigateToGetHelp() {
    print("Get help pressed");
    // Navigate to help/support page
  }

  void _navigateToFAQs() {
    print("FAQs pressed");
    // Navigate to FAQs page
  }

  void _navigateToLegal() {
    print("Legal pressed");
    // Navigate to legal/terms page
  }

  void _navigateToReviews() {
    print("Reviews pressed");
    // Navigate to user reviews page
  }

  @override
  Widget view(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // Profile picture and name section
              Column(
                children: [
                  // Profile picture with camera overlay
                  GestureDetector(
                    onTap: _editProfilePicture,
                    child: Stack(
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey.shade200,
                            image: DecorationImage(
                              image: AssetImage(
                                'profile_image.jpg',
                              ).localAsset(),
                              fit: BoxFit.cover,
                              onError: null,
                            ),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black.withOpacity(0.3),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 8,
                          right: 8,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              size: 16,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // User name
                  const Text(
                    "Cassandra Jones",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF8B4513),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // Personal section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Personal",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildProfileOption(
                    icon: Icons.person_outline,
                    title: "Profile details",
                    onTap: _navigateToProfileDetails,
                  ),
                  _buildProfileOption(
                    icon: Icons.location_on_outlined,
                    title: "Location",
                    onTap: _navigateToLocation,
                  ),
                  _buildProfileOption(
                    icon: Icons.payment_outlined,
                    title: "Payment details",
                    onTap: _navigateToPaymentDetails,
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Support section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Support",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildProfileOption(
                    icon: Icons.help_outline,
                    title: "Get help",
                    onTap: _navigateToGetHelp,
                  ),
                  _buildProfileOption(
                    icon: Icons.quiz_outlined,
                    title: "FAQs",
                    onTap: _navigateToFAQs,
                  ),
                  _buildProfileOption(
                    icon: Icons.description_outlined,
                    title: "Legal",
                    onTap: _navigateToLegal,
                  ),
                  _buildProfileOption(
                    icon: Icons.rate_review_outlined,
                    title: "Reviews",
                    onTap: _navigateToReviews,
                  ),
                ],
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey.shade400,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
