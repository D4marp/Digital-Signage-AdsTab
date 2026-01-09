import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../models/device_model.dart';
import '../services/api_client.dart';
import '../config/api_config.dart';

class DeviceProvider extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();

  List<DeviceModel> _devices = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<DeviceModel> get devices => _devices;
  List<DeviceModel> get onlineDevices =>
      _devices.where((device) => device.isOnline).toList();
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadDevices() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiClient.dio.get(ApiConfig.devices);
      _devices = (response.data as List)
          .map((json) => DeviceModel.fromJson(json))
          .toList();
      _isLoading = false;
      notifyListeners();
    } on DioException catch (e) {
      _errorMessage = 'Failed to load devices: ${e.message}';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<DeviceModel?> registerDevice(String deviceId, String location) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConfig.registerDevice,
        data: {
          'device_id': deviceId,
          'location': location,
        },
      );

      final device = DeviceModel.fromJson(response.data);
      final index = _devices.indexWhere((d) => d.deviceId == deviceId);
      if (index != -1) {
        _devices[index] = device;
      } else {
        _devices.add(device);
      }
      notifyListeners();
      return device;
    } on DioException catch (e) {
      _errorMessage = e.response?.data['error'] ?? 'Failed to register device';
      notifyListeners();
      return null;
    }
  }

  Future<bool> updateDevice({
    required String id,
    String? location,
    bool? isOnline,
    int? todayViews,
    Map<String, dynamic>? settings,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (location != null) data['location'] = location;
      if (isOnline != null) data['is_online'] = isOnline;
      if (todayViews != null) data['today_views'] = todayViews;
      if (settings != null) data['settings'] = settings;

      final response = await _apiClient.dio.put(
        ApiConfig.deviceById(id),
        data: data,
      );

      final updatedDevice = DeviceModel.fromJson(response.data);
      final index = _devices.indexWhere((device) => device.id == id);
      if (index != -1) {
        _devices[index] = updatedDevice;
        notifyListeners();
      }
      return true;
    } on DioException catch (e) {
      _errorMessage = e.response?.data['error'] ?? 'Failed to update device';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteDevice(String id) async {
    try {
      await _apiClient.dio.delete(ApiConfig.deviceById(id));
      _devices.removeWhere((device) => device.id == id);
      notifyListeners();
      return true;
    } on DioException catch (e) {
      _errorMessage = e.response?.data['error'] ?? 'Failed to delete device';
      notifyListeners();
      return false;
    }
  }

  Future<void> sendHeartbeat(String deviceId) async {
    try {
      await _apiClient.dio.post(ApiConfig.heartbeat(deviceId));
    } catch (e) {
      debugPrint('Failed to send heartbeat: $e');
    }
  }

  Future<void> incrementViews(String deviceId) async {
    try {
      await _apiClient.dio.post(ApiConfig.incrementViews(deviceId));
    } catch (e) {
      debugPrint('Failed to increment views: $e');
    }
  }

  Stream<List<DeviceModel>> getDevicesStream() async* {
    while (true) {
      await loadDevices();
      yield _devices;
      await Future.delayed(const Duration(seconds: 30));
    }
  }

  Future<bool> updateDeviceStatus(String deviceId, bool isOnline) async {
    final device = _devices.firstWhere(
      (d) => d.deviceId == deviceId,
      orElse: () => DeviceModel(
        id: '',
        deviceId: deviceId,
        location: '',
        isOnline: false,
        lastActive: DateTime.now(),
        todayViews: 0,
        settings: {},
      ),
    );
    
    if (device.id.isEmpty) return false;
    
    return await updateDevice(id: device.id, isOnline: isOnline);
  }

  Future<bool> updateDeviceSettings(String deviceId, Map<String, dynamic> settings) async {
    final device = _devices.firstWhere(
      (d) => d.deviceId == deviceId,
      orElse: () => DeviceModel(
        id: '',
        deviceId: deviceId,
        location: '',
        isOnline: false,
        lastActive: DateTime.now(),
        todayViews: 0,
        settings: {},
      ),
    );
    
    if (device.id.isEmpty) return false;
    
    return await updateDevice(id: device.id, settings: settings);
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
