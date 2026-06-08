import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/token_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();
  String _selectedCategory = 'all';
  bool _isSending = false;

  static const String _baseUrl = String.fromEnvironment(
    'BACKEND_URL',
    defaultValue: 'https://kanngrowbackend-production.up.railway.app/api/v1',
  );

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _sendBroadcast() async {
    final title = _titleController.text.trim();
    final body = _bodyController.text.trim();

    if (title.isEmpty || body.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both title and body.')),
      );
      return;
    }

    setState(() => _isSending = true);

    try {
      final token = await TokenService.getToken();
      final headers = {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      final response = await http.post(
        Uri.parse('$_baseUrl/admin/broadcast'),
        headers: headers,
        body: jsonEncode({
          'title': title,
          'body': body,
          'targetCategory': _selectedCategory,
        }),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          _titleController.clear();
          _bodyController.clear();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Broadcast sent successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        final errorMsg = jsonDecode(response.body)['error'] ?? 'Unknown error';
        throw Exception(errorMsg);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send broadcast: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
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
                        child: SingleChildScrollView(
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
                              DropdownButtonFormField<String>(
                                value: _selectedCategory,
                                decoration: const InputDecoration(
                                  labelText: 'Target Category',
                                  border: OutlineInputBorder(),
                                ),
                                items: const [
                                  DropdownMenuItem(value: 'all', child: Text('All Users')),
                                  DropdownMenuItem(value: 'active', child: Text('Active Users')),
                                  DropdownMenuItem(value: 'new', child: Text('New Signups')),
                                  DropdownMenuItem(value: 'premium', child: Text('Premium Tiers')),
                                ],
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      _selectedCategory = value;
                                    });
                                  }
                                },
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
                                  label: Text(_isSending ? 'Sending...' : 'Send Broadcast to Users'),
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
                              child: StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection('notifications')
                                    .where('type', isEqualTo: 'broadcast')
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return const Center(child: CircularProgressIndicator());
                                  }
                                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                                    return const Center(
                                      child: Text('No broadcasts sent yet.', style: TextStyle(color: Colors.white54)),
                                    );
                                  }

                                  final docs = snapshot.data!.docs.map((doc) {
                                    return doc.data() as Map<String, dynamic>;
                                  }).toList();

                                  // Sort by sentAt descending
                                  docs.sort((a, b) {
                                    final aTime = a['sentAt'] as String? ?? '';
                                    final bTime = b['sentAt'] as String? ?? '';
                                    return bTime.compareTo(aTime);
                                  });

                                  if (docs.isEmpty) {
                                    return const Center(
                                      child: Text('No broadcasts sent yet.', style: TextStyle(color: Colors.white54)),
                                    );
                                  }

                                  return ListView.separated(
                                    itemCount: docs.length,
                                    separatorBuilder: (_, __) => const Divider(),
                                    itemBuilder: (context, index) {
                                      final broadcast = docs[index];
                                      final title = broadcast['title'] as String? ?? 'Broadcast';
                                      final body = broadcast['body'] as String? ?? '';
                                      final category = broadcast['targetCategory'] as String? ?? 'all';
                                      final sentAt = broadcast['sentAt'] as String? ?? '';
                                      
                                      String timeDisplay = 'Just now';
                                      try {
                                        if (sentAt.isNotEmpty) {
                                          final date = DateTime.parse(sentAt).toLocal();
                                          timeDisplay = '${date.month}/${date.day} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
                                        }
                                      } catch (_) {}

                                      return ListTile(
                                        leading: const CircleAvatar(child: Icon(Icons.campaign)),
                                        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                                        subtitle: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(height: 4),
                                            Text(body, style: const TextStyle(color: Colors.white70)),
                                            const SizedBox(height: 4),
                                            Text('Audience: ${category.toUpperCase()}', style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 11, fontWeight: FontWeight.w600)),
                                          ],
                                        ),
                                        trailing: Text(timeDisplay, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white30)),
                                      );
                                    },
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

