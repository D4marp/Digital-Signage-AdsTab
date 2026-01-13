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

// Environment mode: 'local' atau 'production'
const String appEnvironment = String.fromEnvironment('ENV', defaultValue: 'local');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables based on environment mode
  final envFile = appEnvironment == 'production' ? '.env.production' : '.env.local';
  await dotenv.load(fileName: envFile);
  
  if (kDebugMode) {
    print('🚀 Running in $appEnvironment mode');
    print('📡 API URL: ${dotenv.env['API_BASE_URL']}');
  }
  
  // Initialize API client
  await ApiClient.init();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
    DeviceOrientation.portraitUp,
  ]);
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AdProvider()),
        ChangeNotifierProvider(create: (_) => AnalyticsProvider()),
        ChangeNotifierProvider(create: (_) => DeviceProvider()),
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
