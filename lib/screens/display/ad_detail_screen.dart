import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
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
  late PageController _galleryController;
  int _currentGalleryIndex = 0;
  bool _hasReachedEnd = false;

  @override
  void initState() {
    super.initState();
    _galleryController = PageController();
    _startAutoCloseTimer();
  }

  void _startAutoCloseTimer() {
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted) {
        Navigator.pop(context);
      }
    });
  }

  @override
  void dispose() {
    _galleryController.dispose();
    super.dispose();
  }

  void _trackConversion() {
    if (_currentGalleryIndex == _galleryImages.length - 1 && !_hasReachedEnd) {
      setState(() {
        _hasReachedEnd = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('✓ Konversi tercatat'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  List<String> get _galleryImages {
    // Main media is always first
    final images = [widget.ad.mediaUrl];
    
    // Add gallery images if available
    if (widget.ad.galleryImages.isNotEmpty) {
      debugPrint('📸 Gallery images available: ${widget.ad.galleryImages.length}');
      images.addAll(widget.ad.galleryImages.take(2));
    } else {
      debugPrint('⚠️  No gallery images for ad ${widget.ad.id}');
    }
    
    final result = images.take(3).toList();
    debugPrint('🖼️  Total images in detail: ${result.length} (main + gallery)');
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        body: Stack(
          children: [
            // Full Screen Gallery (Top 60%)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: screenHeight * 0.60,
              child: Container(
                color: Colors.black,
                child: PageView.builder(
                  controller: _galleryController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentGalleryIndex = index;
                    });
                    _trackConversion();
                  },
                  itemCount: _galleryImages.length,
                  itemBuilder: (context, index) {
                    final imageUrl = _galleryImages[index];
                    return Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[900],
                          child: const Icon(
                            Icons.image_not_supported,
                            color: Colors.grey,
                            size: 50,
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),

            // Close Button (Top Right)
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: IconButton(
                  icon: const Icon(Icons.close, size: 28, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),

            // Image Counter (Bottom Left of Gallery)
            Positioned(
              bottom: screenHeight * 0.40 + 10,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_currentGalleryIndex + 1} / ${_galleryImages.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // Bottom Content Section (Bottom 40%)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: screenHeight * 0.40,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Title
                      Text(
                        widget.ad.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),

                      // Description Card
                      if (widget.ad.description != null && widget.ad.description!.isNotEmpty)
                        Card(
                          elevation: 0,
                          color: Colors.blue.withValues(alpha: 0.08),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: Colors.blue.withValues(alpha: 0.3),
                              width: 1.5,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Text(
                              widget.ad.description!,
                              style: const TextStyle(
                                fontSize: 16,
                                height: 1.5,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),

                      const SizedBox(height: 12),

                      // Company Card
                      if (widget.ad.companyName != null && widget.ad.companyName!.isNotEmpty)
                        Card(
                          elevation: 0,
                          color: Colors.orange.withValues(alpha: 0.08),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: Colors.orange.withValues(alpha: 0.3),
                              width: 1.5,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.orange,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Icon(Icons.business,
                                      color: Colors.white, size: 16),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    widget.ad.companyName ?? '',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      const SizedBox(height: 12),

                      // Contact Card
                      if (widget.ad.contactInfo != null && widget.ad.contactInfo!.isNotEmpty)
                        Card(
                          elevation: 0,
                          color: Colors.green.withValues(alpha: 0.08),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: Colors.green.withValues(alpha: 0.3),
                              width: 1.5,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Icon(Icons.email,
                                      color: Colors.white, size: 16),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    widget.ad.contactInfo ?? '',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.blue,
                                      fontWeight: FontWeight.w500,
                                      decoration: TextDecoration.underline,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      const SizedBox(height: 12),

                      // QR Code Section (Compact but Enhanced)
                      if ((widget.ad.websiteUrl ?? '').isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.purple.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.purple.withValues(alpha: 0.3),
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Colors.purple,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Icon(Icons.qr_code2,
                                        color: Colors.white, size: 18),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Scan Kode QR',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.grey[300]!,
                                    width: 1,
                                  ),
                                ),
                                child: QrImageView(
                                  data: widget.ad.websiteUrl ?? '',
                                  version: QrVersions.auto,
                                  size: 120.0,
                                  gapless: false,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],

                      // Buttons Row (Enhanced)
                      Row(
                        children: [
                          // Back Button
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.deepOrange,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                side: const BorderSide(
                                  color: Colors.deepOrange,
                                  width: 2,
                                ),
                              ),
                              icon: const Icon(Icons.arrow_back, size: 18),
                              label: const Text('Kembali', 
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
