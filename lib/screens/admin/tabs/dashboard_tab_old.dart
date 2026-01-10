import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/analytics_provider.dart';
import '../../../models/dashboard_stats.dart';
import '../../../utils/format_helper.dart';
import '../../../utils/app_theme.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStats,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadStats,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Overview',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 24),
                    _buildStatsCards(),
                    const SizedBox(height: 32),
                    Text(
                      'Quick Actions',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    _buildQuickActions(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatsCards() {
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.8,
      children: [
        _buildStatCard(
          'Total Views',
          FormatHelper.formatNumber(_stats?.todayImpressions ?? 0),
          Icons.visibility,
          AppTheme.primaryColor,
        ),
        _buildStatCard(
          'Active Ads',
          '${_stats?.totalAds ?? 0}',
          Icons.campaign,
          AppTheme.successColor,
        ),
        _buildStatCard(
          'Total Ads',
          '${_stats?.totalAds ?? 0}',
          Icons.featured_play_list,
          AppTheme.secondaryColor,
        ),
        _buildStatCard(
          'Online Devices',
          '${_stats?.onlineDevices ?? 0}',
          Icons.tablet_android,
          AppTheme.accentColor,
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
                Icon(icon, color: color, size: 24),
              ],
            ),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        _buildActionButton(
          'Upload New Ad',
          Icons.add_circle_outline,
          AppTheme.primaryColor,
          () {
            // Navigate to ads tab by calling parent
            DefaultTabController.of(context).animateTo(1); // Index 1 = Ads tab
          },
        ),
        _buildActionButton(
          'View Analytics',
          Icons.analytics_outlined,
          AppTheme.successColor,
          () {
            // Navigate to analytics tab
            DefaultTabController.of(context).animateTo(2); // Index 2 = Analytics tab
          },
        ),
        _buildActionButton(
          'Manage Devices',
          Icons.devices_outlined,
          AppTheme.secondaryColor,
          () {
            // Navigate to devices tab
            DefaultTabController.of(context).animateTo(3); // Index 3 = Devices tab
          },
        ),
      ],
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      ),
    );
  }
}
