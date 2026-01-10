class ApiConfig {
  // Use real IP for physical device, localhost for simulator
  // For real device: use Mac's local network IP
  static const String baseUrl = 'http://192.168.9.181:8080/api/v1';
  
  // Auth endpoints
  static const String login = '$baseUrl/auth/login';
  static const String register = '$baseUrl/auth/register';
  static const String resetPassword = '$baseUrl/auth/reset-password';
  static const String currentUser = '$baseUrl/auth/me';
  
  // Ads endpoints
  static const String ads = '$baseUrl/ads';
  static String adById(String id) => '$baseUrl/ads/$id';
  static const String uploadMedia = '$baseUrl/ads/upload';
  static const String reorderAds = '$baseUrl/ads/reorder';
  
  // Devices endpoints
  static const String devices = '$baseUrl/devices';
  static String deviceById(String id) => '$baseUrl/devices/$id';
  static const String registerDevice = '$baseUrl/devices/register';
  static String heartbeat(String id) => '$baseUrl/devices/$id/heartbeat';
  static String incrementViews(String id) => '$baseUrl/devices/$id/increment-views';
  
  // Analytics endpoints
  static const String impressions = '$baseUrl/analytics/impressions';
  static const String analytics = '$baseUrl/analytics';
  static const String dashboardStats = '$baseUrl/analytics/dashboard';
  static String adPerformance(String id) => '$baseUrl/analytics/ads/$id/performance';
  
  // Upload URL base
  static const String uploadBaseUrl = 'http://192.168.9.181:8080';
}
