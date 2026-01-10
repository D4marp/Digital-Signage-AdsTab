import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../providers/analytics_provider.dart';
import '../../../models/dashboard_stats.dart';
import '../../../utils/format_helper.dart';

class DashboardTab extends StatefulWidget {
  const DashboardTab({super.key});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  DashboardStats? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);

    final analyticsProvider = context.read<AnalyticsProvider>();
    final stats = await analyticsProvider.getOverallStats();

    if (mounted) {
      setState(() {
        _stats = stats;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final isMobile = MediaQuery.of(context).size.width < 768;
    final isTablet = MediaQuery.of(context).size.width >= 768 && MediaQuery.of(context).size.width < 1024;

    return RefreshIndicator(
      onRefresh: _loadStats,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Header
            _buildWelcomeHeader(isMobile),
            SizedBox(height: isMobile ? 20 : 32),
            
            // Stats Overview Cards
            _buildStatsOverview(isMobile, isTablet),
            SizedBox(height: isMobile ? 20 : 32),
            
            // Charts and Top Ads
            isMobile
                ? Column(
                    children: [
                      _buildPerformanceChart(isMobile),
                      SizedBox(height: isMobile ? 20 : 32),
                      _buildTopAds(isMobile),
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: _buildPerformanceChart(isMobile),
                      ),
                      SizedBox(width: isMobile ? 16 : 24),
                      Expanded(
                        child: _buildTopAds(isMobile),
                      ),
                    ],
                  ),
            SizedBox(height: isMobile ? 20 : 32),
            
            // Quick Actions
            _buildQuickActions(isMobile),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader(bool isMobile) {
    final hour = DateTime.now().hour;
    String greeting = 'Good Morning';
    IconData icon = Icons.wb_sunny;
    Color iconColor = Colors.orange;

    if (hour >= 12 && hour < 17) {
      greeting = 'Good Afternoon';
      icon = Icons.wb_sunny;
      iconColor = Colors.orange.shade700;
    } else if (hour >= 17) {
      greeting = 'Good Evening';
      icon = Icons.nightlight_round;
      iconColor = Colors.indigo;
    }

    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade600, Colors.blue.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade200,
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(icon, color: iconColor, size: 40),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.dashboard, color: Colors.white, size: 24),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  greeting,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Welcome to Digital Signage Dashboard',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            )
          : Row(
              children: [
                Icon(icon, color: iconColor, size: 48),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        greeting,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Welcome to Digital Signage Dashboard',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.dashboard, color: Colors.white, size: 32),
                ),
              ],
            ),
    );
  }

  Widget _buildStatsOverview(bool isMobile, bool isTablet) {
    int crossCount = 4;
    double aspectRatio = 1.5;
    
    if (isMobile) {
      crossCount = 2;
      aspectRatio = 1.2;
    } else if (isTablet) {
      crossCount = 3;
      aspectRatio = 1.3;
    }

    return GridView.count(
      crossAxisCount: crossCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: isMobile ? 12 : 16,
      crossAxisSpacing: isMobile ? 12 : 16,
      childAspectRatio: aspectRatio,
      children: [
        _buildStatCard(
          'Today\'s Views',
          FormatHelper.formatNumber(_stats?.todayImpressions ?? 0),
          Icons.remove_red_eye,
          Colors.blue,
          Colors.blue.shade50,
          '+12%',
          isMobile,
        ),
        _buildStatCard(
          'Total Impressions (30d)',
          FormatHelper.formatNumber(_stats?.totalImpressions30d ?? 0),
          Icons.visibility,
          Colors.green,
          Colors.green.shade50,
          '+8%',
          isMobile,
        ),
        _buildStatCard(
          'Active Ads',
          '${_stats?.activeAds ?? 0}',
          Icons.campaign,
          Colors.orange,
          Colors.orange.shade50,
          '${_stats?.activeAds ?? 0} live',
          isMobile,
        ),
        _buildStatCard(
          'Online Devices',
          '${_stats?.onlineDevices ?? 0}',
          Icons.devices,
          Colors.purple,
          Colors.purple.shade50,
          'Connected',
          isMobile,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    Color bgColor,
    String badge,
    bool isMobile,
  ) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: isMobile ? 18 : 24),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    color: color,
                    fontSize: isMobile ? 9 : 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: isMobile ? 18 : 28,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                title,
                style: TextStyle(
                  fontSize: isMobile ? 10 : 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceChart(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Performance Overview',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildLegendItem('Impressions', Colors.blue),
                          const SizedBox(width: 20),
                          _buildLegendItem('Devices', Colors.orange),
                        ],
                      ),
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Performance Overview',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        _buildLegendItem('Impressions', Colors.blue),
                        const SizedBox(width: 16),
                        _buildLegendItem('Devices', Colors.orange),
                      ],
                    ),
                  ],
                ),
          const SizedBox(height: 20),
          SizedBox(
            height: isMobile ? 200 : 250,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 20,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.shade200,
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: !isMobile,
                      reservedSize: isMobile ? 30 : 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: isMobile ? 10 : 12,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                        if (value.toInt() < days.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              days[value.toInt()],
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: isMobile ? 10 : 12,
                              ),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  // Impressions line
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 30),
                      FlSpot(1, 45),
                      FlSpot(2, 38),
                      FlSpot(3, 60),
                      FlSpot(4, 52),
                      FlSpot(5, 75),
                      FlSpot(6, 68),
                    ],
                    isCurved: true,
                    color: Colors.blue,
                    barWidth: isMobile ? 2 : 3,
                    dotData: FlDotData(
                      show: !isMobile,
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.blue.withOpacity(0.1),
                    ),
                  ),
                  // Devices line
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 20),
                      FlSpot(1, 25),
                      FlSpot(2, 22),
                      FlSpot(3, 35),
                      FlSpot(4, 30),
                      FlSpot(5, 40),
                      FlSpot(6, 38),
                    ],
                    isCurved: true,
                    color: Colors.orange,
                    barWidth: isMobile ? 2 : 3,
                    dotData: FlDotData(
                      show: !isMobile,
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.orange.withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildTopAds(bool isMobile) {
    final topAds = _stats?.topAds ?? [];

    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.star, color: Colors.amber.shade700, size: isMobile ? 18 : 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Top Performing Ads',
                  style: TextStyle(
                    fontSize: isMobile ? 14 : 18,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (topAds.isEmpty)
            SizedBox(
              height: isMobile ? 120 : 200,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.campaign_outlined, size: isMobile ? 48 : 64, color: Colors.grey.shade300),
                    const SizedBox(height: 12),
                    Text(
                      'No ads yet',
                      style: TextStyle(color: Colors.grey.shade500, fontSize: isMobile ? 12 : 14),
                    ),
                  ],
                ),
              ),
            )
          else
            SingleChildScrollView(
              child: Column(
                children: topAds.asMap().entries.map((entry) {
                  final index = entry.key;
                  final ad = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildTopAdItem(index + 1, ad.title, ad.impressions, isMobile),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTopAdItem(int rank, String title, int impressions, bool isMobile) {
    Color rankColor;
    if (rank == 1) {
      rankColor = Colors.amber.shade700;
    } else if (rank == 2) {
      rankColor = Colors.grey.shade500;
    } else if (rank == 3) {
      rankColor = Colors.orange.shade700;
    } else {
      rankColor = Colors.grey.shade400;
    }

    return Container(
      padding: EdgeInsets.all(isMobile ? 10 : 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: isMobile ? 28 : 32,
            height: isMobile ? 28 : 32,
            decoration: BoxDecoration(
              color: rankColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '#$rank',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: isMobile ? 10 : 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: isMobile ? 12 : 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.visibility, size: 10, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      '${FormatHelper.formatNumber(impressions)} views',
                      style: TextStyle(
                        fontSize: isMobile ? 10 : 12,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo.shade50, Colors.blue.shade50],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.flash_on, color: Colors.amber.shade700, size: isMobile ? 18 : 20),
              ),
              const SizedBox(width: 12),
              Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: isMobile ? 14 : 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          isMobile
              ? Column(
                  children: [
                    _buildActionCard(
                      'Upload New Ad',
                      'Create and publish',
                      Icons.add_photo_alternate,
                      Colors.blue,
                      () {
                        final controller = DefaultTabController.of(context);
                        controller.animateTo(1);
                      },
                      isMobile,
                    ),
                    const SizedBox(height: 12),
                    _buildActionCard(
                      'View Analytics',
                      'Track performance',
                      Icons.bar_chart,
                      Colors.green,
                      () {
                        final controller = DefaultTabController.of(context);
                        controller.animateTo(2);
                      },
                      isMobile,
                    ),
                    const SizedBox(height: 12),
                    _buildActionCard(
                      'Manage Devices',
                      'Monitor screens',
                      Icons.devices,
                      Colors.orange,
                      () {
                        final controller = DefaultTabController.of(context);
                        controller.animateTo(3);
                      },
                      isMobile,
                    ),
                  ],
                )
              : Row(
                  children: [
                    Expanded(
                      child: _buildActionCard(
                        'Upload New Ad',
                        'Create and publish',
                        Icons.add_photo_alternate,
                        Colors.blue,
                        () {
                          final controller = DefaultTabController.of(context);
                          controller.animateTo(1);
                        },
                        isMobile,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildActionCard(
                        'View Analytics',
                        'Track performance',
                        Icons.bar_chart,
                        Colors.green,
                        () {
                          final controller = DefaultTabController.of(context);
                          controller.animateTo(2);
                        },
                        isMobile,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildActionCard(
                        'Manage Devices',
                        'Monitor screens',
                        Icons.devices,
                        Colors.orange,
                        () {
                          final controller = DefaultTabController.of(context);
                          controller.animateTo(3);
                        },
                        isMobile,
                      ),
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
    bool isMobile,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(isMobile ? 16 : 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(isMobile ? 12 : 16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: isMobile ? 24 : 32),
            ),
            SizedBox(height: isMobile ? 10 : 12),
            Text(
              title,
              style: TextStyle(
                fontSize: isMobile ? 12 : 14,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: isMobile ? 2 : 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: isMobile ? 10 : 11,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
