import 'package:flutter/material.dart';

class ChatLogsScreen extends StatelessWidget {
  const ChatLogsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Chat Logs & Conversations', style: Theme.of(context).textTheme.displayLarge),
            const SizedBox(height: 24),
            Expanded(
              child: Row(
                children: [
                  // Chat Session List
                  Expanded(
                    flex: 1,
                    child: Card(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Search sessions...',
                                prefixIcon: const Icon(Icons.search),
                                filled: true,
                                fillColor: Theme.of(context).scaffoldBackgroundColor,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ),
                          const Divider(height: 1),
                          Expanded(
                            child: ListView.separated(
                              itemCount: 10,
                              separatorBuilder: (_, _) => const Divider(height: 1),
                              itemBuilder: (context, index) {
                                return ListTile(
                                  leading: const CircleAvatar(child: Icon(Icons.chat)),
                                  title: Text('Session #100${9 - index}'),
                                  subtitle: const Text('Validation Discussion'),
                                  trailing: const Text('2h ago', style: TextStyle(fontSize: 12)),
                                  selected: index == 0,
                                  selectedTileColor: Theme.of(context).primaryColor.withOpacity(0.1),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  // Chat Detail View
                  Expanded(
                    flex: 2,
                    child: Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Session #1009 Details', style: Theme.of(context).textTheme.titleLarge),
                                ElevatedButton.icon(
                                  onPressed: () {},
                                  icon: const Icon(Icons.download),
                                  label: const Text('Export Transcript'),
                                ),
                              ],
                            ),
                          ),
                          const Divider(height: 1),
                          Expanded(
                            child: ListView(
                              padding: const EdgeInsets.all(24.0),
                              children: const [
                                _ChatBubble(text: 'I want to build a pet supply store.', isAi: false),
                                SizedBox(height: 16),
                                _ChatBubble(text: 'That sounds great! A pet supply store has a strong market. Are you focusing on a specific niche, like organic pet food or dog toys?', isAi: true),
                                SizedBox(height: 16),
                                _ChatBubble(text: 'Organic dog food.', isAi: false),
                                SizedBox(height: 16),
                                _ChatBubble(text: 'Excellent choice. The organic pet food market is growing rapidly. Let\'s validate this idea...', isAi: true),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final String text;
  final bool isAi;

  const _ChatBubble({required this.text, required this.isAi});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isAi ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.4),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isAi ? Theme.of(context).scaffoldBackgroundColor : Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(16).copyWith(
            bottomLeft: isAi ? const Radius.circular(0) : const Radius.circular(16),
            bottomRight: !isAi ? const Radius.circular(0) : const Radius.circular(16),
          ),
          border: isAi ? Border.all(color: Theme.of(context).dividerColor) : null,
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isAi ? Theme.of(context).textTheme.bodyLarge?.color : Colors.white,
          ),
        ),
      ),
    );
  }
}
