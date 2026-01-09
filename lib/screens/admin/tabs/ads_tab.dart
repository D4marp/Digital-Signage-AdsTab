import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/ad_provider.dart';
import '../../../models/ad_model.dart';
import '../../../utils/format_helper.dart';
import '../widgets/ad_upload_dialog.dart';
import '../widgets/ad_edit_dialog.dart';

class AdsTab extends StatefulWidget {
  const AdsTab({super.key});

  @override
  State<AdsTab> createState() => _AdsTabState();
}

class _AdsTabState extends State<AdsTab> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ad Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Upload New Ad',
            onPressed: () => _showUploadDialog(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: StreamBuilder<List<AdModel>>(
        stream: context.read<AdProvider>().getAdsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.campaign_outlined, size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'No ads yet',
                    style: TextStyle(fontSize: 20, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _showUploadDialog(),
                    icon: const Icon(Icons.add),
                    label: const Text('Upload First Ad'),
                  ),
                ],
              ),
            );
          }

          final ads = snapshot.data!;
          return ReorderableListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: ads.length,
            onReorder: (oldIndex, newIndex) {
              _handleReorder(ads, oldIndex, newIndex);
            },
            itemBuilder: (context, index) {
              final ad = ads[index];
              return _buildAdCard(ad, index, key: ValueKey(ad.id));
            },
          );
        },
      ),
    );
  }

  Widget _buildAdCard(AdModel ad, int index, {required Key key}) {
    return Card(
      key: key,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: _buildAdThumbnail(ad),
        title: Row(
          children: [
            Expanded(
              child: Text(
                ad.title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: ad.isEnabled ? Colors.green : Colors.grey,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                ad.isEnabled ? 'Active' : 'Inactive',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    ad.mediaType == 'video'
                        ? Icons.videocam
                        : Icons.image,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(ad.mediaType.toUpperCase()),
                  const SizedBox(width: 16),
                  const Icon(Icons.timer, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text('${ad.durationSeconds}s'),
                  const SizedBox(width: 16),
                  const Icon(Icons.location_on, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    ad.targetLocations.contains('all')
                        ? 'All Locations'
                        : '${ad.targetLocations.length} locations',
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Created: ${FormatHelper.timeAgo(ad.createdAt)}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                ad.isEnabled ? Icons.toggle_on : Icons.toggle_off,
                color: ad.isEnabled ? Colors.green : Colors.grey,
              ),
              onPressed: () => _toggleAdStatus(ad),
            ),
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => _showEditDialog(ad),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => _confirmDelete(ad),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdThumbnail(AdModel ad) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey[200],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: ad.mediaType == 'image'
            ? Image.network(
                ad.mediaUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.error),
              )
            : const Center(
                child: Icon(Icons.play_circle_outline, size: 40),
              ),
      ),
    );
  }

  Future<void> _showUploadDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => const AdUploadDialog(),
    );

    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ad uploaded successfully')),
      );
    }
  }

  Future<void> _showEditDialog(AdModel ad) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AdEditDialog(ad: ad),
    );

    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ad updated successfully')),
      );
    }
  }

  Future<void> _toggleAdStatus(AdModel ad) async {
    final adProvider = context.read<AdProvider>();
    await adProvider.toggleAdStatus(ad.id, !ad.isEnabled);
  }

  Future<void> _confirmDelete(AdModel ad) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Ad'),
        content: Text('Are you sure you want to delete "${ad.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final adProvider = context.read<AdProvider>();
      await adProvider.deleteAd(ad.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ad deleted successfully')),
        );
      }
    }
  }

  Future<void> _handleReorder(List<AdModel> ads, int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    final List<AdModel> reorderedAds = List.from(ads);
    final item = reorderedAds.removeAt(oldIndex);
    reorderedAds.insert(newIndex, item);

    final adProvider = context.read<AdProvider>();
    await adProvider.reorderAds(reorderedAds);
  }
}
