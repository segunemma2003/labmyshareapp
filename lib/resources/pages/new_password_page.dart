import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';

class NewPasswordPage extends NyStatefulWidget {
  static RouteView path = ("/new-password", (_) => NewPasswordPage());

  NewPasswordPage({super.key}) : super(child: () => _NewPasswordPageState());
}

class _NewPasswordPageState extends NyPage<NewPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;

  @override
  get init => () {
        // Initialize any data here
      };

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
          background: Color(0xFFFFFFFF),
        ),
      ),
      child: Scaffold(
        backgroundColor: Color(0xFFFFFFFF),
        appBar: AppBar(
          backgroundColor: Color(0xFFFFFFFF),
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Color(0xFF000000)),
            onPressed: () => Navigator.pop(context),
          ),
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
                    "New Password",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF000000),
                    ),
                  ),
                  SizedBox(height: 8),

                  // Subtitle
                  Text(
                    "Your new password must be different from previously used passwords.",
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
                          // Password
                          _buildLabel("Password"),
                          _buildTextField(
                            controller: _passwordController,
                            hintText: "Enter new password",
                            obscureText: !_isPasswordVisible,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Color(0xFF666666),
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a password';
                              }
                              if (value.length < 8) {
                                return 'Password must be at least 8 characters';
                              }
                              if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)')
                                  .hasMatch(value)) {
                                return 'Password must contain uppercase, lowercase and number';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 20),

                          // Confirm Password
                          _buildLabel("Confirm Password"),
                          _buildTextField(
                            controller: _confirmPasswordController,
                            hintText: "Re-enter new password",
                            obscureText: !_isConfirmPasswordVisible,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isConfirmPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Color(0xFF666666),
                              ),
                              onPressed: () {
                                setState(() {
                                  _isConfirmPasswordVisible =
                                      !_isConfirmPasswordVisible;
                                });
                              },
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please confirm your password';
                              }
                              if (value != _passwordController.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),

                  // Create New Password Button
                  GestureDetector(
                    onTap: _isValidForm() && !_isLoading
                        ? _handleCreatePassword
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
                                "Create New Password",
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
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Material(
      color: Colors.transparent,
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
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
          suffixIcon: suffixIcon,
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

  bool _isValidForm() {
    return _passwordController.text.isNotEmpty &&
        _confirmPasswordController.text.isNotEmpty &&
        _passwordController.text == _confirmPasswordController.text &&
        _passwordController.text.length >= 8;
  }

  Future<void> _handleCreatePassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // TODO: Implement your password creation logic here
        // Example:
        // await Auth.createNewPassword(
        //   password: _passwordController.text,
        // );

        // Simulate API call
        await Future.delayed(Duration(seconds: 2));

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Password updated successfully!',
              style: TextStyle(color: Color(0xFFFFFFFF)),
            ),
            backgroundColor: Color(0xFF4CAF50),
          ),
        );

        // Navigate to success page or login
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/sign-in',
          (route) => false,
        );
      } catch (e) {
        // Handle error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to update password. Please try again.',
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
