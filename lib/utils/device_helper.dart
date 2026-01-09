import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

class DeviceHelper {
  static Future<String> getDeviceId() async {
    final deviceInfo = DeviceInfoPlugin();
    
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      return androidInfo.id; // Android ID
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      return iosInfo.identifierForVendor ?? 'unknown';
    } else {
      return 'web-device';
    }
  }

  static Future<Map<String, String>> getDeviceInfo() async {
    final deviceInfo = DeviceInfoPlugin();
    
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      return {
        'id': androidInfo.id,
        'model': androidInfo.model,
        'manufacturer': androidInfo.manufacturer,
        'version': androidInfo.version.release,
      };
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      return {
        'id': iosInfo.identifierForVendor ?? 'unknown',
        'model': iosInfo.model,
        'manufacturer': 'Apple',
        'version': iosInfo.systemVersion,
      };
    } else {
      return {
        'id': 'web-device',
        'model': 'Web Browser',
        'manufacturer': 'Unknown',
        'version': 'Unknown',
      };
    }
  }
}
