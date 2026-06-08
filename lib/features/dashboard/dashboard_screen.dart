import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dashboard_service.dart';
import '../ai_management/ai_management_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _loading = true;
  DashboardStats? _stats;
  AiUsageReport? _aiReport;
  int _activeBusinesses = 0;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final stats = await DashboardService.getStats();
      final aiReport = await AiManagementService().getUsageStats(days: 30);
      final profilesSnap = await FirebaseFirestore.instance.collection('profiles').count().get();

      if (mounted) {
        setState(() {
          _stats = stats;
          _aiReport = aiReport;
          _activeBusinesses = profilesSnap.count ?? 0;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load dashboard data: $e';
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_error!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadDashboardData,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final totalUsers = _stats?.totalUsers ?? 0;
    final totalTokens = _aiReport?.summary.totalTokens ?? 0;
    final totalCost = _aiReport?.summary.totalCost ?? 0.0;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadDashboardData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Dashboard Overview', style: Theme.of(context).textTheme.displayLarge),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: _loadDashboardData,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Metric Cards
              Wrap(
                spacing: 24,
                runSpacing: 24,
                children: [
                  _MetricCard(title: 'Total Users', value: '$totalUsers', trend: 'Live', isPositive: true),
                  _MetricCard(title: 'Active Businesses', value: '$_activeBusinesses', trend: 'Live', isPositive: true),
                  _MetricCard(title: 'AI Tokens Used', value: '${(totalTokens / 1000000.0).toStringAsFixed(1)}M', trend: '30d', isPositive: false),
                  _MetricCard(title: 'Est. AI Cost', value: '\$${totalCost.toStringAsFixed(2)}', trend: '30d', isPositive: true),
                ],
              ),
              const SizedBox(height: 32),
              Text('Subscribers Overview', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              Wrap(
                spacing: 24,
                runSpacing: 24,
                children: [
                  _MetricCard(title: 'Paid Subscribers', value: '${_stats?.paidSubscribers ?? 0}', trend: 'Payment', isPositive: true),
                  _MetricCard(title: 'Admin Assigned', value: '${_stats?.adminAssignedSubscribers ?? 0}', trend: 'Manual', isPositive: true),
                  _MetricCard(title: 'Trial Subscribers', value: '${_stats?.trialSubscribers ?? 0}', trend: 'Trial', isPositive: true),
                  _MetricCard(title: 'Lifetime Access', value: '${_stats?.lifetimeSubscribers ?? 0}', trend: 'Lifetime', isPositive: true),
                ],
              ),
              const SizedBox(height: 32),
              Text('Tier Distribution', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              Wrap(
                spacing: 24,
                runSpacing: 24,
                children: [
                  _MetricCard(title: 'Free Plan', value: '${_stats?.freeUsers ?? 0}', trend: 'Free', isPositive: true),
                  _MetricCard(title: 'Standard Plan', value: '${_stats?.standardUsers ?? 0}', trend: 'Standard', isPositive: true),
                  _MetricCard(title: 'Premium Plan', value: '${_stats?.premiumUsers ?? 0}', trend: 'Premium', isPositive: true),
                  _MetricCard(title: 'Enterprise Plan', value: '${_stats?.enterpriseUsers ?? 0}', trend: 'Enterprise', isPositive: true),
                ],
              ),
              const SizedBox(height: 32),
              // Charts Area
              Row(
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
                            Text('AI Cost Trend (30 Days)', style: Theme.of(context).textTheme.titleLarge),
                            const SizedBox(height: 24),
                            SizedBox(
                              height: 300,
                              child: _aiReport != null && _aiReport!.dailyChart.isNotEmpty
                                  ? _AiCostChart(dailyChart: _aiReport!.dailyChart)
                                  : const Center(child: Text('No historical usage data yet.')),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    flex: 1,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Live Activities', style: Theme.of(context).textTheme.titleLarge),
                            const SizedBox(height: 16),
                            const _ActivityList(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String trend;
  final bool isPositive;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.trend,
    required this.isPositive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 28)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (isPositive ? Colors.green : Colors.red).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  trend,
                  style: TextStyle(
                    color: isPositive ? Colors.green : Colors.redAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AiCostChart extends StatelessWidget {
  final List<DailyChartPoint> dailyChart;
  const _AiCostChart({required this.dailyChart});

  @override
  Widget build(BuildContext context) {
    final spots = <FlSpot>[];
    for (int i = 0; i < dailyChart.length; i++) {
      spots.add(FlSpot(i.toDouble(), dailyChart[i].cost));
    }

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: dailyChart.length > 7 ? (dailyChart.length / 5).floor().toDouble() : 1,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx >= 0 && idx < dailyChart.length) {
                  final dateStr = dailyChart[idx].date;
                  final parts = dateStr.split('-');
                  if (parts.length >= 3) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text('${parts[1]}/${parts[2]}', style: const TextStyle(fontSize: 10)),
                    );
                  }
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Theme.of(context).primaryColor,
            barWidth: 4,
            isStrokeCapRound: true,
            belowBarData: BarAreaData(
              show: true,
              color: Theme.of(context).primaryColor.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityList extends StatelessWidget {
  const _ActivityList();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('audit_logs')
          .orderBy('timestamp', descending: true)
          .limit(5)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 24.0),
              child: Text('No manual plan changes yet.', style: TextStyle(color: Colors.grey)),
            ),
          );
        }

        final docs = snapshot.data!.docs;

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (context, index) {
            final log = docs[index].data() as Map<String, dynamic>;
            final adminName = log['admin_name'] ?? 'Admin';
            final userName = log['user_name'] ?? 'Founder';
            final newPlan = log['new_plan'] as String? ?? 'free';
            final sourceType = log['source_type'] as String? ?? 'admin_assignment';
            final reason = log['reason'] as String? ?? '';
            final timestamp = log['timestamp'] as String? ?? '';
            
            final planStr = newPlan.toUpperCase();
            
            String sourceStr = '';
            if (sourceType == 'trial') {
              sourceStr = 'Trial';
            } else if (sourceType == 'promo') {
              sourceStr = 'Promo';
            } else if (sourceType == 'lifetime') {
              sourceStr = 'Lifetime';
            } else if (sourceType == 'admin_assignment') {
              sourceStr = 'Manual';
            } else {
              sourceStr = sourceType;
            }

            String timeStr = 'Recently';
            if (timestamp.isNotEmpty) {
              try {
                final date = DateTime.parse(timestamp);
                final diff = DateTime.now().difference(date);
                if (diff.inMinutes < 60) {
                  timeStr = '${diff.inMinutes} mins ago';
                } else if (diff.inHours < 24) {
                  timeStr = '${diff.inHours} hours ago';
                } else {
                  timeStr = '${diff.inDays} days ago';
                }
              } catch (_) {}
            }

            final title = '$adminName updated $userName to $planStr ($sourceStr)';
            final subtitle = reason.isNotEmpty ? '$timeStr • "$reason"' : timeStr;

            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).primaryColor.withOpacity(0.15),
                child: Icon(
                  Icons.admin_panel_settings_outlined,
                  color: Theme.of(context).primaryColor,
                  size: 18,
                ),
              ),
              title: Text(title, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 13)),
              subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            );
          },
        );
      },
    );
  }
}
