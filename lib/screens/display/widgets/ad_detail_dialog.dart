import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../models/ad_model.dart';

class AdDetailDialog extends StatelessWidget {
  final AdModel ad;
  final VoidCallback onClose;

  const AdDetailDialog({
    super.key,
    required this.ad,
    required this.onClose,
  });

  Future<void> _launchUrl(String url) async {
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }
    
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
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
                      ad.title,
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
                    onPressed: onClose,
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
                    // Company Name
                    if (ad.companyName != null && ad.companyName!.isNotEmpty) ...[
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
                        ad.companyName!,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Description
                    if (ad.description != null && ad.description!.isNotEmpty) ...[
                      Row(
                        children: [
                          Icon(Icons.description, color: Colors.grey[700], size: 20),
                          const SizedBox(width: 8),
                          const Text(
                            'Description',
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
                        ad.description!,
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Contact Info
                    if (ad.contactInfo != null && ad.contactInfo!.isNotEmpty) ...[
                      Row(
                        children: [
                          Icon(Icons.contact_phone, color: Colors.grey[700], size: 20),
                          const SizedBox(width: 8),
                          const Text(
                            'Contact',
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
                        ad.contactInfo!,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Website URL
                    if (ad.websiteUrl != null && ad.websiteUrl!.isNotEmpty) ...[
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
                        onTap: () => _launchUrl(ad.websiteUrl!),
                        child: Text(
                          ad.websiteUrl!,
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
                    if (ad.websiteUrl != null && ad.websiteUrl!.isNotEmpty)
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: () => _launchUrl(ad.websiteUrl!),
                          icon: const Icon(Icons.open_in_new),
                          label: const Text('Visit Website'),
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
                'Tap anywhere outside to continue',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
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
