import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
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
                    // Gallery Images (Semua foto promo)
                    if (_galleryImages.isNotEmpty) ...[
                      const Text(
                        'Foto Promo',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        height: 300,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey[200],
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
                                            color: Colors.red, size: 40),
                                        SizedBox(height: 8),
                                        Text('Gagal memuat gambar'),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                            // Left Navigation Button
                            if (_currentGalleryIndex > 0)
                              Positioned(
                                left: 8,
                                top: 0,
                                bottom: 0,
                                child: Center(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black54,
                                      shape: BoxShape.circle,
                                    ),
                                    child: IconButton(
                                      icon: const Icon(Icons.arrow_back_ios,
                                          color: Colors.white, size: 20),
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
                              ),
                            // Right Navigation Button
                            if (_currentGalleryIndex <
                                _galleryImages.length - 1)
                              Positioned(
                                right: 8,
                                top: 0,
                                bottom: 0,
                                child: Center(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black54,
                                      shape: BoxShape.circle,
                                    ),
                                    child: IconButton(
                                      icon: const Icon(
                                          Icons.arrow_forward_ios,
                                          color: Colors.white,
                                          size: 20),
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
                              ),
                            // Image Counter
                            Positioned(
                              bottom: 12,
                              right: 12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black54,
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
                            // Conversion Indicator (Last Image)
                            if (_hasReachedEnd)
                              Positioned(
                                top: 12,
                                right: 12,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      Icon(Icons.check_circle,
                                          color: Colors.white, size: 16),
                                      SizedBox(width: 4),
                                      Text(
                                        'Konversi',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
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
                      const SizedBox(height: 24),
                    ],

                    // Total Views
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.cyan.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.cyan, width: 2),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.visibility, color: Colors.cyan, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Total Penayangan: ${widget.ad.totalViews}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.cyan,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Company Name
                    if (widget.ad.companyName != null &&
                        widget.ad.companyName!.isNotEmpty) ...[
                      Row(
                        children: [
                          Icon(Icons.business, color: Colors.grey[700], size: 20),
                          const SizedBox(width: 8),
                          const Text(
                            'Company',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.ad.companyName!,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Description
                    if (widget.ad.description != null &&
                        widget.ad.description!.isNotEmpty) ...[
                      Row(
                        children: [
                          Icon(Icons.description, color: Colors.grey[700], size: 20),
                          const SizedBox(width: 8),
                          const Text(
                            'Deskripsi',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.ad.description!,
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Contact Info
                    if (widget.ad.contactInfo != null &&
                        widget.ad.contactInfo!.isNotEmpty) ...[
                      Row(
                        children: [
                          Icon(Icons.contact_phone,
                              color: Colors.grey[700], size: 20),
                          const SizedBox(width: 8),
                          const Text(
                            'Kontak',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SelectableText(
                        widget.ad.contactInfo!,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Website URL
                    if (widget.ad.websiteUrl != null &&
                        widget.ad.websiteUrl!.isNotEmpty) ...[
                      Row(
                        children: [
                          Icon(Icons.language, color: Colors.grey[700], size: 20),
                          const SizedBox(width: 8),
                          const Text(
                            'Website',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () => _launchUrl(widget.ad.websiteUrl!),
                        child: Text(
                          widget.ad.websiteUrl!,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Visit Website Button (if URL exists)
                    if (widget.ad.websiteUrl != null &&
                        widget.ad.websiteUrl!.isNotEmpty)
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: () => _launchUrl(widget.ad.websiteUrl!),
                          icon: const Icon(Icons.open_in_new),
                          label: const Text('Buka Website'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                            textStyle: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Footer
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                _hasReachedEnd
                    ? '✓ Konversi tercatat - Tap di luar untuk menutup'
                    : 'Geser gambar promo untuk melacak konversi',
                style: TextStyle(
                  fontSize: 12,
                  color: _hasReachedEnd
                      ? Colors.green[600]
                      : Colors.grey[600],
                  fontStyle: FontStyle.italic,
                  fontWeight: _hasReachedEnd ? FontWeight.w600 : FontWeight.normal,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

