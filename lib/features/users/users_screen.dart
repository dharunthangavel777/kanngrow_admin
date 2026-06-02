import 'package:flutter/material.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

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
                Text('Users Management', style: Theme.of(context).textTheme.displayLarge),
                ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invite user functionality coming soon')));
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Invite User'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    // Search Bar
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Search users by name, email, or ID...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Theme.of(context).dividerColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Theme.of(context).dividerColor),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Table Header
                    Row(
                      children: [
                        Expanded(flex: 2, child: Text('NAME', style: _headerStyle(context))),
                        Expanded(flex: 3, child: Text('EMAIL', style: _headerStyle(context))),
                        Expanded(flex: 2, child: Text('STARTUP PHASE', style: _headerStyle(context))),
                        Expanded(flex: 2, child: Text('STATUS', style: _headerStyle(context))),
                        const SizedBox(width: 48), // For action menu
                      ],
                    ),
                    const Divider(height: 32),
                    // Table Content (Mock Data)
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: 8,
                      separatorBuilder: (_, __) => const Divider(height: 32),
                      itemBuilder: (context, index) {
                        return _UserRow(
                          name: 'Founder ${index + 1}',
                          email: 'founder${index + 1}@startup.com',
                          phase: index % 3 == 0 ? 'Validation' : 'Ideation',
                          isActive: index % 4 != 0,
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

class _UserRow extends StatelessWidget {
  final String name;
  final String email;
  final String phase;
  final bool isActive;

  const _UserRow({
    required this.name,
    required this.email,
    required this.phase,
    required this.isActive,
  });

  void _showActionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('User Actions', style: Theme.of(context).textTheme.titleLarge),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.visibility),
              title: const Text('View Details'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Viewing user details...')));
              },
            ),
            ListTile(
              leading: const Icon(Icons.block, color: Colors.orange),
              title: const Text('Suspend User'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User suspended.')));
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete User', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User deleted.')));
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
                child: Text(name[0], style: TextStyle(color: Theme.of(context).primaryColor)),
              ),
              const SizedBox(width: 16),
              Text(name, style: Theme.of(context).textTheme.bodyLarge),
            ],
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(email, style: Theme.of(context).textTheme.bodyMedium),
        ),
        Expanded(
          flex: 2,
          child: Text(phase, style: Theme.of(context).textTheme.bodyMedium),
        ),
        Expanded(
          flex: 2,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: (isActive ? Colors.green : Colors.grey).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                isActive ? 'Active' : 'Inactive',
                style: TextStyle(
                  color: isActive ? Colors.green : Colors.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          width: 48,
          child: IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showActionDialog(context),
          ),
        ),
      ],
    );
  }
}
