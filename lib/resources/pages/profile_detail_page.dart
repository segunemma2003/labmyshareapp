import 'package:flutter/material.dart';
import 'package:flutter_app/app/services/auth_service.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:flutter_app/app/models/user.dart';

class ProfileDetailPage extends NyStatefulWidget {
  static RouteView path = ("/profile-detail", (_) => ProfileDetailPage());

  ProfileDetailPage({super.key})
      : super(child: () => _ProfileDetailPageState());
}

class _ProfileDetailPageState extends NyPage<ProfileDetailPage> {
  final TextEditingController _accountNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _dateOfBirthController = TextEditingController();

  bool _hasChanges = false;
  String? _errorMessage;
  bool _isInitialized = false;

  User? _user;

  @override
  get init => () async {
        await _loadUserData();
      };

  Future<void> _loadUserData() async {
    try {
      setLoading(true, name: 'user_data');
      print('ProfileDetailPage: Starting to load user data...');

      // First check if user is authenticated
      final isAuth = await AuthService.isAuthenticated();
      print('ProfileDetailPage: User authenticated: $isAuth');

      if (!isAuth) {
        print(
            'ProfileDetailPage: User not authenticated, redirecting to login');
        routeTo("/sign-in");
        return;
      }

      // Always get current user from AuthService
      final user = await AuthService.getCurrentUser();

      if (user != null) {
        print('ProfileDetailPage: User loaded successfully');
        print('  - ID: ${user.id}');
        print('  - Email: ${user.email}');
        print('  - First Name: "${user.firstName}"');
        print('  - Last Name: "${user.lastName}"');
        print('  - Full Name: "${user.fullName}"');
        print('  - Phone: "${user.phoneNumber}"');
        print('  - Date of Birth: "${user.dateOfBirth}"');
        print('  - Profile Completed: ${user.profileCompleted}');
      } else {
        print('ProfileDetailPage: User is null');
      }

      if (mounted) {
        setState(() {
          _user = user;
          _errorMessage = null;
        });

        if (user != null) {
          _populateFields(user);
        }
      }
    } catch (e, stackTrace) {
      print('ProfileDetailPage: Error loading user data: $e');
      print('ProfileDetailPage: Stack trace: $stackTrace');

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

  void _populateFields(User user) {
    print('ProfileDetailPage: Populating fields...');

    // Use fullName if available, otherwise construct from first and last name
    final displayName = user.fullName?.trim() ??
        "${user.firstName ?? ''} ${user.lastName ?? ''}".trim();

    print('  - Setting account name to: "$displayName"');
    print('  - Setting phone to: "${user.phoneNumber ?? ""}"');
    print('  - Setting email to: "${user.email ?? ""}"');
    print('  - Setting date of birth to: "${user.dateOfBirth ?? ""}"');

    // Remove any existing listeners first
    if (_isInitialized) {
      _accountNameController.removeListener(_onFieldChanged);
      _phoneController.removeListener(_onFieldChanged);
      _emailController.removeListener(_onFieldChanged);
      _dateOfBirthController.removeListener(_onFieldChanged);
    }

    // Set the field values
    _accountNameController.text = displayName;
    _phoneController.text = user.phoneNumber ?? "";
    _emailController.text = user.email ?? "";
    _dateOfBirthController.text = user.dateOfBirth ?? "";

    // Add listeners to track changes
    _accountNameController.addListener(_onFieldChanged);
    _phoneController.addListener(_onFieldChanged);
    _emailController.addListener(_onFieldChanged);
    _dateOfBirthController.addListener(_onFieldChanged);

    _isInitialized = true;

    // Reset the changes flag since we're just loading initial data
    setState(() {
      _hasChanges = false;
    });

    print('ProfileDetailPage: Fields populated successfully');
  }

  void _onFieldChanged() {
    if (!_hasChanges) {
      print('ProfileDetailPage: Field changed, marking as having changes');
      setState(() {
        _hasChanges = true;
      });
    }
  }

  @override
  void dispose() {
    if (_isInitialized) {
      _accountNameController.removeListener(_onFieldChanged);
      _phoneController.removeListener(_onFieldChanged);
      _emailController.removeListener(_onFieldChanged);
      _dateOfBirthController.removeListener(_onFieldChanged);
    }

    _accountNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _dateOfBirthController.dispose();
    super.dispose();
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    String? hintText,
    bool isDateField = false,
    bool isEmailField = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextFormField(
            controller: controller,
            readOnly: isEmailField, // Only email is readOnly
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(color: Colors.grey.shade500),
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              suffixIcon: isDateField
                  ? Icon(Icons.calendar_today,
                      color: Colors.grey.shade400, size: 20)
                  : null,
            ),
            style: TextStyle(
              fontSize: 16,
              color: controller.text.isEmpty
                  ? Colors.grey.shade500
                  : Colors.black87,
            ),
            onTap: isDateField ? _editDateOfBirth : null,
          ),
        ),
      ],
    );
  }

  void _editEmail() {
    showToast(
      title: "Information",
      description: "Email cannot be changed from this screen.",
      style: ToastNotificationStyleType.info,
    );
  }

  void _editDateOfBirth() async {
    DateTime? currentDate;
    if (_dateOfBirthController.text.isNotEmpty) {
      try {
        // Handle different date formats
        final text = _dateOfBirthController.text;
        if (text.contains('/')) {
          final parts = text.split('/');
          if (parts.length == 3) {
            currentDate = DateTime(
              int.parse(parts[2]),
              int.parse(parts[1]),
              int.parse(parts[0]),
            );
          }
        } else if (text.contains('-')) {
          // Handle YYYY-MM-DD format
          currentDate = DateTime.tryParse(text);
        }
      } catch (e) {
        print('Error parsing date: $e');
        currentDate = null;
      }
    }

    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate:
          currentDate ?? DateTime.now().subtract(Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      // Format as DD/MM/YYYY for display
      final formattedDate =
          "${pickedDate.day.toString().padLeft(2, '0')}/${pickedDate.month.toString().padLeft(2, '0')}/${pickedDate.year}";
      print('ProfileDetailPage: Setting date to: $formattedDate');
      setState(() {
        _dateOfBirthController.text = formattedDate;
      });
    }
  }

  void _saveChanges() async {
    try {
      print('ProfileDetailPage: Starting to save changes...');
      setLoading(true, name: 'saving_profile');

      final accountName = _accountNameController.text.trim();
      final phone = _phoneController.text.trim();
      final dateOfBirth = _dateOfBirthController.text.trim();

      print('  - Account name: "$accountName"');
      print('  - Phone: "$phone"');
      print('  - Date of birth: "$dateOfBirth"');

      // Split the full name into first and last name
      final names = accountName.split(' ');
      final firstName = names.isNotEmpty ? names.first : '';
      final lastName = names.length > 1 ? names.sublist(1).join(' ') : '';

      print('  - First name: "$firstName"');
      print('  - Last name: "$lastName"');

      // Convert date format from DD/MM/YYYY to YYYY-MM-DD if needed
      String? formattedDate;
      if (dateOfBirth.isNotEmpty) {
        try {
          if (dateOfBirth.contains('/')) {
            final parts = dateOfBirth.split('/');
            if (parts.length == 3) {
              formattedDate =
                  "${parts[2]}-${parts[1].padLeft(2, '0')}-${parts[0].padLeft(2, '0')}";
            }
          } else {
            formattedDate = dateOfBirth; // Already in correct format
          }
          print('  - Formatted date: "$formattedDate"');
        } catch (e) {
          print('  - Error formatting date: $e');
          formattedDate = null;
        }
      }

      final success = await AuthService.updateProfile(
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phone.isEmpty ? null : phone,
        dateOfBirth: formattedDate,
      );

      print('ProfileDetailPage: Update result: $success');

      if (mounted) {
        setState(() {
          _hasChanges = false;
        });

        showToast(
          title: success ? "Success" : "Error",
          description: success
              ? 'Profile updated successfully'
              : 'Failed to update profile',
          style: success
              ? ToastNotificationStyleType.success
              : ToastNotificationStyleType.danger,
        );

        if (success) {
          print(
              'ProfileDetailPage: Reloading user data after successful update...');
          // Always reload user data from AuthService after update
          await _loadUserData();
        }
      }
    } catch (e) {
      print("ProfileDetailPage: Error saving profile: $e");
      if (mounted) {
        showToast(
          title: "Error",
          description: 'Error updating profile: ${e.toString()}',
          style: ToastNotificationStyleType.danger,
        );
      }
    } finally {
      if (mounted) {
        setLoading(false, name: 'saving_profile');
      }
    }
  }

  void _signOut() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Sign Out'),
          content: Text('Are you sure you want to sign out?'),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Sign Out'),
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  await AuthService.logout();
                  routeTo("/sign-in");
                } catch (e) {
                  print("Error signing out: $e");
                  showToast(
                    title: "Error",
                    description: "Failed to sign out. Please try again.",
                    style: ToastNotificationStyleType.danger,
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteAccount() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Account'),
          content: Text(
              'Are you sure you want to delete your account? This action cannot be undone.'),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
                showToast(
                  title: "Coming soon",
                  description: "Delete account feature is coming soon.",
                  style: ToastNotificationStyleType.info,
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            _errorMessage ?? "An error occurred",
            style: const TextStyle(fontSize: 16, color: Colors.red),
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

  Widget _buildMainContent() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInputField(
                  label: "Account name",
                  controller: _accountNameController,
                  hintText: "Enter your full name",
                ),
                SizedBox(height: 24),
                _buildInputField(
                  label: "Phone number",
                  controller: _phoneController,
                  hintText: "Enter your phone number",
                ),
                SizedBox(height: 24),
                _buildInputField(
                  label: "Email",
                  controller: _emailController,
                  isEmailField: true,
                  hintText: "Enter your email",
                ),
                SizedBox(height: 24),
                _buildInputField(
                  label: "Date of birth",
                  controller: _dateOfBirthController,
                  isDateField: true,
                  hintText: "Set date of birth",
                ),
                SizedBox(height: 40),

                // Debug section (you can remove this in production)
              ],
            ),
          ),
        ),

        // Save button (conditionally shown)
        if (_hasChanges)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    isLoading(name: 'saving_profile') ? null : _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: isLoading(name: 'saving_profile')
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        "Save",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ),

        // Bottom options
        Container(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              InkWell(
                onTap: _signOut,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    children: [
                      Icon(Icons.exit_to_app, color: Colors.black87, size: 20),
                      SizedBox(width: 16),
                      Text(
                        "Sign out",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      Spacer(),
                      Icon(Icons.arrow_forward,
                          color: Colors.black87, size: 20),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 8),
              InkWell(
                onTap: _deleteAccount,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, color: Colors.red, size: 20),
                      SizedBox(width: 16),
                      Text(
                        "Delete account",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.red,
                        ),
                      ),
                      Spacer(),
                      Icon(Icons.arrow_forward, color: Colors.red, size: 20),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget view(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "Profile Details",
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
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
}
