import 'package:flutter/material.dart';

class SubscriptionsScreen extends StatelessWidget {
  const SubscriptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Subscriptions & Revenue', style: Theme.of(context).textTheme.displayLarge),
            const SizedBox(height: 24),
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
