import 'package:flutter/material.dart';
import 'package:flutter_app/app/models/booking.dart';
import 'package:flutter_app/app/services/booking_service.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:intl/intl.dart';

class ProgressReportDetailsPage extends NyStatefulWidget {
  static RouteView path =
      ("/progress-report-details", (_) => ProgressReportDetailsPage());

  ProgressReportDetailsPage({super.key})
      : super(child: () => _ProgressReportDetailsPageState());
}

class _ProgressReportDetailsPageState
    extends NyPage<ProgressReportDetailsPage> {
  Booking? _booking;
  bool _loading = true;
  String? _error;

  @override
  get init => () async {
        await _loadBookingDetails();
      };

  Future<void> _loadBookingDetails() async {
    try {
      setState(() {
        _loading = true;
        _error = null;
      });

      final data = widget.data();
      if (data != null && data is Map && data['bookingId'] != null) {
        final bookingId = data['bookingId'] as String;
        final booking =
            await BookingService.getBookingDetails(bookingId: bookingId);

        setState(() {
          _booking = booking;
          _loading = false;
        });
      } else {
        setState(() {
          _error = 'No booking ID provided';
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to load booking details: $e';
        _loading = false;
      });
      print('Error loading booking details: $e');
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Date not available';

    try {
      final date = DateTime.parse(dateString);
      return DateFormat('EEEE, d MMMM yyyy', 'en_US').format(date);
    } catch (e) {
      return dateString;
    }
  }

  String _getBookingReference(String? bookingId) {
    if (bookingId == null) return 'N/A';
    return bookingId.length > 8
        ? bookingId.substring(0, 8).toUpperCase()
        : bookingId.toUpperCase();
  }

  String _getFirst20Words(String? text) {
    if (text == null || text.isEmpty) return '';
    final words = text.split(' ');
    if (words.length <= 20) return text;
    return '${words.take(20).join(' ')}...';
  }

  void _showFullProfessionalNote() {
    if (_booking?.professionalNotes == null) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Appointment Note',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: SingleChildScrollView(
            child: Text(
              _booking!.professionalNotes!,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Close',
                style: TextStyle(
                  color: Color(0xFFC8AD87),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showFullScreenImages(
      List<dynamic> imagesData, int initialIndex, String title) {
    final List<String> imageUrls =
        imagesData.map((item) => item['image_url'] as String).toList();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FullScreenImageViewer(
          images: imageUrls,
          initialIndex: initialIndex,
          title: title,
        ),
      ),
    );
  }

  @override
  Widget view(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: _loading
            ? const Text(
                'Loading...',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              )
            : _booking != null
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatDate(_booking!.scheduledDate),
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${_booking!.serviceName ?? 'Service'} | Booking Ref: ${_getBookingReference(_booking!.bookingId)}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  )
                : const Text(
                    'Progress Report Details',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
        centerTitle: false,
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFC8AD87)),
              ),
            )
          : _error != null
              ? _buildErrorState()
              : _booking == null
                  ? _buildEmptyState()
                  : _buildBookingDetails(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 48,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            _error ?? 'An error occurred',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.red,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadBookingDetails,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC8AD87),
              foregroundColor: Colors.white,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Text('No booking data available'),
    );
  }

  Widget _buildBookingDetails() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Appointment Note Section
          Container(
            margin: const EdgeInsets.only(bottom: 24),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Appointment Note',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const Spacer(),
                    if (_booking!.professionalNotes != null &&
                        _booking!.professionalNotes!.isNotEmpty)
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Color(0xFFC8AD87),
                        ),
                        onPressed: _showFullProfessionalNote,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                if (_booking!.professionalNotes != null &&
                    _booking!.professionalNotes!.isNotEmpty)
                  Text(
                    _getFirst20Words(_booking!.professionalNotes),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  )
                else
                  Text(
                    'No appointment notes available',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ),

          // Before Pictures Section
          _buildPictureSection(
            'Before Photos',
            _booking!.beforePictures ?? [],
            Icons.camera_alt,
          ),

          const SizedBox(height: 16),

          // After Pictures Section
          _buildPictureSection(
            'After the Shea touch',
            _booking!.afterPictures ?? [],
            Icons.camera_alt,
          ),
        ],
      ),
    );
  }

  Widget _buildPictureSection(
      String title, List<dynamic> images, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        if (images.isNotEmpty)
          SizedBox(
            height: 150, // Increased height for better space utilization
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              itemBuilder: (context, index) {
                final imageUrl = images[index]['image_url'] as String;
                return GestureDetector(
                  onTap: () => _showFullScreenImages(images, index, title),
                  child: Container(
                    width: (MediaQuery.of(context).size.width - 32) /
                        2.5, // Show 2.5 images per screen for larger images
                    margin: EdgeInsets.only(
                        right: index < images.length - 1 ? 12 : 0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey.shade200,
                          child: Icon(
                            icon,
                            color: Colors.grey.shade400,
                            size: 32,
                          ),
                        ),
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: Colors.grey.shade200,
                            child: Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                    Color(0xFFC8AD87)),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          )
        else
          Container(
            height: 150,
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    color: Colors.grey.shade400,
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No $title available',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class FullScreenImageViewer extends StatefulWidget {
  final List<String> images;
  final int initialIndex;
  final String title;

  const FullScreenImageViewer({
    Key? key,
    required this.images,
    required this.initialIndex,
    required this.title,
  }) : super(key: key);

  @override
  State<FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<FullScreenImageViewer> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '${widget.title} (${_currentIndex + 1}/${widget.images.length})',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
      ),
      body: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemCount: widget.images.length,
        itemBuilder: (context, index) {
          return InteractiveViewer(
            child: Center(
              child: Image.network(
                widget.images[index],
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey.shade800,
                  child: const Icon(
                    Icons.error,
                    color: Colors.white,
                    size: 64,
                  ),
                ),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
