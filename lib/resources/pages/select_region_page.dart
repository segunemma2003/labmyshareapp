import 'package:flutter/material.dart';
import 'package:flutter_app/app/models/region.dart';
import 'package:flutter_app/app/services/auth_service.dart';
import 'package:flutter_app/app/services/region_service.dart';
import 'package:flutter_app/app/utils/api_error_handler.dart';
import 'package:flutter_app/resources/pages/base_navigation_hub.dart';
import 'package:nylo_framework/nylo_framework.dart';

class SelectRegionPage extends NyStatefulWidget {
  static RouteView path = ("/select-region", (_) => SelectRegionPage());

  SelectRegionPage({super.key}) : super(child: () => _SelectRegionPageState());
}

class _SelectRegionPageState extends NyPage<SelectRegionPage> {
  String? _selectedRegion;
  String? _selectedRegionCode;
  bool _isLoadingRegions = true;
  List<Region> _availableRegions = [];

  @override
  get init => () async {
        // Load regions on initialization
        await _loadRegions();
      };

  Future<void> _loadRegions() async {
    try {
      final regions = await RegionService.getRegions();
      if (regions != null) {
        setState(() {
          _availableRegions = regions;
          _isLoadingRegions = false;
        });
      } else {
        // Handle the case where regions is null
        setState(() {
          _isLoadingRegions = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingRegions = false;
      });
      ApiErrorHandler.handleError(e, context: context);
    }
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
        body: _isLoadingRegions ? _buildLoadingState() : _buildContent(),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF000000)),
          ),
          SizedBox(height: 16),
          Text(
            'Loading regions...',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF666666),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: EdgeInsets.all(24),
      child: Column(
        children: [
          // World Map Section
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              child: Column(
                children: [
                  // World Map Image Area with Pins
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Color(0xFFF5F5F5),
                      ),
                      child: Stack(
                        children: [
                          // World Map Image
                          Image.asset('map.png', fit: BoxFit.contain)
                              .localAsset(),

                          // UK Pin (London) - positioned over Europe
                          Positioned(
                            top: 45,
                            left: MediaQuery.of(context).size.width * 0.48,
                            child: Icon(
                              Icons.location_on,
                              color: _selectedRegionCode == 'UK'
                                  ? Color(0xFF000000)
                                  : Color(0xFF5C7CFA),
                              size: 26,
                            ),
                          ),
                          // UAE Pin (Dubai) - positioned over Middle East
                          Positioned(
                            top: 65,
                            left: MediaQuery.of(context).size.width * 0.58,
                            child: Icon(
                              Icons.location_on,
                              color: _selectedRegionCode == 'UAE'
                                  ? Color(0xFF000000)
                                  : Color(0xFFFF8A50),
                              size: 26,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 20),
                ],
              ),
            ),
          ),

          SizedBox(height: 40),

          // Title and Description
          Text(
            "Select Your Region",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF000000),
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Let us know the region where you'd like to\nbook an appointment.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF666666),
              height: 1.5,
            ),
          ),
          SizedBox(height: 32),

          // Region Selection Cards
          _buildRegionSelection(),

          SizedBox(height: 16),

          // Helper Text
          Text(
            "You can always change your region on the app",
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFFBDBDBD),
            ),
          ),

          SizedBox(height: 32),

          // Continue Button
          GestureDetector(
            onTap: _selectedRegion != null ? _handleConfirmSelection : null,
            child: Container(
              width: double.infinity,
              height: 54,
              decoration: BoxDecoration(
                color: _selectedRegion != null
                    ? Color(0xFF000000)
                    : Color(0xFF9E9E9E),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  "Continue",
                  style: TextStyle(
                    color: Color(0xFFFFFFFF),
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
    );
  }

  Widget _buildRegionSelection() {
    if (_availableRegions.isEmpty) {
      return Text(
        "No regions available",
        style: TextStyle(
          fontSize: 14,
          color: Color(0xFF666666),
        ),
      );
    }

    return Row(
      children: _availableRegions.map((region) {
        bool isSelected = _selectedRegionCode == region.code;

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: _availableRegions.last == region ? 0 : 12,
            ),
            child: GestureDetector(
              onTap: () => _selectRegion(region),
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(0xFFFFFFFF),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? Color(0xFF000000) : Color(0xFFE0E0E0),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Flag
                    Container(
                      width: 24,
                      height: 16,
                      child: CustomPaint(
                        painter: region.code == 'UK'
                            ? UKFlagPainter()
                            : UAEFlagPainter(),
                      ),
                    ),
                    SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        region.name ?? region.code ?? 'Unknown',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF000000),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  void _selectRegion(Region region) {
    setState(() {
      _selectedRegion = region.name;
      _selectedRegionCode = region.code;
    });
  }

  Future<void> _handleConfirmSelection() async {
    if (_selectedRegionCode == null) return;

    // Use Nylo's built-in loading system
    await lockRelease('select_region', perform: () async {
      try {
        // Switch to the selected region using AuthService
        final success = await AuthService.switchRegion(
          regionCode: _selectedRegionCode!,
        );

        if (success) {
          // Show success message
          showToastNotification(
            context,
            style: ToastNotificationStyleType.success,
            title: "Success",
            description: 'Region "$_selectedRegion" selected successfully!',
          );

          // Navigate to main app
          routeTo(
            BaseNavigationHub.path,
            navigationType: NavigationType.pushAndRemoveUntil,
            removeUntilPredicate: (route) => false,
          );
        } else {
          // Show error message
          showToastNotification(
            context,
            style: ToastNotificationStyleType.danger,
            title: "Error",
            description: 'Failed to select region. Please try again.',
          );
        }
      } catch (e) {
        // Handle error
        ApiErrorHandler.handleError(e, context: context);
      }
    });
  }
}

class UKFlagPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Blue background
    final bluePaint = Paint()..color = Color(0xFF012169);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bluePaint);

    // White diagonals
    final whitePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = size.height * 0.3;

    canvas.drawLine(Offset(0, 0), Offset(size.width, size.height), whitePaint);
    canvas.drawLine(Offset(size.width, 0), Offset(0, size.height), whitePaint);

    // White cross
    final whiteCrossPaint = Paint()..color = Colors.white;
    canvas.drawRect(
        Rect.fromLTWH(0, size.height * 0.4, size.width, size.height * 0.2),
        whiteCrossPaint);
    canvas.drawRect(
        Rect.fromLTWH(size.width * 0.4, 0, size.width * 0.2, size.height),
        whiteCrossPaint);

    // Red diagonals
    final redPaint = Paint()
      ..color = Color(0xFFC8102E)
      ..strokeWidth = size.height * 0.15;

    canvas.drawLine(Offset(0, 0), Offset(size.width, size.height), redPaint);
    canvas.drawLine(Offset(size.width, 0), Offset(0, size.height), redPaint);

    // Red cross
    final redCrossPaint = Paint()..color = Color(0xFFC8102E);
    canvas.drawRect(
        Rect.fromLTWH(0, size.height * 0.42, size.width, size.height * 0.16),
        redCrossPaint);
    canvas.drawRect(
        Rect.fromLTWH(size.width * 0.42, 0, size.width * 0.16, size.height),
        redCrossPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class UAEFlagPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Red vertical stripe
    final redPaint = Paint()..color = Color(0xFFFF0000);
    canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width * 0.25, size.height), redPaint);

    // Green horizontal stripe
    final greenPaint = Paint()..color = Color(0xFF00732F);
    canvas.drawRect(
        Rect.fromLTWH(size.width * 0.25, 0, size.width * 0.75, size.height / 3),
        greenPaint);

    // White horizontal stripe
    final whitePaint = Paint()..color = Colors.white;
    canvas.drawRect(
        Rect.fromLTWH(size.width * 0.25, size.height / 3, size.width * 0.75,
            size.height / 3),
        whitePaint);

    // Black horizontal stripe
    final blackPaint = Paint()..color = Colors.black;
    canvas.drawRect(
        Rect.fromLTWH(size.width * 0.25, (size.height / 3) * 2,
            size.width * 0.75, size.height / 3),
        blackPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
