import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import 'package:flutter/foundation.dart';

class ApiClient {
  static ApiClient? _instance;
  factory ApiClient() {
    _instance ??= ApiClient._internal();
    return _instance!;
  }
  
  late Dio _dio;
  static bool _initialized = false;
  
  static Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    // Force instance creation with updated BaseURL
    _instance = null;
    // This will create a new instance with the current ApiConfig.baseUrl
    ApiClient();
  }
  
  ApiClient._internal() {
    final currentBaseUrl = ApiConfig.baseUrl;
    _debugLog('🔧 Creating ApiClient with baseUrl: $currentBaseUrl');
    
    _dio = Dio(BaseOptions(
      baseUrl: currentBaseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));
    
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Add auth token to requests
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('auth_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        _debugLog('📤 Request: ${options.method} ${options.path}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        _debugLog('📥 Response: ${response.statusCode} ${response.requestOptions.path}');
        return handler.next(response);
      },
      onError: (error, handler) async {
        _debugLog('❌ Error: ${error.response?.statusCode} ${error.message}');
        
        // Handle 401 Unauthorized
        if (error.response?.statusCode == 401) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('auth_token');
          // Navigate to login screen would be handled by UI layer
        }
        return handler.next(error);
      },
    ));
  }
  
  static void _debugLog(String message) {
    if (kDebugMode) {
      debugPrint('[ApiClient] $message');
    }
  }
  
  Dio get dio => _dio;
  
  Future<void> setAuthToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    _debugLog('✅ Auth token saved');
  }
  
  Future<void> clearAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    _debugLog('✅ Auth token cleared');
  }
  
  Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }
}
