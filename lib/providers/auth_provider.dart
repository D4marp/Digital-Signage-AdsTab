import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/api_client.dart';
import '../config/api_config.dart';

class AuthProvider extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  
  UserModel? _userModel;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get userModel => _userModel;
  UserModel? get user => _userModel;  // Alias for backward compatibility
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _userModel != null;

  AuthProvider() {
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    try {
      final token = await _apiClient.getAuthToken();
      if (token != null) {
        final response = await _apiClient.dio.get(ApiConfig.currentUser);
        _userModel = UserModel.fromJson(response.data);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading current user: $e');
    }
  }

  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      debugPrint('🔐 Attempting login with email: $email');
      final response = await _apiClient.dio.post(
        ApiConfig.login,
        data: {
          'email': email,
          'password': password,
        },
      );

      debugPrint('✅ Login response: ${response.data}');
      
      final token = response.data['token'];
      if (token == null) {
        throw Exception('Token not found in response');
      }
      
      await _apiClient.setAuthToken(token);
      
      // Parse user data - handle both nested and direct user object
      final userData = response.data['user'] ?? response.data;
      _userModel = UserModel.fromJson(userData);
      
      debugPrint('✅ User logged in: ${_userModel?.email}');
      _isLoading = false;
      notifyListeners();
      return true;
    } on DioException catch (e) {
      _isLoading = false;
      final errorMsg = e.response?.data['error'] ?? 
                       e.response?.data?.toString() ?? 
                       'Login failed: ${e.message}';
      _errorMessage = errorMsg;
      debugPrint('❌ Login error: $errorMsg');
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Login failed: $e';
      debugPrint('❌ Unexpected error: $e');
      notifyListeners();
      return false;
    }
  }

  // Alias for signIn (for compatibility)
  Future<bool> login(String email, String password) async {
    return await signIn(email, password);
  }

  Future<bool> signUp(String email, String password, String displayName) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      debugPrint('📝 Attempting registration with email: $email');
      final response = await _apiClient.dio.post(
        ApiConfig.register,
        data: {
          'email': email,
          'password': password,
          'display_name': displayName,
        },
      );

      debugPrint('✅ Registration response: ${response.data}');
      
      final token = response.data['token'];
      if (token == null) {
        throw Exception('Token not found in response');
      }
      
      await _apiClient.setAuthToken(token);
      
      // Parse user data - handle both nested and direct user object
      final userData = response.data['user'] ?? response.data;
      _userModel = UserModel.fromJson(userData);
      
      debugPrint('✅ User registered: ${_userModel?.email}');
      _isLoading = false;
      notifyListeners();
      return true;
    } on DioException catch (e) {
      _isLoading = false;
      final errorMsg = e.response?.data['error'] ?? 
                       e.response?.data?.toString() ?? 
                       'Registration failed: ${e.message}';
      _errorMessage = errorMsg;
      debugPrint('❌ Registration error: $errorMsg');
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Registration failed: $e';
      debugPrint('❌ Unexpected error: $e');
      notifyListeners();
      return false;
    }
  }

  Future<bool> resetPassword(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _apiClient.dio.post(
        ApiConfig.resetPassword,
        data: {'email': email},
      );
      
      _isLoading = false;
      notifyListeners();
      return true;
    } on DioException catch (e) {
      _isLoading = false;
      _errorMessage = e.response?.data['error'] ?? 'Password reset failed';
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    await _apiClient.clearAuthToken();
    _userModel = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // NEW: Save login credentials locally
  Future<void> saveCredentials(String email, String password) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('saved_email', email);
      // Note: Never save plain passwords in production. This is just for demo.
      // In production, use secure storage.
      await prefs.setString('saved_password', password);
      await prefs.setBool('remember_me', true);
    } catch (e) {
      debugPrint('Error saving credentials: $e');
    }
  }

  // NEW: Get saved credentials
  Future<Map<String, String>?> getSavedCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rememberMe = prefs.getBool('remember_me') ?? false;
      
      if (rememberMe) {
        final email = prefs.getString('saved_email');
        final password = prefs.getString('saved_password');
        
        if (email != null && password != null) {
          return {
            'email': email,
            'password': password,
          };
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error getting saved credentials: $e');
      return null;
    }
  }

  // NEW: Clear saved credentials
  Future<void> clearCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('saved_email');
      await prefs.remove('saved_password');
      await prefs.setBool('remember_me', false);
    } catch (e) {
      debugPrint('Error clearing credentials: $e');
    }
  }
}
