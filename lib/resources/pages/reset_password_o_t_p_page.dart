import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/app/services/auth_service.dart';
import 'package:flutter_app/app/utils/api_error_handler.dart';
import 'package:flutter_app/resources/pages/new_password_page.dart';
import 'package:nylo_framework/nylo_framework.dart';

class ResetPasswordOTPPage extends NyStatefulWidget {
  static RouteView path =
      ("/reset-password-otp", (_) => ResetPasswordOTPPage());

  ResetPasswordOTPPage({super.key})
      : super(child: () => _ResetPasswordOTPPageState());
}

class _ResetPasswordOTPPageState extends NyPage<ResetPasswordOTPPage> {
  final List<TextEditingController> _controllers =
      List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());

  bool _canResend = false;
  int _resendCountdown = 120; // 2 minutes as per API rate limit
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
    _resendCountdown = 120; // 2 minutes
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

  String _formatCountdown() {
    int minutes = _resendCountdown ~/ 60;
    int seconds = _resendCountdown % 60;
    return '${minutes}:${seconds.toString().padLeft(2, '0')}';
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  "Verify Reset Code",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF000000),
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
                    color: Color(0xFF666666),
                  ),
                ),
                SizedBox(height: 12),

                // OTP expiry info
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Color(0xFFFFE0B2)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.timer_outlined,
                          size: 16, color: Color(0xFFE65100)),
                      SizedBox(width: 8),
                      Text(
                        "Code expires in 10 minutes",
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFFE65100),
                        ),
                      ),
                    ],
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
                        color: Color(0xFF666666),
                      ),
                    ),
                    GestureDetector(
                      onTap: _canResend && !isLocked('resend_otp')
                          ? _handleResendCode
                          : null,
                      child: Text(
                        _canResend
                            ? "Resend code"
                            : "Resend code (${_formatCountdown()})",
                        style: TextStyle(
                          fontSize: 14,
                          color: _canResend
                              ? Color(0xFF2196F3)
                              : Color(0xFF9E9E9E),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),

                Spacer(),

                // Verify Button
                GestureDetector(
                  onTap: _isValidCode() && !isLocked('verify_reset_otp')
                      ? _handleVerify
                      : null,
                  child: Container(
                    width: double.infinity,
                    height: 54,
                    decoration: BoxDecoration(
                      color: _isValidCode()
                          ? Color(0xFF000000)
                          : Color(0xFFE0E0E0),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: isLocked('verify_reset_otp')
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
                              "Verify Code",
                              style: TextStyle(
                                color: _isValidCode()
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
    );
  }

  Widget _buildOTPField(int index) {
    return Container(
      width: 50,
      height: 64,
      decoration: BoxDecoration(
        border: Border.all(
          color: _controllers[index].text.isNotEmpty
              ? Color(0xFF2196F3)
              : Color(0xFFE0E0E0),
          width: _controllers[index].text.isNotEmpty ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(8),
        color: Color(0xFFFAFAFA),
      ),
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Color(0xFF000000),
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
    if (!_isValidCode() || _email == null) return;

    await lockRelease('verify_reset_otp', perform: () async {
      try {
        final success = await AuthService.verifyResetOtp(
          email: _email!,
          otp: _getOTPCode(),
        );

        if (success) {
          // Show success message
          showToastNotification(
            context,
            style: ToastNotificationStyleType.success,
            title: "Success",
            description: "Code verified successfully!",
          );

          // Navigate to new password page with email and OTP
          routeTo(NewPasswordPage.path, data: {
            'email': _email,
            'otp': _getOTPCode(),
          });
        } else {
          // Invalid code
          showToastNotification(
            context,
            style: ToastNotificationStyleType.danger,
            title: "Invalid Code",
            description: "The verification code is invalid or has expired.",
          );
          _clearFields();
        }
      } catch (e) {
        ApiErrorHandler.handleError(e, context: context);
        _clearFields();
      }
    });
  }

  Future<void> _handleResendCode() async {
    if (!_canResend || _email == null) return;

    await lockRelease('resend_otp', perform: () async {
      try {
        final success = await AuthService.resendOtp(
          email: _email!,
          purpose: 'password_reset',
        );

        if (success) {
          // Show success message
          showToastNotification(
            context,
            style: ToastNotificationStyleType.success,
            title: "Code Sent",
            description: "A new verification code has been sent to your email.",
          );

          // Restart timer
          _startResendTimer();

          // Clear existing input
          _clearFields();
        } else {
          showToastNotification(
            context,
            style: ToastNotificationStyleType.danger,
            title: "Error",
            description: "Failed to resend code. Please try again later.",
          );
        }
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
}
