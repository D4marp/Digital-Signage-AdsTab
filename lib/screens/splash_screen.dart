import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../widgets/responsive_layout.dart';
import '../../utils/responsive_helper.dart';
import 'mode_selection_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    if (kDebugMode) {
      print('✅ [SplashScreen] initState called');
    }
    _navigate();
  }

  Future<void> _navigate() async {
    if (kDebugMode) {
      print('✅ [SplashScreen] _navigate started');
    }
    await Future.delayed(const Duration(seconds: 2));
    
    if (!mounted) {
      if (kDebugMode) {
        print('❌ [SplashScreen] Not mounted, returning');
      }
      return;
    }

    // Navigate to Mode Selection Screen
    if (kDebugMode) {
      print('✅ [SplashScreen] Navigating to ModeSelectionScreen');
    }
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const ModeSelectionScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      print('✅ [SplashScreen] build called');
    }
    final isSmallMobile = ResponsiveHelper.isSmallMobile(context);
    final isMobile = ResponsiveHelper.isMobile(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.withValues(alpha: 0.6),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Logo
              Container(
                padding: EdgeInsets.all(isSmallMobile ? 16 : 24),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.campaign,
                  size: isSmallMobile ? 60 : (isMobile ? 80 : 100),
                  color: Colors.white,
                ),
              ),
              ResponsiveSpacer(height: isSmallMobile ? 20 : 24),

              // Title
              ResponsiveText(
                'AdsTap',
                baseFontSize: 32,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              ResponsiveSpacer(height: isSmallMobile ? 8 : 12),

              // Subtitle
              ResponsiveText(
                'Loading...',
                baseFontSize: 16,
                style: TextStyle(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              ResponsiveSpacer(height: isSmallMobile ? 16 : 32),

              // Loading indicator
              SizedBox(
                width: isSmallMobile ? 40 : 50,
                height: isSmallMobile ? 40 : 50,
                child: const CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
