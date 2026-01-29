import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';

class ApiConfig {
  // Static base URL - initialize once on app start
  static late String _baseUrl;
  
  // Initialize with the actual base URL from env or fallback
  static void initialize() {
    try {
      final url = dotenv.env['API_BASE_URL'];
      _baseUrl = url ?? 'http://saas.hcm-lab.id/api/v1';
      if (kDebugMode) {
        print('✅ [ApiConfig] Initialized baseUrl: $_baseUrl');
      }
    } catch (e) {
      _baseUrl = 'http://saas.hcm-lab.id/api/v1';
      if (kDebugMode) {
        print('⚠️  [ApiConfig] Error initializing baseUrl: $e, using fallback: $_baseUrl');
      }
    }
  }

  // Use environment variable for base URL with fallback
  static String get baseUrl {
    if (_baseUrl.isEmpty) {
      initialize();
    }
    return _baseUrl;
  }
  
  // Auth endpoints
  static String get login => '$baseUrl/auth/login';
  static String get register => '$baseUrl/auth/register';
  static String get resetPassword => '$baseUrl/auth/reset-password';
  static String get currentUser => '$baseUrl/auth/me';
  
  // Ads endpoints
  static String get ads => '$baseUrl/ads';
  static String adById(String id) => '$baseUrl/ads/$id';
  static String get uploadMedia => '$baseUrl/ads/upload';
  static String get reorderAds => '$baseUrl/ads/reorder';
  static String trackAdView(String id) => '$baseUrl/ads/$id/view';
  static String getAdsByCompany(String company) => '$baseUrl/ads/company/list?company=$company';
  static String checkCompanyUploadLimit(String company) => '$baseUrl/ads/company/check-limit?company=$company';
  
  // Devices endpoints
  static String get devices => '$baseUrl/devices';
  static String deviceById(String id) => '$baseUrl/devices/$id';
  static String get registerDevice => '$baseUrl/devices/register';
  static String heartbeat(String id) => '$baseUrl/devices/$id/heartbeat';
  static String incrementViews(String id) => '$baseUrl/devices/$id/increment-views';
  
  // Analytics endpoints
  static String get impressions => '$baseUrl/analytics/impressions';
  static String get analytics => '$baseUrl/analytics';
  static String get dashboardStats => '$baseUrl/analytics/dashboard';
  static String adPerformance(String id) => '$baseUrl/analytics/ads/$id/performance';
  
  // Upload URL base
  static String get uploadBaseUrl => baseUrl.replaceAll('/api/v1', '');
}
