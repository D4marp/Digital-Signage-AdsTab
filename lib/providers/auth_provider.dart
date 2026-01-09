import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
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
      final response = await _apiClient.dio.post(
        ApiConfig.login,
        data: {
          'email': email,
          'password': password,
        },
      );

      final token = response.data['token'];
      await _apiClient.setAuthToken(token);
      
      _userModel = UserModel.fromJson(response.data['user']);
      _isLoading = false;
      notifyListeners();
      return true;
    } on DioException catch (e) {
      _isLoading = false;
      _errorMessage = e.response?.data['error'] ?? 'Login failed';
      notifyListeners();
      return false;
    }
  }

  Future<bool> signUp(String email, String password, String displayName) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiClient.dio.post(
        ApiConfig.register,
        data: {
          'email': email,
          'password': password,
          'display_name': displayName,
        },
      );

      final token = response.data['token'];
      await _apiClient.setAuthToken(token);
      
      _userModel = UserModel.fromJson(response.data['user']);
      _isLoading = false;
      notifyListeners();
      return true;
    } on DioException catch (e) {
      _isLoading = false;
      _errorMessage = e.response?.data['error'] ?? 'Registration failed';
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
}
