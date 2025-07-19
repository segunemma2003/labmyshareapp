import 'package:flutter/material.dart';
import 'package:flutter_app/app/services/auth_service.dart';
import 'package:flutter_app/resources/pages/profile_detail_page.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_app/app/models/user.dart';
import 'dart:convert'; // Add this import

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  createState() => _ProfileTabState();
}

class _ProfileTabState extends NyState<ProfileTab> {
  User? _user;
  String? _errorMessage;

  @override
  get init => () async {
        await _loadUserData();
      };

  Future<void> _loadUserData() async {
    print("-------------------------");

    try {
      setLoading(true, name: 'user_data');
      print('ProfileTab: Starting to load user data...');

      // First check if user is authenticated
      final isAuth = await AuthService.isAuthenticated();
      print('ProfileTab: User authenticated: $isAuth');

      if (!isAuth) {
        print('ProfileTab: User not authenticated');
        if (mounted) {
          setState(() {
            _user = null;
            _errorMessage = null;
          });
        }
        return;
      }

      // Get current user
      User? userData = await AuthService.getCurrentUser();
      print(userData);

      // print('ProfileTab: Retrieved user: $user');

      // print('ProfileTab: User details:');
      // print('  - ID: ${user.id}');
      // print('  - Email: ${user.email}');
      // print('  - First Name: ${user.firstName}');
      // print('  - Last Name: ${user.lastName}');
      // print('  - Full Name: ${user.fullName}');
      // print('  - Profile Picture: ${user.profilePicture}');
      // print('  - Current Region: ${user.currentRegion?.name}');

      if (mounted) {
        setState(() {
          _user = userData;
          _errorMessage = null;
        });
      }
    } catch (e, stackTrace) {
      print('ProfileTab: Error loading user: $e');
      print('ProfileTab: Stack trace: $stackTrace');

      if (mounted) {
        setState(() {
          _errorMessage = "Failed to load user data: $e";
        });
      }
    } finally {
      if (mounted) {
        setLoading(false, name: 'user_data');
      }
    }
  }

  void _editProfilePicture() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      try {
        setLoading(true, name: 'profile_picture');
        print('ProfileTab: Updating profile picture...');

        bool success =
            await AuthService.updateProfileImage(imagePath: pickedFile.path);
        print('ProfileTab: Profile picture update success: $success');

        if (success) {
          // Reload user data after successful update
          await _loadUserData();
          showToast(
            title: "Success",
            description: "Profile picture updated.",
            style: ToastNotificationStyleType.success,
          );
        } else {
          showToast(
            title: "Error",
            description: "Failed to update profile picture.",
            style: ToastNotificationStyleType.danger,
          );
        }
      } catch (e) {
        print("ProfileTab: Error updating profile picture: $e");
        showToast(
          title: "Error",
          description: "Failed to update profile picture.",
          style: ToastNotificationStyleType.danger,
        );
      } finally {
        setLoading(false, name: 'profile_picture');
      }
    }
  }

  void _navigateToProfileDetails() {
    routeTo("/profile-detail");
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

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            _errorMessage ?? "An error occurred",
            style: const TextStyle(
              fontSize: 16,
              color: Colors.red,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadUserData,
            child: const Text("Retry"),
          ),
        ],
      ),
    );
  }

  String? _getProfileImageUrl(User? user) {
    if (user?.profilePicture == null || user!.profilePicture!.isEmpty)
      return null;
    final url = user.profilePicture!;
    if (url.startsWith('http')) return url;
    return 'http://backend.beautyspabyshea.co.uk$url';
  }

  Widget _buildMainContent() {
    return SingleChildScrollView(
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
                        image: (_user != null &&
                                _getProfileImageUrl(_user) != null)
                            ? DecorationImage(
                                image:
                                    NetworkImage(_getProfileImageUrl(_user)!),
                                fit: BoxFit.cover,
                              )
                            : DecorationImage(
                                image: AssetImage('profile_image.jpg')
                                    .localAsset(),
                                fit: BoxFit.cover,
                              ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withOpacity(0.3),
                        ),
                        child: isLoading(name: 'profile_picture')
                            ? const Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : null,
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
              Text(
                _user != null ? _getDisplayName(_user!) : "Guest",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF985F5F),
                ),
              ),

              // Show email if name is empty
              if (_user != null && _shouldShowEmail(_user!))
                Text(
                  _user!.email ?? "",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),

              // Debug info (remove in production)
              // if (_user != null)
              //   Padding(
              //     padding: const EdgeInsets.only(top: 8),
              //     child: Text(
              //       'Debug: User ID: ${_user!.id}, Email: ${_user!.email}',
              //       style: TextStyle(
              //         fontSize: 10,
              //         color: Colors.grey.shade400,
              //       ),
              //       textAlign: TextAlign.center,
              //     ),
              //   ),
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

          // Debug section (remove in production)
        ],
      ),
    );
  }

  String _getDisplayName(User user) {
    print('ProfileTab: Getting display name for user...');
    print('  - Full Name: "${user.fullName}"');
    print('  - First Name: "${user.firstName}"');
    print('  - Last Name: "${user.lastName}"');
    print('  - Email: "${user.email}"');

    // Use fullName if available
    if (user.fullName != null && user.fullName!.trim().isNotEmpty) {
      print('  - Using fullName: "${user.fullName!.trim()}"');
      return user.fullName!.trim();
    }

    // Otherwise construct from first and last name
    final firstName = user.firstName ?? '';
    final lastName = user.lastName ?? '';
    final fullName = "$firstName $lastName".trim();
    print('  - Constructed name: "$fullName"');

    // If name is empty, return email or fallback
    if (fullName.isEmpty) {
      final fallback = user.email ?? "Guest";
      print('  - Using fallback: "$fallback"');
      return fallback;
    }

    return fullName;
  }

  bool _shouldShowEmail(User user) {
    final fullName = user.fullName ?? '';
    final firstName = user.firstName ?? '';
    final lastName = user.lastName ?? '';
    final constructedName = "$firstName $lastName".trim();

    // Show email if both fullName and constructed name are empty
    return fullName.isEmpty && constructedName.isEmpty && user.email != null;
  }

  @override
  Widget view(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _errorMessage != null
            ? _buildErrorState()
            : afterLoad(
                child: () => _buildMainContent(),
                loadingKey: 'user_data',
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
