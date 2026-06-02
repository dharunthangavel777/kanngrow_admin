import 'package:flutter/material.dart';

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
                Text('Roadmap Templates Engine', style: Theme.of(context).textTheme.displayLarge),
                ElevatedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        final titleController = TextEditingController();
                        return AlertDialog(
                          title: const Text('New Template'),
                          content: TextField(
                            controller: titleController,
                            decoration: const InputDecoration(
                              labelText: 'Template Title',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                if (titleController.text.trim().isNotEmpty) {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Created template: ${titleController.text}')),
                                  );
                                }
                              },
                              child: const Text('Save'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('New Template'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 350,
                mainAxisSpacing: 24,
                crossAxisSpacing: 24,
                childAspectRatio: 1.0,
              ),
              itemCount: 4,
              itemBuilder: (context, index) {
                final templates = [
                  {'title': 'E-commerce Store Launch', 'tasks': 45, 'uses': 1205},
                  {'title': 'Dropshipping MVP', 'tasks': 32, 'uses': 890},
                  {'title': 'SaaS Initial Growth', 'tasks': 60, 'uses': 450},
                  {'title': 'Local Service Business', 'tasks': 25, 'uses': 310},
                ];
                return _TemplateCard(
                  title: templates[index]['title'] as String,
                  tasksCount: templates[index]['tasks'] as int,
                  usageCount: templates[index]['uses'] as int,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _TemplateCard extends StatelessWidget {
  final String title;
  final int tasksCount;
  final int usageCount;

  const _TemplateCard({
    required this.title,
    required this.tasksCount,
    required this.usageCount,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
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
            const SizedBox(height: 24),
            Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 20)),
            const Spacer(),
            const Divider(),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tasks', style: Theme.of(context).textTheme.bodyMedium),
                    Text('$tasksCount', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Global Uses', style: Theme.of(context).textTheme.bodyMedium),
                    Text('$usageCount', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
