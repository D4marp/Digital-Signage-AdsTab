class DeviceModel {
  final String id;
  final String deviceId;
  final String location;
  final bool isOnline;
  final DateTime lastActive;
  final int todayViews;
  final Map<String, dynamic> settings;

  DeviceModel({
    required this.id,
    required this.deviceId,
    required this.location,
    required this.isOnline,
    required this.lastActive,
    required this.todayViews,
    required this.settings,
  });

  factory DeviceModel.fromJson(Map<String, dynamic> json) {
    return DeviceModel(
      id: json['id'] ?? '',
      deviceId: json['device_id'] ?? '',
      location: json['location'] ?? 'Unknown',
      isOnline: json['is_online'] ?? false,
      lastActive: DateTime.parse(json['last_active'] ?? DateTime.now().toIso8601String()),
      todayViews: json['today_views'] ?? 0,
      settings: json['settings'] ?? {
        'slideshowInterval': 5,
        'videoAutoplay': true,
        'enabledAds': [],
      },
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'device_id': deviceId,
      'location': location,
      'is_online': isOnline,
      'last_active': lastActive.toIso8601String(),
      'today_views': todayViews,
      'settings': settings,
    };
  }


  DeviceModel copyWith({
    String? location,
    bool? isOnline,
    DateTime? lastActive,
    int? todayViews,
    Map<String, dynamic>? settings,
  }) {
    return DeviceModel(
      id: id,
      deviceId: deviceId,
      location: location ?? this.location,
      isOnline: isOnline ?? this.isOnline,
      lastActive: lastActive ?? this.lastActive,
      todayViews: todayViews ?? this.todayViews,
      settings: settings ?? this.settings,
    );
  }
}

