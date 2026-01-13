import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/ad_provider.dart';
import '../../models/ad_model.dart';
import '../../utils/responsive_helper.dart';
import 'widgets/ad_detail_dialog.dart';
import 'widgets/video_ad_widget.dart';

class DisplayHomeScreen extends StatefulWidget {
  const DisplayHomeScreen({super.key});

  @override
  State<DisplayHomeScreen> createState() => _DisplayHomeScreenState();
}

class _DisplayHomeScreenState extends State<DisplayHomeScreen>
    with WidgetsBindingObserver {
  late PageController _pageController;
  int _currentAdIndex = 0;
  late List<AdModel> _displayAds = [];
  int _totalViewsForCurrentTab = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _pageController = PageController();
    _loadAds();
  }

  void _loadAds() {
    final adProvider = Provider.of<AdProvider>(context, listen: false);
    _displayAds = adProvider.activeAds;
    if (_displayAds.isNotEmpty) {
      _trackViewForCurrentAd();
    }
  }

  Future<void> _trackViewForCurrentAd() async {
    if (_displayAds.isNotEmpty) {
      final currentAd = _displayAds[_currentAdIndex];
      final adProvider = Provider.of<AdProvider>(context, listen: false);
      await adProvider.trackAdView(currentAd.id);
      setState(() {
        _totalViewsForCurrentTab = currentAd.totalViews;
      });
    }
  }

  Future<void> _refreshData() async {
    final adProvider = Provider.of<AdProvider>(context, listen: false);
    await adProvider.loadAds();
    _loadAds();
    setState(() {});
  }

  void _previousAd() {
    if (_currentAdIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _nextAd() {
    if (_currentAdIndex < _displayAds.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _showAdDetail() {
    if (_displayAds.isNotEmpty) {
      showDialog(
        context: context,
        builder: (context) => AdDetailDialog(
          ad: _displayAds[_currentAdIndex],
          onClose: () => Navigator.pop(context),
        ),
      );
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: _displayAds.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.display_settings,
                    size: 80,
                    color: Colors.grey[700],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Tidak ada iklan untuk ditampilkan',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _refreshData,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Muat Ulang'),
                  ),
                ],
              ),
            )
          : Stack(
              children: [
                // Ad Display PageView
                PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentAdIndex = index;
                      _totalViewsForCurrentTab =
                          _displayAds[index].totalViews;
                    });
                    _trackViewForCurrentAd();
                  },
                  itemCount: _displayAds.length,
                  itemBuilder: (context, index) {
                    final ad = _displayAds[index];
                    return _buildAdWidget(ad, isMobile);
                  },
                ),

                // Top Bar - Title & Views
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.6),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    padding: EdgeInsets.fromLTRB(
                      16,
                      isMobile ? 16 : 24,
                      16,
                      24,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Title
                        Text(
                          _displayAds[_currentAdIndex].title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        // Total Views
                        Row(
                          children: [
                            Icon(
                              Icons.visibility,
                              color: Colors.amber[300],
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Total Penayangan: $_totalViewsForCurrentTab',
                              style: TextStyle(
                                color: Colors.amber[300],
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Bottom Bar - Navigation & More Info
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.8),
                        ],
                      ),
                    ),
                    padding: EdgeInsets.all(isMobile ? 16 : 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Tab Indicator
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            _displayAds.length,
                            (index) => Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: _currentAdIndex == index ? 24 : 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: _currentAdIndex == index
                                    ? Colors.cyan
                                    : Colors.grey,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Navigation & Actions Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Previous Button
                            SizedBox(
                              width: 50,
                              height: 50,
                              child: ElevatedButton(
                                onPressed:
                                    _currentAdIndex > 0 ? _previousAd : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _currentAdIndex > 0
                                      ? Colors.cyan
                                      : Colors.grey[700],
                                  shape: const CircleBorder(),
                                  disabledBackgroundColor: Colors.grey[700],
                                ),
                                child: const Icon(
                                  Icons.arrow_back_ios,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),

                            // Refresh Button
                            SizedBox(
                              width: 50,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: _refreshData,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                  shape: const CircleBorder(),
                                ),
                                child: const Icon(
                                  Icons.refresh,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),

                            // More Info Button (Tap Disini)
                            ElevatedButton.icon(
                              onPressed: _showAdDetail,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepOrange,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                              ),
                              icon: const Icon(Icons.info_outline),
                              label: const Text('Tap Disini'),
                            ),

                            // Next Button
                            SizedBox(
                              width: 50,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: _currentAdIndex <
                                        _displayAds.length - 1
                                    ? _nextAd
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _currentAdIndex <
                                          _displayAds.length - 1
                                      ? Colors.cyan
                                      : Colors.grey[700],
                                  shape: const CircleBorder(),
                                  disabledBackgroundColor: Colors.grey[700],
                                ),
                                child: const Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Navigation Indicator
                        const SizedBox(height: 12),
                        Text(
                          '${_currentAdIndex + 1} / ${_displayAds.length}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildAdWidget(AdModel ad, bool isMobile) {
    if (ad.mediaType == 'image') {
      return Container(
        color: Colors.black,
        child: Image.network(
          ad.mediaUrl,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline,
                      color: Colors.red, size: 60),
                  const SizedBox(height: 16),
                  const Text(
                    'Gagal memuat gambar',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            );
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.cyan[400]!),
              ),
            );
          },
        ),
      );
    } else if (ad.mediaType == 'video') {
      return VideoAdWidget(videoUrl: ad.mediaUrl);
    } else if (ad.mediaType == 'pdf') {
      return Container(
        color: Colors.black,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.picture_as_pdf, color: Colors.red, size: 80),
            const SizedBox(height: 16),
            Text(
              ad.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('PDF viewer sedang dalam pengembangan')),
                );
              },
              icon: const Icon(Icons.open_in_new),
              label: const Text('Buka PDF'),
            ),
          ],
        ),
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.question_mark, color: Colors.grey, size: 60),
          const SizedBox(height: 16),
          const Text(
            'Tipe media tidak dikenal',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
