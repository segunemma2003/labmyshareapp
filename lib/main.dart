import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'bootstrap/boot.dart';
import 'package:flutter_app/app/services/firebase_auth_service.dart';

/// Nylo - Framework for Flutter Developers
/// Docs: https://nylo.dev/docs/6.x

/// Main entry point for the application.
void main() async {
  await Nylo.init(
    setup: Boot.nylo,
    setupFinished: Boot.finished,

    showSplashScreen: true,
    // Uncomment showSplashScreen to show the splash screen
    // File: lib/resources/widgets/splash_screen.dart
  );
}
