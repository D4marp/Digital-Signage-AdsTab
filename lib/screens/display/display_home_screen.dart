import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:async';
import 'dart:io' as io;
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
  Timer? _autoRotateTimer;
  static const int AUTO_ROTATE_INTERVAL_SECONDS = 10;

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
          _startAutoRotate();
          // Skip image preloading on Android to avoid crashes - will load lazily
          if (!kIsWeb && !_isAndroid()) {
            _preloadAdImages(_displayAds);
          }
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

  bool _isAndroid() {
    return io.Platform.isAndroid;
  }

  Future<void> _preloadAdImages(List<AdModel> ads) async {
    if (kDebugMode) {
      print('🖼️  [DisplayHomeScreen] Preloading ${ads.length} ad images in background...');
    }
    try {
      for (final ad in ads) {
        if (ad.mediaType == 'image' && mounted) {
          try {
            final ImageProvider imageProvider = NetworkImage(ad.mediaUrl);
            await precacheImage(imageProvider, context).timeout(
              const Duration(seconds: 10),
              onTimeout: () {
                if (kDebugMode) {
                  print('⏱️  [DisplayHomeScreen] Preload timeout for: ${ad.mediaUrl}');
                }
              },
            );
            if (kDebugMode) {
              print('✅ [DisplayHomeScreen] Preloaded: ${ad.mediaUrl}');
            }
          } catch (e) {
            if (kDebugMode) {
              print('⚠️  [DisplayHomeScreen] Failed to preload ${ad.mediaUrl}: $e');
            }
            // Continue with next image
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️  [DisplayHomeScreen] Error in preload batch: $e');
      }
    }
  }

  Future<void> _trackViewForCurrentAd() async {
    if (_displayAds.isNotEmpty) {
      final currentAd = _displayAds[_currentAdIndex];
      final adProvider = Provider.of<AdProvider>(context, listen: false);
      await adProvider.trackAdView(currentAd.id);
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
    _stopAutoRotate();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoRotate() {
    // Cancel existing timer
    _autoRotateTimer?.cancel();
    
    // Start new timer to auto-advance to next ad every 10 seconds
    _autoRotateTimer = Timer.periodic(
      Duration(seconds: AUTO_ROTATE_INTERVAL_SECONDS),
      (_) {
        if (mounted && _displayAds.isNotEmpty) {
          _nextAd();
        }
      },
    );
    
    if (kDebugMode) {
      print('✅ [DisplayHomeScreen] Auto-rotate started (${AUTO_ROTATE_INTERVAL_SECONDS}s interval)');
    }
  }

  void _stopAutoRotate() {
    _autoRotateTimer?.cancel();
    _autoRotateTimer = null;
    
    if (kDebugMode) {
      print('⏹️  [DisplayHomeScreen] Auto-rotate stopped');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final isSmallMobile = ResponsiveHelper.isSmallMobile(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Consumer<AdProvider>(
        builder: (context, adProvider, _) {
          // Show loading shimmer
          if (adProvider.isLoading && _displayAds.isEmpty) {
            return _buildShimmerLoading(context, isSmallMobile);
          }

          // Show content with refresh indicator
          return RefreshIndicator(
            onRefresh: () async {
              // Force refresh with new data
              final adProvider = Provider.of<AdProvider>(context, listen: false);
              await adProvider.refreshAds();
              _loadAds();
            },
            backgroundColor: Colors.white,
            color: Colors.cyan,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: SizedBox(
                height: MediaQuery.of(context).size.height,
                child: _buildAdDisplayContent(context, adProvider, isMobile, isSmallMobile),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildShimmerLoading(BuildContext context, bool isSmallMobile) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final containerWidth = (screenWidth * 0.8).clamp(250, 400);
    final containerHeight = (screenHeight * 0.5).clamp(300, 500);
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: containerWidth.toDouble(),
            height: containerHeight.toDouble(),
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
          SizedBox(height: isSmallMobile ? 16 : 24),
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
          SizedBox(height: isSmallMobile ? 16 : 24),
          Text(
            'Memuat iklan...',
            style: TextStyle(
              color: Colors.grey,
              fontSize: isSmallMobile ? 14 : 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdDisplayContent(
      BuildContext context, AdProvider adProvider, bool isMobile, bool isSmallMobile) {
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
        // (Removed - title display hidden)

        // Left Navigation Button (Middle Left)
        Positioned(
          left: 40,
          top: 0,
          bottom: 0,
          child: Center(
            child: SizedBox(
              width: 60,
              height: 60,
              child: ElevatedButton(
                onPressed: _previousAd,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEC0303),
                  shape: const CircleBorder(),
                ),
                child: const Icon(
                  Icons.chevron_left,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          ),
        ),

        // Right Navigation Button (Middle Right)
        Positioned(
          right: 40,
          top: 0,
          bottom: 0,
          child: Center(
            child: SizedBox(
              width: 60,
              height: 60,
              child: ElevatedButton(
                onPressed: _nextAd,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEC0303),
                  shape: const CircleBorder(),
                ),
                child: const Icon(
                  Icons.chevron_right,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          ),
        ),



        // Bottom Bar - Pagination Dots & Tap Here Button
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
                // Pagination Dots
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
                            ? const Color(0xFFEC0303)
                            : Colors.grey,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Tap Here Button
                SizedBox(
                  width: 200,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _showAdDetail,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEC0303),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                    child: const Text(
                      'Tap Here',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
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
          ad.mediaUrl,  // HOME SCREEN ONLY: Display main image (NOT gallery images)
          fit: BoxFit.contain,
          cacheHeight: (MediaQuery.of(context).size.height * MediaQuery.of(context).devicePixelRatio).toInt(),
          cacheWidth: (MediaQuery.of(context).size.width * MediaQuery.of(context).devicePixelRatio).toInt(),
          errorBuilder: (context, error, stackTrace) {
            debugPrint('❌ [DisplayHome] Image load error for ${ad.mediaUrl}: $error');
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.cyan[400]!),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Memuat: ${(loadingProgress.cumulativeBytesLoaded / 1024 / 1024).toStringAsFixed(1)}MB',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
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
