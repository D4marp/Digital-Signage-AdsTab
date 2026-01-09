import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../providers/ad_provider.dart';
import '../../providers/analytics_provider.dart';
import '../../providers/device_provider.dart';
import '../../models/ad_model.dart';
import '../../utils/device_helper.dart';
import 'widgets/video_ad_widget.dart';
import 'widgets/ad_detail_dialog.dart';

class DisplayHomeScreen extends StatefulWidget {
  const DisplayHomeScreen({super.key});

  @override
  State<DisplayHomeScreen> createState() => _DisplayHomeScreenState();
}

class _DisplayHomeScreenState extends State<DisplayHomeScreen> with WidgetsBindingObserver {
  String _deviceId = '';
  String _location = 'Default Location';
  List<AdModel> _ads = [];
  int _currentIndex = 0;
  Timer? _adTimer;
  DateTime? _adStartTime;
  bool _isLoading = true;
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeDisplay();
    _enterFullScreen();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _adTimer?.cancel();
    _exitFullScreen();
    super.dispose();
  }

  Future<void> _initializeDisplay() async {
    // Get device ID
    _deviceId = await DeviceHelper.getDeviceId();

    // Show location dialog
    if (mounted) {
      await _showLocationDialog();
    }

    // Register device
    if (mounted) {
      await context.read<DeviceProvider>().registerDevice(_deviceId, _location);
    }

    // Load ads
    await _loadAds();

    // Start heartbeat to update device status
    _startHeartbeat();
  }

  Future<void> _showLocationDialog() async {
    final controller = TextEditingController(text: _location);
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Set Device Location'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Location (e.g., Hotel Lobby, Restaurant Entrance)',
            hintText: 'Enter location name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _location = controller.text.isNotEmpty
                  ? controller.text
                  : 'Default Location';
              Navigator.of(context).pop();
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
    controller.dispose();
  }

  Future<void> _loadAds() async {
    setState(() => _isLoading = true);

    final adProvider = context.read<AdProvider>();
    final ads = await adProvider.getActiveAdsForDevice(_location);

    if (mounted) {
      setState(() {
        _ads = ads;
        _isLoading = false;
      });

      if (_ads.isNotEmpty) {
        _startAdTracking();
      }
    }
  }

  void _startAdTracking() {
    if (_isPaused) return; // Don't start if paused
    
    _adStartTime = DateTime.now();
    
    // Schedule next ad change
    final currentAd = _ads[_currentIndex];
    _adTimer?.cancel();
    _adTimer = Timer(Duration(seconds: currentAd.durationSeconds), () {
      _trackCurrentAdImpression(isCompleted: true);
      _moveToNextAd();
    });
  }

  void _pauseAdTracking() {
    setState(() {
      _isPaused = true;
    });
    _adTimer?.cancel();
  }

  void _resumeAdTracking() {
    setState(() {
      _isPaused = false;
    });
    _startAdTracking();
  }

  void _showAdDetail() {
    if (_ads.isEmpty) return;
    
    final currentAd = _ads[_currentIndex];
    _pauseAdTracking();

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AdDetailDialog(
        ad: currentAd,
        onClose: () {
          Navigator.of(context).pop();
          _resumeAdTracking();
        },
      ),
    ).then((_) {
      // Resume if dialog closed by tapping outside
      if (_isPaused) {
        _resumeAdTracking();
      }
    });
  }

  void _moveToNextAd() {
    if (_ads.isEmpty) return;

    setState(() {
      _currentIndex = (_currentIndex + 1) % _ads.length;
    });

    _startAdTracking();
  }

  Future<void> _trackCurrentAdImpression({required bool isCompleted}) async {
    if (_adStartTime == null || _ads.isEmpty) return;

    final currentAd = _ads[_currentIndex];

    await context.read<AnalyticsProvider>().trackImpression(
          currentAd.id,
          _deviceId,
        );
  }

  void _startHeartbeat() {
    // Update device status every 30 seconds
    Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) {
        context.read<DeviceProvider>().updateDeviceStatus(_deviceId, true);
      } else {
        timer.cancel();
      }
    });
  }

  void _enterFullScreen() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  void _exitFullScreen() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _trackCurrentAdImpression(isCompleted: false);
      context.read<DeviceProvider>().updateDeviceStatus(_deviceId, false);
    } else if (state == AppLifecycleState.resumed) {
      context.read<DeviceProvider>().updateDeviceStatus(_deviceId, true);
      _adStartTime = DateTime.now();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_ads.isEmpty) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.info_outline, size: 80, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                'No ads available',
                style: TextStyle(fontSize: 24, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadAds,
                icon: const Icon(Icons.refresh),
                label: const Text('Reload'),
              ),
            ],
          ),
        ),
      );
    }

    final currentAd = _ads[_currentIndex];

    return Scaffold(
      body: GestureDetector(
        onTap: _showAdDetail, // Single tap to show details
        onLongPress: () {
          // Secret gesture to exit kiosk mode
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Exit Display Mode?'),
              content: const Text('Do you want to return to mode selection?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    _exitFullScreen();
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                  child: const Text('Exit'),
                ),
              ],
            ),
          );
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Ad Display
            if (currentAd.mediaType == 'video')
              VideoAdWidget(
                key: ValueKey(currentAd.id),
                videoUrl: currentAd.mediaUrl,
                onEnded: () {
                  _trackCurrentAdImpression(isCompleted: true);
                  _moveToNextAd();
                },
              )
            else
              CachedNetworkImage(
                imageUrl: currentAd.mediaUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(),
                ),
                errorWidget: (context, url, error) => const Center(
                  child: Icon(Icons.error, size: 80, color: Colors.red),
                ),
              ),

            // Progress indicator
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(
                value: (_currentIndex + 1) / _ads.length,
                backgroundColor: Colors.black26,
                valueColor: const AlwaysStoppedAnimation(Colors.white),
              ),
            ),

            // Ad info overlay (optional, can be removed)
            Positioned(
              bottom: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_currentIndex + 1} / ${_ads.length}',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),

            // Tap hint overlay
            Positioned(
              top: 20,
              left: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.touch_app,
                      color: Colors.white.withOpacity(0.9),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Tap for details',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
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
