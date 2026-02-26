import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'dart:io' as io;
import 'dart:async';
import '../models/ad_model.dart';
import '../services/api_client.dart';
import '../services/upload_service.dart';
import '../config/api_config.dart';

class AdProvider extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  late StreamController<List<AdModel>> _adsStreamController;

  List<AdModel> _ads = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<AdModel> get ads => _ads;
  List<AdModel> get activeAds => _ads.where((ad) => ad.isEnabled).toList();
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AdProvider() {
    _adsStreamController = StreamController<List<AdModel>>.broadcast();
    loadAds();
  }

  @override
  void dispose() {
    _adsStreamController.close();
    super.dispose();
  }

  Future<void> loadAds() async {
    // Skip if already loading or already have data
    if (_isLoading || _ads.isNotEmpty) {
      debugPrint('⏭️  [AdProvider] Skipping load - already have ${_ads.length} ads');
      return;
    }
    
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiClient.dio.get(ApiConfig.ads);
      _ads = (response.data as List)
          .map((json) => AdModel.fromJson(json))
          .toList();
      
      debugPrint('📥 [AdProvider] Loaded ${_ads.length} ads');
      for (var ad in _ads) {
        if (ad.galleryImages.isNotEmpty) {
          debugPrint('  ✅ Ad ${ad.id}: ${ad.galleryImages.length} gallery images');
        } else {
          debugPrint('  ⚠️  Ad ${ad.id}: No gallery images');
        }
      }
      
      _isLoading = false;
      // Emit data ke stream
      if (!_adsStreamController.isClosed) {
        _adsStreamController.add(_ads);
      }
      
      notifyListeners();
    } on DioException catch (e) {
      _errorMessage = 'Failed to load ads: ${e.message}';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshAds() async {
    // Force refresh by clearing cache
    _ads.clear();
    await loadAds();
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

  Future<String> uploadMedia(io.File? file, String fileName, {List<int>? fileBytes}) async {
    try {
      // Use UploadService with retry logic and validation
      final uploadService = UploadService();
      
      // Validate file before upload
      final isValid = uploadService.validateFile(fileName);
      if (!isValid) {
        throw Exception('Invalid file format or size. Supported: jpg, png, gif, webp (max 100MB)');
      }
      
      // Upload with retry logic
      final uploadedUrl = await uploadService.uploadFile(
        fileName,
        file: file,
        fileBytes: fileBytes,
      );
      
      debugPrint('Upload successful with UploadService: $uploadedUrl');
      return uploadedUrl;
    } catch (e) {
      debugPrint('Upload media error: $e');
      throw Exception('Failed to upload media: $e');
    }
  }

  Future<bool> createAd({
    required String title,
    required String mediaUrl,
    required String mediaType,
    required int durationSeconds,
    required List<String> targetLocations,
    List<String>? galleryImages,
    List<String>? aboutImages,
  }) async {
    try {
      final data = {
        'title': title,
        'media_url': mediaUrl,
        'media_type': mediaType,
        'duration_seconds': durationSeconds,
        'target_locations': targetLocations,
      };
      
      if (galleryImages != null) data['gallery_images'] = galleryImages;
      if (aboutImages != null) data['about_images'] = aboutImages;
      
      final response = await _apiClient.dio.post(
        ApiConfig.ads,
        data: data,
      );

      final newAd = AdModel.fromJson(response.data);
      debugPrint('📝 [AdProvider] Created ad: ${newAd.id}');
      debugPrint('📸 [AdProvider] Gallery images in response: ${newAd.galleryImages.length}');
      debugPrint('🎨 [AdProvider] About images in response: ${newAd.aboutImages.length}');
      _ads.add(newAd);
      
      // Emit ke stream
      if (!_adsStreamController.isClosed) {
        _adsStreamController.add(_ads);
      }
      
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
    List<String>? galleryImages,
    List<String>? aboutImages,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (title != null) data['title'] = title;
      if (mediaUrl != null) data['media_url'] = mediaUrl;
      if (mediaType != null) data['media_type'] = mediaType;
      if (durationSeconds != null) data['duration_seconds'] = durationSeconds;
      if (isEnabled != null) data['is_enabled'] = isEnabled;
      if (targetLocations != null) data['target_locations'] = targetLocations;
      if (galleryImages != null) data['gallery_images'] = galleryImages;
      if (aboutImages != null) data['about_images'] = aboutImages;

      final response = await _apiClient.dio.put(
        ApiConfig.adById(id),
        data: data,
      );

      final updatedAd = AdModel.fromJson(response.data);
      final index = _ads.indexWhere((ad) => ad.id == id);
      if (index != -1) {
        _ads[index] = updatedAd;
        
        // Emit ke stream
        if (!_adsStreamController.isClosed) {
          _adsStreamController.add(_ads);
        }
        
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
      
      // Emit ke stream
      if (!_adsStreamController.isClosed) {
        _adsStreamController.add(_ads);
      }
      
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
      
      // Emit ke stream
      if (!_adsStreamController.isClosed) {
        _adsStreamController.add(_ads);
      }
      
      notifyListeners();
      return true;
    } on DioException catch (e) {
      _errorMessage = e.response?.data['error'] ?? 'Failed to reorder ads';
      notifyListeners();
      return false;
    }
  }

  Stream<List<AdModel>> getAdsStream() {
    // Emit data awal jika sudah ada
    if (_ads.isNotEmpty && !_adsStreamController.isClosed) {
      _adsStreamController.add(_ads);
    }
    return _adsStreamController.stream;
  }

  Future<bool> toggleAdStatus(String id, bool isEnabled) async {
    return await updateAd(id: id, isEnabled: isEnabled);
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // NEW: Track ad view
  Future<bool> trackAdView(String adId) async {
    try {
      await _apiClient.dio.post(
        '${ApiConfig.ads}/$adId/view',
      );
      
      // Update local ad's total views
      final index = _ads.indexWhere((ad) => ad.id == adId);
      if (index != -1) {
        final ad = _ads[index];
        _ads[index] = ad.copyWith(totalViews: ad.totalViews + 1);
        
        if (!_adsStreamController.isClosed) {
          _adsStreamController.add(_ads);
        }
        notifyListeners();
      }
      
      return true;
    } on DioException catch (e) {
      // Silent fail for view tracking - app should continue working
      if (kDebugMode) {
        debugPrint('⚠️ View tracking failed (non-critical): ${e.response?.statusCode} ${e.message}');
      }
      
      // Still update local counter even if API fails
      final index = _ads.indexWhere((ad) => ad.id == adId);
      if (index != -1) {
        final ad = _ads[index];
        _ads[index] = ad.copyWith(totalViews: ad.totalViews + 1);
        
        if (!_adsStreamController.isClosed) {
          _adsStreamController.add(_ads);
        }
        notifyListeners();
      }
      
      return false;
    }
  }

  // NEW: Check company upload limit
  // Returns: {company, current_ads, max_ads, can_upload, remaining_quota}
  Future<Map<String, dynamic>?> checkCompanyUploadLimit(String companyName) async {
    try {
      final response = await _apiClient.dio.get(
        ApiConfig.checkCompanyUploadLimit(companyName),
      );
      
      return response.data as Map<String, dynamic>?;
    } on DioException catch (e) {
      debugPrint('Error checking upload limit: $e');
      return null;
    }
  }

  // NEW: Get ads by company with analytics
  // Returns: {company, ads_count, total_views, ads[]}
  Future<Map<String, dynamic>?> getAdsByCompany(String companyName) async {
    try {
      final response = await _apiClient.dio.get(
        ApiConfig.getAdsByCompany(companyName),
      );
      
      return response.data as Map<String, dynamic>?;
    } on DioException catch (e) {
      debugPrint('Error getting company ads: $e');
      return null;
    }
  }
}
