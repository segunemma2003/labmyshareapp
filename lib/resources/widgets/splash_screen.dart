import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  /// Create a new instance of the MaterialApp
  static MaterialApp app() {
    return MaterialApp(
      home: SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background SVG
          SvgPicture.asset(
            'public/images/splash_bg.svg',
            fit: BoxFit.cover,
          ),
          // Centered logo
          Center(
            child: SvgPicture.asset(
              'public/images/splash_logo.svg',
              width: MediaQuery.of(context).size.width * 0.55,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}
