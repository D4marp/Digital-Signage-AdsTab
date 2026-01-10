class DashboardStats {
  final int activeAds;
  final int onlineDevices;
  final int todayImpressions;
  final int totalAds;
  final int totalDevices;
  final int totalImpressions30d;
  final List<TopAd> topAds;

  DashboardStats({
    required this.activeAds,
    required this.onlineDevices,
    required this.todayImpressions,
    required this.totalAds,
    required this.totalDevices,
    required this.totalImpressions30d,
    required this.topAds,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      activeAds: json['active_ads'] ?? 0,
      onlineDevices: json['online_devices'] ?? 0,
      todayImpressions: json['today_impressions'] ?? 0,
      totalAds: json['total_ads'] ?? 0,
      totalDevices: json['total_devices'] ?? 0,
      totalImpressions30d: json['total_impressions_30d'] ?? 0,
      topAds: (json['top_ads'] as List? ?? [])
          .map((item) => TopAd.fromJson(item))
          .toList(),
    );
  }
}

class TopAd {
  final String adId;
  final String title;
  final int impressions;

  TopAd({
    required this.adId,
    required this.title,
    required this.impressions,
  });

  factory TopAd.fromJson(Map<String, dynamic> json) {
    return TopAd(
      adId: json['ad_id'] ?? '',
      title: json['title'] ?? '',
      impressions: json['impressions'] ?? 0,
    );
  }
}

class AdPerformance {
  final String date;
  final int impressions;
  final int uniqueDevices;

  AdPerformance({
    required this.date,
    required this.impressions,
    required this.uniqueDevices,
  });

  factory AdPerformance.fromJson(Map<String, dynamic> json) {
    return AdPerformance(
      date: json['date'] ?? '',
      impressions: json['impressions'] ?? 0,
      uniqueDevices: json['unique_devices'] ?? 0,
    );
  }
}
