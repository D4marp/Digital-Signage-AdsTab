import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../models/ad_model.dart';
import '../../utils/responsive_helper.dart';

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

  Future<void> _launchUrl(String url) async {
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }

    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
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
    final images = [widget.ad.mediaUrl];
    images.addAll(widget.ad.galleryImages.take(2));
    return images.take(3).toList();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

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
                      const SizedBox(height: 6),

                      // Company
                      if (widget.ad.companyName != null && widget.ad.companyName!.isNotEmpty)
                        Text(
                          widget.ad.companyName ?? '',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                      const SizedBox(height: 12),

                      // QR Code Section (Compact)
                      if ((widget.ad.websiteUrl ?? '').isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey[300]!, width: 1),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text(
                                'Scan',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: QrImageView(
                                  data: widget.ad.websiteUrl ?? '',
                                  version: QrVersions.auto,
                                  size: 100.0,
                                  gapless: false,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],

                      // Contact Info (Compact)
                      if (widget.ad.contactInfo != null && widget.ad.contactInfo!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: [
                              const Icon(Icons.email, color: Colors.blue, size: 14),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  widget.ad.contactInfo ?? '',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.black87,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Buttons Row
                      Row(
                        children: [
                          // Close Button
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.deepOrange,
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                side: const BorderSide(
                                  color: Colors.deepOrange,
                                  width: 1.5,
                                ),
                              ),
                              icon: const Icon(Icons.arrow_back, size: 14),
                              label: const Text('Kembali', style: TextStyle(fontSize: 11)),
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
