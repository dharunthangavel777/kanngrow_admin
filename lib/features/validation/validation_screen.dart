import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ValidationScreen extends StatelessWidget {
  const ValidationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Validation Engine Reports', style: Theme.of(context).textTheme.displayLarge),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(flex: 3, child: Text('BUSINESS IDEA', style: _headerStyle(context))),
                        Expanded(flex: 2, child: Text('MARKET SCORE', style: _headerStyle(context))),
                        Expanded(flex: 2, child: Text('COMPETITION', style: _headerStyle(context))),
                        Expanded(flex: 2, child: Text('RISK LEVEL', style: _headerStyle(context))),
                        Expanded(flex: 1, child: Text('ACTION', style: _headerStyle(context))),
                      ],
                    ),
                    const Divider(height: 32),
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collectionGroup('workspace').snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Center(child: Text('No validation reports found.'));
                        }

                        final docs = snapshot.data!.docs
                            .map((doc) => doc.data() as Map<String, dynamic>)
                            .where((doc) => doc['type'] == 'validation')
                            .toList();

                        // Sort by createdAt descending
                        docs.sort((a, b) {
                          final aTime = a['createdAt'] as String? ?? '';
                          final bTime = b['createdAt'] as String? ?? '';
                          return bTime.compareTo(aTime);
                        });

                        if (docs.isEmpty) {
                          return const Center(child: Text('No validation reports found.'));
                        }

                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: docs.length,
                          separatorBuilder: (_, __) => const Divider(height: 32),
                          itemBuilder: (context, index) {
                            final report = docs[index];
                            final productName = report['productName'] ?? 'Business Concept';
                            final data = report['data'] as Map<String, dynamic>? ?? {};
                            final overallScore = (data['overallScore'] ?? 0) as int;
                            
                            final dimensions = data['dimensions'] as Map<String, dynamic>? ?? {};
                            final compData = dimensions['competition'] as Map<String, dynamic>? ?? {};
                            final competitionScore = (compData['score'] ?? 0) as int;

                            final riskData = dimensions['riskLevel'] as Map<String, dynamic>? ?? {};
                            final riskScore = (riskData['score'] ?? 0) as int;
                            
                            String riskLevel = 'Medium';
                            if (riskScore > 70) riskLevel = 'High';
                            if (riskScore < 40) riskLevel = 'Low';

                            return _ValidationRow(
                              ideaName: productName,
                              marketScore: overallScore,
                              competitionScore: competitionScore,
                              riskLevel: riskLevel,
                              details: data,
                            );
                          },
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

  TextStyle _headerStyle(BuildContext context) {
    return Theme.of(context).textTheme.bodyMedium!.copyWith(
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        );
  }
}

class _ValidationRow extends StatelessWidget {
  final String ideaName;
  final int marketScore;
  final int competitionScore;
  final String riskLevel;
  final Map<String, dynamic> details;

  const _ValidationRow({
    required this.ideaName,
    required this.marketScore,
    required this.competitionScore,
    required this.riskLevel,
    required this.details,
  });

  Color _getRiskColor() {
    switch (riskLevel) {
      case 'High':
        return Colors.red;
      case 'Medium':
        return Colors.orange;
      case 'Low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  void _showDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF111111),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(ideaName, style: const TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Overall Score: $marketScore/100', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Verdict: ${details['verdict'] ?? ""}', style: const TextStyle(color: Colors.white)),
              const SizedBox(height: 16),
              const Text('Top Risks:', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
              for (final risk in (details['topRisks'] as List<dynamic>? ?? []))
                Text('• $risk', style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 16),
              const Text('Quick Wins:', style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
              for (final win in (details['quickWins'] as List<dynamic>? ?? []))
                Text('• $win', style: const TextStyle(color: Colors.white70)),
            ],
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

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Text(ideaName, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
        ),
        Expanded(
          flex: 2,
          child: Text('$marketScore/100', style: TextStyle(color: marketScore > 75 ? Colors.green : Colors.orange, fontWeight: FontWeight.bold)),
        ),
        Expanded(
          flex: 2,
          child: Text('$competitionScore/100', style: TextStyle(color: competitionScore > 70 ? Colors.red : Colors.green)),
        ),
        Expanded(
          flex: 2,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: _getRiskColor().withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                riskLevel,
                style: TextStyle(color: _getRiskColor(), fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: const Icon(Icons.arrow_forward_ios, size: 16),
              onPressed: () => _showDetails(context),
            ),
          ),
        ),
      ],
    );
  }
}
