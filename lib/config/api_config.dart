import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  // Use environment variable for base URL
  static String get baseUrl => dotenv.env['API_BASE_URL'] ?? 'http://localhost:8080/api/v1';
  
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
