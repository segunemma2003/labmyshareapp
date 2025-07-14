import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/app/services/auth_service.dart';
import 'package:flutter_app/app/utils/api_error_handler.dart';
import 'package:flutter_app/resources/pages/sign_in_page.dart';
import 'package:flutter_app/resources/pages/select_region_page.dart';
import 'package:nylo_framework/nylo_framework.dart';

class VerifyEmailPage extends NyStatefulWidget {
  static RouteView path = ("/verify-email", (_) => VerifyEmailPage());

  VerifyEmailPage({super.key}) : super(child: () => _VerifyEmailPageState());
}

class _VerifyEmailPageState extends NyPage<VerifyEmailPage> {
  final List<TextEditingController> _controllers =
      List.generate(6, (index) => TextEditingController()); // 6 digits for OTP
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());

  bool _canResend = false;
  int _resendCountdown = 60;
  Timer? _timer;
  String? _email;

  @override
  get init => () {
        // Get email from route data
        final data = widget.data();
        if (data != null && data['email'] != null) {
          _email = data['email'];
        }
      };

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Start timer on first load
    if (_timer == null) {
      _startResendTimer();
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    _timer?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    _canResend = false;
    _resendCountdown = 60;
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_resendCountdown > 0) {
            _resendCountdown--;
          } else {
            _canResend = true;
            timer.cancel();
          }
        });
      }
    });
  }

  @override
  Widget view(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                "Verify Code",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 8),

              // Subtitle
              Text(
                _email != null
                    ? "Please enter the 6-digit code we just sent to $_email"
                    : "Please enter the 6-digit code we just sent to your email",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 48),

              // OTP Input Fields (6 digits)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(6, (index) => _buildOTPField(index)),
              ),
              SizedBox(height: 32),

              // Resend Code Section
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Didn't receive OTP? ",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  GestureDetector(
                    onTap: _canResend ? _handleResendCode : null,
                    child: Text(
                      _canResend
                          ? "Resend code"
                          : "Resend code (${_resendCountdown}s)",
                      style: TextStyle(
                        fontSize: 14,
                        color: _canResend ? Colors.blue : Colors.grey[400],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),

              Spacer(),

              // Verify Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isValidCode() ? _handleVerify : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _isValidCode() ? Colors.black : Colors.grey[300],
                    disabledBackgroundColor: Colors.grey[300],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    "Verify",
                    style: TextStyle(
                      color: _isValidCode() ? Colors.white : Colors.grey[600],
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),

              // Skip for now (for development/testing)
              Center(
                child: TextButton(
                  onPressed: () {
                    // For development - skip verification
                    _navigateToNextPage();
                  },
                  child: Text(
                    "Skip for now (Dev only)",
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOTPField(int index) {
    return Container(
      width: 50,
      height: 64,
      decoration: BoxDecoration(
        border: Border.all(
          color: _controllers[index].text.isNotEmpty
              ? Colors.blue
              : Colors.grey[300]!,
          width: _controllers[index].text.isNotEmpty ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey[50],
      ),
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        keyboardType: TextInputType.number,
        maxLength: 1,
        decoration: InputDecoration(
          counterText: "",
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
        ),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        onChanged: (value) {
          setState(() {});

          if (value.isNotEmpty) {
            // Move to next field
            if (index < 5) {
              _focusNodes[index + 1].requestFocus();
            } else {
              // Hide keyboard when last field is filled
              _focusNodes[index].unfocus();
              // Auto-verify when all fields are filled
              if (_isValidCode()) {
                _handleVerify();
              }
            }
          } else {
            // Move to previous field when deleting
            if (index > 0) {
              _focusNodes[index - 1].requestFocus();
            }
          }
        },
        onTap: () {
          // Clear the field when tapped
          _controllers[index].clear();
        },
      ),
    );
  }

  bool _isValidCode() {
    return _controllers.every((controller) => controller.text.isNotEmpty);
  }

  String _getOTPCode() {
    return _controllers.map((controller) => controller.text).join();
  }

  Future<void> _handleVerify() async {
    if (!_isValidCode()) return;

    // Use Nylo's built-in loading system
    await lockRelease('verify_otp', perform: () async {
      try {
        // For now, we'll simulate verification since the API doesn't have an OTP verification endpoint
        // In a real implementation, you would call an API endpoint like:
        // bool isValid = await AuthService.verifyOTP(email: _email, otp: _getOTPCode());

        String otpCode = _getOTPCode();

        // Simulate API call
        await Future.delayed(Duration(seconds: 1));

        // For demo purposes, accept any 6-digit code
        // In production, this would be validated by your backend
        bool isValid = otpCode.length == 6;

        if (isValid) {
          // Show success message
          showToastNotification(
            context,
            style: ToastNotificationStyleType.success,
            title: "Success",
            description: "Email verified successfully!",
          );

          // Navigate to next page
          _navigateToNextPage();
        } else {
          // Invalid code
          showToastNotification(
            context,
            style: ToastNotificationStyleType.danger,
            title: "Invalid Code",
            description: "Invalid verification code. Please try again.",
          );
          _clearFields();
        }
      } catch (e) {
        // Handle error
        ApiErrorHandler.handleError(e, context: context);
        _clearFields();
      }
    });
  }

  Future<void> _handleResendCode() async {
    if (!_canResend || _email == null) return;

    // Use Nylo's built-in loading system
    await lockRelease('resend_otp', perform: () async {
      try {
        // Since the API doesn't have a specific resend OTP endpoint,
        // we would typically call the forgot password endpoint or similar
        // For now, we'll simulate the resend

        // Example of what you might call:
        // await AuthService.forgotPassword(email: _email!);

        // Simulate API call
        await Future.delayed(Duration(seconds: 1));

        // Show success message
        showToastNotification(
          context,
          style: ToastNotificationStyleType.success,
          title: "Code Sent",
          description: "Verification code has been resent to your email.",
        );

        // Restart timer
        _startResendTimer();

        // Clear existing input
        _clearFields();
      } catch (e) {
        ApiErrorHandler.handleError(e, context: context);
      }
    });
  }

  void _clearFields() {
    for (var controller in _controllers) {
      controller.clear();
    }
    if (_focusNodes.isNotEmpty) {
      _focusNodes[0].requestFocus();
    }
    setState(() {});
  }

  void _navigateToNextPage() {
    // After email verification, navigate to region selection
    // since region selection happens after login/registration
    routeTo(SelectRegionPage.path, removeUntilPredicate: (route) => false);
  }
}
