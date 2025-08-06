import 'package:flutter/material.dart';
import 'package:flutter_app/app/services/booking_service.dart';
import 'package:flutter_app/app/models/booking.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:intl/intl.dart';

class BookingDetailPage extends NyStatefulWidget {
  static RouteView path = ("/booking-detail", (_) => BookingDetailPage());

  BookingDetailPage({super.key})
      : super(child: () => _BookingDetailPageState());
}

class _BookingDetailPageState extends NyPage<BookingDetailPage> {
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

      // Get booking ID from route data
      final String? bookingId = widget.data()['bookingId'];

      if (bookingId == null) {
        setState(() {
          _error = 'Booking ID not provided';
          _loading = false;
        });
        return;
      }

      final booking =
          await BookingService.getBookingDetails(bookingId: bookingId);

      setState(() {
        _booking = booking;
        if (booking == null) {
          _error = 'Booking not found';
        }
        _loading = false;
      });
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
      return DateFormat('EEEE, d MMMM yyyy.', 'en_US').format(date);
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

  void _showImageGallery(BuildContext context, List<dynamic> images,
      String title, int initialIndex) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ImageGalleryPage(
          images: images,
          title: title,
          initialIndex: initialIndex,
        ),
      ),
    );
  }

  void _showFullNote() {
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
        title: Text(
          _formatDate(_booking?.scheduledDate),
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
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
                  : _buildBookingDetail(),
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
      child: Text(
        'Booking not found',
        style: TextStyle(
          fontSize: 16,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildBookingDetail() {
    // Debug information
    print('Booking Details Debug:');
    print('Before Pictures: ${_booking!.beforePictures}');
    print('After Pictures: ${_booking!.afterPictures}');
    print('Professional Notes: ${_booking!.professionalNotes}');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Service details and booking reference
          Text(
            '${_booking!.serviceName ?? 'Service'} | Booking Ref: ${_getBookingReference(_booking!.bookingId)}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),

          const SizedBox(height: 24),

          // Appointment Note Section
          if (_booking!.professionalNotes != null &&
              _booking!.professionalNotes!.isNotEmpty)
            _buildAppointmentNote(),

          const SizedBox(height: 24),

          // Before Pictures Section
          if (_booking!.beforePictures != null &&
              _booking!.beforePictures!.isNotEmpty)
            _buildPictureSection(
              'Appointment Picture - Before',
              _booking!.beforePictures!,
              'before',
            )
          else if (_booking!.beforePictures != null)
            _buildEmptyPictureSection('Appointment Picture - Before'),

          const SizedBox(height: 24),

          // After Pictures Section
          if (_booking!.afterPictures != null &&
              _booking!.afterPictures!.isNotEmpty)
            _buildPictureSection(
              'Appointment Picture - After',
              _booking!.afterPictures!,
              'after',
            )
          else if (_booking!.afterPictures != null)
            _buildEmptyPictureSection('Appointment Picture - After'),

          // Show message if no pictures available
          if ((_booking!.beforePictures == null ||
                  _booking!.beforePictures!.isEmpty) &&
              (_booking!.afterPictures == null ||
                  _booking!.afterPictures!.isEmpty))
            _buildNoPicturesMessage(),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildAppointmentNote() {
    return Container(
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
              IconButton(
                icon: const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey,
                ),
                onPressed: () => _showFullNote(),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _booking!.professionalNotes!.length > 50
                ? '${_booking!.professionalNotes!.substring(0, 50)}...'
                : _booking!.professionalNotes!,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPictureSection(
      String title, List<dynamic> pictures, String type) {
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
        const SizedBox(height: 16),

        // Grid of images
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: pictures.length == 1 ? 1 : 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1.0,
          ),
          itemCount: pictures.length,
          itemBuilder: (context, index) {
            final picture = pictures[index];
            return _buildPictureItem(picture, pictures, type, index);
          },
        ),
      ],
    );
  }

  Widget _buildNoPicturesMessage() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(
            Icons.photo_library_outlined,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No before/after pictures available',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pictures will appear here once uploaded by your professional',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyPictureSection(String title) {
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
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              Icon(
                Icons.photo_library_outlined,
                size: 48,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                'No pictures available',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Pictures will appear here once uploaded by your professional',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPictureItem(
      dynamic picture, List<dynamic> pictures, String type, int index) {
    String imageUrl = '';
    String caption = '';

    if (picture is Map<String, dynamic>) {
      imageUrl = picture['image_url'] ?? '';
      caption = picture['caption'] ?? '';
    }

    // Debug information
    print('Building picture item for $type:');
    print('Picture data: $picture');
    print('Image URL: $imageUrl');
    print('Caption: $caption');

    if (imageUrl.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.image_not_supported,
          color: Colors.grey,
        ),
      );
    }

    // The API already provides complete URLs, so no need to modify

    return GestureDetector(
      onTap: () => _showImageGallery(
        context,
        pictures,
        'Appointment Picture - ${type == 'before' ? 'Before' : 'After'}',
        index,
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            children: [
              Image.network(
                imageUrl,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey.shade200,
                    child: const Icon(
                      Icons.image_not_supported,
                      color: Colors.grey,
                    ),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: Colors.grey.shade200,
                    child: const Center(
                      child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Color(0xFFC8AD87)),
                      ),
                    ),
                  );
                },
              ),
              if (caption.isNotEmpty)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.7),
                        ],
                      ),
                    ),
                    child: Text(
                      caption,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class ImageGalleryPage extends StatefulWidget {
  final List<dynamic> images;
  final String title;
  final int initialIndex;

  const ImageGalleryPage({
    super.key,
    required this.images,
    required this.title,
    required this.initialIndex,
  });

  @override
  State<ImageGalleryPage> createState() => _ImageGalleryPageState();
}

class _ImageGalleryPageState extends State<ImageGalleryPage> {
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

  String _getImageUrl(dynamic picture) {
    if (picture is Map<String, dynamic>) {
      return picture['image_url'] ?? '';
    }
    return '';
  }

  String _getCaption(dynamic picture) {
    if (picture is Map<String, dynamic>) {
      return picture['caption'] ?? '';
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
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
          final picture = widget.images[index];
          final imageUrl = _getImageUrl(picture);
          final caption = _getCaption(picture);

          return InteractiveViewer(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: imageUrl.isNotEmpty
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Icon(
                                  Icons.image_not_supported,
                                  color: Colors.white,
                                  size: 64,
                                ),
                              );
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              );
                            },
                          )
                        : const Center(
                            child: Icon(
                              Icons.image_not_supported,
                              color: Colors.white,
                              size: 64,
                            ),
                          ),
                  ),
                  if (caption.isNotEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        caption,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
