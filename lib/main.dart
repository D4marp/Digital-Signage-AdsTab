import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/ad_provider.dart';
import 'providers/analytics_provider.dart';
import 'providers/device_provider.dart';
import 'screens/splash_screen.dart';
import 'utils/app_theme.dart';
import 'services/api_client.dart';

Future<void> initializeApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  if (kDebugMode) {
    print('🚀 [INIT] Starting initialization...');
  }
  
  try {
    // Load environment variables from .env file FIRST and wait
    if (kDebugMode) {
      print('🚀 [INIT] Loading .env file...');
    }
    await dotenv.load(fileName: '.env');
    
    // Add small delay to ensure dotenv is fully initialized
    await Future.delayed(const Duration(milliseconds: 100));
    
    if (kDebugMode) {
      print('✅ [INIT] .env loaded successfully');
      print('📡 [INIT] API URL: ${dotenv.env['API_BASE_URL'] ?? 'NOT SET'}');
    }
  } catch (e) {
    if (kDebugMode) {
      print('❌ [INIT] Error loading .env: $e');
    }
  }
  
  try {
    // Initialize API client AFTER dotenv is loaded
    if (kDebugMode) {
      print('🚀 [INIT] Initializing ApiClient...');
    }
    await ApiClient.init();
    if (kDebugMode) {
      print('✅ [INIT] ApiClient initialized');
    }
  } catch (e) {
    if (kDebugMode) {
      print('❌ [INIT] Error initializing ApiClient: $e');
    }
  }
  
  try {
    // Set preferred orientations
    if (kDebugMode) {
      print('🚀 [INIT] Setting preferred orientations...');
    }
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.portraitUp,
    ]);
    if (kDebugMode) {
      print('✅ [INIT] Orientations set');
    }
  } catch (e) {
    if (kDebugMode) {
      print('❌ [INIT] Error setting orientations: $e');
    }
  }
}

void main() async {
  await initializeApp();
  
  if (kDebugMode) {
    print('🚀 [MAIN] Running app...');
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) {
          if (kDebugMode) {
            print('✅ [PROVIDERS] Creating AuthProvider');
          }
          return AuthProvider();
        }),
        ChangeNotifierProvider(create: (_) {
          if (kDebugMode) {
            print('✅ [PROVIDERS] Creating AdProvider');
          }
          return AdProvider();
        }),
        ChangeNotifierProvider(create: (_) {
          if (kDebugMode) {
            print('✅ [PROVIDERS] Creating AnalyticsProvider');
          }
          return AnalyticsProvider();
        }),
        ChangeNotifierProvider(create: (_) {
          if (kDebugMode) {
            print('✅ [PROVIDERS] Creating DeviceProvider');
          }
          return DeviceProvider();
        }),
      ],
      child: MaterialApp(
        title: 'Digital Signage',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        home: const SplashScreen(),
      ),
    );
  }
}
