class ImpressionModel {
  final String id;
  final String adId;
  final String deviceId;
  final DateTime viewedAt;

  ImpressionModel({
    required this.id,
    required this.adId,
    required this.deviceId,
    required this.viewedAt,
  });

  factory ImpressionModel.fromJson(Map<String, dynamic> json) {
    return ImpressionModel(
      id: json['id'] ?? '',
      adId: json['ad_id'] ?? '',
      deviceId: json['device_id'] ?? '',
      viewedAt: DateTime.parse(json['viewed_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ad_id': adId,
      'device_id': deviceId,
    };
  }
}

class AdAnalytics {
  final String id;
  final String adId;
  final String date;
  final int impressions;
  final int uniqueDevices;
  final DateTime createdAt;
  final DateTime updatedAt;

  AdAnalytics({
    required this.id,
    required this.adId,
    required this.date,
    required this.impressions,
    required this.uniqueDevices,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AdAnalytics.fromJson(Map<String, dynamic> json) {
    return AdAnalytics(
      id: json['id'] ?? '',
      adId: json['ad_id'] ?? '',
      date: json['date'] ?? '',
      impressions: json['impressions'] ?? 0,
      uniqueDevices: json['unique_devices'] ?? 0,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  factory AdAnalytics.empty(String adId) {
    return AdAnalytics(
      id: '',
      adId: adId,
      date: DateTime.now().toIso8601String().split('T')[0],
      impressions: 0,
      uniqueDevices: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}
