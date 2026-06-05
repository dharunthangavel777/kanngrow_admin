import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'ai_management_service.dart';
import '../../core/theme.dart';

class AiManagementScreen extends StatefulWidget {
  const AiManagementScreen({super.key});

  @override
  State<AiManagementScreen> createState() => _AiManagementScreenState();
}

class _AiManagementScreenState extends State<AiManagementScreen> {
  final AiManagementService _service = AiManagementService();
  AiUsageReport? _report;
  bool _loading = true;
  String? _error;
  int _selectedDays = 30;

  // Live optimization settings state
  int _historyLimit = 6;
  double _tokensMultiplier = 1.0;
  bool _tierDown = false;
  bool _savingSettings = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final report = await _service.getUsageStats(days: _selectedDays);
      setState(() {
        _report = report;
        _loading = false;
        _historyLimit = report.currentSettings.maxHistoryLimit;
        _tokensMultiplier = report.currentSettings.maxTokensMultiplier;
        _tierDown = report.currentSettings.tierDownModel;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _saveSettings() async {
    setState(() {
      _savingSettings = true;
    });
    try {
      await _service.updateSettings(
        maxHistoryLimit: _historyLimit,
        maxTokensMultiplier: _tokensMultiplier,
        tierDownModel: _tierDown,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('OpenAI settings applied successfully!'),
            backgroundColor: AdminTheme.successGreen,
          ),
        );
      }
      final report = await _service.getUsageStats(days: _selectedDays);
      if (mounted) {
        setState(() {
          _report = report;
          _savingSettings = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _savingSettings = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update settings: $e'),
            backgroundColor: AdminTheme.errorRed,
          ),
        );
      }
    }
  }

  String _formatNumber(int val) {
    final RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return val.toString().replaceAllMapped(reg, (match) => '${match[1]},');
  }

  String _formatCost(double cost) {
    if (cost == 0) return '\$0.00';
    if (cost < 0.01) return '\$${cost.toStringAsFixed(4)}';
    return '\$${cost.toStringAsFixed(2)}';
  }

