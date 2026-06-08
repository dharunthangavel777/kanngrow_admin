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
  // Push Composer State
  final TextEditingController _pushTitleController = TextEditingController();
  final TextEditingController _pushBodyController = TextEditingController();
  String _pushTargetCategory = 'all';
  bool _isSendingPush = false;

  // Email Composer State
  final TextEditingController _emailSubjectController = TextEditingController();
  final TextEditingController _emailBodyController = TextEditingController();
  final TextEditingController _specificEmailController = TextEditingController();
  String _emailTargetCategory = 'all';
  bool _isSendingEmail = false;

  static const String _baseUrl = String.fromEnvironment(
    'BACKEND_URL',
    defaultValue: 'https://kanngrowbackend-production.up.railway.app/api/v1',
  );

  @override
  void dispose() {
    _pushTitleController.dispose();
    _pushBodyController.dispose();
    _emailSubjectController.dispose();
    _emailBodyController.dispose();
    _specificEmailController.dispose();
    super.dispose();
  }

  Future<void> _sendPushBroadcast() async {
    final title = _pushTitleController.text.trim();
    final body = _pushBodyController.text.trim();

    if (title.isEmpty || body.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both title and body.')),
      );
      return;
    }

    setState(() => _isSendingPush = true);

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
          'targetCategory': _pushTargetCategory,
        }),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          _pushTitleController.clear();
          _pushBodyController.clear();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Push Broadcast sent successfully!'),
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
            content: Text('Failed to send push: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSendingPush = false);
    }
  }

  Future<void> _sendEmailBroadcast() async {
    final subject = _emailSubjectController.text.trim();
    final body = _emailBodyController.text.trim();
    final specificEmail = _specificEmailController.text.trim();

    if (subject.isEmpty || body.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both subject and body.')),
      );
      return;
    }

    if (_emailTargetCategory == 'specific' && specificEmail.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a recipient email address.')),
      );
      return;
    }

    setState(() => _isSendingEmail = true);

    try {
      final token = await TokenService.getToken();
      final headers = {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      final response = await http.post(
        Uri.parse('$_baseUrl/admin/email-broadcast'),
        headers: headers,
        body: jsonEncode({
          'subject': subject,
          'body': body,
          'targetCategory': _emailTargetCategory,
          if (_emailTargetCategory == 'specific') 'specificEmail': specificEmail,
        }),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          _emailSubjectController.clear();
          _emailBodyController.clear();
          _specificEmailController.clear();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Email Broadcast sent successfully!'),
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
            content: Text('Failed to send email: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSendingEmail = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Notification & Communication Center',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          backgroundColor: const Color(0xFF151821),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.campaign), text: 'Push Broadcasts'),
              Tab(icon: Icon(Icons.email), text: 'Email Broadcasts'),
              Tab(icon: Icon(Icons.history_toggle_off), text: 'Delivery Logs'),
            ],
            indicatorColor: Color(0xFF00E5FF),
            labelColor: Color(0xFF00E5FF),
            unselectedLabelColor: Colors.white70,
          ),
        ),
        body: Container(
          color: const Color(0xFF0D0F14),
          padding: const EdgeInsets.all(24.0),
          child: TabBarView(
            children: [
              _buildPushBroadcastTab(),
              _buildEmailBroadcastTab(),
              _buildDeliveryLogsTab(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPushBroadcastTab() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Card(
            color: const Color(0xFF151821),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Compose Push Notification', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 24),
                    TextField(
                      controller: _pushTitleController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Notification Title',
                        labelStyle: TextStyle(color: Colors.white70),
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _pushTargetCategory,
                      dropdownColor: const Color(0xFF151821),
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Target Category',
                        labelStyle: TextStyle(color: Colors.white70),
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'all', child: Text('All Users')),
                        DropdownMenuItem(value: 'active', child: Text('Active Users')),
                        DropdownMenuItem(value: 'premium', child: Text('Premium Tiers')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _pushTargetCategory = value);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _pushBodyController,
                      maxLines: 4,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Message Body',
                        labelStyle: TextStyle(color: Colors.white70),
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isSendingPush ? null : _sendPushBroadcast,
                        icon: _isSendingPush
                            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.send),
                        label: Text(_isSendingPush ? 'Sending...' : 'Send Broadcast to Users'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00E5FF),
                          foregroundColor: const Color(0xFF0D0F14),
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
            color: const Color(0xFF151821),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Recent Broadcasts', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
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

                        docs.sort((a, b) {
                          final aTime = a['sentAt'] as String? ?? '';
                          final bTime = b['sentAt'] as String? ?? '';
                          return bTime.compareTo(aTime);
                        });

                        return ListView.separated(
                          itemCount: docs.length,
                          separatorBuilder: (_, __) => const Divider(color: Colors.white12),
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
                              leading: const CircleAvatar(
                                backgroundColor: Color(0xFF1E293B),
                                child: Icon(Icons.campaign, color: Color(0xFF00E5FF)),
                              ),
                              title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(body, style: const TextStyle(color: Colors.white70)),
                                  const SizedBox(height: 4),
                                  Text('Audience: ${category.toUpperCase()}',
                                      style: const TextStyle(color: Color(0xFF00E5FF), fontSize: 11, fontWeight: FontWeight.w600)),
                                ],
                              ),
                              trailing: Text(timeDisplay, style: const TextStyle(color: Colors.white30, fontSize: 12)),
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
    );
  }

  Widget _buildEmailBroadcastTab() {
    return Card(
      color: const Color(0xFF151821),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Compose Email Broadcast', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 24),
              TextField(
                controller: _emailSubjectController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Email Subject',
                  labelStyle: TextStyle(color: Colors.white70),
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _emailTargetCategory,
                dropdownColor: const Color(0xFF151821),
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Target Category',
                  labelStyle: TextStyle(color: Colors.white70),
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                ),
                items: const [
                  DropdownMenuItem(value: 'all', child: Text('All Registered Users')),
                  DropdownMenuItem(value: 'active', child: Text('Active Users')),
                  DropdownMenuItem(value: 'premium', child: Text('Premium Plan Users')),
                  DropdownMenuItem(value: 'specific', child: Text('Specific Email Address')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _emailTargetCategory = value);
                  }
                },
              ),
              if (_emailTargetCategory == 'specific') ...[
                const SizedBox(height: 16),
                TextField(
                  controller: _specificEmailController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Recipient Email Address',
                    labelStyle: TextStyle(color: Colors.white70),
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              TextField(
                controller: _emailBodyController,
                maxLines: 8,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Email Body (Markdown or plain text supported)',
                  labelStyle: TextStyle(color: Colors.white70),
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isSendingEmail ? null : _sendEmailBroadcast,
                  icon: _isSendingEmail
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.email),
                  label: Text(_isSendingEmail ? 'Sending Email Broadcast...' : 'Send Email Broadcast'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00E5FF),
                    foregroundColor: const Color(0xFF0D0F14),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeliveryLogsTab() {
    return Card(
      color: const Color(0xFF151821),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Notification Delivery Logs', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('notification_logs')
                    .orderBy('sentAt', descending: true)
                    .limit(100)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text('No delivery logs found.', style: TextStyle(color: Colors.white54)),
                    );
                  }

                  final docs = snapshot.data!.docs;

                  return ListView.separated(
                    itemCount: docs.length,
                    separatorBuilder: (_, __) => const Divider(color: Colors.white12),
                    itemBuilder: (context, index) {
                      final log = docs[index].data() as Map<String, dynamic>;
                      final type = log['type'] as String? ?? 'general';
                      final title = log['title'] as String? ?? 'Notification';
                      final userName = log['userName'] as String? ?? 'User';
                      final sentAt = log['sentAt'] as String? ?? '';
                      final channels = log['channels'] as Map<String, dynamic>? ?? {};

                      String timeDisplay = 'Just now';
                      try {
                        if (sentAt.isNotEmpty) {
                          final date = DateTime.parse(sentAt).toLocal();
                          timeDisplay = '${date.month}/${date.day} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
                        }
                      } catch (_) {}

                      return ListTile(
                        title: Text(
                          '${type.toUpperCase()}: $title',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text('Recipient: $userName', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                _buildStatusIndicator('In-App', channels['inApp']),
                                const SizedBox(width: 12),
                                _buildStatusIndicator('Push', channels['push']),
                                const SizedBox(width: 12),
                                _buildStatusIndicator('Email', channels['email']),
                              ],
                            ),
                          ],
                        ),
                        trailing: Text(timeDisplay, style: const TextStyle(color: Colors.white30, fontSize: 12)),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(String label, dynamic status) {
    Color color;
    IconData icon;

    if (status == 'success') {
      color = Colors.greenAccent;
      icon = Icons.check_circle_outline;
    } else if (status == 'failed') {
      color = Colors.redAccent;
      icon = Icons.error_outline;
    } else if (status == 'pending') {
      color = Colors.amberAccent;
      icon = Icons.hourglass_empty;
    } else {
      color = Colors.white24;
      icon = Icons.block;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 4),
        Text(
          '$label: ${status ?? "none"}',
          style: TextStyle(color: color, fontSize: 11),
        ),
      ],
    );
  }
}
