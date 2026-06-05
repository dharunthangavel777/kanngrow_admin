import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collectionGroup('ideas').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(48.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _StatCard(title: 'Total Saved Ideas', value: '0'),
                          const SizedBox(width: 24),
                          _StatCard(title: 'Top Category / Niche', value: 'N/A'),
                        ],
                      ),
                      const SizedBox(height: 32),
                      const Center(
                        child: Text('No product ideas found in the database.', style: TextStyle(color: Colors.white54)),
                      ),
                    ],
                  );
                }

                final docs = snapshot.data!.docs
                    .map((doc) => doc.data() as Map<String, dynamic>)
                    .toList();

                // Sort by createdAt descending
                docs.sort((a, b) {
                  final aTime = a['createdAt'] as String? ?? '';
                  final bTime = b['createdAt'] as String? ?? '';
                  return bTime.compareTo(aTime);
                });

                // Calculate Top Niche
                final nicheCounts = <String, int>{};
                for (final doc in docs) {
                  final niche = doc['niche'] as String? ?? 'General';
                  if (niche.trim().isNotEmpty) {
                    nicheCounts[niche] = (nicheCounts[niche] ?? 0) + 1;
                  }
                }
                String topNiche = 'N/A';
                int maxCount = 0;
                nicheCounts.forEach((niche, count) {
                  if (count > maxCount) {
                    maxCount = count;
                    topNiche = niche;
                  }
                });

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _StatCard(title: 'Total Saved Ideas', value: docs.length.toString()),
                        const SizedBox(width: 24),
                        _StatCard(title: 'Top Category / Niche', value: topNiche),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Text('Saved Product Ideas', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 16),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: docs.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final idea = docs[index];
                        final name = idea['name'] as String? ?? 'Unnamed Idea';
                        final niche = idea['niche'] as String? ?? 'General';
                        final uniqueAngle = idea['uniqueAngle'] as String? ?? '';

                        return Card(
                          child: ListTile(
                            onTap: () => _showIdeaDetails(context, idea),
                            contentPadding: const EdgeInsets.all(16),
                            leading: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(Icons.lightbulb, color: Theme.of(context).primaryColor),
                            ),
                            title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('Niche: $niche • ${uniqueAngle.isNotEmpty ? uniqueAngle : "No specific details"}'),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          ),
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showIdeaDetails(BuildContext context, Map<String, dynamic> idea) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF111827),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(idea['name'] as String? ?? 'Product Idea', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _detailRow('Niche', idea['niche']),
                _detailRow('Target Customer', idea['targetCustomer']),
                _detailRow('Margin', idea['margin']),
                _detailRow('Competition', idea['competition']),
                _detailRow('Sourcing Platform', idea['sourcingPlatform']),
                _detailRow('Validation Strategy', idea['validationStrategy']),
                _detailRow('Unique Angle', idea['uniqueAngle']),
                const SizedBox(height: 16),
                Text(
                  'Created At: ${idea['createdAt'] ?? 'N/A'}',
                  style: const TextStyle(color: Colors.white30, fontSize: 11),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: Colors.cyan)),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, dynamic value) {
    final displayValue = value?.toString() ?? 'N/A';
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(color: Colors.cyan, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.1),
          ),
          const SizedBox(height: 4),
          Text(
            displayValue,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
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
              Text(title, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white54)),
              const SizedBox(height: 16),
              Text(
                value,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 24, fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

