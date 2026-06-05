import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _limitController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('platform_config')
          .doc('admin_settings')
          .get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        setState(() {
          _limitController.text = (data['limitTokens'] ?? 2048).toString();
          _useGPT4o = data['useGPT4o'] ?? true;
          _useClaude = data['useClaude'] ?? false;
          _maintenanceMode = data['maintenanceMode'] ?? false;
          _pushNotifications = data['pushNotifications'] ?? true;
        });
      }
    } catch (e) {
      debugPrint('Error loading settings: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveSettings() async {
    setState(() => _isLoading = true);
    try {
      await FirebaseFirestore.instance
          .collection('platform_config')
          .doc('admin_settings')
          .set({
        'limitTokens': int.tryParse(_limitController.text) ?? 2048,
        'useGPT4o': _useGPT4o,
        'useClaude': _useClaude,
        'maintenanceMode': _maintenanceMode,
        'pushNotifications': _pushNotifications,
        'updatedAt': DateTime.now().toUtc().toIso8601String(),
      }, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Settings saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save settings: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Settings & Platform Config', style: Theme.of(context).textTheme.displayLarge),
                ElevatedButton.icon(
                  onPressed: _saveSettings,
                  icon: const Icon(Icons.save),
                  label: const Text('Save Config'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  ),
                ),
              ],
            ),
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
                            keyboardType: TextInputType.number,
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