  Widget _buildPeriodChip(int days, String label) {
    final isSelected = _selectedDays == days;
    return GestureDetector(
      onTap: () {
        if (isSelected) return;
        setState(() {
          _selectedDays = days;
        });
        _loadData();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AdminTheme.primaryBlue : AdminTheme.surfaceHighlight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AdminTheme.primaryBlue : AdminTheme.borderSubtle,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AdminTheme.textSecondary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OpenAI Cost Center'),
        actions: [
          Row(
            children: [
              _buildPeriodChip(7, '7 Days'),
              const SizedBox(width: 8),
              _buildPeriodChip(14, '14 Days'),
              const SizedBox(width: 8),
              _buildPeriodChip(30, '30 Days'),
              const SizedBox(width: 8),
              _buildPeriodChip(90, '90 Days'),
              const SizedBox(width: 16),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loading ? null : _loadData,
            tooltip: 'Refresh Stats',
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: _loading
          ? _buildLoadingWidget()
          : _error != null
              ? _buildErrorWidget()
              : _buildMainDashboard(),
    );
  }

  Widget _buildLoadingWidget() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AdminTheme.primaryBlue),
          SizedBox(height: 16),
          Text(
            'Aggregating Token Usage Logs...',
            style: TextStyle(color: AdminTheme.textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: AdminTheme.errorRed),
          const SizedBox(height: 16),
          Text('Error loading stats', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              _error ?? 'Unknown error',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AdminTheme.primaryBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainDashboard() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 1100;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSummaryCards(),
              const SizedBox(height: 24),
              if (isWide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildChartCard(),
                          const SizedBox(height: 24),
                          _buildFeatureBreakdownCard(),
                          const SizedBox(height: 24),
                          _buildMasterPlanCard(),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildPlatformControlsCard(),
                          const SizedBox(height: 24),
                          _buildModelDistributionCard(),
                          const SizedBox(height: 24),
                          _buildTopUsersCard(),
                        ],
                      ),
                    ),
                  ],
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPlatformControlsCard(),
                    const SizedBox(height: 24),
                    _buildChartCard(),
                    const SizedBox(height: 24),
                    _buildFeatureBreakdownCard(),
                    const SizedBox(height: 24),
                    _buildModelDistributionCard(),
                    const SizedBox(height: 24),
                    _buildTopUsersCard(),
                    const SizedBox(height: 24),
                    _buildMasterPlanCard(),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryCards() {
    final summary = _report!.summary;
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: MediaQuery.of(context).size.width > 1200
          ? 4
          : (MediaQuery.of(context).size.width > 600 ? 2 : 1),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: MediaQuery.of(context).size.width > 600 ? 1.8 : 2.5,
      children: [
        _buildSummaryCard(
          'Total Cost (Est)',
          _formatCost(summary.totalCost),
          Icons.monetization_on_outlined,
          AdminTheme.successGreen,
        ),
        _buildSummaryCard(
          'Total Tokens',
          _formatNumber(summary.totalTokens),
          Icons.generating_tokens_outlined,
          AdminTheme.primaryBlue,
        ),
        _buildSummaryCard(
          'API Call Count',
          _formatNumber(summary.totalCalls),
          Icons.api_outlined,
          AdminTheme.accentPurple,
        ),
        _buildSummaryCard(
          'Avg Tokens / Call',
          _formatNumber(summary.avgTokensPerCall),
          Icons.speed_outlined,
          AdminTheme.warningOrange,
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: AdminTheme.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(icon, color: color, size: 22),
              ],
            ),
            const SizedBox(height: 12),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: const TextStyle(
                  color: AdminTheme.textPrimary,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Daily OpenAI Expenses',
                  style: TextStyle(
                    color: AdminTheme.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Last $_selectedDays Days',
                  style: const TextStyle(
                    color: AdminTheme.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 260,
              child: _CostChart(points: _report!.dailyChart, formatter: _formatNumber),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureBreakdownCard() {
    final totalCost = _report!.summary.totalCost;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Feature Breakdown',
              style: TextStyle(
                color: AdminTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (_report!.featureBreakdown.isEmpty)
              const Text('No feature telemetry recorded yet.')
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _report!.featureBreakdown.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final item = _report!.featureBreakdown[index];
                  final percentage = totalCost > 0 ? (item.cost / totalCost) * 100 : 0.0;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AdminTheme.primaryBlue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            _getFeatureIcon(item.feature),
                            color: AdminTheme.primaryBlue,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _formatFeatureName(item.feature),
                                style: const TextStyle(
                                  color: AdminTheme.textPrimary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${_formatNumber(item.calls)} calls • ${_formatNumber(item.tokens)} tokens',
                                style: const TextStyle(
                                  color: AdminTheme.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              _formatCost(item.cost),
                              style: const TextStyle(
                                color: AdminTheme.textPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${percentage.toStringAsFixed(1)}%',
                              style: const TextStyle(
                                color: AdminTheme.successGreen,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlatformControlsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.tune, color: AdminTheme.primaryBlue, size: 24),
                SizedBox(width: 8),
                Text(
                  'Platform AI Controls',
                  style: TextStyle(
                    color: AdminTheme.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Configure live token minimization strategy:',
              style: TextStyle(color: AdminTheme.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 24),

            // History Limit
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Chat History Limit',
                  style: TextStyle(
                    color: AdminTheme.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '$_historyLimit turns',
                  style: const TextStyle(
                    color: AdminTheme.primaryBlue,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'Limits conversation history payload sent to OpenAI API.',
              style: TextStyle(color: AdminTheme.textSecondary, fontSize: 12),
            ),
            Slider(
              value: _historyLimit.toDouble(),
              min: 1,
              max: 20,
              divisions: 19,
              label: '$_historyLimit turns',
              activeColor: AdminTheme.primaryBlue,
              inactiveColor: AdminTheme.surfaceHighlight,
              onChanged: (val) {
                setState(() {
                  _historyLimit = val.round();
                });
              },
            ),
            const Divider(height: 24),

            // Max Tokens Multiplier
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Max Output Multiplier',
                  style: TextStyle(
                    color: AdminTheme.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '${_tokensMultiplier.toStringAsFixed(2)}x',
                  style: const TextStyle(
                    color: AdminTheme.primaryBlue,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'Scales completion token limits (reduces output size).',
              style: TextStyle(color: AdminTheme.textSecondary, fontSize: 12),
            ),
            Slider(
              value: _tokensMultiplier,
              min: 0.1,
              max: 2.0,
              divisions: 38,
              label: '${_tokensMultiplier.toStringAsFixed(2)}x',
              activeColor: AdminTheme.primaryBlue,
              inactiveColor: AdminTheme.surfaceHighlight,
              onChanged: (val) {
                setState(() {
                  _tokensMultiplier = double.parse(val.toStringAsFixed(2));
                });
              },
            ),
            const Divider(height: 24),

            // Force Economy Switch
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Force Economy Model',
                        style: TextStyle(
                          color: AdminTheme.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _tierDown ? 'Forces cheap gpt-4o-mini' : 'Allows default model routing',
                        style: const TextStyle(color: AdminTheme.textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _tierDown,
                  activeColor: AdminTheme.successGreen,
                  activeTrackColor: AdminTheme.successGreen.withOpacity(0.3),
                  onChanged: (val) {
                    setState(() {
                      _tierDown = val;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _savingSettings ? null : _saveSettings,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AdminTheme.primaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _savingSettings
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Apply Optimization Strategy',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModelDistributionCard() {
    final dists = _report!.modelDistribution;
    final colors = [
      AdminTheme.primaryBlue,
      AdminTheme.accentPurple,
      AdminTheme.successGreen,
      AdminTheme.warningOrange,
      Colors.teal,
    ];
    final totalCalls = dists.fold<int>(0, (sum, d) => sum + d.calls);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Model Usage Distribution',
              style: TextStyle(
                color: AdminTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            if (dists.isEmpty)
              const SizedBox(
                height: 180,
                child: Center(child: Text('No model distribution telemetry')),
              )
            else
              Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: SizedBox(
                      height: 160,
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 2,
                          centerSpaceRadius: 28,
                          sections: List.generate(dists.length, (index) {
                            final dist = dists[index];
                            final pct = totalCalls > 0 ? (dist.calls / totalCalls) * 100 : 0.0;
                            final color = colors[index % colors.length];
                            return PieChartSectionData(
                              color: color,
                              value: dist.calls.toDouble(),
                              title: '${pct.toStringAsFixed(0)}%',
                              radius: 44,
                              titleStyle: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            );
                          }),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(dists.length, (index) {
                        final dist = dists[index];
                        final color = colors[index % colors.length];
                        final pct = totalCalls > 0 ? (dist.calls / totalCalls) * 100 : 0.0;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                           child: Row(
                             children: [
                               Container(
                                 width: 10,
                                 height: 10,
                                 decoration: BoxDecoration(
                                   color: color,
                                   shape: BoxShape.circle,
                                 ),
                               ),
                               const SizedBox(width: 8),
                               Expanded(
                                 child: Text(
                                   '${dist.model} (${pct.toStringAsFixed(0)}%)',
                                   style: const TextStyle(
                                     color: AdminTheme.textPrimary,
                                     fontSize: 12,
                                     fontWeight: FontWeight.w500,
                                   ),
                                   overflow: TextOverflow.ellipsis,
                                 ),
                               ),
                             ],
                           ),
                         );
                       }),
                     ),
                   ),
                 ],
               ),
           ],
         ),
       ),
     );
   }

   Widget _buildTopUsersCard() {
     return Card(
       child: Padding(
         padding: const EdgeInsets.all(20.0),
         child: Column(
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
             const Text(
               'Top OpenAI Consumers',
               style: TextStyle(
                 color: AdminTheme.textPrimary,
                 fontSize: 18,
                 fontWeight: FontWeight.bold,
               ),
             ),
             const SizedBox(height: 16),
             if (_report!.topUsers.isEmpty)
               const Text('No user usage logged yet.')
             else
               ListView.separated(
                 shrinkWrap: true,
                 physics: const NeverScrollableScrollPhysics(),
                 itemCount: _report!.topUsers.length,
                 separatorBuilder: (context, index) => const Divider(),
                 itemBuilder: (context, index) {
                   final u = _report!.topUsers[index];
                   final truncatedUid = u.uid.startsWith('demo_user_')
                       ? u.uid.replaceAll('demo_user_', 'Demo User #')
                       : (u.uid.length > 8 ? '${u.uid.substring(0, 8)}...' : u.uid);
                   return Padding(
                     padding: const EdgeInsets.symmetric(vertical: 8.0),
                     child: Row(
                       children: [
                         const CircleAvatar(
                           radius: 14,
                           backgroundColor: AdminTheme.surfaceHighlight,
                           child: Icon(Icons.person, size: 14, color: AdminTheme.textSecondary),
                         ),
                         const SizedBox(width: 12),
                         Expanded(
                           child: Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                             children: [
                               Text(
                                 truncatedUid,
                                 style: const TextStyle(
                                   color: AdminTheme.textPrimary,
                                   fontWeight: FontWeight.bold,
                                   fontSize: 13,
                                 ),
                               ),
                               const SizedBox(height: 2),
                               Text(
                                 '${_formatNumber(u.calls)} calls • ${_formatNumber(u.tokens)} tokens',
                                 style: const TextStyle(
                                   color: AdminTheme.textSecondary,
                                   fontSize: 11,
                                 ),
                               ),
                             ],
                           ),
                         ),
                         Text(
                           _formatCost(u.cost),
                           style: const TextStyle(
                             color: AdminTheme.errorRed,
                             fontWeight: FontWeight.bold,
                             fontSize: 13,
                           ),
                         ),
                       ],
                     ),
                   );
                 },
               ),
           ],
         ),
       ),
     );
   }

  Widget _buildMasterPlanCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.auto_awesome, color: AdminTheme.warningOrange, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'Master Plan for Extreme Token Reduction',
                  style: TextStyle(
                    color: AdminTheme.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Architectural strategies to minimize OpenAI API key costs by up to 80%:',
              style: TextStyle(color: AdminTheme.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 16),
            _buildMasterPlanItem(
              '1. Programmatic Pre-Routing',
              'Saves ~100% of Router tokens on clicks',
              'Skip the AI intent router when users click direct action buttons (e.g. "Validate Idea"). Route the command directly from client-side handlers.',
              Icons.alt_route,
              AdminTheme.successGreen,
            ),
            const SizedBox(height: 12),
            _buildMasterPlanItem(
              '2. Semantic Caching Layer',
              'Saves 100% of tokens on cache hits',
              'Store finished product ideas, roadmaps, and vendor queries in local Firestore index caches. Serve matching queries directly from cache.',
              Icons.cached,
              AdminTheme.primaryBlue,
            ),
            const SizedBox(height: 12),
            _buildMasterPlanItem(
              '3. Intent-Driven Context Scoping',
              'Saves ~50% input tokens on chats',
              'Do not fetch and inject memory documents or RAG knowledge for simple statements (like greetings). Scope prompts dynamically.',
              Icons.filter_alt_outlined,
              AdminTheme.accentPurple,
            ),
            const SizedBox(height: 12),
            _buildMasterPlanItem(
              '4. Running Memory Summarization',
              'Saves ~70% history tokens on long chats',
              'Every 4 turns, compress old history messages into a one-paragraph summary. Send only the summary + last 2 turns raw.',
              Icons.compress,
              AdminTheme.warningOrange,
            ),
            const SizedBox(height: 12),
            _buildMasterPlanItem(
              '5. Prompt Schema Minification',
              'Saves ~30% completion tokens',
              'Minify JSON object keys inside system prompts (e.g., use "mkt" instead of "marketDemand"). Map keys back to labels on the client.',
              Icons.settings_ethernet,
              AdminTheme.errorRed,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMasterPlanItem(
    String title,
    String badge,
    String desc,
    IconData icon,
    Color badgeColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AdminTheme.surfaceHighlight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AdminTheme.borderSubtle, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: badgeColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: badgeColor, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AdminTheme.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: badgeColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: badgeColor.withOpacity(0.4), width: 1),
                      ),
                      child: Text(
                        badge,
                        style: TextStyle(
                          color: badgeColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  desc,
                  style: const TextStyle(
                    color: AdminTheme.textSecondary,
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatFeatureName(String raw) {
    switch (raw) {
      case 'chat':
        return 'General Chat';
      case 'validation':
        return 'Product Validation';
      case 'idea-generator':
        return 'Idea Generator';
      case 'business-planner':
        return 'Business Planner';
      case 'ai-router':
        return 'AI Router';
      case 'memory-extraction':
        return 'Memory Extraction';
      case 'onboarding':
        return 'Onboarding Engine';
      default:
        return raw[0].toUpperCase() + raw.substring(1).replaceAll('-', ' ');
    }
  }

  IconData _getFeatureIcon(String feature) {
    switch (feature) {
      case 'chat':
        return Icons.chat_bubble_outline;
      case 'validation':
        return Icons.verified_user_outlined;
      case 'idea-generator':
        return Icons.lightbulb_outline;
      case 'business-planner':
        return Icons.business_center_outlined;
      case 'ai-router':
        return Icons.router_outlined;
      case 'memory-extraction':
        return Icons.psychology_outlined;
      case 'onboarding':
        return Icons.hail_outlined;
      default:
        return Icons.code;
    }
  }
}

class _CostChart extends StatelessWidget {
  final List<DailyChartPoint> points;
  final String Function(int) formatter;

  const _CostChart({required this.points, required this.formatter});

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return const Center(child: Text('No daily cost data available'));
    }

    final double maxCost = points.map((p) => p.cost).reduce((a, b) => a > b ? a : b);
    final double maxVal = maxCost == 0 ? 1.0 : maxCost * 1.15;

    return BarChart(
      BarChartData(
        maxY: maxVal,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) {
            return const FlLine(
              color: AdminTheme.borderSubtle,
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 56,
              getTitlesWidget: (value, meta) {
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(
                    '\$${value.toStringAsFixed(3)}',
                    style: const TextStyle(
                      color: AdminTheme.textSecondary,
                      fontSize: 10,
                    ),
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final int index = value.toInt();
                if (index < 0 || index >= points.length) {
                  return const SizedBox.shrink();
                }

                int interval = (points.length / 6).ceil();
                if (interval < 1) interval = 1;
                if (index % interval != 0 && index != points.length - 1) {
                  return const SizedBox.shrink();
                }

                final dateStr = points[index].date;
                final displayDate = dateStr.length >= 10 ? dateStr.substring(5, 10) : dateStr;

                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(
                    displayDate,
                    style: const TextStyle(
                      color: AdminTheme.textSecondary,
                      fontSize: 10,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: const Border(
            bottom: BorderSide(color: AdminTheme.borderSubtle, width: 1),
            left: BorderSide(color: AdminTheme.borderSubtle, width: 1),
          ),
        ),
        barGroups: List.generate(
          points.length,
          (index) {
            final pt = points[index];
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: pt.cost,
                  color: AdminTheme.primaryBlue,
                  width: points.length > 30 ? 4 : (points.length > 14 ? 8 : 16),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                ),
              ],
            );
          },
        ),
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (group) => AdminTheme.surfaceHighlight,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final pt = points[group.x.toInt()];
              return BarTooltipItem(
                '${pt.date}\nCost: \$${pt.cost.toStringAsFixed(4)}\nTokens: ${formatter(pt.tokens)}\nCalls: ${pt.calls}',
                const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
              );
            },
          ),
        ),
      ),
    );
  }
}
