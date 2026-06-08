import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserDnaDashboardScreen extends StatefulWidget {
  const UserDnaDashboardScreen({super.key});

  @override
  State<UserDnaDashboardScreen> createState() => _UserDnaDashboardScreenState();
}

class _UserDnaDashboardScreenState extends State<UserDnaDashboardScreen> {
  String _selectedStageFilter = 'All';
  String _selectedLangFilter = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('user_dna').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading DNA metrics: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final docs = snapshot.data?.docs ?? [];
          final allDna = docs.map((d) => d.data() as Map<String, dynamic>).toList();

          // ── Metrics calculations ──
          final totalUsers = allDna.length;
          
          final langCounts = <String, int>{};
          final stageCounts = <String, int>{};
          final riskCounts = <String, int>{};
          final emotionCounts = <String, int>{};
          final nicheCounts = <String, int>{};
          double totalBudget = 0;
          int usersWithBudget = 0;

          for (final dna in allDna) {
            final lang = dna['language']?.toString() ?? 'unknown';
            langCounts[lang] = (langCounts[lang] ?? 0) + 1;

            final stage = dna['businessStage']?.toString() ?? 'unknown';
            stageCounts[stage] = (stageCounts[stage] ?? 0) + 1;

            final risk = dna['riskTolerance']?.toString() ?? 'unknown';
            riskCounts[risk] = (riskCounts[risk] ?? 0) + 1;

            final emotion = dna['emotionalState']?.toString() ?? 'unknown';
            emotionCounts[emotion] = (emotionCounts[emotion] ?? 0) + 1;

            final niche = dna['niche']?.toString() ?? 'none';
            if (niche != 'none') {
              nicheCounts[niche] = (nicheCounts[niche] ?? 0) + 1;
            }

            final budgetVal = dna['budget'];
            if (budgetVal != null) {
              final budget = double.tryParse(budgetVal.toString()) ?? 0;
              if (budget > 0) {
                totalBudget += budget;
                usersWithBudget++;
              }
            }
          }

          final avgBudget = usersWithBudget > 0 ? totalBudget / usersWithBudget : 0.0;

