import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../providers/ad_provider.dart';
import '../../models/ad_model.dart';
import '../../utils/responsive_helper.dart';
import 'widgets/video_ad_widget.dart';
import 'ad_detail_screen.dart';
import '../../gen/assets.gen.dart';

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
    if (kDebugMode) {
      print('✅ [DisplayHomeScreen] initState called');
    }
    WidgetsBinding.instance.addObserver(this);
    _pageController = PageController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (kDebugMode) {
        print('✅ [DisplayHomeScreen] postFrameCallback - calling _loadAds');
      }
      _loadAds();
    });
  }

  void _loadAds() async {
    if (kDebugMode) {
      print('✅ [DisplayHomeScreen] _loadAds started');
    }
    try {
      final adProvider = Provider.of<AdProvider>(context, listen: false);
      if (kDebugMode) {
        print('✅ [DisplayHomeScreen] AdProvider obtained, ads.isEmpty: ${adProvider.ads.isEmpty}');
      }
      
      // Load ads from API if not already loaded
      if (adProvider.ads.isEmpty) {
        if (kDebugMode) {
          print('✅ [DisplayHomeScreen] Calling adProvider.loadAds()');
        }
        await adProvider.loadAds();
        if (kDebugMode) {
          print('✅ [DisplayHomeScreen] adProvider.loadAds() completed');
        }
      }
      
      if (mounted) {
        setState(() {
          _displayAds = adProvider.activeAds;
          if (kDebugMode) {
            print('✅ [DisplayHomeScreen] State updated, activeAds count: ${_displayAds.length}');
          }
        });
        if (_displayAds.isNotEmpty) {
          await _trackViewForCurrentAd();
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [DisplayHomeScreen] Error loading ads: $e');
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading ads: $e')),
        );
      }
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

  void _previousAd() {
    if (_currentAdIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Loop ke akhir
      _pageController.animateToPage(
        _displayAds.length - 1,
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
    } else {
      // Loop ke awal
      _pageController.animateToPage(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _showAdDetail() {
    if (_displayAds.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AdDetailScreen(ad: _displayAds[_currentAdIndex]),
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
      body: Consumer<AdProvider>(
        builder: (context, adProvider, _) {
          // Show loading shimmer
          if (adProvider.isLoading && _displayAds.isEmpty) {
            return _buildShimmerLoading();
          }

          // Show content with refresh indicator
          return RefreshIndicator(
            onRefresh: () async {
              _loadAds();
            },
            backgroundColor: Colors.white,
            color: Colors.cyan,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: SizedBox(
                height: MediaQuery.of(context).size.height,
                child: _buildAdDisplayContent(context, adProvider, isMobile),
            ),
            )
          );
        },
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 300,
            height: 400,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.grey[800]!,
                  Colors.grey[700]!,
                  Colors.grey[800]!,
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 15,
                ),
              ],
            ),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[800]!,
              highlightColor: Colors.grey[600]!,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[700],
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Shimmer.fromColors(
            baseColor: Colors.grey[800]!,
            highlightColor: Colors.grey[600]!,
            child: Column(
              children: [
                Container(
                  width: 200,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.grey[700],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 150,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.grey[700],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Memuat iklan...',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdDisplayContent(
      BuildContext context, AdProvider adProvider, bool isMobile) {
    // Show error if any
    if (adProvider.errorMessage != null && _displayAds.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red,
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                adProvider.errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadAds,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }
    
    // Show no ads message
    if (_displayAds.isEmpty) {
      return Center(
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
              onPressed: _loadAds,
              icon: const Icon(Icons.refresh),
              label: const Text('Muat Ulang'),
            ),
          ],
        ),
      );
    }

    // Show ads
    return Stack(
      children: [
        // Ad Display PageView
        PageView.builder(
          controller: _pageController,
          onPageChanged: (index) {
            // Handle looping
            int actualIndex = index % _displayAds.length;
            setState(() {
              _currentAdIndex = actualIndex;
              _totalViewsForCurrentTab =
                  _displayAds[actualIndex].totalViews;
            });
            _trackViewForCurrentAd();
          },
          itemCount: _displayAds.length,
          itemBuilder: (context, index) {
            final ad = _displayAds[index % _displayAds.length];
            return _buildAdWidget(ad, isMobile, context);
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
                // Tab Indicator with Double Tap Icon
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Double Tap Icon
                    Assets.icons.doubleTap.svg(
                      width: 24,
                      height: 24,
                      colorFilter: const ColorFilter.mode(
                        Colors.cyan,
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Tabs
                    Flexible(
                      child: Row(
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
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Navigation & Actions Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Previous Button (Always Active - Looping)
                    SizedBox(
                      width: 50,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _previousAd,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.cyan,
                          shape: const CircleBorder(),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),

                    // More Info Button (Double Tap Icon Only)
                    SizedBox(
                      width: 50,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _showAdDetail,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepOrange,
                          shape: const CircleBorder(),
                          padding: EdgeInsets.zero,
                        ),
                        child: Assets.icons.doubleTap.svg(
                          width: 28,
                          height: 28,
                          colorFilter: const ColorFilter.mode(
                            Colors.white,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),

                    // Next Button (Always Active - Looping)
                    SizedBox(
                      width: 50,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _nextAd,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.cyan,
                          shape: const CircleBorder(),
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
    );
  }

  Widget _buildAdWidget(AdModel ad, bool isMobile, BuildContext context) {
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
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Informasi'),
                    content: const Text('PDF viewer sedang dalam pengembangan'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
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
