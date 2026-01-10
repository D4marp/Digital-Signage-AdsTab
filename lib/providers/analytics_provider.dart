import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../services/api_client.dart';
import '../config/api_config.dart';
import '../models/dashboard_stats.dart';
import '../models/impression_model.dart';

class AnalyticsProvider extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();

  Map<String, dynamic> _dashboardStats = {};
  List<Map<String, dynamic>> _analytics = [];
  bool _isLoading = false;
  String? _errorMessage;

  Map<String, dynamic> get dashboardStats => _dashboardStats;
  List<Map<String, dynamic>> get analytics => _analytics;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadDashboardStats() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiClient.dio.get(ApiConfig.dashboardStats);
      _dashboardStats = response.data;
      _isLoading = false;
      notifyListeners();
    } on DioException catch (e) {
      _errorMessage = 'Failed to load dashboard stats: ${e.message}';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadAnalytics({
    String? startDate,
    String? endDate,
    String? adId,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final queryParams = <String, dynamic>{};
      if (startDate != null) queryParams['start_date'] = startDate;
      if (endDate != null) queryParams['end_date'] = endDate;
      if (adId != null) queryParams['ad_id'] = adId;

      final response = await _apiClient.dio.get(
        ApiConfig.analytics,
        queryParameters: queryParams,
      );
      
      _analytics = List<Map<String, dynamic>>.from(response.data);
      _isLoading = false;
      notifyListeners();
    } on DioException catch (e) {
      _errorMessage = 'Failed to load analytics: ${e.message}';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<Map<String, dynamic>>> getAdPerformance(String adId, int days) async {
    try {
      final response = await _apiClient.dio.get(
        ApiConfig.adPerformance(adId),
        queryParameters: {'days': days.toString()},
      );
      
      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      debugPrint('Error getting ad performance: $e');
      return [];
    }
  }

  Future<void> trackImpression(String adId, String deviceId) async {
    try {
      await _apiClient.dio.post(
        ApiConfig.impressions,
        data: {
          'ad_id': adId,
          'device_id': deviceId,
        },
      );
    } catch (e) {
      debugPrint('Error tracking impression: $e');
    }
  }

  Future<DashboardStats> getOverallStats() async {
    try {
      final response = await _apiClient.dio.get(ApiConfig.dashboardStats);
      return DashboardStats.fromJson(response.data);
    } catch (e) {
      debugPrint('Error getting overall stats: $e');
      return DashboardStats(
        activeAds: 0,
        onlineDevices: 0,
        todayImpressions: 0,
        totalAds: 0,
        totalDevices: 0,
        totalImpressions30d: 0,
        topAds: [],
      );
    }
  }

  Future<List<AdAnalytics>> getAdAnalytics(
    String adId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{'ad_id': adId};
      if (startDate != null) {
        queryParams['start_date'] = startDate.toIso8601String().split('T')[0];
      }
      if (endDate != null) {
        queryParams['end_date'] = endDate.toIso8601String().split('T')[0];
      }

      final response = await _apiClient.dio.get(
        ApiConfig.analytics,
        queryParameters: queryParams,
      );
      
      return (response.data as List)
          .map((json) => AdAnalytics.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('Error getting ad analytics: $e');
      return [];
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
