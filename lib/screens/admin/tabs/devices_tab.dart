import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/device_provider.dart';
import '../../../models/device_model.dart';
import '../../../utils/format_helper.dart';
import '../../../utils/app_theme.dart';

class DevicesTab extends StatefulWidget {
  const DevicesTab({super.key});

  @override
  State<DevicesTab> createState() => _DevicesTabState();
}

class _DevicesTabState extends State<DevicesTab> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Device Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<DeviceProvider>().loadDevices();
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: StreamBuilder<List<DeviceModel>>(
        stream: context.read<DeviceProvider>().getDevicesStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.devices_outlined, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No devices registered yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          final devices = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: devices.length,
            itemBuilder: (context, index) {
              return _buildDeviceCard(devices[index]);
            },
          );
        },
      ),
    );
  }

  Widget _buildDeviceCard(DeviceModel device) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: Icon(
          Icons.tablet_android,
          size: 40,
          color: device.isOnline ? AppTheme.successColor : Colors.grey,
        ),
        title: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    device.location,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Device ID: ${device.deviceId.substring(0, 12)}...',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: device.isOnline ? AppTheme.successColor : Colors.grey,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                device.isOnline ? 'Online' : 'Offline',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            children: [
              const Icon(Icons.access_time, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                'Last active: ${FormatHelper.timeAgo(device.lastActive)}',
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.visibility, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                'Today: ${device.todayViews} views',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),
                const SizedBox(height: 8),
                Text(
                  'Device Settings',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                _buildSettingRow(
                  'Slideshow Interval',
                  '${device.settings['slideshowInterval'] ?? 5}s',
                ),
                _buildSettingRow(
                  'Video Autoplay',
                  device.settings['videoAutoplay'] == true ? 'Enabled' : 'Disabled',
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => _showSettingsDialog(device),
                      icon: const Icon(Icons.settings),
                      label: const Text('Configure'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () => _restartDevice(device),
                      icon: const Icon(Icons.restart_alt),
                      label: const Text('Restart'),
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

  Widget _buildSettingRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showSettingsDialog(DeviceModel device) async {
    int slideshowInterval = device.settings['slideshowInterval'] ?? 5;
    bool videoAutoplay = device.settings['videoAutoplay'] ?? true;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Configure ${device.location}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Text('Slideshow Interval:'),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Slider(
                      value: slideshowInterval.toDouble(),
                      min: 3,
                      max: 30,
                      divisions: 27,
                      label: '${slideshowInterval}s',
                      onChanged: (value) {
                        setState(() {
                          slideshowInterval = value.toInt();
                        });
                      },
                    ),
                  ),
                  Text('${slideshowInterval}s'),
                ],
              ),
              SwitchListTile(
                title: const Text('Video Autoplay'),
                value: videoAutoplay,
                onChanged: (value) {
                  setState(() {
                    videoAutoplay = value;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop({
                  'slideshowInterval': slideshowInterval,
                  'videoAutoplay': videoAutoplay,
                  'enabledAds': device.settings['enabledAds'] ?? [],
                });
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );

    if (result != null && mounted) {
      final deviceProvider = context.read<DeviceProvider>();
      await deviceProvider.updateDeviceSettings(device.deviceId, result);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Settings updated successfully')),
        );
      }
    }
  }

  Future<void> _restartDevice(DeviceModel device) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restart Device'),
        content: Text('Are you sure you want to restart ${device.location}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Restart'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      // In a real implementation, you would send a restart command through Firebase
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Restart command sent')),
      );
    }
  }
}
