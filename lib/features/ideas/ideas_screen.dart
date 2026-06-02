import 'package:flutter/material.dart';

class IdeasScreen extends StatelessWidget {
  const IdeasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Product Ideas Engine', style: Theme.of(context).textTheme.displayLarge),
            const SizedBox(height: 24),
            Row(
              children: [
                _StatCard(title: 'Total Generated', value: '14,205'),
                const SizedBox(width: 24),
                _StatCard(title: 'Top Category', value: 'SaaS / AI'),
                const SizedBox(width: 24),
                _StatCard(title: 'Saved by Users', value: '4,102'),
              ],
            ),
            const SizedBox(height: 32),
            Text('Top Performing Ideas', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 5,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.lightbulb, color: Theme.of(context).primaryColor),
                    ),
                    title: Text('AI-Powered Pet Nutrition Planner ${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text('Niche: Pet Care • Validation Score: 92/100'),
                    trailing: Text('${120 - (index * 15)} saves', style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
                  ),
                );
              },
            ),
          ],
        ),
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
              Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 28)),
            ],
          ),
        ),
      ),
    );
  }
}
