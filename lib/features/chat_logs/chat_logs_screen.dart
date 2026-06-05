import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatLogsScreen extends StatefulWidget {
  const ChatLogsScreen({super.key});

  @override
  State<ChatLogsScreen> createState() => _ChatLogsScreenState();
}

class _ChatLogsScreenState extends State<ChatLogsScreen> {
  Map<String, dynamic>? _selectedSession;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText: 'Search sessions by title...',
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
                            child: StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collectionGroup('chatSessions')
                                  .orderBy('updatedAt', descending: true)
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return const Center(child: CircularProgressIndicator());
                                }
                                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                                  return const Center(child: Text('No chat sessions found.'));
                                }

                                var docs = snapshot.data!.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();

                                if (_searchQuery.isNotEmpty) {
                                  docs = docs.where((doc) {
                                    final title = (doc['title'] ?? '').toString().toLowerCase();
                                    return title.contains(_searchQuery);
                                  }).toList();
                                }

                                return ListView.separated(
                                  itemCount: docs.length,
                                  separatorBuilder: (_, _) => const Divider(height: 1),
                                  itemBuilder: (context, index) {
                                    final session = docs[index];
                                    final isSelected = _selectedSession != null && _selectedSession!['id'] == session['id'];

                                    return StreamBuilder<DocumentSnapshot>(
                                      stream: FirebaseFirestore.instance.collection('users').doc(session['uid']).snapshots(),
                                      builder: (context, userSnap) {
                                        final userName = userSnap.hasData && userSnap.data!.exists
                                            ? ((userSnap.data!.data() as Map<String, dynamic>?)?['displayName'] ?? 'Founder')
                                            : 'Founder';

                                        return ListTile(
                                          leading: const CircleAvatar(child: Icon(Icons.chat)),
                                          title: Text(session['title'] ?? 'Chat Session'),
                                          subtitle: Text('User: $userName'),
                                          selected: isSelected,
                                          selectedTileColor: Theme.of(context).primaryColor.withOpacity(0.1),
                                          onTap: () {
                                            setState(() {
                                              _selectedSession = session;
                                            });
                                          },
                                        );
                                      },
                                    );
                                  },
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
                      child: _selectedSession == null
                          ? const Center(child: Text('Select a conversation to view details'))
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(24.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          '${_selectedSession!['title'] ?? 'Session'} Details',
                                          style: Theme.of(context).textTheme.titleLarge,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      ElevatedButton.icon(
                                        onPressed: () {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Export functionality coming soon')),
                                          );
                                        },
                                        icon: const Icon(Icons.download),
                                        label: const Text('Export'),
                                      ),
                                    ],
                                  ),
                                ),
                                const Divider(height: 1),
                                Expanded(
                                  child: StreamBuilder<QuerySnapshot>(
                                    stream: FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(_selectedSession!['uid'])
                                        .collection('chatSessions')
                                        .doc(_selectedSession!['id'])
                                        .collection('messages')
                                        .orderBy('createdAt', descending: false)
                                        .snapshots(),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                        return const Center(child: CircularProgressIndicator());
                                      }
                                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                                        return const Center(child: Text('No messages in this conversation.'));
                                      }

                                      final messages = snapshot.data!.docs;

                                      return ListView.builder(
                                        padding: const EdgeInsets.all(24.0),
                                        itemCount: messages.length,
                                        itemBuilder: (context, idx) {
                                          final msg = messages[idx].data() as Map<String, dynamic>;
                                          final role = msg['role'] as String? ?? 'user';
                                          final content = msg['content'] as String? ?? '';
                                          final isAi = role == 'assistant';

                                          return Padding(
                                            padding: const EdgeInsets.only(bottom: 16.0),
                                            child: _ChatBubble(text: content, isAi: isAi),
                                          );
                                        },
                                      );
                                    },
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
