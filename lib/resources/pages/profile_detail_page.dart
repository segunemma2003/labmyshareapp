import 'package:flutter/material.dart';
import 'package:flutter_app/app/services/auth_service.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:flutter_app/app/models/user.dart';
import 'package:image_picker/image_picker.dart';

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

  User? _user;

  @override
  boot() async {
    await _loadUserData();
  }

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

      // Get current user
      final user = await AuthService.getCurrentUser();
      print('ProfileDetailPage: Retrieved user: $user');

      if (user != null) {
        print('ProfileDetailPage: User details:');
        print('  - ID: ${user.id}');
        print('  - Email: ${user.email}');
        print('  - First Name: ${user.firstName}');
        print('  - Last Name: ${user.lastName}');
        print('  - Full Name: ${user.fullName}');
        print('  - Phone: ${user.phoneNumber}');
        print('  - Date of Birth: ${user.dateOfBirth}');
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
    // Use fullName if available, otherwise construct from first and last name
    final displayName = user.fullName?.trim() ??
        "${user.firstName ?? ''} ${user.lastName ?? ''}".trim();

    _accountNameController.text = displayName;
    _phoneController.text = user.phoneNumber ?? "";
    _emailController.text = user.email ?? "";
    _dateOfBirthController.text = user.dateOfBirth ?? "";

    // Add listeners to track changes
    _accountNameController.addListener(_onFieldChanged);
    _phoneController.addListener(_onFieldChanged);
    _emailController.addListener(_onFieldChanged);
    _dateOfBirthController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    if (!_hasChanges) {
      setState(() {
        _hasChanges = true;
      });
    }
  }

  @override
  void dispose() {
    _accountNameController.removeListener(_onFieldChanged);
    _phoneController.removeListener(_onFieldChanged);
    _emailController.removeListener(_onFieldChanged);
    _dateOfBirthController.removeListener(_onFieldChanged);

    _accountNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _dateOfBirthController.dispose();
    super.dispose();
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required VoidCallback onEdit,
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
            readOnly: isDateField || isEmailField,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(color: Colors.grey.shade500),
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              suffixIcon: isEmailField
                  ? Icon(Icons.email, color: Colors.grey.shade400, size: 20)
                  : IconButton(
                      icon: Icon(Icons.edit,
                          color: Colors.grey.shade600, size: 20),
                      onPressed: onEdit,
                    ),
            ),
            style: TextStyle(
              fontSize: 16,
              color: controller.text.isEmpty
                  ? Colors.grey.shade500
                  : Colors.black87,
            ),
            onTap: isDateField ? onEdit : null,
          ),
        ),
      ],
    );
  }

  void _editAccountName() {
    showDialog(
      context: context,
      builder: (context) {
        final nameController =
            TextEditingController(text: _accountNameController.text);
        return AlertDialog(
          title: Text('Edit Account Name'),
          content: TextField(
            controller: nameController,
            decoration: InputDecoration(
              labelText: 'Full Name',
              hintText: 'Enter your full name',
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _accountNameController.text = nameController.text;
                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _editPhoneNumber() {
    showDialog(
      context: context,
      builder: (context) {
        final phoneController =
            TextEditingController(text: _phoneController.text);
        return AlertDialog(
          title: Text('Edit Phone Number'),
          content: TextField(
            controller: phoneController,
            decoration: InputDecoration(
              labelText: 'Phone Number',
              hintText: 'Enter your phone number',
            ),
            keyboardType: TextInputType.phone,
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _phoneController.text = phoneController.text;
                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
          ],
        );
      },
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
        final parts = _dateOfBirthController.text.split('/');
        if (parts.length == 3) {
          currentDate = DateTime(
            int.parse(parts[2]),
            int.parse(parts[1]),
            int.parse(parts[0]),
          );
        }
      } catch (e) {
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
      setState(() {
        _dateOfBirthController.text =
            "${pickedDate.day.toString().padLeft(2, '0')}/${pickedDate.month.toString().padLeft(2, '0')}/${pickedDate.year}";
      });
    }
  }

  void _saveChanges() async {
    try {
      setLoading(true, name: 'saving_profile');

      final names = _accountNameController.text.trim().split(' ');
      final firstName = names.isNotEmpty ? names.first : '';
      final lastName = names.length > 1 ? names.sublist(1).join(' ') : '';

      final success = await AuthService.updateProfile(
        firstName: firstName,
        lastName: lastName,
        phoneNumber: _phoneController.text.trim(),
        dateOfBirth: _dateOfBirthController.text.trim(),
      );

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
          // Reload user data after successful update
          await _loadUserData();
        }
      }
    } catch (e) {
      print("Error saving profile: $e");
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
                  onEdit: _editAccountName,
                  hintText: "Enter your full name",
                ),
                SizedBox(height: 24),
                _buildInputField(
                  label: "Phone number",
                  controller: _phoneController,
                  onEdit: _editPhoneNumber,
                  hintText: "Enter your phone number",
                ),
                SizedBox(height: 24),
                _buildInputField(
                  label: "Email",
                  controller: _emailController,
                  onEdit: _editEmail,
                  isEmailField: true,
                ),
                SizedBox(height: 24),
                _buildInputField(
                  label: "Date of birth",
                  controller: _dateOfBirthController,
                  onEdit: _editDateOfBirth,
                  hintText: "Set date of birth",
                  isDateField: true,
                ),
                SizedBox(height: 40),

                // Debug section (remove in production)
                // if (_user != null)
                // Container(
                //   padding: const EdgeInsets.all(16),
                //   decoration: BoxDecoration(
                //     color: Colors.grey.shade100,
                //     borderRadius: BorderRadius.circular(8),
                //   ),
                //   child: Column(
                //     crossAxisAlignment: CrossAxisAlignment.start,
                //     children: [
                //       const Text(
                //         'Debug Info:',
                //         style: TextStyle(fontWeight: FontWeight.bold),
                //       ),
                //       const SizedBox(height: 8),
                //       Text('ID: ${_user!.id}'),
                //       Text('Email: ${_user!.email}'),
                //       Text('First Name: "${_user!.firstName}"'),
                //       Text('Last Name: "${_user!.lastName}"'),
                //       Text('Full Name: "${_user!.fullName}"'),
                //       Text('Phone: "${_user!.phoneNumber}"'),
                //       Text('Date of Birth: "${_user!.dateOfBirth}"'),
                //       Text('Profile Completed: ${_user!.profileCompleted}'),
                //       Text('Is Verified: ${_user!.isVerified}'),
                //       Text(
                //           'Current Region: ${_user!.currentRegion?.name ?? 'None'}'),
                //     ],
                //   ),
                // ),
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
