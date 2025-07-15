import 'package:flutter/material.dart';
import 'package:flutter_app/app/services/auth_service.dart';
import 'package:flutter_app/app/utils/api_error_handler.dart';
import 'package:flutter_app/resources/pages/base_navigation_hub.dart';
import 'package:flutter_app/resources/pages/forgot_password_page.dart';
import 'package:flutter_app/resources/pages/select_region_page.dart';
import 'package:flutter_app/resources/pages/sign_up_page.dart';
import 'package:nylo_framework/nylo_framework.dart';

class SignInPage extends NyStatefulWidget {
  static RouteView path = ("/sign-in", (_) => SignInPage());

  SignInPage({super.key}) : super(child: () => _SignInPageState());
}

class _SignInPageState extends NyPage<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
                "Log in or Sign up",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 8),

              // Subtitle
              Text(
                "Hi! Welcome, Log in to book and manage your appointment",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 32),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Continue with Google Button
                      _buildSocialButton(
                        icon: _buildGoogleIcon(),
                        text: "Continue with Google",
                        onPressed: _handleGoogleSignIn,
                      ),
                      SizedBox(height: 16),

                      // Continue with Apple Button
                      _buildSocialButton(
                        icon: Icon(Icons.apple, size: 24, color: Colors.black),
                        text: "Continue with Apple",
                        onPressed: _handleAppleSignIn,
                      ),
                      SizedBox(height: 32),

                      // OR Divider
                      Row(
                        children: [
                          Expanded(child: Divider(color: Colors.grey[300])),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              "OR",
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Expanded(child: Divider(color: Colors.grey[300])),
                        ],
                      ),
                      SizedBox(height: 32),

                      // Form
                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Email
                            _buildLabel("Email"),
                            _buildTextField(
                              controller: _emailController,
                              hintText: "example@email.com",
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your email';
                                }
                                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                    .hasMatch(value.trim())) {
                                  return 'Please enter a valid email';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 20),

                            // Password
                            _buildLabel("Password"),
                            _buildTextField(
                              controller: _passwordController,
                              hintText: "Enter password",
                              obscureText: !_isPasswordVisible,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Colors.grey,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                },
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your password';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 12),

                            // Forgot Password
                            Align(
                              alignment: Alignment.centerRight,
                              child: GestureDetector(
                                onTap: _handleForgotPassword,
                                child: Text(
                                  "Forgot Password?",
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Sign In Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: isLocked('signin') ? null : _handleSignIn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    disabledBackgroundColor: Colors.grey[400],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: isLocked('signin')
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
                          "Sign In",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              SizedBox(height: 24),

              // Don't have account
              Center(
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    children: [
                      TextSpan(text: "Don't have an account? "),
                      WidgetSpan(
                        child: GestureDetector(
                          onTap: () {
                            routeTo(SignUpPage.path);
                          },
                          child: Text(
                            "Sign Up",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.blue,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required Widget icon,
    required String text,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.grey[300]!),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            SizedBox(width: 12),
            Text(
              text,
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoogleIcon() {
    return Container(
      width: 24,
      height: 24,
      child: Image.asset('google_logo.png').localAsset(),
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
          color: Colors.black,
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
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: Colors.grey[400],
          fontSize: 16,
        ),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.blue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.red, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  Future<void> _handleSignIn() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    await lockRelease('signin', perform: () async {
      try {
        final success = await AuthService.login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        if (success) {
          // Check if user is verified
          final user = await AuthService.getCurrentUser();

          if (user != null && !(user.isVerified ?? false)) {
            // User needs to verify email
            showToastNotification(
              context,
              style: ToastNotificationStyleType.warning,
              title: "Verify Email",
              description: "Please verify your email to continue.",
            );
            return;
          }

          // Check if user needs to select region

          showToastNotification(
            context,
            style: ToastNotificationStyleType.success,
            title: "Success",
            description: "Signed in successfully!",
          );

          routeTo(
            SelectRegionPage.path,
            navigationType: NavigationType.pushAndRemoveUntil,
            removeUntilPredicate: (route) => false,
          );
        } else {
          showToastNotification(
            context,
            style: ToastNotificationStyleType.danger,
            title: "Login Failed",
            description: "Invalid email or password. Please try again.",
          );
        }
      } catch (e) {
        print('SignIn error: $e'); // Add more detailed logging
        ApiErrorHandler.handleError(e, context: context);
      }
    });
  }

  Future<void> _handleGoogleSignIn() async {
    await lockRelease('google_signin', perform: () async {
      try {
        // TODO: Implement Firebase Google Sign In
        // 1. Sign in with Google using Firebase Auth
        // 2. Get the Firebase token
        // 3. Call AuthService.socialAuth with the token

        // Example implementation:
        // final googleUser = await GoogleSignIn().signIn();
        // if (googleUser != null) {
        //   final googleAuth = await googleUser.authentication;
        //   final credential = GoogleAuthProvider.credential(
        //     accessToken: googleAuth.accessToken,
        //     idToken: googleAuth.idToken,
        //   );
        //   final firebaseUser = await FirebaseAuth.instance.signInWithCredential(credential);
        //   final firebaseToken = await firebaseUser.user?.getIdToken();
        //
        //   if (firebaseToken != null) {
        //     final success = await AuthService.socialAuth(
        //       firebaseToken: firebaseToken,
        //       provider: 'google',
        //     );
        //   }
        // }

        showToastNotification(
          context,
          style: ToastNotificationStyleType.info,
          title: "Coming Soon",
          description: "Google Sign In will be available soon!",
        );
      } catch (e) {
        ApiErrorHandler.handleError(e, context: context);
      }
    });
  }

  Future<void> _handleAppleSignIn() async {
    await lockRelease('apple_signin', perform: () async {
      try {
        // TODO: Implement Firebase Apple Sign In
        // 1. Sign in with Apple using Firebase Auth
        // 2. Get the Firebase token
        // 3. Call AuthService.socialAuth with the token

        // Example implementation:
        // final appleCredential = await SignInWithApple.getAppleIDCredential(
        //   scopes: [AppleIDAuthorizationScopes.email, AppleIDAuthorizationScopes.fullName],
        // );
        // final oauthCredential = OAuthProvider("apple.com").credential(
        //   idToken: appleCredential.identityToken,
        //   accessToken: appleCredential.authorizationCode,
        // );
        // final firebaseUser = await FirebaseAuth.instance.signInWithCredential(oauthCredential);
        // final firebaseToken = await firebaseUser.user?.getIdToken();
        //
        // if (firebaseToken != null) {
        //   final success = await AuthService.socialAuth(
        //     firebaseToken: firebaseToken,
        //     provider: 'apple',
        //   );
        // }

        showToastNotification(
          context,
          style: ToastNotificationStyleType.info,
          title: "Coming Soon",
          description: "Apple Sign In will be available soon!",
        );
      } catch (e) {
        ApiErrorHandler.handleError(e, context: context);
      }
    });
  }

  void _handleForgotPassword() {
    // Navigate to forgot password page
    routeTo(ForgotPasswordPage.path);
  }
}

// Simple Google logo representation
class GoogleIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Google "G" simplified representation
    // Blue
    paint.color = Color(0xFF4285F4);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width * 0.5, size.height), paint);

    // Red
    paint.color = Color(0xFFEA4335);
    canvas.drawRect(
        Rect.fromLTWH(size.width * 0.5, 0, size.width * 0.5, size.height * 0.5),
        paint);

    // Yellow
    paint.color = Color(0xFFFBBC05);
    canvas.drawRect(
        Rect.fromLTWH(size.width * 0.5, size.height * 0.5, size.width * 0.5,
            size.height * 0.5),
        paint);

    // Green
    paint.color = Color(0xFF34A853);
    canvas.drawRect(
        Rect.fromLTWH(
            0, size.height * 0.5, size.width * 0.5, size.height * 0.5),
        paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
