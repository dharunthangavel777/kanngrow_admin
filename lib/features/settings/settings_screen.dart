import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/admin_auth_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _limitController = TextEditingController(text: '2048');
  bool _useGPT4o = true;
  bool _useClaude = false;
  bool _maintenanceMode = false;
  bool _pushNotifications = true;

  @override
  void dispose() {
    _limitController.dispose();
    super.dispose();
  }

  void _clearCache() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Redis cache cleared successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _logout() {
    context.read<AdminAuthProvider>().logout();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Settings & Platform Config', style: Theme.of(context).textTheme.displayLarge),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('AI Model Settings', style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 16),
                          SwitchListTile(
                            title: const Text('Use OpenAI GPT-4o (Default)'),
                            subtitle: const Text('Primary engine for Ideas & Validation'),
                            value: _useGPT4o,
                            onChanged: (val) {
                              setState(() {
                                _useGPT4o = val;
                                if (val) _useClaude = false;
                              });
                            },
                          ),
                          SwitchListTile(
                            title: const Text('Use Claude 3.5 Sonnet'),
                            subtitle: const Text('Fallback engine'),
                            value: _useClaude,
                            onChanged: (val) {
                              setState(() {
                                _useClaude = val;
                                if (val) _useGPT4o = false;
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _limitController,
                            decoration: const InputDecoration(
                              labelText: 'OpenAI Max Tokens Limit',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('App Settings & Maintenance', style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 16),
                          SwitchListTile(
                            title: const Text('Maintenance Mode'),
                            subtitle: const Text('Disable app access for all users'),
                            value: _maintenanceMode,
                            onChanged: (val) {
                              setState(() => _maintenanceMode = val);
                            },
                          ),
                          SwitchListTile(
                            title: const Text('Enable Push Notifications'),
                            value: _pushNotifications,
                            onChanged: (val) {
                              setState(() => _pushNotifications = val);
                            },
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _clearCache,
                            icon: const Icon(Icons.clear_all),
                            label: const Text('Clear Redis Cache'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Account Options
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Account Options', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _logout,
                      icon: const Icon(Icons.logout),
                      label: const Text('Log Out'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).cardColor,
                        foregroundColor: Theme.of(context).colorScheme.error,
                        side: BorderSide(color: Theme.of(context).colorScheme.error),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