          // ── Filtered user list ──
          final filteredDna = allDna.where((dna) {
            if (_selectedStageFilter != 'All' &&
                (dna['businessStage']?.toString() ?? 'unknown').toLowerCase() != _selectedStageFilter.toLowerCase()) {
              return false;
            }
            if (_selectedLangFilter != 'All' &&
                (dna['language']?.toString() ?? 'unknown').toLowerCase() != _selectedLangFilter.toLowerCase()) {
              return false;
            }
            return true;
          }).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  'User DNA Insights',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 28),
                ),
                const SizedBox(height: 4),
                Text(
                  'Real-time behavioral intelligence and demographic breakdowns of Kanngrow AI users',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),

                // Core Stats Summary Cards
                Row(
                  children: [
                    _buildSummaryCard(
                      title: 'Total Profiles Analyzed',
                      value: totalUsers.toString(),
                      icon: Icons.analytics,
                      color: Colors.indigo,
                    ),
                    const SizedBox(width: 16),
                    _buildSummaryCard(
                      title: 'Avg. Founder Budget',
                      value: avgBudget > 0
                          ? '₹${(avgBudget / 1000).toStringAsFixed(1)}K'
                          : '₹0',
                      icon: Icons.account_balance_wallet_outlined,
                      color: Colors.teal,
                    ),
                    const SizedBox(width: 16),
                    _buildSummaryCard(
                      title: 'Top Business Stage',
                      value: _getTopKey(stageCounts).toUpperCase(),
                      icon: Icons.rocket_launch_outlined,
                      color: Colors.orange,
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // DNA Dimension Breakdowns
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Languages & Stages
                    Expanded(
                      child: Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey[200]!),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Languages Spoken', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 16),
                              if (langCounts.isEmpty)
                                const Text('No language data available.', style: TextStyle(color: Colors.grey))
                              else
                                ...langCounts.entries.map((e) => _buildDistributionRow(e.key, e.value, totalUsers, Colors.blue)),
                              const SizedBox(height: 24),
                              const Text('Startup Stages', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 16),
                              if (stageCounts.isEmpty)
                                const Text('No business stage data available.', style: TextStyle(color: Colors.grey))
                              else
                                ...stageCounts.entries.map((e) => _buildDistributionRow(e.key, e.value, totalUsers, Colors.orange)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    // Emotional States & Niches
                    Expanded(
                      child: Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey[200]!),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Emotional States', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 16),
                              if (emotionCounts.isEmpty)
                                const Text('No emotion data available.', style: TextStyle(color: Colors.grey))
                              else
                                ...emotionCounts.entries.map((e) => _buildDistributionRow(e.key, e.value, totalUsers, Colors.purple)),
                              const SizedBox(height: 24),
                              const Text('Hot Niches & Topics', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 16),
                              if (nicheCounts.isEmpty)
                                const Text('No niche data available.', style: TextStyle(color: Colors.grey))
                              else
                                ...nicheCounts.entries.map((e) => _buildDistributionRow(e.key, e.value, totalUsers, Colors.teal)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Filters Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Individual User DNA Directory',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        // Stage Filter
                        DropdownButton<String>(
                          value: _selectedStageFilter,
                          items: ['All', 'Idea', 'Validating', 'Starting', 'Growing']
                              .map((s) => DropdownMenuItem(value: s, child: Text('Stage: $s')))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _selectedStageFilter = val;
                              });
                            }
                          },
                        ),
                        const SizedBox(width: 16),
                        // Language Filter
                        DropdownButton<String>(
                          value: _selectedLangFilter,
                          items: ['All', 'English', 'Tamil', 'Tanglish', 'Hindi', 'Hinglish']
                              .map((s) => DropdownMenuItem(value: s, child: Text('Lang: $s')))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _selectedLangFilter = val;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Individual DNA Records list
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey[200]!),
                  ),
                  child: filteredDna.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(32.0),
                          child: Center(child: Text('No users match the selected DNA filters.')),
                        )
                      : DataTable(
                          columnSpacing: 16,
                          columns: const [
                            DataColumn(label: Text('User ID')),
                            DataColumn(label: Text('Language')),
                            DataColumn(label: Text('Location')),
                            DataColumn(label: Text('Stage')),
                            DataColumn(label: Text('Budget')),
                            DataColumn(label: Text('Niche')),
                            DataColumn(label: Text('Risk')),
                            DataColumn(label: Text('State of Mind')),
                            DataColumn(label: Text('Active')),
                          ],
                          rows: filteredDna.map((dna) {
                            final uid = dna['uid']?.toString() ?? 'anonymous';
                            final lang = dna['language']?.toString() ?? 'english';
                            final state = dna['state']?.toString() ?? 'unknown';
                            final stage = dna['businessStage']?.toString() ?? 'idea';
                            final budgetLabel = dna['budgetLabel']?.toString() ?? '₹0';
                            final niche = dna['niche']?.toString() ?? 'none';
                            final risk = dna['riskTolerance']?.toString() ?? 'low';
                            final emotionalState = dna['emotionalState']?.toString() ?? 'researching';
                            final totalMsgs = dna['totalMessages']?.toString() ?? '0';

                            return DataRow(
                              cells: [
                                DataCell(
                                  Text(
                                    uid.length > 8 ? '${uid.substring(0, 8)}...' : uid,
                                    style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
                                  ),
                                ),
                                DataCell(_buildBadge(lang, Colors.blue)),
                                DataCell(Text(state)),
                                DataCell(_buildBadge(stage, Colors.orange)),
                                DataCell(Text(budgetLabel, style: const TextStyle(fontWeight: FontWeight.bold))),
                                DataCell(Text(niche)),
                                DataCell(_buildBadge(risk, Colors.redAccent)),
                                DataCell(_buildBadge(emotionalState, Colors.purple)),
                                DataCell(Text('$totalMsgs msgs', style: const TextStyle(fontSize: 12))),
                              ],
                            );
                          }).toList(),
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.15)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(color: Colors.grey[700], fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDistributionRow(String label, int count, int total, Color color) {
    final pct = total > 0 ? count / total : 0.0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
              Text('$count (${(pct * 100).toStringAsFixed(0)}%)',
                  style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct,
              backgroundColor: Colors.grey[100],
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  String _getTopKey(Map<String, int> map) {
    if (map.isEmpty) return 'none';
    var maxVal = -1;
    var maxKey = 'none';
    map.forEach((k, v) {
      if (v > maxVal) {
        maxVal = v;
        maxKey = k;
      }
    });
    return maxKey;
  }
}
