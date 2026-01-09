class AdAnalyticsSummary {
  final String adId;
  final int totalViews;
  final int totalDurationSeconds;
  final double averageDurationSeconds;
  final int completionCount;
  final double completionRate;
  final Map<String, int> viewsByDevice;
  final Map<String, int> viewsByLocation;

  AdAnalyticsSummary({
    required this.adId,
    required this.totalViews,
    required this.totalDurationSeconds,
    required this.averageDurationSeconds,
    required this.completionCount,
    required this.completionRate,
    required this.viewsByDevice,
    required this.viewsByLocation,
  });

  factory AdAnalyticsSummary.empty(String adId) {
    return AdAnalyticsSummary(
      adId: adId,
      totalViews: 0,
      totalDurationSeconds: 0,
      averageDurationSeconds: 0,
      completionCount: 0,
      completionRate: 0,
      viewsByDevice: {},
      viewsByLocation: {},
    );
  }
}
