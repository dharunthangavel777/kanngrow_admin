import 'package:flutter/material.dart';
import '../users/users_service.dart';

class SubscriptionsScreen extends StatefulWidget {
  const SubscriptionsScreen({super.key});

  @override
  State<SubscriptionsScreen> createState() => _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends State<SubscriptionsScreen> {
  List<AdminAuditLog> _logs = [];
  bool _loadingLogs = true;
  String? _logsError;

  @override
  void initState() {
    super.initState();
    _loadAuditLogs();
  }

  Future<void> _loadAuditLogs() async {
    setState(() {
      _loadingLogs = true;
      _logsError = null;
    });
    try {
      final list = await UsersService.getAuditLogs();
      if (mounted) {
        setState(() {
          _logs = list;
          _loadingLogs = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _logsError = e.toString();
          _loadingLogs = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text('Subscriptions & Revenue', style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 24)),
          ),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'REVENUE OVERVIEW'),
              Tab(text: 'MANUAL PLAN AUDIT LOGS'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: Revenue Overview
            _buildRevenueOverviewTab(),
            // Tab 2: Manual Plan Audit Logs
            _buildAuditLogsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _StatCard(title: 'MRR (Monthly Recurring Revenue)', value: '\$24,500'),
              const SizedBox(width: 24),
              _StatCard(title: 'Active Subscribers', value: '1,250'),
              const SizedBox(width: 24),
              _StatCard(title: 'Churn Rate', value: '2.4%'),
            ],
          ),
          const SizedBox(height: 32),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Recent Transactions', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 6,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.check_circle, color: Colors.green),
                        ),
                        title: Text('Pro Plan Subscription - user${index}@email.com'),
                        subtitle: const Text('Credit Card • Stripe'),
                        trailing: const Text('+\$49.00', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16)),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuditLogsTab() {
    if (_loadingLogs) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_logsError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Failed to load audit logs: $_logsError', style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadAuditLogs, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (_logs.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadAuditLogs,
        child: const Center(
          child: Text('No manual plan assignment audit logs found.'),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAuditLogs,
      child: ListView.separated(
        padding: const EdgeInsets.all(24),
        itemCount: _logs.length,
        separatorBuilder: (_, __) => const Divider(height: 24),
        itemBuilder: (context, index) {
          final log = _logs[index];
          final timestamp = log.timestamp.isNotEmpty ? log.timestamp.split('T')[0] : 'N/A';
          return Card(
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.assignment_ind, color: Theme.of(context).primaryColor, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        '${log.previousPlan.toUpperCase()} ➔ ${log.newPlan.toUpperCase()}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          log.sourceType.toUpperCase(),
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('USER', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(log.userName, style: const TextStyle(fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('ASSIGNED BY', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(log.adminName, style: const TextStyle(fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('DATE', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(timestamp, style: const TextStyle(fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (log.reason.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Text('REASON / NOTES', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(
                      log.reason,
                      style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.black87),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;

  const _StatCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 16),
              Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 28, color: Colors.green)),
            ],
          ),
        ),
      ),
    );
  }
}
