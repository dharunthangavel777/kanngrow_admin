import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class AiManagementScreen extends StatelessWidget {
  const AiManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('AI Cost Center (Secret Feature)', style: Theme.of(context).textTheme.displayLarge),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('OpenAI Token Cost (Last 30 Days)', style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 24),
                          SizedBox(
                            height: 300,
                            child: _CostChart(),
                          ),
                        ],
                      ),
                    ),
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
                          Text('Most Expensive Users', style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 16),
                          const _ExpensiveUserList(),
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
                          Text('Model Usage Distribution', style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 200,
                            child: _ModelPieChart(),
                          ),
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

class _CostChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(
          14,
          (index) => BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: (index * 1.5) % 8 + 2,
                color: Theme.of(context).primaryColor,
                width: 16,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExpensiveUserList extends StatelessWidget {
  const _ExpensiveUserList();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 4,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (context, index) {
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const CircleAvatar(child: Icon(Icons.person, size: 16)),
          title: Text('Power User ${index + 1}', style: Theme.of(context).textTheme.bodyLarge),
          trailing: Text('\$${45 - index * 10}.50', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent)),
        );
      },
    );
  }
}

class _ModelPieChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 40,
        sections: [
          PieChartSectionData(
            color: Theme.of(context).primaryColor,
            value: 65,
            title: 'GPT-4o',
            radius: 50,
            titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          PieChartSectionData(
            color: Theme.of(context).colorScheme.secondary,
            value: 25,
            title: 'GPT-4o-mini',
            radius: 50,
            titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          PieChartSectionData(
            color: Colors.green,
            value: 10,
            title: 'O1',
            radius: 50,
            titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
