import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
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
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.campaign,
              size: 100,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 24),
            Text(
              'Digital Signage',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Loading...',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey,
                  ),
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
