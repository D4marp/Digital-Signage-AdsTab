import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'dart:io';
import '../models/ad_model.dart';
import '../services/api_client.dart';
import '../config/api_config.dart';

class AdProvider extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();

  List<AdModel> _ads = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<AdModel> get ads => _ads;
  List<AdModel> get activeAds => _ads.where((ad) => ad.isEnabled).toList();
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AdProvider() {
    loadAds();
  }

  Future<void> loadAds() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiClient.dio.get(ApiConfig.ads);
      _ads = (response.data as List)
          .map((json) => AdModel.fromJson(json))
          .toList();
      _isLoading = false;
      notifyListeners();
    } on DioException catch (e) {
      _errorMessage = 'Failed to load ads: ${e.message}';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<AdModel>> getActiveAdsForDevice(String location) async {
    try {
      final response = await _apiClient.dio.get(
        ApiConfig.ads,
        queryParameters: {
          'location': location,
          'active': 'true',
        },
      );
      return (response.data as List)
          .map((json) => AdModel.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('Error getting active ads: $e');
      return [];
    }
  }

  Future<String> uploadMedia(File file, String fileName) async {
    try {
      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: fileName,
        ),
      });

      final response = await _apiClient.dio.post(
        ApiConfig.uploadMedia,
        data: formData,
      );

      return ApiConfig.uploadBaseUrl + response.data['url'];
    } catch (e) {
      throw Exception('Failed to upload media: $e');
    }
  }

  Future<bool> createAd({
    required String title,
    required String mediaUrl,
    required String mediaType,
    required int durationSeconds,
    required List<String> targetLocations,
    String? description,
    String? companyName,
    String? contactInfo,
    String? websiteUrl,
  }) async {
    try {
      final data = {
        'title': title,
        'media_url': mediaUrl,
        'media_type': mediaType,
        'duration_seconds': durationSeconds,
        'target_locations': targetLocations,
      };
      
      if (description != null) data['description'] = description;
      if (companyName != null) data['company_name'] = companyName;
      if (contactInfo != null) data['contact_info'] = contactInfo;
      if (websiteUrl != null) data['website_url'] = websiteUrl;
      
      final response = await _apiClient.dio.post(
        ApiConfig.ads,
        data: data,
      );

      final newAd = AdModel.fromJson(response.data);
      _ads.add(newAd);
      notifyListeners();
      return true;
    } on DioException catch (e) {
      _errorMessage = e.response?.data['error'] ?? 'Failed to create ad';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateAd({
    required String id,
    String? title,
    String? mediaUrl,
    String? mediaType,
    int? durationSeconds,
    bool? isEnabled,
    List<String>? targetLocations,
    String? description,
    String? companyName,
    String? contactInfo,
    String? websiteUrl,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (title != null) data['title'] = title;
      if (mediaUrl != null) data['media_url'] = mediaUrl;
      if (mediaType != null) data['media_type'] = mediaType;
      if (durationSeconds != null) data['duration_seconds'] = durationSeconds;
      if (isEnabled != null) data['is_enabled'] = isEnabled;
      if (targetLocations != null) data['target_locations'] = targetLocations;
      if (description != null) data['description'] = description;
      if (companyName != null) data['company_name'] = companyName;
      if (contactInfo != null) data['contact_info'] = contactInfo;
      if (websiteUrl != null) data['website_url'] = websiteUrl;

      final response = await _apiClient.dio.put(
        ApiConfig.adById(id),
        data: data,
      );

      final updatedAd = AdModel.fromJson(response.data);
      final index = _ads.indexWhere((ad) => ad.id == id);
      if (index != -1) {
        _ads[index] = updatedAd;
        notifyListeners();
      }
      return true;
    } on DioException catch (e) {
      _errorMessage = e.response?.data['error'] ?? 'Failed to update ad';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteAd(String id) async {
    try {
      await _apiClient.dio.delete(ApiConfig.adById(id));
      _ads.removeWhere((ad) => ad.id == id);
      notifyListeners();
      return true;
    } on DioException catch (e) {
      _errorMessage = e.response?.data['error'] ?? 'Failed to delete ad';
      notifyListeners();
      return false;
    }
  }

  Future<bool> reorderAds(List<AdModel> reorderedAds) async {
    try {
      final orders = reorderedAds
          .asMap()
          .entries
          .map((entry) => {
                'id': entry.value.id,
                'order': entry.key,
              })
          .toList();

      await _apiClient.dio.post(
        ApiConfig.reorderAds,
        data: {'orders': orders},
      );

      _ads = reorderedAds;
      notifyListeners();
      return true;
    } on DioException catch (e) {
      _errorMessage = e.response?.data['error'] ?? 'Failed to reorder ads';
      notifyListeners();
      return false;
    }
  }

  Stream<List<AdModel>> getAdsStream() async* {
    while (true) {
      await loadAds();
      yield _ads;
      await Future.delayed(const Duration(seconds: 30));
    }
  }

  Future<bool> toggleAdStatus(String id, bool isEnabled) async {
    return await updateAd(id: id, isEnabled: isEnabled);
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
