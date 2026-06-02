import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Analytics Center', style: Theme.of(context).textTheme.displayLarge),
              const SizedBox(height: 24),
              TabBar(
                isScrollable: true,
                indicatorColor: Theme.of(context).primaryColor,
                labelColor: Theme.of(context).primaryColor,
                unselectedLabelColor: Theme.of(context).textTheme.bodyMedium?.color,
                tabs: const [
                  Tab(text: 'User Growth'),
                  Tab(text: 'Business'),
                  Tab(text: 'AI Usage'),
                  Tab(text: 'Revenue'),
                  Tab(text: 'Retention'),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildChartTab(context, 'User Growth Analytics', _PlaceholderChart()),
                    _buildChartTab(context, 'Business Analytics', _PlaceholderChart()),
                    _buildChartTab(context, 'AI Usage Analytics', _PlaceholderChart()),
                    _buildChartTab(context, 'Revenue Analytics', _PlaceholderChart()),
                    _buildChartTab(context, 'Retention Analytics', _RetentionChart()),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChartTab(BuildContext context, String title, Widget chart) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 24),
            Expanded(child: chart),
          ],
        ),
      ),
    );
  }
}

class _RetentionChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: true),
        titlesData: const FlTitlesData(
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: const [
              FlSpot(0, 100),
              FlSpot(1, 80),
              FlSpot(2, 65),
              FlSpot(3, 50),
              FlSpot(4, 45),
              FlSpot(5, 40),
            ],
            isCurved: true,
            color: Colors.blueAccent,
            barWidth: 4,
            isStrokeCapRound: true,
            belowBarData: BarAreaData(show: true, color: Colors.blueAccent.withOpacity(0.1)),
          ),
        ],
      ),
    );
  }
}

class _PlaceholderChart extends StatelessWidget {
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

