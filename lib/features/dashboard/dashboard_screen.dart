import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Dashboard Overview', style: Theme.of(context).textTheme.displayLarge),
            const SizedBox(height: 24),
            // Metric Cards
            Wrap(
              spacing: 24,
              runSpacing: 24,
              children: const [
                _MetricCard(title: 'Total Users', value: '12,450', trend: '+14%', isPositive: true),
                _MetricCard(title: 'Active Businesses', value: '3,210', trend: '+8%', isPositive: true),
                _MetricCard(title: 'AI Tokens Used', value: '45.2M', trend: '+22%', isPositive: false),
                _MetricCard(title: 'Est. AI Cost', value: '\$1,450', trend: '-5%', isPositive: true),
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
                          Text('User Growth', style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 24),
                          SizedBox(
                            height: 300,
                            child: _UserGrowthChart(),
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

class _UserGrowthChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30, interval: 1)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: const [
              FlSpot(0, 1),
              FlSpot(1, 1.5),
              FlSpot(2, 1.4),
              FlSpot(3, 3.4),
              FlSpot(4, 2),
              FlSpot(5, 2.2),
              FlSpot(6, 4.8),
            ],
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
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 5,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (context, index) {
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const CircleAvatar(child: Icon(Icons.person, size: 16)),
          title: Text('User joined new startup', style: Theme.of(context).textTheme.bodyLarge),
          subtitle: const Text('2 mins ago'),
        );
      },
    );
  }
}
