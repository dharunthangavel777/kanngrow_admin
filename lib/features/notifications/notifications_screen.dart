import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();
  bool _isSending = false;

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  void _sendBroadcast() async {
    if (_titleController.text.trim().isEmpty || _bodyController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both title and body.')),
      );
      return;
    }

    setState(() => _isSending = true);

    // Mock API call
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() {
        _isSending = false;
        _titleController.clear();
        _bodyController.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Broadcast sent successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Push Notifications & Broadcasts', style: Theme.of(context).textTheme.displayLarge),
            const SizedBox(height: 24),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Compose Broadcast', style: Theme.of(context).textTheme.titleLarge),
                            const SizedBox(height: 24),
                            TextField(
                              controller: _titleController,
                              decoration: const InputDecoration(
                                labelText: 'Notification Title',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _bodyController,
                              maxLines: 4,
                              decoration: const InputDecoration(
                                labelText: 'Message Body',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: _isSending ? null : _sendBroadcast,
                                icon: _isSending 
                                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                    : const Icon(Icons.send),
                                label: Text(_isSending ? 'Sending...' : 'Send Broadcast to All Users'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(context).primaryColor,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    flex: 3,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Recent Broadcasts', style: Theme.of(context).textTheme.titleLarge),
                            const SizedBox(height: 16),
                            Expanded(
                              child: ListView.separated(
                                itemCount: 5,
                                separatorBuilder: (_, __) => const Divider(),
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    leading: const CircleAvatar(child: Icon(Icons.campaign)),
                                    title: Text('System Maintenance Update ${index + 1}'),
                                    subtitle: const Text('Sent to 14,205 users • 98% Delivery Rate'),
                                    trailing: Text('${index + 1} days ago', style: Theme.of(context).textTheme.bodySmall),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
