import 'package:flutter/material.dart';
import '../../models/ad_model.dart';

class AdDetailScreen extends StatefulWidget {
  final AdModel ad;

  const AdDetailScreen({
    super.key,
    required this.ad,
  });

  @override
  State<AdDetailScreen> createState() => _AdDetailScreenState();
}

class _AdDetailScreenState extends State<AdDetailScreen> {
  late PageController _imageCarouselController;
  late PageController _detailPageController;
  int _currentImageIndex = 0;
  bool _hasReachedEnd = false;

  @override
  void initState() {
    super.initState();
    _imageCarouselController = PageController();
    _detailPageController = PageController();
    _startAutoCloseTimer();
  }

  void _startAutoCloseTimer() {
    Future.delayed(const Duration(seconds: 60), () {
      if (mounted) {
        Navigator.pop(context);
      }
    });
  }

  @override
  void dispose() {
    _imageCarouselController.dispose();
    _detailPageController.dispose();
    super.dispose();
  }

  void _trackConversion() {
    if (_currentImageIndex == _galleryImages.length - 1 && !_hasReachedEnd) {
      setState(() {
        _hasReachedEnd = true;
      });
    }
  }

  List<String> get _galleryImages {
    final images = [widget.ad.mediaUrl];
    debugPrint('🎯 [AdDetailScreen] Main image (mediaUrl): ${widget.ad.mediaUrl}');
    
    if (widget.ad.galleryImages.isNotEmpty) {
      debugPrint('📸 [AdDetailScreen] Gallery images found: ${widget.ad.galleryImages.length}');
      images.addAll(widget.ad.galleryImages.take(2));
    }
    
    final result = images.take(3).toList();
    debugPrint('🖼️  [AdDetailScreen] Total images: ${result.length}');
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => true,
      child: Scaffold(
        body: PageView(
          physics: const NeverScrollableScrollPhysics(),
          controller: _detailPageController,
          children: [
            // PAGE 1: Full Screen Image Carousel
            _buildImagePage(),
            
            // PAGE 2: About & QR
            _buildAboutPage(),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePage() {
    return Stack(
      children: [
      // Full Screen Carousel
      PageView.builder(
        controller: _imageCarouselController,
        onPageChanged: (index) {
        setState(() => _currentImageIndex = index);
        _trackConversion();
        },
        itemCount: _galleryImages.length,
        itemBuilder: (context, index) {
        return Image.network(
          _galleryImages[index],
          fit: BoxFit.cover,
          cacheHeight: 1080,
          cacheWidth: 1920,
          errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[900],
            child: const Icon(Icons.image_not_supported,
              color: Colors.grey, size: 50),
          );
          },
        );
        },
      ),

      // Navigation Buttons (Left)
      Positioned(
        left: 0,
        right: 0,
        top: 0,
        bottom: 0,
        child: Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: IconButton(
          onPressed: () {
            if (_currentImageIndex > 0) {
            _imageCarouselController.previousPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
            }
          },
          icon: const Icon(
            Icons.chevron_left,
            color: Colors.white,
            size: 40,
          ),
          ),
        ),
        ),
      ),

      // Navigation Buttons (Right)
      Positioned(
        left: 0,
        right: 0,
        top: 0,
        bottom: 0,
        child: Align(
        alignment: Alignment.centerRight,
        child: Padding(
          padding: const EdgeInsets.only(right: 16),
          child: IconButton(
          onPressed: () {
            if (_currentImageIndex < _galleryImages.length - 1) {
            _imageCarouselController.nextPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
            }
          },
          icon: const Icon(
            Icons.chevron_right,
            color: Colors.white,
            size: 40,
          ),
          ),
        ),
        ),
      ),

      // Bottom: Tap Here Button & Pagination
      Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
          // Pagination Dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
            _galleryImages.length,
            (index) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentImageIndex == index ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
              color: _currentImageIndex == index
                ? const Color(0xFFEC0303)
                : Colors.grey,
              borderRadius: BorderRadius.circular(4),
              ),
            ),
            ),
          ),
          const SizedBox(height: 16),

          // Navigation Buttons Row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Home Button
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.home, color: Colors.grey[800], size: 24),
                        const SizedBox(width: 8),
                        Text(
                          'Home',
                          style: TextStyle(
                            color: Colors.grey[800],
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Details Button (About Images)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
                decoration: BoxDecoration(
                  color: const Color(0xFFEC0303),
                  border: Border.all(color: const Color(0xFFEC0303)),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      _detailPageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.info, color: Colors.white, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          'Details',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ],
        ),
        ),
      ),
      ],
    );
  }

  Widget _buildAboutPage() {
    if (widget.ad.aboutImages.isEmpty) {
      return _buildAboutPageWithoutImages();
    }
    
    return _buildFullScreenAboutImages();
  }

  Widget _buildAboutPageWithoutImages() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    // Responsive values
    final horizontalPadding = screenWidth < 1200 ? screenWidth * 0.05 : 32.0;
    final verticalPadding = screenHeight * 0.03;
    final titleFontSize = screenWidth < 1200 ? screenWidth * 0.025 : 28.0;
    final labelFontSize = screenWidth < 1200 ? screenWidth * 0.016 : 18.0;
    final cardPadding = screenWidth < 1200 ? screenWidth * 0.02 : 24.0;
    
    return Container(
      color: const Color(0xFFFAFAFA),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.fromLTRB(horizontalPadding, verticalPadding, horizontalPadding, verticalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Navigation Buttons - Centered
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Back Button
                    GestureDetector(
                      onTap: () {
                        _detailPageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.035,
                          vertical: screenHeight * 0.015,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEC0303),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.arrow_back, color: Colors.white, size: screenWidth * 0.025),
                            SizedBox(width: screenWidth * 0.008),
                            Text(
                              'Gallery',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: labelFontSize * 0.85,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.02),
                    // Home Button
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.035,
                          vertical: screenHeight * 0.015,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.home, color: Colors.grey[800], size: screenWidth * 0.025),
                            SizedBox(width: screenWidth * 0.008),
                            Text(
                              'Home',
                              style: TextStyle(
                                color: Colors.grey[800],
                                fontSize: labelFontSize * 0.85,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: verticalPadding * 2),

              // Product Title Card
              Container(
                padding: EdgeInsets.all(cardPadding),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFFEC0303).withOpacity(0.1),
                      const Color(0xFFEC0303).withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFEC0303).withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.ad.title,
                      style: TextStyle(
                        fontSize: titleFontSize,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1A1A1A),
                        letterSpacing: -0.3,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFullScreenAboutImages() {
    return Stack(
      children: [
        // Full Screen Image Carousel
        PageView.builder(
          controller: PageController(),
          onPageChanged: (index) {
            setState(() {});
          },
          itemCount: widget.ad.aboutImages.length,
          itemBuilder: (context, index) {
            return Image.network(
              widget.ad.aboutImages[index],
              fit: BoxFit.cover,
              cacheHeight: 1080,
              cacheWidth: 1920,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[900],
                  child: const Icon(Icons.image_not_supported,
                    color: Colors.grey, size: 50),
                );
              },
            );
          },
        ),

        // Bottom: Navigation & Pagination
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
              ),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 16),
                // Navigation Buttons Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Back Button
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEC0303),
                        border: Border.all(color: const Color(0xFFEC0303)),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            _detailPageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.arrow_back, color: Colors.white, size: 24),
                              const SizedBox(width: 8),
                              Text(
                                'Gallery',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Home Button
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.home, color: Colors.grey[800], size: 24),
                              const SizedBox(width: 8),
                              Text(
                                'Home',
                                style: TextStyle(
                                  color: Colors.grey[800],
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
                            