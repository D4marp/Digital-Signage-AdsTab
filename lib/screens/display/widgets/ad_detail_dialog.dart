import 'package:flutter/material.dart';
import '../../../models/ad_model.dart';

class AdDetailDialog extends StatefulWidget {
  final AdModel ad;
  final VoidCallback onClose;

  const AdDetailDialog({
    super.key,
    required this.ad,
    required this.onClose,
  });

  @override
  State<AdDetailDialog> createState() => _AdDetailDialogState();
}

class _AdDetailDialogState extends State<AdDetailDialog> {
  late PageController _galleryController;
  int _currentGalleryIndex = 0;
  bool _hasReachedEnd = false;

  @override
  void initState() {
    super.initState();
    _galleryController = PageController();
  }

  @override
  void dispose() {
    _galleryController.dispose();
    super.dispose();
  }

  void _trackConversion() {
    // Track conversion when user reaches the last gallery image
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
    // Combine main image + gallery images (up to 3 total)
    final images = [widget.ad.mediaUrl];
    images.addAll(widget.ad.galleryImages.take(2)); // Add up to 2 more gallery images
    return images.take(3).toList(); // Limit to 3 images
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 800),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with close button
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.ad.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 28),
                    onPressed: widget.onClose,
                  ),
                ],
              ),
            ),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Gallery Images Section (Enhanced)
                    if (_galleryImages.isNotEmpty) ...[
                      Container(
                        height: 350,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Colors.grey[200],
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            PageView.builder(
                              controller: _galleryController,
                              onPageChanged: (index) {
                                setState(() {
                                  _currentGalleryIndex = index;
                                });
                                _trackConversion();
                              },
                              itemCount: _galleryImages.length,
                              itemBuilder: (context, index) {
                                return Image.network(
                                  _galleryImages[index],
                                  fit: BoxFit.cover,
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Center(
                                      child: CircularProgressIndicator(
                                        value: loadingProgress
                                                    .expectedTotalBytes !=
                                                null
                                            ? loadingProgress
                                                    .cumulativeBytesLoaded /
                                                loadingProgress
                                                    .expectedTotalBytes!
                                            : null,
                                      ),
                                    );
                                  },
                                  errorBuilder: (_, __, ___) => Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: const [
                                        Icon(Icons.error_outline,
                                            color: Colors.red, size: 50),
                                        SizedBox(height: 12),
                                        Text('Gagal memuat gambar',
                                            style: TextStyle(fontSize: 16)),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                            // Left Navigation Button
                            if (_currentGalleryIndex > 0)
                              Positioned(
                                left: 12,
                                top: 0,
                                bottom: 0,
                                child: Center(
                                  child: IconButton(
                                    icon: const Icon(Icons.chevron_left,
                                        color: Colors.white, size: 32),
                                    onPressed: () {
                                      _galleryController.previousPage(
                                        duration: const Duration(
                                            milliseconds: 300),
                                        curve: Curves.easeInOut,
                                      );
                                    },
                                  ),
                                ),
                              ),
                            // Right Navigation Button
                            if (_currentGalleryIndex <
                                _galleryImages.length - 1)
                              Positioned(
                                right: 12,
                                top: 0,
                                bottom: 0,
                                child: Center(
                                  child: IconButton(
                                    icon: const Icon(
                                        Icons.chevron_right,
                                        color: Colors.white,
                                        size: 32),
                                    onPressed: () {
                                      _galleryController.nextPage(
                                        duration: const Duration(
                                            milliseconds: 300),
                                        curve: Curves.easeInOut,
                                      );
                                    },
                                  ),
                                ),
                              ),
                            // Image Counter Badge
                            Positioned(
                              bottom: 16,
                              right: 16,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.7),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${_currentGalleryIndex + 1}/${_galleryImages.length}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            // Conversion Indicator
                            if (_hasReachedEnd)
                              Positioned(
                                top: 16,
                                right: 16,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.green.withValues(alpha: 0.3),
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      Icon(Icons.check_circle,
                                          color: Colors.white, size: 18),
                                      SizedBox(width: 6),
                                      Text(
                                        'Konversi',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                    ],

                    // Close Button
                    Center(
                      child: OutlinedButton.icon(
                        onPressed: widget.onClose,
                        icon: const Icon(Icons.close, size: 22),
                        label: const Text('Tutup'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.deepOrange,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: const BorderSide(
                            color: Colors.deepOrange,
                            width: 2,
                          ),
                          textStyle: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // Footer Status
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: _hasReachedEnd
                      ? Colors.green.withValues(alpha: 0.15)
                      : Colors.blue.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _hasReachedEnd
                        ? Colors.green.withValues(alpha: 0.4)
                        : Colors.blue.withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _hasReachedEnd ? Icons.check_circle : Icons.info,
                      size: 20,
                      color: _hasReachedEnd ? Colors.green : Colors.blue,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        _hasReachedEnd
                            ? '✓ Konversi tercatat!'
                            : 'Geser gambar untuk melacak konversi',
                        style: TextStyle(
                          fontSize: 14,
                          color: _hasReachedEnd ? Colors.green[700] : Colors.blue[700],
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

