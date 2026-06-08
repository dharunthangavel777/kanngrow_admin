import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RoadmapsScreen extends StatelessWidget {
  const RoadmapsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('User Roadmaps Engine', style: Theme.of(context).textTheme.displayLarge),
              ],
            ),
            const SizedBox(height: 24),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collectionGroup('workspace').snapshots(),
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
                  return _buildEmptyState(context);
                }

                final docs = snapshot.data!.docs
                    .map((doc) => doc.data() as Map<String, dynamic>)
                    .where((doc) => doc['type'] == 'roadmap')
                    .toList();

                // Sort by createdAt descending
                docs.sort((a, b) {
                  final aTime = a['createdAt'] as String? ?? '';
                  final bTime = b['createdAt'] as String? ?? '';
                  return bTime.compareTo(aTime);
                });

                if (docs.isEmpty) {
                  return _buildEmptyState(context);
                }

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 380,
                    mainAxisSpacing: 24,
                    crossAxisSpacing: 24,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final roadmap = docs[index];
                    final productName = roadmap['productName'] as String? ?? 'Business Launch';
                    final data = roadmap['data'] as Map<String, dynamic>? ?? {};
                    final milestones = data['milestones'] as List<dynamic>? ?? [];
                    
                    int totalTasks = 0;
                    for (final milestone in milestones) {
                      final tasks = milestone['tasks'] as List<dynamic>? ?? [];
                      totalTasks += tasks.length;
                    }

                    return _TemplateCard(
                      title: productName,
                      phasesCount: milestones.length,
                      tasksCount: totalTasks,
                      uid: roadmap['uid'] as String? ?? 'Unknown',
                      roadmap: roadmap,
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

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.map_outlined, size: 64, color: Colors.white.withOpacity(0.2)),
            const SizedBox(height: 16),
            Text(
              'No active user roadmaps found.',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white60),
            ),
          ],
        ),
      ),
    );
  }
}

class _TemplateCard extends StatelessWidget {
  final String title;
  final int phasesCount;
  final int tasksCount;
  final String uid;
  final Map<String, dynamic> roadmap;

  const _TemplateCard({
    required this.title,
    required this.phasesCount,
    required this.tasksCount,
    required this.uid,
    required this.roadmap,
  });

  void _showRoadmapDetails(BuildContext context) {
    final data = roadmap['data'] as Map<String, dynamic>? ?? {};
    final milestones = data['milestones'] as List<dynamic>? ?? [];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF111111),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(
              'User UID: $uid',
              style: const TextStyle(color: Colors.white54, fontSize: 12),
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
                if (milestones.isEmpty)
                  const Text('No phases defined in this roadmap.', style: TextStyle(color: Colors.white70))
                else
                  ...milestones.map((m) {
                    final phaseName = m['phase'] as String? ?? 'Phase';
                    final tasks = m['tasks'] as List<dynamic>? ?? [];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Colors.cyan,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  phaseName,
                                  style: const TextStyle(
                                    color: Colors.cyan,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          if (tasks.isEmpty)
                            const Padding(
                              padding: EdgeInsets.only(left: 16.0),
                              child: Text('No tasks in this phase.', style: TextStyle(color: Colors.white30, fontSize: 13)),
                            )
                          else
                            ...tasks.map((t) {
                              final taskText = t is Map ? (t['text'] ?? '') : t.toString();
                              return Padding(
                                padding: const EdgeInsets.only(left: 16.0, bottom: 6.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('• ', style: TextStyle(color: Colors.white54)),
                                    Expanded(
                                      child: Text(
                                        taskText,
                                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                        ],
                      ),
                    );
                  }),
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

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () => _showRoadmapDetails(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.map_outlined, color: Theme.of(context).colorScheme.secondary, size: 32),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                'UID: ${uid.length > 15 ? "${uid.substring(0, 15)}..." : uid}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white30),
              ),
              const Spacer(),
              const Divider(),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Phases', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white54)),
                      Text('$phasesCount', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Total Tasks', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white54)),
                      Text('$tasksCount', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
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

