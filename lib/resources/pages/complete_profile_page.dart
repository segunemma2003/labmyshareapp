import 'package:flutter/material.dart';
import 'package:flutter_app/resources/pages/select_region_page.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter_app/app/services/auth_service.dart';
import 'package:flutter_app/resources/pages/confirm_selfie_page.dart';
import 'package:country_picker/country_picker.dart';

class CompleteProfilePage extends NyStatefulWidget {
  static RouteView path = ("/complete-profile", (_) => CompleteProfilePage());

  CompleteProfilePage({super.key})
      : super(child: () => _CompleteProfilePageState());
}

class _CompleteProfilePageState extends NyPage<CompleteProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();

  String _selectedGender = '';
  DateTime? _selectedDate;
  File? _profileImage;
  bool _isLoading = false;

  // Country code variables
  String _selectedCountryCode = '+44'; // Default to UK
  String _selectedCountryFlag = '🇬🇧';

  final ImagePicker _picker = ImagePicker();

  final List<String> _genderOptions = [
    'Male',
    'Female',
    'Other',
    'Prefer not to say'
  ];

  @override
  get init => () async {
        // Preload user data if available
        final data = widget.data();
        if (data != null && data is Map<String, dynamic>) {
          _firstNameController.text = data['first_name'] ?? '';
          _lastNameController.text = data['last_name'] ?? '';
          _phoneController.text = data['phone_number'] ?? '';
          // Gender mapping if available
          if (data['gender'] != null && data['gender'].toString().isNotEmpty) {
            switch (data['gender']) {
              case 'M':
                _selectedGender = 'Male';
                break;
              case 'F':
                _selectedGender = 'Female';
                break;
              case 'O':
                _selectedGender = 'Other';
                break;
              case 'P':
                _selectedGender = 'Prefer not to say';
                break;
              default:
                _selectedGender = data['gender'];
            }
          }
          if (data['date_of_birth'] != null &&
              data['date_of_birth'].toString().isNotEmpty) {
            try {
              final parts = data['date_of_birth'].toString().split('-');
              if (parts.length == 3) {
                _selectedDate = DateTime(
                  int.parse(parts[0]),
                  int.parse(parts[1]),
                  int.parse(parts[2]),
                );
              }
            } catch (_) {}
          }
          setState(() {});
        } else {
          final user = await AuthService.getCurrentUser();
          if (user != null) {
            _firstNameController.text = user.firstName ?? '';
            _lastNameController.text = user.lastName ?? '';
            _phoneController.text = user.phoneNumber ?? '';
            if (user.gender != null && user.gender!.isNotEmpty) {
              switch (user.gender) {
                case 'M':
                  _selectedGender = 'Male';
                  break;
                case 'F':
                  _selectedGender = 'Female';
                  break;
                case 'O':
                  _selectedGender = 'Other';
                  break;
                case 'P':
                  _selectedGender = 'Prefer not to say';
                  break;
              }
            }
            if (user.dateOfBirth != null && user.dateOfBirth!.isNotEmpty) {
              try {
                final parts = user.dateOfBirth!.split('-');
                if (parts.length == 3) {
                  _selectedDate = DateTime(
                    int.parse(parts[0]),
                    int.parse(parts[1]),
                    int.parse(parts[2]),
                  );
                }
              } catch (_) {}
            }
            setState(() {});
          }
        }
      };

  @override
  void dispose() {
    _firstNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget view(BuildContext context) {
    return Theme(
      data: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.grey,
        primaryColor: Color(0xFF000000),
        colorScheme: ColorScheme.light(
          primary: Color(0xFF000000),
          secondary: Color(0xFF000000),
          surface: Color(0xFFFFFFFF),
        ),
      ),
      child: Scaffold(
        backgroundColor: Color(0xFFFFFFFF),
        appBar: AppBar(
          backgroundColor: Color(0xFFFFFFFF),
          elevation: 0,
          automaticallyImplyLeading: false,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    "Complete Your Profile",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF000000),
                    ),
                  ),
                  SizedBox(height: 8),

                  // Subtitle
                  Text(
                    "Don't worry only you can see your personal data. No one else will be able to see it.",
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF666666),
                    ),
                  ),
                  SizedBox(height: 32),

                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Profile Picture
                          Center(
                            child: GestureDetector(
                              onTap: _pickImage,
                              child: Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFFE0E0E0),
                                ),
                                child: Stack(
                                  children: [
                                    Container(
                                      width: 120,
                                      height: 120,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Color(0xFFE0E0E0),
                                        image: _profileImage != null
                                            ? DecorationImage(
                                                image:
                                                    FileImage(_profileImage!),
                                                fit: BoxFit.cover,
                                              )
                                            : null,
                                      ),
                                      child: _profileImage == null
                                          ? Icon(
                                              Icons.person,
                                              size: 60,
                                              color: Color(0xFF9E9E9E),
                                            )
                                          : null,
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: Container(
                                        width: 36,
                                        height: 36,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Color(0xFF000000),
                                          border: Border.all(
                                            color: Color(0xFFFFFFFF),
                                            width: 2,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.camera_alt,
                                          size: 18,
                                          color: Color(0xFFFFFFFF),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 32),

                          // First Name
                          _buildLabel("First name"),
                          _buildTextField(
                            controller: _firstNameController,
                            hintText: "Demi 3D",
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your first name';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 20),
                          // Last Name
                          _buildLabel("Last name"),
                          _buildTextField(
                            controller: _lastNameController,
                            hintText: "Doe",
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your last name';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 20),

                          // Phone Number
                          _buildLabel("Phone Number"),
                          _buildPhoneField(),
                          SizedBox(height: 20),

                          // Gender
                          _buildLabel("Gender"),
                          _buildGenderDropdown(),
                          SizedBox(height: 20),

                          // Date of Birth
                          _buildLabel("Date of birth"),
                          _buildDateField(),
                          SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),

                  // Complete Profile Button
                  GestureDetector(
                    onTap: _isValidForm() && !_isLoading
                        ? _handleCompleteProfile
                        : null,
                    child: Container(
                      width: double.infinity,
                      height: 54,
                      decoration: BoxDecoration(
                        color: _isValidForm()
                            ? Color(0xFF000000)
                            : Color(0xFFE0E0E0),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: _isLoading
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Color(0xFFFFFFFF)),
                                ),
                              )
                            : Text(
                                "Complete Profile",
                                style: TextStyle(
                                  color: _isValidForm()
                                      ? Color(0xFFFFFFFF)
                                      : Color(0xFF9E9E9E),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Color(0xFF000000),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Material(
      color: Colors.transparent,
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        style: TextStyle(
          color: Color(0xFF000000),
          fontSize: 16,
        ),
        cursorColor: Color(0xFF000000),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: Color(0xFFBDBDBD),
            fontSize: 16,
          ),
          filled: true,
          fillColor: Color(0xFFFAFAFA),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Color(0xFFE0E0E0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Color(0xFFE0E0E0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Color(0xFF000000), width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Color(0xFFF44336)),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Color(0xFFF44336), width: 2),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          errorStyle: TextStyle(color: Color(0xFFF44336)),
        ),
      ),
    );
  }

  Widget _buildPhoneField() {
    return Row(
      children: [
        // Country Code Dropdown
        GestureDetector(
          onTap: () {
            showCountryPicker(
              context: context,
              showPhoneCode: true,
              onSelect: (Country country) {
                setState(() {
                  _selectedCountryCode = country.phoneCode;
                  _selectedCountryFlag = country.flagEmoji;
                });
              },
            );
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              color: Color(0xFFFAFAFA),
              border: Border.all(color: Color(0xFFE0E0E0)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _selectedCountryFlag,
                  style: TextStyle(
                    color: Color(0xFF000000),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(width: 4),
                Text(
                  _selectedCountryCode,
                  style: TextStyle(
                    color: Color(0xFF000000),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(width: 4),
                Icon(
                  Icons.keyboard_arrow_down,
                  color: Color(0xFF666666),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: 8),
        // Phone Number Input
        Expanded(
          child: Material(
            color: Colors.transparent,
            child: TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              style: TextStyle(
                color: Color(0xFF000000),
                fontSize: 16,
              ),
              cursorColor: Color(0xFF000000),
              decoration: InputDecoration(
                hintText: "Enter Phone Number",
                hintStyle: TextStyle(
                  color: Color(0xFFBDBDBD),
                  fontSize: 16,
                ),
                filled: true,
                fillColor: Color(0xFFFAFAFA),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Color(0xFFE0E0E0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Color(0xFFE0E0E0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Color(0xFF000000), width: 2),
                ),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your phone number';
                }
                return null;
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderDropdown() {
    return GestureDetector(
      onTap: _showGenderPicker,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Color(0xFFFAFAFA),
          border: Border.all(color: Color(0xFFE0E0E0)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _selectedGender.isEmpty ? "Select" : _selectedGender,
              style: TextStyle(
                color: _selectedGender.isEmpty
                    ? Color(0xFFBDBDBD)
                    : Color(0xFF000000),
                fontSize: 16,
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down,
              color: Color(0xFF666666),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateField() {
    return GestureDetector(
      onTap: _pickDate,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Color(0xFFFAFAFA),
          border: Border.all(color: Color(0xFFE0E0E0)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _selectedDate == null
                  ? "Set date of birth"
                  : "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}",
              style: TextStyle(
                color: _selectedDate == null
                    ? Color(0xFFBDBDBD)
                    : Color(0xFF000000),
                fontSize: 16,
              ),
            ),
            Icon(
              Icons.calendar_today,
              size: 20,
              color: Color(0xFF666666),
            ),
          ],
        ),
      ),
    );
  }

  void _showGenderPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Color(0xFFFFFFFF),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Select Gender",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF000000),
              ),
            ),
            SizedBox(height: 20),
            ..._genderOptions
                .map((gender) => ListTile(
                      title: Text(
                        gender,
                        style: TextStyle(color: Color(0xFF000000)),
                      ),
                      onTap: () {
                        setState(() {
                          _selectedGender = gender;
                        });
                        Navigator.pop(context);
                      },
                    ))
                .toList(),
          ],
        ),
      ),
    );
  }

  void _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xFF000000),
              onPrimary: Color(0xFFFFFFFF),
              surface: Color(0xFFFFFFFF),
              onSurface: Color(0xFF000000),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _profileImage = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to pick image. Please try again.',
            style: TextStyle(color: Color(0xFFFFFFFF)),
          ),
          backgroundColor: Color(0xFFF44336),
        ),
      );
    }
  }

  bool _isValidForm() {
    return _firstNameController.text.isNotEmpty &&
        _lastNameController.text.isNotEmpty &&
        _phoneController.text.isNotEmpty &&
        _selectedGender.isNotEmpty &&
        _selectedDate != null;
  }

  Future<void> _handleCompleteProfile() async {
    if (_formKey.currentState!.validate() && _isValidForm()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // 1. Update profile info (without image)
        final firstName = _firstNameController.text.trim();
        final lastName = _lastNameController.text.trim();
        final phone = _selectedCountryCode +
            _phoneController.text.trim(); // Combine country code with phone
        final gender = _selectedGender.isNotEmpty
            ? _selectedGender[0].toUpperCase()
            : null; // 'M', 'F', 'O', 'P'
        final dateOfBirth = _selectedDate != null
            ? "${_selectedDate!.year.toString().padLeft(4, '0')}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}"
            : null;

        final success = await AuthService.updateProfile(
          firstName: firstName,
          lastName: lastName,
          phoneNumber: phone,
          dateOfBirth: dateOfBirth,
          gender: gender,
        );

        if (!success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Failed to complete profile. Please try again.',
                style: TextStyle(color: Color(0xFFFFFFFF)),
              ),
              backgroundColor: Color(0xFFF44336),
            ),
          );
          setState(() {
            _isLoading = false;
          });
          return;
        }

        // 2. If user picked a profile image, go to ConfirmSelfiePage for confirmation
        if (_profileImage != null) {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ConfirmSelfiePage(),
              settings: RouteSettings(arguments: {'image': _profileImage}),
            ),
          );

          if (result is Map &&
              result['confirmed'] == true &&
              result['image'] != null) {
            // Upload the confirmed image
            final uploadSuccess = await AuthService.updateProfileImage(
                imagePath: result['image'].path);
            if (!uploadSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Failed to upload profile picture. You can add it later in your profile.',
                    style: TextStyle(color: Color(0xFFFFFFFF)),
                  ),
                  backgroundColor: Color(0xFFF44336),
                ),
              );
            }
          }
        }

        // 3. Navigate to select region page
        routeTo(
          SelectRegionPage.path,
          navigationType: NavigationType.pushAndRemoveUntil,
          removeUntilPredicate: (route) => false,
        );
      } catch (e) {
        // Handle error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to complete profile. Please try again.',
              style: TextStyle(color: Color(0xFFFFFFFF)),
            ),
            backgroundColor: Color(0xFFF44336),
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
