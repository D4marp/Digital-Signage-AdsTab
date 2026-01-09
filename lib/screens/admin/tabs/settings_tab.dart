import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';

class SettingsTab extends StatefulWidget {
  const SettingsTab({super.key});

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.userModel;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Profile Section
          Text(
            'Profile',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: CircleAvatar(
                child: Text(
                  user?.displayName.substring(0, 1).toUpperCase() ?? 'U',
                ),
              ),
              title: Text(user?.displayName ?? 'User'),
              subtitle: Text(user?.email ?? ''),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  // TODO: Edit profile
                },
              ),
            ),
          ),
          const SizedBox(height: 32),

          // General Settings
          Text(
            'General Settings',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.timer),
                  title: const Text('Default Slideshow Interval'),
                  subtitle: const Text('5 seconds'),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      // TODO: Edit interval
                    },
                  ),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(Icons.play_circle),
                  title: const Text('Video Autoplay'),
                  subtitle: const Text('Automatically play videos'),
                  value: true,
                  onChanged: (value) {
                    // TODO: Update setting
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.storage),
                  title: const Text('Max Cache Size'),
                  subtitle: const Text('500 MB'),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      // TODO: Edit cache size
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // User Management (for super admin)
          if (user?.role == 'superadmin') ...[
            Text(
              'User Management',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.person_add),
                    title: const Text('Add Admin User'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // TODO: Add admin
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.people),
                    title: const Text('Manage Users'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // TODO: Manage users
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],

          // About
          Text(
            'About',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                const ListTile(
                  leading: Icon(Icons.info),
                  title: Text('Version'),
                  subtitle: Text('1.0.0'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.description),
                  title: const Text('Terms & Conditions'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // TODO: Show terms
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.privacy_tip),
                  title: const Text('Privacy Policy'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // TODO: Show privacy policy
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Danger Zone
          Text(
            'Danger Zone',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: const Text('Clear All Data'),
              subtitle: const Text('Delete all ads and analytics'),
              trailing: const Icon(Icons.chevron_right, color: Colors.red),
              onTap: () => _confirmClearData(),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmClearData() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'This will permanently delete all ads, analytics, and device data. '
          'This action cannot be undone.\n\n'
          'Are you sure you want to continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('DELETE ALL'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      // TODO: Implement data clearing
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data clearing not implemented yet'),
        ),
      );
    }
  }
}
