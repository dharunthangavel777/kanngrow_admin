import 'package:flutter/material.dart';
import '../users/users_service.dart';
import 'subscriptions_service.dart';

class SubscriptionsScreen extends StatefulWidget {
  const SubscriptionsScreen({super.key});

  @override
  State<SubscriptionsScreen> createState() => _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends State<SubscriptionsScreen> {
  List<AdminAuditLog> _logs = [];
  bool _loadingLogs = true;
  String? _logsError;

  List<SubscriptionPlan> _plans = [];
  bool _loadingPlans = true;
  String? _plansError;

  @override
  void initState() {
    super.initState();
    _loadAuditLogs();
    _loadPlans();
  }

  Future<void> _loadPlans() async {
    setState(() {
      _loadingPlans = true;
      _plansError = null;
    });
    try {
      final list = await SubscriptionsService.getPlans();
      if (mounted) {
        setState(() {
          _plans = list;
          _loadingPlans = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _plansError = e.toString();
          _loadingPlans = false;
        });
      }
    }
  }

  Future<void> _loadAuditLogs() async {
    setState(() {
      _loadingLogs = true;
      _logsError = null;
    });
    try {
      final list = await UsersService.getAuditLogs();
      if (mounted) {
        setState(() {
          _logs = list;
          _loadingLogs = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _logsError = e.toString();
          _loadingLogs = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text('Subscriptions & Revenue', style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 24)),
          ),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'REVENUE OVERVIEW'),
              Tab(text: 'MANUAL PLAN AUDIT LOGS'),
              Tab(text: 'MANAGE PLANS'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: Revenue Overview
            _buildRevenueOverviewTab(),
            // Tab 2: Manual Plan Audit Logs
            _buildAuditLogsTab(),
            // Tab 3: Manage Plans
            _buildManagePlansTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _StatCard(title: 'MRR (Monthly Recurring Revenue)', value: '\$24,500'),
              const SizedBox(width: 24),
              _StatCard(title: 'Active Subscribers', value: '1,250'),
              const SizedBox(width: 24),
              _StatCard(title: 'Churn Rate', value: '2.4%'),
            ],
          ),
          const SizedBox(height: 32),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Recent Transactions', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 6,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.check_circle, color: Colors.green),
                        ),
                        title: Text('Pro Plan Subscription - user${index}@email.com'),
                        subtitle: const Text('Credit Card • Stripe'),
                        trailing: const Text('+\$49.00', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16)),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuditLogsTab() {
    if (_loadingLogs) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_logsError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Failed to load audit logs: $_logsError', style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadAuditLogs, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (_logs.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadAuditLogs,
        child: const Center(
          child: Text('No manual plan assignment audit logs found.'),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAuditLogs,
      child: ListView.separated(
        padding: const EdgeInsets.all(24),
        itemCount: _logs.length,
        separatorBuilder: (_, __) => const Divider(height: 24),
        itemBuilder: (context, index) {
          final log = _logs[index];
          final timestamp = log.timestamp.isNotEmpty ? log.timestamp.split('T')[0] : 'N/A';
          return Card(
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.assignment_ind, color: Theme.of(context).primaryColor, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        '${log.previousPlan.toUpperCase()} ➔ ${log.newPlan.toUpperCase()}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          log.sourceType.toUpperCase(),
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('USER', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(log.userName, style: const TextStyle(fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('ASSIGNED BY', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(log.adminName, style: const TextStyle(fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('DATE', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(timestamp, style: const TextStyle(fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (log.reason.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Text('REASON / NOTES', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(
                      log.reason,
                      style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.black87),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildManagePlansTab() {
    if (_loadingPlans) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_plansError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Failed to load plans: $_plansError', style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadPlans, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (_plans.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadPlans,
        child: const Center(
          child: Text('No subscription plans found in the database.'),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadPlans,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 900;
          return GridView.builder(
            padding: const EdgeInsets.all(24),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isWide ? 2 : 1,
              crossAxisSpacing: 24,
              mainAxisSpacing: 24,
              childAspectRatio: isWide ? 1.25 : 0.85,
            ),
            itemCount: _plans.length,
            itemBuilder: (context, index) {
              final plan = _plans[index];
              return _buildPlanConfigCard(plan);
            },
          );
        },
      ),
    );
  }

  Widget _buildPlanConfigCard(SubscriptionPlan plan) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFF222222), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  plan.id == 'free'
                      ? Icons.card_membership
                      : plan.id == 'standard'
                          ? Icons.star_border
                          : plan.id == 'premium'
                              ? Icons.star
                              : Icons.business,
                  color: Colors.cyan,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plan.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        plan.description,
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showEditPlanDialog(plan),
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Configure'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyan.withOpacity(0.1),
                    foregroundColor: Colors.cyan,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Pricing
                    const Text('PRICING', style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(
                      'Monthly: \$${plan.pricing.monthlyUsd.toStringAsFixed(2)} | Annual: \$${plan.pricing.annualUsd.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 12),

                    // Limits
                    const Text('RESOURCE LIMITS', style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(
                      'Daily Requests: ${plan.limits.dailyRequests == 0 ? "Unlimited" : plan.limits.dailyRequests} • '
                      'Monthly Tokens: ${plan.limits.monthlyTokens == 0 ? "Unlimited" : plan.limits.monthlyTokens} • '
                      'Max Upload: ${plan.limits.maxUploadSizeMb} MB • '
                      'Doc Uploads: ${plan.limits.maxDocumentUploads} • '
                      'Stores: ${plan.limits.maxStoreCount} • '
                      'Queue: ${plan.limits.priorityQueue.toUpperCase()}',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 12),

                    // Allowed Models
                    const Text('ALLOWED MODELS', style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: plan.allowedModels.isEmpty
                          ? [const Text('None', style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic))]
                          : plan.allowedModels.map((model) {
                              return Chip(
                                label: Text(model, style: const TextStyle(fontSize: 11)),
                                backgroundColor: Colors.cyan.withOpacity(0.1),
                                padding: EdgeInsets.zero,
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              );
                            }).toList(),
                    ),
                    const SizedBox(height: 12),

                    // Features List
                    const Text('ACTIVATED FEATURES', style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    _buildFeaturesGrid(plan.features),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesGrid(PlanFeatures features) {
    final list = [
      {'name': 'Chat', 'enabled': features.chat},
      {'name': 'Competitor Research', 'enabled': features.competitorResearch},
      {'name': 'SEO Optimizations', 'enabled': features.seoOptimizations},
      {'name': 'Trend Analysis', 'enabled': features.trendAnalysis},
      {'name': 'Marketing Strategy', 'enabled': features.marketingStrategy},
      {'name': 'Content Gen Suite', 'enabled': features.contentGenerationSuite},
      {'name': 'Custom Knowledge Base', 'enabled': features.customKnowledgeBase},
      {'name': 'API Token Access', 'enabled': features.apiAccess},
      {'name': 'White Labeling', 'enabled': features.whiteLabel},
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: list.map((item) {
        final enabled = item['enabled'] as bool;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              enabled ? Icons.check_circle : Icons.cancel,
              color: enabled ? Colors.green : Colors.red,
              size: 14,
            ),
            const SizedBox(width: 4),
            Text(
              item['name'] as String,
              style: TextStyle(
                fontSize: 12,
                color: enabled ? Colors.white : Colors.grey,
                decoration: enabled ? null : TextDecoration.lineThrough,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  void _showEditPlanDialog(SubscriptionPlan plan) {
    final formKey = GlobalKey<FormState>();

    // Controllers
    final monthlyController = TextEditingController(text: plan.pricing.monthlyUsd.toString());
    final annualController = TextEditingController(text: plan.pricing.annualUsd.toString());
    final stripeMonthlyController = TextEditingController(text: plan.pricing.stripePriceIdMonthly);
    final stripeAnnualController = TextEditingController(text: plan.pricing.stripePriceIdAnnual);

    final dailyRequestsController = TextEditingController(text: plan.limits.dailyRequests.toString());
    final monthlyTokensController = TextEditingController(text: plan.limits.monthlyTokens.toString());
    final maxUploadController = TextEditingController(text: plan.limits.maxUploadSizeMb.toString());
    final maxDocsController = TextEditingController(text: plan.limits.maxDocumentUploads.toString());
    final maxStoresController = TextEditingController(text: plan.limits.maxStoreCount.toString());
    final priorityQueueController = TextEditingController(text: plan.limits.priorityQueue);

    final allowedModelsController = TextEditingController(text: plan.allowedModels.join(', '));

    // Feature toggles state
    bool chat = plan.features.chat;
    bool competitorResearch = plan.features.competitorResearch;
    bool seoOptimizations = plan.features.seoOptimizations;
    bool trendAnalysis = plan.features.trendAnalysis;
    bool marketingStrategy = plan.features.marketingStrategy;
    bool contentGenerationSuite = plan.features.contentGenerationSuite;
    bool customKnowledgeBase = plan.features.customKnowledgeBase;
    bool apiAccess = plan.features.apiAccess;
    bool whiteLabel = plan.features.whiteLabel;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Row(
                children: [
                  const Icon(Icons.settings, color: Colors.cyan),
                  const SizedBox(width: 8),
                  Text('Configure Plan: ${plan.name}'),
                ],
              ),
              content: SizedBox(
                width: 800,
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Pricing Structure',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.cyan),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: monthlyController,
                                decoration: const InputDecoration(labelText: 'Monthly Price (USD)'),
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                validator: (v) => v == null || double.tryParse(v) == null ? 'Invalid price' : null,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: annualController,
                                decoration: const InputDecoration(labelText: 'Annual Price (USD)'),
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                validator: (v) => v == null || double.tryParse(v) == null ? 'Invalid price' : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: stripeMonthlyController,
                                decoration: const InputDecoration(labelText: 'Stripe Monthly Price ID'),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: stripeAnnualController,
                                decoration: const InputDecoration(labelText: 'Stripe Annual Price ID'),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 32),

                        const Text(
                          'Resource Limits',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.cyan),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: dailyRequestsController,
                                decoration: const InputDecoration(labelText: 'Daily API Request Limit (0 for Unlimited)'),
                                keyboardType: TextInputType.number,
                                validator: (v) => v == null || int.tryParse(v) == null ? 'Invalid number' : null,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: monthlyTokensController,
                                decoration: const InputDecoration(labelText: 'Monthly Tokens Limit (0 for Unlimited)'),
                                keyboardType: TextInputType.number,
                                validator: (v) => v == null || int.tryParse(v) == null ? 'Invalid number' : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: maxUploadController,
                                decoration: const InputDecoration(labelText: 'Max Upload Size (MB)'),
                                keyboardType: TextInputType.number,
                                validator: (v) => v == null || int.tryParse(v) == null ? 'Invalid number' : null,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: maxDocsController,
                                decoration: const InputDecoration(labelText: 'Max Document Uploads'),
                                keyboardType: TextInputType.number,
                                validator: (v) => v == null || int.tryParse(v) == null ? 'Invalid number' : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: maxStoresController,
                                decoration: const InputDecoration(labelText: 'Max Store/E-commerce Connections'),
                                keyboardType: TextInputType.number,
                                validator: (v) => v == null || int.tryParse(v) == null ? 'Invalid number' : null,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: priorityQueueController,
                                decoration: const InputDecoration(labelText: 'Priority Queue (e.g. basic, high)'),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 32),

                        const Text(
                          'Allowed AI Models',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.cyan),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: allowedModelsController,
                          decoration: const InputDecoration(
                            labelText: 'Model IDs (comma separated)',
                            hintText: 'gpt-4o, gpt-4o-mini',
                          ),
                        ),
                        const Divider(height: 32),

                        const Text(
                          'Feature Gating & Access',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.cyan),
                        ),
                        const SizedBox(height: 12),
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          childAspectRatio: 5,
                          children: [
                            SwitchListTile(
                              title: const Text('General Chat'),
                              value: chat,
                              onChanged: (v) => setDialogState(() => chat = v),
                            ),
                            SwitchListTile(
                              title: const Text('Competitor Research'),
                              value: competitorResearch,
                              onChanged: (v) => setDialogState(() => competitorResearch = v),
                            ),
                            SwitchListTile(
                              title: const Text('SEO Optimizations'),
                              value: seoOptimizations,
                              onChanged: (v) => setDialogState(() => seoOptimizations = v),
                            ),
                            SwitchListTile(
                              title: const Text('Trend Analysis'),
                              value: trendAnalysis,
                              onChanged: (v) => setDialogState(() => trendAnalysis = v),
                            ),
                            SwitchListTile(
                              title: const Text('Marketing Strategy'),
                              value: marketingStrategy,
                              onChanged: (v) => setDialogState(() => marketingStrategy = v),
                            ),
                            SwitchListTile(
                              title: const Text('Content Gen Suite'),
                              value: contentGenerationSuite,
                              onChanged: (v) => setDialogState(() => contentGenerationSuite = v),
                            ),
                            SwitchListTile(
                              title: const Text('Custom Knowledge Base'),
                              value: customKnowledgeBase,
                              onChanged: (v) => setDialogState(() => customKnowledgeBase = v),
                            ),
                            SwitchListTile(
                              title: const Text('API Token Access'),
                              value: apiAccess,
                              onChanged: (v) => setDialogState(() => apiAccess = v),
                            ),
                            SwitchListTile(
                              title: const Text('White Labeling'),
                              value: whiteLabel,
                              onChanged: (v) => setDialogState(() => whiteLabel = v),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      final allowedModelsList = allowedModelsController.text
                          .split(',')
                          .map((e) => e.trim())
                          .where((e) => e.isNotEmpty)
                          .toList();

                      final updatePayload = {
                        'pricing': {
                          'monthlyUsd': double.parse(monthlyController.text),
                          'annualUsd': double.parse(annualController.text),
                          'stripePriceIdMonthly': stripeMonthlyController.text,
                          'stripePriceIdAnnual': stripeAnnualController.text,
                        },
                        'limits': {
                          'dailyRequests': int.parse(dailyRequestsController.text),
                          'monthlyTokens': int.parse(monthlyTokensController.text),
                          'maxUploadSizeMb': int.parse(maxUploadController.text),
                          'maxDocumentUploads': int.parse(maxDocsController.text),
                          'maxStoreCount': int.parse(maxStoresController.text),
                          'priorityQueue': priorityQueueController.text,
                        },
                        'features': {
                          'chat': chat,
                          'competitorResearch': competitorResearch,
                          'seoOptimizations': seoOptimizations,
                          'trendAnalysis': trendAnalysis,
                          'marketingStrategy': marketingStrategy,
                          'contentGenerationSuite': contentGenerationSuite,
                          'customKnowledgeBase': customKnowledgeBase,
                          'apiAccess': apiAccess,
                          'whiteLabel': whiteLabel,
                        },
                        'allowedModels': allowedModelsList,
                      };

                      try {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) => const Center(child: CircularProgressIndicator()),
                        );
                        
                        await SubscriptionsService.updatePlan(plan.id, updatePayload);
                        
                        if (context.mounted) Navigator.pop(context);
                        if (context.mounted) Navigator.pop(context);
                        
                        _loadPlans();

                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Plan "${plan.name}" updated successfully!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) Navigator.pop(context);
                        
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error updating plan: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    }
                  },
                  child: const Text('Save Changes'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;

  const _StatCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 16),
              Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 28, color: Colors.green)),
            ],
          ),
        ),
      ),
    );
  }
}
