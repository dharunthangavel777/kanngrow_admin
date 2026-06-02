import 'package:flutter/material.dart';

class EcommerceScreen extends StatelessWidget {
  const EcommerceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ecommerce Businesses', style: Theme.of(context).textTheme.displayLarge),
            const SizedBox(height: 24),
            // Grid of businesses
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 400,
                mainAxisSpacing: 24,
                crossAxisSpacing: 24,
                childAspectRatio: 1.2,
              ),
              itemCount: 6,
              itemBuilder: (context, index) {
                return _BusinessCard(
                  name: 'Startup Concept ${index + 1}',
                  niche: 'Fashion & Apparel',
                  validationScore: 85 - (index * 5),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _BusinessCard extends StatelessWidget {
  final String name;
  final String niche;
  final int validationScore;

  const _BusinessCard({
    required this.name,
    required this.niche,
    required this.validationScore,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.storefront, color: Theme.of(context).primaryColor),
                ),
                IconButton(icon: const Icon(Icons.more_horiz), onPressed: () {}),
              ],
            ),
            const Spacer(),
            Text(name, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(niche, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Validation Score', style: Theme.of(context).textTheme.bodyMedium),
                Text(
                  '$validationScore / 100',
                  style: TextStyle(
                    color: validationScore >= 80 ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.bold,
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
