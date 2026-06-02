import 'package:flutter/material.dart';

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
                        Expanded(flex: 3, child: Text('SUBJECT', style: _headerStyle(context))),
                        Expanded(flex: 2, child: Text('USER', style: _headerStyle(context))),
                        Expanded(flex: 2, child: Text('TYPE', style: _headerStyle(context))),
                        Expanded(flex: 2, child: Text('STATUS', style: _headerStyle(context))),
                        Expanded(flex: 1, child: Text('ACTION', style: _headerStyle(context))),
                      ],
                    ),
                    const Divider(height: 32),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: 6,
                      separatorBuilder: (_, __) => const Divider(height: 32),
                      itemBuilder: (context, index) {
                        return _TicketRow(
                          subject: index % 2 == 0 ? 'Bug in Idea Generator' : 'Feature Request: Dark Mode',
                          user: 'user${index}@startup.com',
                          type: index % 2 == 0 ? 'Bug Report' : 'Feature Request',
                          status: index == 0 ? 'Open' : 'Resolved',
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
  final String subject;
  final String user;
  final String type;
  final String status;

  const _TicketRow({
    required this.subject,
    required this.user,
    required this.type,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Text(subject, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
        ),
        Expanded(
          flex: 2,
          child: Text(user, style: Theme.of(context).textTheme.bodyMedium),
        ),
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: type == 'Bug Report' ? Colors.red.withOpacity(0.1) : Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              type,
              style: TextStyle(color: type == 'Bug Report' ? Colors.red : Colors.blue, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            status,
            style: TextStyle(
              color: status == 'Open' ? Colors.orange : Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: const Icon(Icons.arrow_forward_ios, size: 16),
              onPressed: () {},
            ),
          ),
        ),
      ],
    );
  }
}
