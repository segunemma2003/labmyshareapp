import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';

import '../widgets/booking_tab_widget.dart';
import '../widgets/home_tab_widget.dart';
import '../widgets/profile_tab_widget.dart';
import '../widgets/services_tab_widget.dart';

class BaseNavigationHub extends NyStatefulWidget with BottomNavPageControls {
  static RouteView path = ("/base", (_) => BaseNavigationHub());

  BaseNavigationHub()
      : super(
            child: () => _BaseNavigationHubState(),
            stateName: path.stateName());

  /// State actions
  static NavigationHubStateActions stateActions =
      NavigationHubStateActions(path.stateName());
}

class _BaseNavigationHubState extends NavigationHub<BaseNavigationHub> {
  /// Bottom navigation layout with custom styling
  NavigationHubLayout? layout = NavigationHubLayout.bottomNav(
    backgroundColor: Colors.white,
    selectedItemColor: Color(0xFF985F5F), // Brown color for active state
    unselectedItemColor: Color(0xFF9E9E9E), // Grey for inactive
    elevation: 8,
    type: BottomNavigationBarType.fixed,
  );

  /// Should the state be maintained
  @override
  bool get maintainState => false;

  /// Navigation pages with image icons
  _BaseNavigationHubState()
      : super(() async {
          return {
            0: NavigationTab(
              title: "Home",
              page: HomeTab(), // Your home \page widget
              icon: Container(
                width: 24,
                height: 24,
                child: Image.asset(
                  'home_icon.png',
                  width: 24,
                  height: 24,
                  color: Color(0xFF9E9E9E),
                  colorBlendMode: BlendMode.srcIn,
                ).localAsset(),
              ),
              activeIcon: Container(
                width: 24,
                height: 24,
                child: Image.asset(
                  'home_icon_active.png',
                  width: 24,
                  height: 24,
                  color: Color(0xFF985F5F),
                  colorBlendMode: BlendMode.srcIn,
                ).localAsset(),
              ),
            ),
            1: NavigationTab(
              title: "Services",
              page: ServicesTab(), // Your services page widget
              icon: Container(
                width: 24,
                height: 24,
                child: Image.asset(
                  'scissors.png',
                  width: 24,
                  height: 24,
                  color: Color(0xFF9E9E9E),
                  colorBlendMode: BlendMode.srcIn,
                ).localAsset(),
              ),
              activeIcon: Container(
                width: 24,
                height: 24,
                child: Image.asset(
                  'scissors_active.png',
                  width: 24,
                  height: 24,
                  color: Color(0xFF985F5F),
                  colorBlendMode: BlendMode.srcIn,
                ).localAsset(),
              ),
            ),
            2: NavigationTab(
              title: "Booking",
              page: BookingTab(), // Your booking page widget
              icon: Container(
                width: 24,
                height: 24,
                child: Image.asset(
                  'calendar.png',
                  width: 24,
                  height: 24,
                  color: Color(0xFF9E9E9E),
                  colorBlendMode: BlendMode.srcIn,
                ).localAsset(),
              ),
              activeIcon: Container(
                width: 24,
                height: 24,
                child: Image.asset(
                  'calendar_active.png',
                  width: 24,
                  height: 24,
                  color: Color(0xFF985F5F),
                  colorBlendMode: BlendMode.srcIn,
                ).localAsset(),
              ),
            ),
            3: NavigationTab(
              title: "Profile",
              page: ProfileTab(), // Your profile page widget
              icon: Container(
                width: 24,
                height: 24,
                child: Image.asset(
                  'user.png',
                  width: 24,
                  height: 24,
                  color: Color(0xFF9E9E9E),
                  colorBlendMode: BlendMode.srcIn,
                ).localAsset(),
              ),
              activeIcon: Container(
                width: 24,
                height: 24,
                child: Image.asset(
                  'user_active.png',
                  width: 24,
                  height: 24,
                  color: Color(0xFF985F5F),
                  colorBlendMode: BlendMode.srcIn,
                ).localAsset(),
              ),
            ),
          };
        });

  /// Handle the tap event
  @override
  onTap(int index) {
    super.onTap(index);
    // Add any custom logic here
  }
}
