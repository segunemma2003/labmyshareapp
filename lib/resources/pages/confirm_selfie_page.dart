import 'dart:io';
import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';

class ConfirmSelfiePage extends NyStatefulWidget {
  static RouteView path = ("/confirm-selfie", (_) => ConfirmSelfiePage());

  ConfirmSelfiePage({super.key})
      : super(child: () => _ConfirmSelfiePageState());
}

class _ConfirmSelfiePageState extends NyPage<ConfirmSelfiePage> {
  File? _selectedImage;
  bool _isLoading = false;

  @override
  get init => () {
        // Image will be retrieved in didChangeDependencies
      };

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get image from route arguments if passed
    if (_selectedImage == null) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is File) {
        setState(() {
          _selectedImage = args;
        });
      } else if (args is Map && args.containsKey('image')) {
        setState(() {
          _selectedImage = args['image'] as File?;
        });
      }
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
            icon: Icon(Icons.close, color: Color(0xFF000000)),
            onPressed: () => Navigator.pop(context),
          ),
          automaticallyImplyLeading: false,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  "Confirm Your Selfie",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF000000),
                  ),
                ),
                SizedBox(height: 8),

                // Subtitle
                Text(
                  "Ensure to check your photo and confirm or retake if necessary",
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF666666),
                  ),
                ),
                SizedBox(height: 48),

                // Image Preview
                Expanded(
                  child: Center(
                    child: Container(
                      width: 280,
                      height: 280,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFE0E0E0),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x1A000000),
                            blurRadius: 20,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: _selectedImage != null
                            ? Image.file(
                                _selectedImage!,
                                fit: BoxFit.cover,
                                width: 280,
                                height: 280,
                              )
                            : Container(
                                color: Color(0xFFE0E0E0),
                                child: Icon(
                                  Icons.person,
                                  size: 120,
                                  color: Color(0xFF9E9E9E),
                                ),
                              ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 48),

                // Confirm Photo Button
                GestureDetector(
                  onTap: !_isLoading ? _handleConfirmPhoto : null,
                  child: Container(
                    width: double.infinity,
                    height: 54,
                    decoration: BoxDecoration(
                      color: Color(0xFF000000),
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
                              "Confirm photo",
                              style: TextStyle(
                                color: Color(0xFFFFFFFF),
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ),
                SizedBox(height: 16),

                // Retake Photo Button
                GestureDetector(
                  onTap: !_isLoading ? _handleRetakePhoto : null,
                  child: Container(
                    width: double.infinity,
                    height: 54,
                    decoration: BoxDecoration(
                      color: Color(0xFF9E9E9E),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        "Retake photo",
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
      ),
    );
  }

  Future<void> _handleConfirmPhoto() async {
    if (_selectedImage == null) {
      _showError('No photo selected');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Implement your photo confirmation logic here
      // Example:
      // await UserProfile.updateProfilePhoto(_selectedImage!);

      // Simulate API call
      await Future.delayed(Duration(seconds: 2));

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Photo confirmed successfully!',
            style: TextStyle(color: Color(0xFFFFFFFF)),
          ),
          backgroundColor: Color(0xFF4CAF50),
        ),
      );

      // Navigate back with success result
      Navigator.pop(context, {
        'confirmed': true,
        'image': _selectedImage,
      });
    } catch (e) {
      _showError('Failed to confirm photo. Please try again.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _handleRetakePhoto() {
    // Navigate back to camera or image picker
    Navigator.pop(context, {
      'confirmed': false,
      'retake': true,
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: Color(0xFFFFFFFF)),
        ),
        backgroundColor: Color(0xFFF44336),
      ),
    );
  }
}
