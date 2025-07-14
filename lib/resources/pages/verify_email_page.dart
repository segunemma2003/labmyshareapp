import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nylo_framework/nylo_framework.dart';

class VerifyEmailPage extends NyStatefulWidget {
  static RouteView path = ("/verify-email", (_) => VerifyEmailPage());

  VerifyEmailPage({super.key}) : super(child: () => _VerifyEmailPageState());
}

class _VerifyEmailPageState extends NyPage<VerifyEmailPage> {
  final List<TextEditingController> _controllers =
      List.generate(4, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (index) => FocusNode());

  bool _isLoading = false;
  bool _canResend = false;
  int _resendCountdown = 60;
  Timer? _timer;
  String? _email;

  @override
  get init => () {
        // Timer will be started in didChangeDependencies
      };

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get email from route arguments if passed
    if (_email == null) {
      _email = ModalRoute.of(context)?.settings.arguments as String?;
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
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_resendCountdown > 0) {
          _resendCountdown--;
        } else {
          _canResend = true;
          timer.cancel();
        }
      });
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
                    ? "Please enter the code we just sent to $_email"
                    : "Please enter the code we just sent your email",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 48),

              // OTP Input Fields
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(4, (index) => _buildOTPField(index)),
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
                  onPressed:
                      _isValidCode() && !_isLoading ? _handleVerify : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _isValidCode() ? Colors.black : Colors.grey[300],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
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
                          "Verify",
                          style: TextStyle(
                            color: _isValidCode()
                                ? Colors.white
                                : Colors.grey[600],
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
    );
  }

  Widget _buildOTPField(int index) {
    return Container(
      width: 64,
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
            if (index < 3) {
              _focusNodes[index + 1].requestFocus();
            } else {
              // Hide keyboard when last field is filled
              _focusNodes[index].unfocus();
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

    setState(() {
      _isLoading = true;
    });

    try {
      String otpCode = _getOTPCode();

      // TODO: Implement your OTP verification logic here
      // Example:
      // bool isValid = await Auth.verifyOTP(
      //   email: _email,
      //   code: otpCode,
      // );

      // Simulate API call
      await Future.delayed(Duration(seconds: 2));

      // For demo purposes, let's say code is valid if it's "1234"
      bool isValid = otpCode == "1234";

      if (isValid) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Email verified successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to next page (e.g., home or profile setup)
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        // Invalid code
        _showError('Invalid verification code. Please try again.');
        _clearFields();
      }
    } catch (e) {
      // Handle error
      _showError('Verification failed. Please try again.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleResendCode() async {
    if (!_canResend) return;

    try {
      // TODO: Implement resend OTP logic here
      // Example:
      // await Auth.resendOTP(email: _email);

      // Simulate API call
      await Future.delayed(Duration(seconds: 1));

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Verification code resent!',
            style: TextStyle(color: Color(0xFFFFFFFF)), // Force white text
          ),
          backgroundColor: Color(0xFF4CAF50), // Force green
        ),
      );

      // Restart timer
      _startResendTimer();

      // Clear existing input
      _clearFields();
    } catch (e) {
      _showError('Failed to resend code. Please try again.');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: Color(0xFFFFFFFF)), // Force white text
        ),
        backgroundColor: Color(0xFFF44336), // Force red
      ),
    );
  }

  void _clearFields() {
    for (var controller in _controllers) {
      controller.clear();
    }
    _focusNodes[0].requestFocus();
    setState(() {});
  }
}
