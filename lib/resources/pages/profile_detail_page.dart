import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';

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

  bool _isEditing = false;
  bool _hasChanges = false;

  @override
  get init => () {
        // Initialize with sample data
        _accountNameController.text = "Cassandra Jones";
        _phoneController.text = "+22 564 6765 565";
        _emailController.text = "cassjones23@gmail.com";
        _dateOfBirthController.text = "";

        // Add listeners to detect changes
        _accountNameController.addListener(_onFieldChanged);
        _phoneController.addListener(_onFieldChanged);
        _emailController.addListener(_onFieldChanged);
        _dateOfBirthController.addListener(_onFieldChanged);
      };

  void _onFieldChanged() {
    setState(() {
      _hasChanges = true;
    });
  }

  @override
  void dispose() {
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
            readOnly: isDateField,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(color: Colors.grey.shade500),
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              suffixIcon: IconButton(
                icon: Icon(Icons.edit, color: Colors.grey.shade600, size: 20),
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
    // Implementation for editing account name
  }

  void _editPhoneNumber() {
    // Implementation for editing phone number
  }

  void _editEmail() {
    // Implementation for editing email
  }

  void _editDateOfBirth() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        _dateOfBirthController.text =
            "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
        _hasChanges = true;
      });
    }
  }

  void _saveChanges() {
    // Implementation for saving changes
    setState(() {
      _hasChanges = false;
    });

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Profile updated successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _signOut() {
    // Implementation for sign out
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
              onPressed: () {
                Navigator.of(context).pop();
                // Navigate to login screen
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteAccount() {
    // Implementation for delete account
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
                // Delete account logic
              },
            ),
          ],
        );
      },
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
        child: Column(
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
                    ),
                    SizedBox(height: 24),
                    _buildInputField(
                      label: "Phone number",
                      controller: _phoneController,
                      onEdit: _editPhoneNumber,
                    ),
                    SizedBox(height: 24),
                    _buildInputField(
                      label: "Email",
                      controller: _emailController,
                      onEdit: _editEmail,
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
                    onPressed: _saveChanges,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
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
                          Icon(Icons.exit_to_app,
                              color: Colors.black87, size: 20),
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
                          Icon(Icons.delete_outline,
                              color: Colors.red, size: 20),
                          SizedBox(width: 16),
                          Text(
                            "Delete account",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.red,
                            ),
                          ),
                          Spacer(),
                          Icon(Icons.arrow_forward,
                              color: Colors.red, size: 20),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
