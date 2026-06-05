import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'users_service.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  List<AdminUser> _users = [];
  List<AdminUser> _filteredUsers = [];
  bool _loading = true;
  String? _error;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final list = await UsersService.getUsers();
      if (mounted) {
        setState(() {
          _users = list;
          _filteredUsers = list;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load users: $e';
          _loading = false;
        });
      }
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredUsers = _users;
      } else {
        _filteredUsers = _users.where((u) {
          return u.name.toLowerCase().contains(query) ||
              u.email.toLowerCase().contains(query) ||
              u.id.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  Future<void> _suspendUser(String id, String name) async {
    try {
      await UsersService.suspendUser(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Suspended user $name'), backgroundColor: Colors.orange),
        );
        _loadUsers();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to suspend user: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _restoreUser(String id, String name) async {
    try {
      await UsersService.restoreUser(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Restored user $name'), backgroundColor: Colors.green),
        );
        _loadUsers();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to restore user: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _deleteUser(String id, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete user $name? This will soft delete their record.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await UsersService.deleteUser(id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Deleted user $name'), backgroundColor: Colors.red),
          );
          _loadUsers();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete user: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

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
                  onPressed: _loadUsers,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh'),
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
                      controller: _searchController,
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
                    if (_loading)
                      const Center(child: CircularProgressIndicator())
                    else if (_error != null)
                      Center(
                        child: Column(
                          children: [
                            Text(_error!, style: const TextStyle(color: Colors.red)),
                            const SizedBox(height: 8),
                            ElevatedButton(onPressed: _loadUsers, child: const Text('Retry')),
                          ],
                        ),
                      )
                    else if (_filteredUsers.isEmpty)
                      const Center(child: Text('No users found.'))
                    else ...[
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
                      // Table Content (Real Data)
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _filteredUsers.length,
                        separatorBuilder: (_, __) => const Divider(height: 32),
                        itemBuilder: (context, index) {
                          final user = _filteredUsers[index];
                          return _UserRow(
                            user: user,
                            onSuspend: () => _suspendUser(user.id, user.name),
                            onRestore: () => _restoreUser(user.id, user.name),
                            onDelete: () => _deleteUser(user.id, user.name),
                          );
                        },
                      ),
                    ],
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
  final AdminUser user;
  final VoidCallback onSuspend;
  final VoidCallback onRestore;
  final VoidCallback onDelete;

  const _UserRow({
    required this.user,
    required this.onSuspend,
    required this.onRestore,
    required this.onDelete,
  });

  void _showActionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('User Actions', style: Theme.of(context).textTheme.titleLarge),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (user.isActive)
              ListTile(
                leading: const Icon(Icons.block, color: Colors.orange),
                title: const Text('Suspend User'),
                onTap: () {
                  Navigator.pop(context);
                  onSuspend();
                },
              )
            else
              ListTile(
                leading: const Icon(Icons.check_circle_outline, color: Colors.green),
                title: const Text('Restore User'),
                onTap: () {
                  Navigator.pop(context);
                  onRestore();
                },
              ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete User', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                onDelete();
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
                child: Text(
                  user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(user.name, style: Theme.of(context).textTheme.bodyLarge, overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(user.email, style: Theme.of(context).textTheme.bodyMedium),
        ),
        Expanded(
          flex: 2,
          child: StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance.collection('profiles').doc(user.id).snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || !snapshot.data!.exists) {
                return const Text('Ideation', style: TextStyle(color: Colors.grey));
              }
              final data = snapshot.data!.data() as Map<String, dynamic>?;
              final stage = data?['stage'] ?? 'Ideation';
              return Text(stage.toString());
            },
          ),
        ),
        Expanded(
          flex: 2,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: (user.isActive ? Colors.green : Colors.grey).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                user.isActive ? 'Active' : 'Suspended',
                style: TextStyle(
                  color: user.isActive ? Colors.green : Colors.grey,
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
