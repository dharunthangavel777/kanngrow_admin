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

  Future<void> _showAssignPlanDialog(String id, String name) async {
    String selectedTier = 'free';
    String assignmentType = 'lifetime'; // 'lifetime', 'trial_7', 'trial_14', 'trial_30', 'custom'
    String sourceType = 'admin_assignment';
    final notesController = TextEditingController();
    DateTime? customExpiryDate;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Assign Subscription: $name'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedTier,
                  decoration: const InputDecoration(labelText: 'Plan Tier'),
                  items: const [
                    DropdownMenuItem(value: 'free', child: Text('Free')),
                    DropdownMenuItem(value: 'standard', child: Text('Standard')),
                    DropdownMenuItem(value: 'premium', child: Text('Premium')),
                    DropdownMenuItem(value: 'enterprise', child: Text('Enterprise')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setDialogState(() => selectedTier = val);
                    }
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: assignmentType,
                  decoration: const InputDecoration(labelText: 'Assignment Type'),
                  items: const [
                    DropdownMenuItem(value: 'lifetime', child: Text('Lifetime Assignment')),
                    DropdownMenuItem(value: 'trial_7', child: Text('7-Day Trial')),
                    DropdownMenuItem(value: 'trial_14', child: Text('14-Day Trial')),
                    DropdownMenuItem(value: 'trial_30', child: Text('30-Day Trial')),
                    DropdownMenuItem(value: 'custom', child: Text('Custom Expiry (Direct)')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setDialogState(() => assignmentType = val);
                    }
                  },
                ),
                if (assignmentType == 'custom') ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          customExpiryDate == null
                              ? 'Select Expiry Date'
                              : 'Expires: ${customExpiryDate!.toLocal().toString().split(' ')[0]}',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.calendar_today),
                        label: const Text('Pick'),
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now().add(const Duration(days: 1)),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 3650)),
                          );
                          if (picked != null) {
                            setDialogState(() => customExpiryDate = picked);
                          }
                        },
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: sourceType,
                  decoration: const InputDecoration(labelText: 'Source Type'),
                  items: const [
                    DropdownMenuItem(value: 'admin_assignment', child: Text('Admin Assignment')),
                    DropdownMenuItem(value: 'payment', child: Text('Payment')),
                    DropdownMenuItem(value: 'promo', child: Text('Promotional')),
                    DropdownMenuItem(value: 'trial', child: Text('Trial')),
                    DropdownMenuItem(value: 'referral_reward', child: Text('Referral Reward')),
                    DropdownMenuItem(value: 'enterprise_contract', child: Text('Enterprise Contract')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setDialogState(() => sourceType = val);
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes / Reason',
                    hintText: 'e.g. Beta testing, partner promotion',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                notesController.dispose();
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (assignmentType == 'custom' && customExpiryDate == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please select an expiry date for custom assignment'), backgroundColor: Colors.red),
                  );
                  return;
                }

                // Resolve Expiry Date
                String? expiryStr;
                bool isLifetime = false;

                if (assignmentType == 'lifetime') {
                  isLifetime = true;
                } else if (assignmentType == 'trial_7') {
                  expiryStr = DateTime.now().add(const Duration(days: 7)).toIso8601String();
                } else if (assignmentType == 'trial_14') {
                  expiryStr = DateTime.now().add(const Duration(days: 14)).toIso8601String();
                } else if (assignmentType == 'trial_30') {
                  expiryStr = DateTime.now().add(const Duration(days: 30)).toIso8601String();
                } else if (assignmentType == 'custom') {
                  expiryStr = DateTime(
                    customExpiryDate!.year,
                    customExpiryDate!.month,
                    customExpiryDate!.day,
                    23,
                    59,
                    59,
                  ).toIso8601String();
                }

                final notes = notesController.text.trim();
                Navigator.pop(context);

                try {
                  await UsersService.assignUserPlan(
                    id,
                    tier: selectedTier,
                    sourceType: sourceType,
                    isLifetime: isLifetime,
                    expiryDate: expiryStr,
                    notes: notes.isNotEmpty ? notes : null,
                  );
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Assigned plan $selectedTier to $name'), backgroundColor: Colors.green),
                    );
                    _loadUsers();
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to assign plan: $e'), backgroundColor: Colors.red),
                    );
                  }
                } finally {
                  notesController.dispose();
                }
              },
              child: const Text('Assign'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showOverrideLimitsDialog(String id, String name) async {
    final dailyController = TextEditingController();
    final tokenController = TextEditingController();
    final reasonController = TextEditingController();
    bool chat = false;
    bool competitorResearch = false;
    bool seo = false;
    bool trends = false;
    bool marketing = false;
    bool contentGen = false;
    bool customKb = false;
    bool apiAccess = false;
    bool whiteLabel = false;

    try {
      final snap = await FirebaseFirestore.instance.collection('user_overrides').doc(id).get();
      if (snap.exists && snap.data() != null) {
        final data = snap.data()!;
        final limits = data['limitOverrides'] as Map<String, dynamic>?;
        final features = data['featuresEnabled'] as Map<String, dynamic>?;
        if (limits != null) {
          dailyController.text = (limits['dailyRequests'] ?? '').toString();
          tokenController.text = (limits['monthlyTokens'] ?? '').toString();
        }
        if (features != null) {
          chat = features['chat'] ?? false;
          competitorResearch = features['competitorResearch'] ?? false;
          seo = features['seoOptimizations'] ?? false;
          trends = features['trendAnalysis'] ?? false;
          marketing = features['marketingStrategy'] ?? false;
          contentGen = features['contentGenerationSuite'] ?? false;
          customKb = features['customKnowledgeBase'] ?? false;
          apiAccess = features['apiAccess'] ?? false;
          whiteLabel = features['whiteLabel'] ?? false;
        }
        reasonController.text = data['reason'] ?? '';
      }
    } catch (e) {
      debugPrint('Failed to load overrides: $e');
    }

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Override AI Limits: $name'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: dailyController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Daily Requests Limit Override'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: tokenController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Monthly Tokens Limit Override'),
                ),
                const SizedBox(height: 16),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Feature Overrides', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                SwitchListTile(
                  title: const Text('Unlimited AI Chats'),
                  value: chat,
                  onChanged: (val) => setDialogState(() => chat = val),
                ),
                SwitchListTile(
                  title: const Text('Competitor Research'),
                  value: competitorResearch,
                  onChanged: (val) => setDialogState(() => competitorResearch = val),
                ),
                SwitchListTile(
                  title: const Text('SEO Recommendations'),
                  value: seo,
                  onChanged: (val) => setDialogState(() => seo = val),
                ),
                SwitchListTile(
                  title: const Text('Trend Analysis'),
                  value: trends,
                  onChanged: (val) => setDialogState(() => trends = val),
                ),
                SwitchListTile(
                  title: const Text('Marketing Strategy'),
                  value: marketing,
                  onChanged: (val) => setDialogState(() => marketing = val),
                ),
                SwitchListTile(
                  title: const Text('Content Gen Suite'),
                  value: contentGen,
                  onChanged: (val) => setDialogState(() => contentGen = val),
                ),
                SwitchListTile(
                  title: const Text('Custom Knowledge Base'),
                  value: customKb,
                  onChanged: (val) => setDialogState(() => customKb = val),
                ),
                SwitchListTile(
                  title: const Text('API Access'),
                  value: apiAccess,
                  onChanged: (val) => setDialogState(() => apiAccess = val),
                ),
                SwitchListTile(
                  title: const Text('White Label / Branding'),
                  value: whiteLabel,
                  onChanged: (val) => setDialogState(() => whiteLabel = val),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: reasonController,
                  decoration: const InputDecoration(labelText: 'Reason for Override'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                dailyController.dispose();
                tokenController.dispose();
                reasonController.dispose();
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final daily = int.tryParse(dailyController.text);
                final tokens = int.tryParse(tokenController.text);
                final reason = reasonController.text;

                Navigator.pop(context);

                dailyController.dispose();
                tokenController.dispose();
                reasonController.dispose();

                try {
                  await UsersService.overrideUserLimits(
                    id,
                    limitOverrides: {
                      if (daily != null) 'dailyRequests': daily,
                      if (tokens != null) 'monthlyTokens': tokens,
                    },
                    featuresEnabled: {
                      'chat': chat,
                      'competitorResearch': competitorResearch,
                      'seoOptimizations': seo,
                      'trendAnalysis': trends,
                      'marketingStrategy': marketing,
                      'contentGenerationSuite': contentGen,
                      'customKnowledgeBase': customKb,
                      'apiAccess': apiAccess,
                      'whiteLabel': whiteLabel,
                    },
                    reason: reason,
                  );
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Limits overridden for $name'), backgroundColor: Colors.green),
                    );
                    _loadUsers();
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to override limits: $e'), backgroundColor: Colors.red),
                    );
                  }
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
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
                          Expanded(flex: 2, child: Text('SUBSCRIPTION', style: _headerStyle(context))),
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
                            onAssignPlan: () => _showAssignPlanDialog(user.id, user.name),
                            onOverrideLimits: () => _showOverrideLimitsDialog(user.id, user.name),
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
  final VoidCallback onAssignPlan;
  final VoidCallback onOverrideLimits;

  const _UserRow({
    required this.user,
    required this.onSuspend,
    required this.onRestore,
    required this.onDelete,
    required this.onAssignPlan,
    required this.onOverrideLimits,
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
              leading: const Icon(Icons.card_membership, color: Colors.blue),
              title: const Text('Assign Plan'),
              onTap: () {
                Navigator.pop(context);
                onAssignPlan();
              },
            ),
            ListTile(
              leading: const Icon(Icons.speed, color: Colors.purple),
              title: const Text('Override Limits'),
              onTap: () {
                Navigator.pop(context);
                onOverrideLimits();
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

  Widget _buildSubscriptionBadge(String tier, bool isLifetime, String? expiry) {
    Color badgeColor;
    switch (tier.toLowerCase()) {
      case 'standard':
        badgeColor = Colors.blue;
        break;
      case 'premium':
        badgeColor = Colors.purple;
        break;
      case 'enterprise':
        badgeColor = Colors.green;
        break;
      default:
        badgeColor = Colors.grey;
    }

    String label = tier.toUpperCase();
    String subtext = '';
    
    if (isLifetime) {
      subtext = 'Lifetime';
    } else if (expiry != null && expiry != 'lifetime') {
      try {
        final expDate = DateTime.parse(expiry);
        final diff = expDate.difference(DateTime.now());
        if (diff.isNegative) {
          subtext = 'Expired';
          badgeColor = Colors.red;
        } else if (diff.inDays <= 14) {
          subtext = 'Trial (${diff.inDays}d left)';
        } else {
          subtext = '${expDate.month}/${expDate.day}/${expDate.year}';
        }
      } catch (_) {
        subtext = 'Active';
      }
    } else {
      subtext = tier.toLowerCase() == 'free' ? 'Basic' : 'Active';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
          decoration: BoxDecoration(
            color: badgeColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: badgeColor.withOpacity(0.3), width: 1),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: badgeColor,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        if (subtext.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            subtext,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 10,
            ),
          ),
        ],
      ],
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
          child: StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance.collection('users').doc(user.id).snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || !snapshot.data!.exists) {
                return _buildSubscriptionBadge('free', false, null);
              }
              final data = snapshot.data!.data() as Map<String, dynamic>?;
              final sub = data?['subscription'] as Map<String, dynamic>? ?? {};
              final tier = sub['tier'] as String? ?? 'free';
              final isLifetime = sub['isLifetime'] == true;
              final expiry = sub['currentPeriodEnd'] as String?;
              return _buildSubscriptionBadge(tier, isLifetime, expiry);
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
