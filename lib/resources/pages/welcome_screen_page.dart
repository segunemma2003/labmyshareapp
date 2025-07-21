import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'sign_up_page.dart';
import 'sign_in_page.dart';

class WelcomeScreenPage extends NyStatefulWidget {
  static RouteView path = ("/welcome-screen", (_) => WelcomeScreenPage());

  WelcomeScreenPage({super.key})
      : super(child: () => _WelcomeScreenPageState());
}

class _WelcomeScreenPageState extends NyPage<WelcomeScreenPage> {
  @override
  get init => () {};

  @override
  Widget view(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double phoneHeight = screenHeight * 0.60;
    final double sheetHeight = screenHeight * 0.38;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // SVG Phone at the top
          Positioned(
            top: 80,
            left: 0,
            right: 0,
            child: Image.asset(
              'welcome.png',
              width: double.infinity,
              height: phoneHeight,
              fit: BoxFit.contain,
            ).localAsset(),
          ),
          // Permanent bottom sheet overlay
          Positioned(
            left: 0,
            right: 0,
            bottom: 35,
            child: Container(
              height: sheetHeight,
              margin: EdgeInsets.symmetric(horizontal: 0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(32),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.07),
                    blurRadius: 16,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'The Lab By Shea',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFC2A05C),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Booking App',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Discover a world of beauty at your fingertips with The Lab by Shea booking app.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: () {
                          routeTo(SignUpPage.path);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          "Let's Get Started",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account? ',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            routeTo(SignInPage.path);
                          },
                          child: Text(
                            'Sign In',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
