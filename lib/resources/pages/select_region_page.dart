import 'package:flutter/material.dart';
import 'package:flutter_app/resources/pages/base_navigation_hub.dart';
import 'package:nylo_framework/nylo_framework.dart';

class SelectRegionPage extends NyStatefulWidget {
  static RouteView path = ("/select-region", (_) => SelectRegionPage());

  SelectRegionPage({super.key}) : super(child: () => _SelectRegionPageState());
}

class _SelectRegionPageState extends NyPage<SelectRegionPage> {
  String? _selectedRegion;
  bool _isLoading = false;

  @override
  get init => () {
        // Initialize any data here
      };

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
        body: Padding(
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
                            color: Color(
                                0xFFF5F5F5), // Light background for image placeholder
                          ),
                          child: Stack(
                            children: [
                              // YOUR WORLD MAP IMAGE GOES HERE
                              // Replace this Container with your image:
                              // Image.asset('assets/images/world_map.png', fit: BoxFit.contain)
                              // or Image.network('your_image_url', fit: BoxFit.contain)
                              Image.asset('map.png', fit: BoxFit.contain)
                                  .localAsset(),

                              // UK Pin (London) - positioned over Europe
                              Positioned(
                                top: 45,
                                left: MediaQuery.of(context).size.width * 0.48,
                                child: Icon(
                                  Icons.location_on,
                                  color: Color(0xFF5C7CFA),
                                  size: 26,
                                ),
                              ),
                              // UAE Pin (Dubai) - positioned over Middle East
                              Positioned(
                                top: 65,
                                left: MediaQuery.of(context).size.width * 0.58,
                                child: Icon(
                                  Icons.location_on,
                                  color: Color(0xFFFF8A50),
                                  size: 26,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Location Labels (if you want to add them back)
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
              Row(
                children: [
                  // United Kingdom
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _selectRegion('United Kingdom'),
                      child: Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Color(0xFFFFFFFF),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _selectedRegion == 'United Kingdom'
                                ? Color(0xFF000000)
                                : Color(0xFFE0E0E0),
                            width: _selectedRegion == 'United Kingdom' ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // UK Flag
                            Container(
                              width: 24,
                              height: 16,
                              child: CustomPaint(
                                painter: UKFlagPainter(),
                              ),
                            ),
                            SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                "United Kingdom",
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

                  SizedBox(width: 12),

                  // United Arab Emirates
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _selectRegion('United Arab Emirates'),
                      child: Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Color(0xFFFFFFFF),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _selectedRegion == 'United Arab Emirates'
                                ? Color(0xFF000000)
                                : Color(0xFFE0E0E0),
                            width: _selectedRegion == 'United Arab Emirates'
                                ? 2
                                : 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // UAE Flag
                            Container(
                              width: 24,
                              height: 16,
                              child: CustomPaint(
                                painter: UAEFlagPainter(),
                              ),
                            ),
                            SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                "United Arab Emirates",
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
                ],
              ),

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
                onTap: _selectedRegion != null && !_isLoading
                    ? _handleConfirmSelection
                    : null,
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
                    child: _isLoading
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
        ),
      ),
    );
  }

  void _selectRegion(String regionName) {
    setState(() {
      _selectedRegion = regionName;
    });
  }

  Future<void> _handleConfirmSelection() async {
    if (_selectedRegion == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Implement your region selection logic here
      await Future.delayed(Duration(seconds: 1));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Region "$_selectedRegion" selected successfully!',
            style: TextStyle(color: Color(0xFFFFFFFF)),
          ),
          backgroundColor: Color(0xFF4CAF50),
        ),
      );

      // Navigator.pop(context, _selectedRegion);
      routeTo(
        BaseNavigationHub.path,
        navigationType: NavigationType.pushAndRemoveUntil,
        removeUntilPredicate: (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to select region. Please try again.',
            style: TextStyle(color: Color(0xFFFFFFFF)),
          ),
          backgroundColor: Color(0xFFF44336),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
