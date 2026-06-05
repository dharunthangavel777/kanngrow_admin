import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FeedbackScreen extends StatelessWidget {
  const FeedbackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Feedback & Support Tickets', style: Theme.of(context).textTheme.displayLarge),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(flex: 4, child: Text('FEEDBACK / MESSAGE', style: _headerStyle(context))),
                        Expanded(flex: 3, child: Text('USER EMAIL', style: _headerStyle(context))),
                        Expanded(flex: 2, child: Text('CATEGORY', style: _headerStyle(context))),
                        Expanded(flex: 2, child: Text('RATING', style: _headerStyle(context))),
                        Expanded(flex: 1, child: Text('ACTION', style: _headerStyle(context))),
                      ],
                    ),
                    const Divider(height: 32),
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection('feedback').snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(24.0),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(24.0),
                              child: Text('No feedback tickets found.'),
                            ),
                          );
                        }

                        final docs = snapshot.data!.docs.map((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          return {
                            'id': doc.id,
                            ...data,
                          };
                        }).toList();

                        // Sort by createdAt descending
                        docs.sort((a, b) {
                          final aTime = a['createdAt'];
                          final bTime = b['createdAt'];
                          if (aTime is Timestamp && bTime is Timestamp) {
                            return bTime.compareTo(aTime);
                          } else if (aTime is String && bTime is String) {
                            return bTime.compareTo(aTime);
                          }
                          return 0;
                        });

                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: docs.length,
                          separatorBuilder: (_, __) => const Divider(height: 32),
                          itemBuilder: (context, index) {
                            final ticket = docs[index];
                            final message = ticket['message'] as String? ?? '';
                            final email = ticket['email'] as String? ?? 'anonymous';
                            final category = ticket['category'] as String? ?? 'General';
                            final rating = (ticket['rating'] ?? 0) as num;

                            return _TicketRow(
                              message: message,
                              user: email,
                              category: category,
                              rating: rating.toInt(),
                              ticket: ticket,
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

class _TicketRow extends StatelessWidget {
  final String message;
  final String user;
  final String category;
  final int rating;
  final Map<String, dynamic> ticket;

  const _TicketRow({
    required this.message,
    required this.user,
    required this.category,
    required this.rating,
    required this.ticket,
  });

  void _showTicketDetails(BuildContext context) {
    String formattedTime = 'N/A';
    final createdAt = ticket['createdAt'];
    if (createdAt is Timestamp) {
      formattedTime = createdAt.toDate().toLocal().toString();
    } else if (createdAt is String) {
      formattedTime = createdAt;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF111827),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Feedback Detail', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.cyan.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                category.toUpperCase(),
                style: const TextStyle(color: Colors.cyan, fontSize: 11, fontWeight: FontWeight.bold),
              ),
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
                const Text('USER EMAIL', style: TextStyle(color: Colors.cyan, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
                const SizedBox(height: 4),
                Text(user, style: const TextStyle(color: Colors.white70, fontSize: 14)),
                const SizedBox(height: 16),
                const Text('USER RATING', style: TextStyle(color: Colors.cyan, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
                const SizedBox(height: 4),
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      index < rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 20,
                    );
                  }),
                ),
                const SizedBox(height: 16),
                const Text('FEEDBACK MESSAGE', style: TextStyle(color: Colors.cyan, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
                const SizedBox(height: 4),
                Text(message, style: const TextStyle(color: Colors.white, fontSize: 14)),
                const SizedBox(height: 20),
                Text('Submitted: $formattedTime', style: const TextStyle(color: Colors.white30, fontSize: 12)),
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
    final truncatedMsg = message.length > 50 ? "${message.substring(0, 50)}..." : message;

    return Row(
      children: [
        Expanded(
          flex: 4,
          child: Text(
            truncatedMsg.isEmpty ? '(No message provided)' : truncatedMsg,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontStyle: truncatedMsg.isEmpty ? FontStyle.italic : FontStyle.normal,
                ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(user, style: Theme.of(context).textTheme.bodyMedium),
        ),
        Expanded(
          flex: 2,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: category.toLowerCase().contains('bug')
                    ? Colors.red.withOpacity(0.1)
                    : Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                category,
                style: TextStyle(
                  color: category.toLowerCase().contains('bug') ? Colors.red : Colors.blue,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Row(
            children: List.generate(5, (index) {
              return Icon(
                index < rating ? Icons.star : Icons.star_border,
                color: Colors.amber,
                size: 16,
              );
            }),
          ),
        ),
        Expanded(
          flex: 1,
          child: Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: const Icon(Icons.arrow_forward_ios, size: 16),
              onPressed: () => _showTicketDetails(context),
            ),
          ),
        ),
      ],
    );
  }
}

