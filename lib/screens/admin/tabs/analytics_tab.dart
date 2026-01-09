import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/analytics_provider.dart';
import '../../../providers/ad_provider.dart';
import '../../../models/ad_model.dart';
import '../../../models/impression_model.dart';

class AnalyticsTab extends StatefulWidget {
  const AnalyticsTab({super.key});

  @override
  State<AnalyticsTab> createState() => _AnalyticsTabState();
}

class _AnalyticsTabState extends State<AnalyticsTab> {
  String? _selectedAdId;
  List<AdAnalytics> _analytics = [];
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAnalytics,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _analytics.isEmpty
                    ? _buildEmptyState()
                    : _buildAnalyticsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: StreamBuilder<List<AdModel>>(
        stream: context.read<AdProvider>().getAdsStream(),
        builder: (context, snapshot) {
          final ads = snapshot.data ?? [];
          
          return Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedAdId,
                  decoration: const InputDecoration(
                    labelText: 'Select Ad',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('All Ads'),
                    ),
                    ...ads.map((ad) => DropdownMenuItem(
                          value: ad.id,
                          child: Text(ad.title),
                        )),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedAdId = value);
                    _loadAnalytics();
                  },
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.filter_list),
                label: const Text('Load Analytics'),
                onPressed: _loadAnalytics,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.analytics_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No analytics data yet',
            style: TextStyle(fontSize: 20, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Select an ad and click Load Analytics',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsList() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSummaryCard(),
        const SizedBox(height: 16),
        _buildAnalyticsTable(),
      ],
    );
  }

  Widget _buildSummaryCard() {
    final totalImpressions = _analytics.fold<int>(
      0,
      (sum, item) => sum + item.impressions,
    );
    final totalUniqueDevices = _analytics.fold<int>(
      0,
      (sum, item) => sum + item.uniqueDevices,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Summary',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildStatBox(
                    'Total Impressions',
                    totalImpressions.toString(),
                    Icons.visibility,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatBox(
                    'Unique Devices',
                    totalUniqueDevices.toString(),
                    Icons.devices,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatBox(
                    'Days Tracked',
                    _analytics.length.toString(),
                    Icons.calendar_today,
                    Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBox(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsTable() {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              'Daily Analytics',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Date')),
                DataColumn(label: Text('Impressions'), numeric: true),
                DataColumn(label: Text('Unique Devices'), numeric: true),
              ],
              rows: _analytics.map((analytics) {
                return DataRow(cells: [
                  DataCell(Text(analytics.date)),
                  DataCell(Text(analytics.impressions.toString())),
                  DataCell(Text(analytics.uniqueDevices.toString())),
                ]);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _loadAnalytics() async {
    if (_selectedAdId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an ad')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final analyticsProvider = context.read<AnalyticsProvider>();
      final analytics = await analyticsProvider.getAdAnalytics(
        _selectedAdId!,
        startDate: DateTime.now().subtract(const Duration(days: 30)),
        endDate: DateTime.now(),
      );

      if (mounted) {
        setState(() {
          _analytics = analytics;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading analytics: $e')),
        );
      }
    }
  }
}
