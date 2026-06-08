import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('profiles').snapshots(),
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
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(48.0),
                      child: Text('No active business profiles found.', style: TextStyle(color: Colors.white54)),
                    ),
                  );
                }

                final docs = snapshot.data!.docs
                    .map((doc) => doc.data() as Map<String, dynamic>)
                    .toList();

                // Sort by updatedAt descending
                docs.sort((a, b) {
                  final aTime = a['updatedAt'] as String? ?? '';
                  final bTime = b['updatedAt'] as String? ?? '';
                  return bTime.compareTo(aTime);
                });

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 400,
                    mainAxisSpacing: 24,
                    crossAxisSpacing: 24,
                    childAspectRatio: 1.25,
                  ),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final profile = docs[index];
                    final storeName = profile['storeName'] as String? ?? 'Unnamed Store';
                    final industry = profile['industry'] as String? ?? 'General';
                    final stage = profile['stage'] as String? ?? 'Idea Stage';
                    final state = profile['state'] as String? ?? 'India';

                    return _BusinessCard(
                      storeName: storeName,
                      industry: industry,
                      stage: stage,
                      state: state,
                      profile: profile,
                    );
                  },
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
  final String storeName;
  final String industry;
  final String stage;
  final String state;
  final Map<String, dynamic> profile;

  const _BusinessCard({
    required this.storeName,
    required this.industry,
    required this.stage,
    required this.state,
    required this.profile,
  });

  void _showProfileDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF111111),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(storeName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(
              'UID: ${profile['uid'] ?? 'N/A'}',
              style: const TextStyle(color: Colors.white30, fontSize: 12),
            ),
          ],
        ),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _detailRow('Industry', profile['industry']),
                _detailRow('Product Category', profile['productCategory']),
                _detailRow('Business Model', profile['businessModel']),
                _detailRow('Target Audience', profile['targetAudience']),
                _detailRow('State / Region', profile['state']),
                _detailRow('Experience Level', profile['experienceLevel']),
                _detailRow('User Type', profile['userType']),
                _detailRow('Stage', profile['stage']),
                _detailRow('Goal', profile['goal']),
                _detailRow('Budget', profile['budget']),
                const SizedBox(height: 16),
                Text(
                  'Last Updated: ${profile['updatedAt'] ?? 'N/A'}',
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

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () => _showProfileDetails(context),
        borderRadius: BorderRadius.circular(12),
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
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      state,
                      style: const TextStyle(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                storeName,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 18),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                industry,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Stage', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white54)),
                  Text(
                    stage,
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
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

