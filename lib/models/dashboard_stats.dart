class DashboardStats {
  final int todayImpressions;
  final int totalImpressions;
  final int activeDevices;
  final int totalAds;
  final List<TopAd> topAds;

  DashboardStats({
    required this.todayImpressions,
    required this.totalImpressions,
    required this.activeDevices,
    required this.totalAds,
    required this.topAds,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      todayImpressions: json['today_impressions'] ?? 0,
      totalImpressions: json['total_impressions'] ?? 0,
      activeDevices: json['active_devices'] ?? 0,
      totalAds: json['total_ads'] ?? 0,
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
