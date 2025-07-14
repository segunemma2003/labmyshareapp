import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';

class WelcomeScreenPage extends NyStatefulWidget {

  static RouteView path = ("/welcome-screen", (_) => WelcomeScreenPage());
  
  WelcomeScreenPage({super.key}) : super(child: () => _WelcomeScreenPageState());
}

class _WelcomeScreenPageState extends NyPage<WelcomeScreenPage> {

  @override
  get init => () {

  };

  @override
  Widget view(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Welcome Screen")
      ),
      body: SafeArea(
         child: Container(),
      ),
    );
  }
}
