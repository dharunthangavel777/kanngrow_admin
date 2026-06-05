import 'package:flutter/material.dart';
import 'knowledge_service.dart';

class KnowledgeManagerScreen extends StatefulWidget {
  const KnowledgeManagerScreen({super.key});

  @override
  State<KnowledgeManagerScreen> createState() => _KnowledgeManagerScreenState();
}

class _KnowledgeManagerScreenState extends State<KnowledgeManagerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  bool _isSyncing = false;

  List<dynamic> _ideas = [];
  List<dynamic> _vendors = [];
  List<dynamic> _schemes = [];
  List<dynamic> _marketReports = [];
  Map<String, dynamic> _stats = {
    'totalIdeas': 0,
    'totalVendors': 0,
    'totalSchemes': 0,
    'totalReports': 0
  };

  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_handleTabSelection);
    _fetchData();
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _searchQuery = '';
      });
    }
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final stats = await KnowledgeService.getStats();
      final ideas = await KnowledgeService.getIdeas();
      final vendors = await KnowledgeService.getVendors();
      final schemes = await KnowledgeService.getSchemes();
      final reports = await KnowledgeService.getMarketReports();

      setState(() {
        _stats = stats;
        _ideas = ideas;
        _vendors = vendors;
        _schemes = schemes;
        _marketReports = reports;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _handleImportLocalHtml() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final result = await KnowledgeService.importLocalHtml();
      setState(() {
        _isLoading = false;
      });
      _fetchData();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Successfully imported: '
              '${result['ideasCount']} Ideas, '
              '${result['vendorsCount']} Vendors, '
              '${result['schemesCount']} Schemes, '
              '${result['reportsCount']} Reports!'
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to import local HTML: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleSyncWebsite() async {
    setState(() {
      _isSyncing = true;
    });
    try {
      final result = await KnowledgeService.syncFromWebsite();
      setState(() {
        _isSyncing = false;
      });
      _fetchData();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Successfully synced website: '
              '${result['ideasCount']} Ideas, '
              '${result['vendorsCount']} Vendors, '
              '${result['schemesCount']} Schemes, '
              '${result['reportsCount']} Reports!'
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isSyncing = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to sync website: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header section
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Knowledge Base Manager',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 28),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Manage proprietary data powering Kangrow Co-Founder AI (RAG)',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _handleImportLocalHtml,
                      icon: const Icon(Icons.file_download, size: 18),
                      label: const Text('Import HTML Data'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: _isSyncing ? null : _handleSyncWebsite,
                      icon: _isSyncing
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.sync, size: 18),
                      label: Text(_isSyncing ? 'Syncing...' : 'Sync Website Docs'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: _showAddDialog,
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add Entry'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Stats row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _MiniStatCard(
                  title: 'Business Ideas',
                  value: _stats['totalIdeas'].toString(),
                  icon: Icons.lightbulb_outline,
                  color: Colors.amber,
                ),
                _MiniStatCard(
                  title: 'Verified Vendors',
                  value: _stats['totalVendors'].toString(),
                  icon: Icons.storefront,
                  color: Colors.blue,
                ),
                _MiniStatCard(
                  title: 'Govt Schemes',
                  value: _stats['totalSchemes'].toString(),
                  icon: Icons.gavel,
                  color: Colors.green,
                ),
                _MiniStatCard(
                  title: 'Market Reports',
                  value: _stats['totalReports'].toString(),
                  icon: Icons.trending_up,
                  color: Colors.purple,
                ),
              ],
            ),
          ),

          // Search and Tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    indicatorColor: Theme.of(context).primaryColor,
                    labelColor: Theme.of(context).primaryColor,
                    unselectedLabelColor: Colors.grey,
                    tabs: const [
                      Tab(text: 'Ideas'),
                      Tab(text: 'Vendors'),
                      Tab(text: 'Govt Schemes'),
                      Tab(text: 'Market Reports'),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                SizedBox(
                  width: 300,
                  height: 40,
                  child: TextField(
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      prefixIcon: const Icon(Icons.search, size: 18),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(),

          // Main lists
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildIdeasTab(),
                      _buildVendorsTab(),
                      _buildSchemesTab(),
                      _buildReportsTab(),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  // ── IDEAS TAB ──

  Widget _buildIdeasTab() {
    final filtered = _ideas.where((idea) {
      final name = (idea['name'] ?? '').toString().toLowerCase();
      final cat = (idea['category'] ?? '').toString().toLowerCase();
      return name.contains(_searchQuery.toLowerCase()) || cat.contains(_searchQuery.toLowerCase());
    }).toList();

    if (filtered.isEmpty) return _buildEmptyState('No business ideas found');

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: filtered.length,
      itemBuilder: (context, idx) {
        final idea = filtered[idx];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ExpansionTile(
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    idea['category'] ?? 'N/A',
                    style: const TextStyle(color: Colors.amber, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  idea['name'] ?? 'Untitled Idea',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const Spacer(),
                Text(
                  'Score: ${idea['kangrowScore'] ?? 0}/100',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                'Investment: ₹${(idea['investmentMin'] ?? 0).toString()} - ₹${(idea['investmentMax'] ?? 0).toString()} | Margins: ${idea['profitMarginMin']}%-${idea['profitMarginMax']}%',
                style: const TextStyle(fontSize: 13),
              ),
            ),
            childrenPadding: const EdgeInsets.all(20),
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      idea['description'] ?? 'No description provided.',
                      style: const TextStyle(color: Colors.white70, height: 1.4),
                    ),
                    const SizedBox(height: 16),
                    _buildTagsSection('Target States', List<String>.from(idea['targetStates'] ?? [])),
                    _buildTagsSection('Required Docs', List<String>.from(idea['requiredDocuments'] ?? [])),
                    _buildTagsSection('Sourcing Options', List<String>.from(idea['sourcingOptions'] ?? [])),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _editIdea(idea),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _confirmDelete('ideas', idea['id']),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }

  // ── VENDORS TAB ──

  Widget _buildVendorsTab() {
    final filtered = _vendors.where((vendor) {
      final name = (vendor['name'] ?? '').toString().toLowerCase();
      final cat = (vendor['category'] ?? '').toString().toLowerCase();
      return name.contains(_searchQuery.toLowerCase()) || cat.contains(_searchQuery.toLowerCase());
    }).toList();

    if (filtered.isEmpty) return _buildEmptyState('No suppliers/vendors found');

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: filtered.length,
      itemBuilder: (context, idx) {
        final vendor = filtered[idx];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ListTile(
            contentPadding: const EdgeInsets.all(20),
            title: Row(
              children: [
                Text(vendor['name'] ?? 'Unknown Vendor', style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 12),
                if (vendor['verifiedByKangrow'] == true)
                  const Tooltip(
                    message: 'Verified by Kangrow',
                    child: Icon(Icons.verified, color: Colors.green, size: 16),
                  ),
                const Spacer(),
                Row(
                  children: List.generate(5, (starIdx) {
                    return Icon(
                      Icons.star,
                      size: 14,
                      color: starIdx < (vendor['rating'] ?? 0) ? Colors.orange : Colors.grey,
                    );
                  }),
                ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text('Category: ${vendor['category'] ?? "N/A"} | Sourcing: ${vendor['type'] ?? "Both"}'),
                const SizedBox(height: 4),
                Text('Location: ${vendor['location'] ?? "Pan India"} | Min Order: ₹${(vendor['minOrderValue'] ?? 0).toString()}'),
                if (vendor['description'] != null) ...[
                  const SizedBox(height: 8),
                  Text(vendor['description'], style: const TextStyle(color: Colors.white70)),
                ]
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => _editVendor(vendor),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _confirmDelete('vendors', vendor['id']),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── GOVT SCHEMES TAB ──

  Widget _buildSchemesTab() {
    final filtered = _schemes.where((s) {
      final name = (s['name'] ?? '').toString().toLowerCase();
      final dept = (s['department'] ?? '').toString().toLowerCase();
      return name.contains(_searchQuery.toLowerCase()) || dept.contains(_searchQuery.toLowerCase());
    }).toList();

    if (filtered.isEmpty) return _buildEmptyState('No government schemes found');

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: filtered.length,
      itemBuilder: (context, idx) {
        final scheme = filtered[idx];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ExpansionTile(
            title: Row(
              children: [
                Text(
                  scheme['name'] ?? 'Scheme Title',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const Spacer(),
                Text(
                  scheme['department'] ?? 'MSME',
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(scheme['fullName'] ?? ''),
            ),
            childrenPadding: const EdgeInsets.all(20),
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(scheme['description'] ?? 'No description.'),
                    const SizedBox(height: 16),
                    _buildTagsSection('Benefits', List<String>.from(scheme['benefits'] ?? [])),
                    _buildTagsSection('Eligibility', List<String>.from(scheme['eligibility'] ?? [])),
                    _buildTagsSection('Documents Required', List<String>.from(scheme['documentRequired'] ?? [])),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _editScheme(scheme),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _confirmDelete('schemes', scheme['id']),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }

  // ── MARKET REPORTS TAB ──

  Widget _buildReportsTab() {
    final filtered = _marketReports.where((r) {
      final title = (r['title'] ?? '').toString().toLowerCase();
      final category = (r['category'] ?? '').toString().toLowerCase();
      return title.contains(_searchQuery.toLowerCase()) || category.contains(_searchQuery.toLowerCase());
    }).toList();

    if (filtered.isEmpty) return _buildEmptyState('No market intelligence reports found');

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: filtered.length,
      itemBuilder: (context, idx) {
        final report = filtered[idx];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ListTile(
            contentPadding: const EdgeInsets.all(20),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getReportColor(report['type']).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    report['type'] ?? 'Trending',
                    style: TextStyle(color: _getReportColor(report['type']), fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    report['title'] ?? 'Market Opportunity',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  'Score: ${report['opportunityScore'] ?? 0}/100',
                  style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text('Category: ${report['category'] ?? "N/A"} | Budget: ${report['investmentRange'] ?? "All"}'),
                const SizedBox(height: 6),
                Text(report['summary'] ?? '', style: const TextStyle(color: Colors.white70)),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => _editReport(report),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _confirmDelete('market', report['id']),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getReportColor(String? type) {
    switch (type) {
      case 'Trending':
        return Colors.green;
      case 'Seasonal':
        return Colors.amber;
      case 'Emerging':
        return Colors.purple;
      case 'Declining':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildEmptyState(String msg) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_open, size: 64, color: Colors.grey.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text(msg, style: const TextStyle(color: Colors.grey, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildTagsSection(String title, List<String> tags) {
    if (tags.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$title: ', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
          Expanded(
            child: Wrap(
              spacing: 6,
              runSpacing: 4,
              children: tags.map((t) => Chip(
                label: Text(t, style: const TextStyle(fontSize: 10)),
                padding: EdgeInsets.zero,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ── DIALOG TRIGGER ──

  void _showAddDialog() {
    switch (_tabController.index) {
      case 0:
        _showIdeaDialog(null);
        break;
      case 1:
        _showVendorDialog(null);
        break;
      case 2:
        _showSchemeDialog(null);
        break;
      case 3:
        _showReportDialog(null);
        break;
    }
  }

  void _editIdea(dynamic idea) => _showIdeaDialog(idea);
  void _editVendor(dynamic vendor) => _showVendorDialog(vendor);
  void _editScheme(dynamic scheme) => _showSchemeDialog(scheme);
  void _editReport(dynamic report) => _showReportDialog(report);

  // ── DELETE CONFIRMATION ──

  void _confirmDelete(String collection, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deactivation'),
        content: const Text('Are you sure you want to soft-delete/deactivate this item? it will no longer be visible or used in RAG contexts.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              setState(() => _isLoading = true);
              try {
                if (collection == 'ideas') {
                  await KnowledgeService.deleteIdea(id);
                } else if (collection == 'vendors') {
                  await KnowledgeService.deleteVendor(id);
                } else if (collection == 'schemes') {
                  await KnowledgeService.deleteScheme(id);
                } else if (collection == 'market') {
                  await KnowledgeService.deleteMarketReport(id);
                }
                _fetchData();
              } catch (e) {
                setState(() => _isLoading = false);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Delete failed: $e'), backgroundColor: Colors.red),
                );
              }
            },
            child: const Text('Deactivate', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // ── BUSINESS IDEA FORM DIALOG ──

  void _showIdeaDialog(dynamic existing) {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController(text: existing?['name']);
    final catCtrl = TextEditingController(text: existing?['category']);
    final descCtrl = TextEditingController(text: existing?['description']);
    final invMinCtrl = TextEditingController(text: existing?['investmentMin']?.toString());
    final invMaxCtrl = TextEditingController(text: existing?['investmentMax']?.toString());
    final margMinCtrl = TextEditingController(text: existing?['profitMarginMin']?.toString());
    final margMaxCtrl = TextEditingController(text: existing?['profitMarginMax']?.toString());
    final mktSizeCtrl = TextEditingController(text: existing?['marketSize']);
    final audCtrl = TextEditingController(text: existing?['targetAudience']);
    final scoreCtrl = TextEditingController(text: existing?['kangrowScore']?.toString() ?? '80');

    // List fields (comma separated)
    final statesCtrl = TextEditingController(text: (existing?['targetStates'] as List?)?.join(', '));
    final docsCtrl = TextEditingController(text: (existing?['requiredDocuments'] as List?)?.join(', '));
    final sourcesCtrl = TextEditingController(text: (existing?['sourcingOptions'] as List?)?.join(', '));
    final successCtrl = TextEditingController(text: (existing?['keySuccessFactors'] as List?)?.join(', '));
    final challengesCtrl = TextEditingController(text: (existing?['challenges'] as List?)?.join(', '));

    String demand = existing?['demandLevel'] ?? 'Medium';
    String competition = existing?['competitionLevel'] ?? 'Medium';
    String risk = existing?['riskLevel'] ?? 'Medium';

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600, maxHeight: 800),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      existing == null ? 'Add Business Idea' : 'Edit Business Idea',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(labelText: 'Idea Name*', hintText: 'Textile Reseller'),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: catCtrl,
                      decoration: const InputDecoration(labelText: 'Category*', hintText: 'Fashion & Apparel'),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: descCtrl,
                      decoration: const InputDecoration(labelText: 'Description*'),
                      maxLines: 3,
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: invMinCtrl,
                            decoration: const InputDecoration(labelText: 'Min Investment (₹)*'),
                            keyboardType: TextInputType.number,
                            validator: (v) => v!.isEmpty ? 'Required' : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: invMaxCtrl,
                            decoration: const InputDecoration(labelText: 'Max Investment (₹)*'),
                            keyboardType: TextInputType.number,
                            validator: (v) => v!.isEmpty ? 'Required' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: margMinCtrl,
                            decoration: const InputDecoration(labelText: 'Min Margin (%)*'),
                            keyboardType: TextInputType.number,
                            validator: (v) => v!.isEmpty ? 'Required' : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: margMaxCtrl,
                            decoration: const InputDecoration(labelText: 'Max Margin (%)*'),
                            keyboardType: TextInputType.number,
                            validator: (v) => v!.isEmpty ? 'Required' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: mktSizeCtrl,
                            decoration: const InputDecoration(labelText: 'Market Size', hintText: '₹500 Cr'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: scoreCtrl,
                            decoration: const InputDecoration(labelText: 'Kangrow Score (0-100)*'),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: demand,
                            decoration: const InputDecoration(labelText: 'Demand Level'),
                            items: ['Low', 'Medium', 'High', 'Very High'].map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
                            onChanged: (val) => demand = val!,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: competition,
                            decoration: const InputDecoration(labelText: 'Competition Level'),
                            items: ['Low', 'Medium', 'High'].map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
                            onChanged: (val) => competition = val!,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: risk,
                            decoration: const InputDecoration(labelText: 'Risk Level'),
                            items: ['Low', 'Medium', 'High'].map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
                            onChanged: (val) => risk = val!,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: audCtrl,
                      decoration: const InputDecoration(labelText: 'Target Audience'),
                    ),
                    const SizedBox(height: 16),
                    const Text('Lists (comma separated values)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: statesCtrl,
                      decoration: const InputDecoration(labelText: 'Target States (e.g. Karnataka, Tamil Nadu)'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: docsCtrl,
                      decoration: const InputDecoration(labelText: 'Required Documents (e.g. GST, PAN, MSME)'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: sourcesCtrl,
                      decoration: const InputDecoration(labelText: 'Sourcing Options (e.g. Alibaba, Indiamart)'),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: () async {
                            if (formKey.currentState!.validate()) {
                              final parsedData = {
                                'name': nameCtrl.text,
                                'category': catCtrl.text,
                                'description': descCtrl.text,
                                'investmentMin': int.parse(invMinCtrl.text),
                                'investmentMax': int.parse(invMaxCtrl.text),
                                'profitMarginMin': int.parse(margMinCtrl.text),
                                'profitMarginMax': int.parse(margMaxCtrl.text),
                                'marketSize': mktSizeCtrl.text,
                                'demandLevel': demand,
                                'competitionLevel': competition,
                                'riskLevel': risk,
                                'targetAudience': audCtrl.text,
                                'kangrowScore': int.tryParse(scoreCtrl.text) ?? 80,
                                'targetStates': statesCtrl.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList(),
                                'requiredDocuments': docsCtrl.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList(),
                                'sourcingOptions': sourcesCtrl.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList(),
                                'keySuccessFactors': successCtrl.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList(),
                                'challenges': challengesCtrl.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList(),
                                'growthPotential': '',
                                'tags': [catCtrl.text.toLowerCase()],
                              };
                              Navigator.pop(context);
                              setState(() => _isLoading = true);
                              try {
                                if (existing == null) {
                                  await KnowledgeService.createIdea(parsedData);
                                } else {
                                  await KnowledgeService.updateIdea(existing['id'], parsedData);
                                }
                                _fetchData();
                              } catch (e) {
                                setState(() => _isLoading = false);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Save failed: $e'), backgroundColor: Colors.red),
                                );
                              }
                            }
                          },
                          child: const Text('Save'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── VENDOR FORM DIALOG ──

  void _showVendorDialog(dynamic existing) {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController(text: existing?['name']);
    final catCtrl = TextEditingController(text: existing?['category']);
    final descCtrl = TextEditingController(text: existing?['description']);
    final webCtrl = TextEditingController(text: existing?['website']);
    final locCtrl = TextEditingController(text: existing?['location']);
    final minOrdCtrl = TextEditingController(text: existing?['minOrderValue']?.toString());
    final delCtrl = TextEditingController(text: existing?['deliveryDays']);
    final payCtrl = TextEditingController(text: existing?['paymentTerms']);
    final specCtrl = TextEditingController(text: (existing?['specialties'] as List?)?.join(', '));

    double rating = (existing?['rating'] ?? 4).toDouble();
    bool verified = existing?['verifiedByKangrow'] ?? true;
    String type = existing?['type'] ?? 'Both';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600, maxHeight: 800),
            child: Container(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        existing == null ? 'Add Vendor / Supplier' : 'Edit Vendor / Supplier',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: nameCtrl,
                        decoration: const InputDecoration(labelText: 'Vendor Name*', hintText: 'Indiamart Supplier'),
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: catCtrl,
                        decoration: const InputDecoration(labelText: 'Category*', hintText: 'Home Decor'),
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: descCtrl,
                        decoration: const InputDecoration(labelText: 'Description*'),
                        maxLines: 2,
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: webCtrl,
                        decoration: const InputDecoration(labelText: 'Website / Link'),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: locCtrl,
                              decoration: const InputDecoration(labelText: 'Location', hintText: 'New Delhi'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: minOrdCtrl,
                              decoration: const InputDecoration(labelText: 'Min Order Value (₹)'),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: delCtrl,
                              decoration: const InputDecoration(labelText: 'Delivery Days', hintText: '3-7 days'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: type,
                              decoration: const InputDecoration(labelText: 'Type'),
                              items: ['Online', 'Offline', 'Both'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                              onChanged: (val) => setDialogState(() => type = val!),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: payCtrl,
                        decoration: const InputDecoration(labelText: 'Payment Terms', hintText: '50% advance, 50% on delivery'),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: specCtrl,
                        decoration: const InputDecoration(labelText: 'Specialties (comma separated)'),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Text('Verified by Kangrow:'),
                          Checkbox(
                            value: verified,
                            onChanged: (val) => setDialogState(() => verified = val!),
                          ),
                          const Spacer(),
                          Text('Rating: ${rating.toInt()} Star(s)'),
                          Slider(
                            min: 1,
                            max: 5,
                            divisions: 4,
                            value: rating,
                            onChanged: (val) => setDialogState(() => rating = val),
                          )
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: () async {
                              if (formKey.currentState!.validate()) {
                                final parsedData = {
                                  'name': nameCtrl.text,
                                  'category': catCtrl.text,
                                  'type': type,
                                  'description': descCtrl.text,
                                  'website': webCtrl.text.isEmpty ? null : webCtrl.text,
                                  'location': locCtrl.text.isEmpty ? 'Pan India' : locCtrl.text,
                                  'minOrderValue': int.tryParse(minOrdCtrl.text) ?? 0,
                                  'deliveryDays': delCtrl.text.isEmpty ? '3-5 days' : delCtrl.text,
                                  'paymentTerms': payCtrl.text.isEmpty ? 'N/A' : payCtrl.text,
                                  'specialties': specCtrl.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList(),
                                  'rating': rating.toInt(),
                                  'verifiedByKangrow': verified,
                                  'tags': [catCtrl.text.toLowerCase()],
                                };
                                Navigator.pop(context);
                                setState(() => _isLoading = true);
                                try {
                                  if (existing == null) {
                                      await KnowledgeService.createVendor(parsedData);
                                  } else {
                                      await KnowledgeService.updateVendor(existing['id'], parsedData);
                                  }
                                  _fetchData();
                                } catch (e) {
                                  setState(() => _isLoading = false);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Save failed: $e'), backgroundColor: Colors.red),
                                  );
                                }
                              }
                            },
                            child: const Text('Save'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── GOVT SCHEME FORM DIALOG ──

  void _showSchemeDialog(dynamic existing) {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController(text: existing?['name']);
    final fullCtrl = TextEditingController(text: existing?['fullName']);
    final deptCtrl = TextEditingController(text: existing?['department']);
    final descCtrl = TextEditingController(text: existing?['description']);
    final urlCtrl = TextEditingController(text: existing?['applicationUrl']);
    final valCtrl = TextEditingController(text: existing?['validUntil']);

    final eligCtrl = TextEditingController(text: (existing?['eligibility'] as List?)?.join(', '));
    final benCtrl = TextEditingController(text: (existing?['benefits'] as List?)?.join(', '));
    final catsCtrl = TextEditingController(text: (existing?['targetCategories'] as List?)?.join(', '));
    final statesCtrl = TextEditingController(text: (existing?['targetStates'] as List?)?.join(', '));
    final docsCtrl = TextEditingController(text: (existing?['documentRequired'] as List?)?.join(', '));

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600, maxHeight: 800),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      existing == null ? 'Add Government Scheme' : 'Edit Government Scheme',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(labelText: 'Short Name*', hintText: 'PMEGP'),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: fullCtrl,
                      decoration: const InputDecoration(labelText: 'Full Name*', hintText: 'Prime Minister\'s Employment Generation Programme'),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: deptCtrl,
                      decoration: const InputDecoration(labelText: 'Department*', hintText: 'Ministry of MSME'),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: descCtrl,
                      decoration: const InputDecoration(labelText: 'Description*'),
                      maxLines: 3,
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: urlCtrl,
                      decoration: const InputDecoration(labelText: 'Application URL'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: valCtrl,
                      decoration: const InputDecoration(labelText: 'Valid Until', hintText: 'Ongoing or YYYY-MM-DD'),
                    ),
                    const SizedBox(height: 16),
                    const Text('Lists (comma separated values)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: benCtrl,
                      decoration: const InputDecoration(labelText: 'Benefits (e.g. 35% subsidy, Max ₹25L loan)'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: eligCtrl,
                      decoration: const InputDecoration(labelText: 'Eligibility criteria'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: catsCtrl,
                      decoration: const InputDecoration(labelText: 'Target Categories (e.g. Manufacturing, Retail)'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: statesCtrl,
                      decoration: const InputDecoration(labelText: 'Target States (leave blank for Pan India)'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: docsCtrl,
                      decoration: const InputDecoration(labelText: 'Documents Required (e.g. Aadhaar, Project Report)'),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: () async {
                            if (formKey.currentState!.validate()) {
                              final parsedData = {
                                'name': nameCtrl.text,
                                'fullName': fullCtrl.text,
                                'department': deptCtrl.text,
                                'description': descCtrl.text,
                                'applicationUrl': urlCtrl.text.isEmpty ? null : urlCtrl.text,
                                'validUntil': valCtrl.text.isEmpty ? 'Ongoing' : valCtrl.text,
                                'benefits': benCtrl.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList(),
                                'eligibility': eligCtrl.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList(),
                                'targetCategories': catsCtrl.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList(),
                                'targetStates': statesCtrl.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList(),
                                'documentRequired': docsCtrl.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList(),
                              };
                              Navigator.pop(context);
                              setState(() => _isLoading = true);
                              try {
                                if (existing == null) {
                                  await KnowledgeService.createScheme(parsedData);
                                } else {
                                  await KnowledgeService.updateScheme(existing['id'], parsedData);
                                }
                                _fetchData();
                              } catch (e) {
                                setState(() => _isLoading = false);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Save failed: $e'), backgroundColor: Colors.red),
                                );
                              }
                            }
                          },
                          child: const Text('Save'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── MARKET REPORT FORM DIALOG ──

  void _showReportDialog(dynamic existing) {
    final formKey = GlobalKey<FormState>();
    final titleCtrl = TextEditingController(text: existing?['title']);
    final catCtrl = TextEditingController(text: existing?['category']);
    final sumCtrl = TextEditingController(text: existing?['summary']);
    final rangeCtrl = TextEditingController(text: existing?['investmentRange']);
    final scoreCtrl = TextEditingController(text: existing?['opportunityScore']?.toString() ?? '85');
    final srcCtrl = TextEditingController(text: existing?['source']);

    final insCtrl = TextEditingController(text: (existing?['insights'] as List?)?.join(', '));
    final statesCtrl = TextEditingController(text: (existing?['relevantStates'] as List?)?.join(', '));
    final audCtrl = TextEditingController(text: (existing?['targetAudience'] as List?)?.join(', '));

    String type = existing?['type'] ?? 'Trending';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600, maxHeight: 800),
            child: Container(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        existing == null ? 'Add Market Intelligence Report' : 'Edit Market Intelligence Report',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: titleCtrl,
                        decoration: const InputDecoration(labelText: 'Title*', hintText: 'Eco-friendly Kitchenware Surge'),
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: catCtrl,
                        decoration: const InputDecoration(labelText: 'Category*', hintText: 'Home & Kitchen'),
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: sumCtrl,
                        decoration: const InputDecoration(labelText: 'Summary (Overview)*'),
                        maxLines: 3,
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: type,
                              decoration: const InputDecoration(labelText: 'Report Type'),
                              items: ['Trending', 'Seasonal', 'Emerging', 'Declining'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                              onChanged: (val) => setDialogState(() => type = val!),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: scoreCtrl,
                              decoration: const InputDecoration(labelText: 'Opportunity Score (0-100)*'),
                              keyboardType: TextInputType.number,
                              validator: (v) => v!.isEmpty ? 'Required' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: rangeCtrl,
                              decoration: const InputDecoration(labelText: 'Investment Range', hintText: '₹10k - ₹50k'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: srcCtrl,
                              decoration: const InputDecoration(labelText: 'Source', hintText: 'Google Trends'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text('Lists (comma separated values)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: insCtrl,
                        decoration: const InputDecoration(labelText: 'Key Insights (e.g. +40% MoM search growth, High demand in tier-1)'),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: statesCtrl,
                        decoration: const InputDecoration(labelText: 'Relevant States (comma separated)'),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: audCtrl,
                        decoration: const InputDecoration(labelText: 'Target Audience segments'),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: () async {
                              if (formKey.currentState!.validate()) {
                                final parsedData = {
                                  'title': titleCtrl.text,
                                  'category': catCtrl.text,
                                  'type': type,
                                  'summary': sumCtrl.text,
                                  'opportunityScore': int.tryParse(scoreCtrl.text) ?? 85,
                                  'investmentRange': rangeCtrl.text.isEmpty ? 'Any' : rangeCtrl.text,
                                  'source': srcCtrl.text.isEmpty ? 'Internal Analysis' : srcCtrl.text,
                                  'insights': insCtrl.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList(),
                                  'relevantStates': statesCtrl.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList(),
                                  'targetAudience': audCtrl.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList(),
                                  'validFrom': DateTime.now().toIso8601String(),
                                };
                                Navigator.pop(context);
                                setState(() => _isLoading = true);
                                try {
                                  if (existing == null) {
                                    await KnowledgeService.createMarketReport(parsedData);
                                  } else {
                                    await KnowledgeService.updateMarketReport(existing['id'], parsedData);
                                  }
                                  _fetchData();
                                } catch (e) {
                                  setState(() => _isLoading = false);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Save failed: $e'), backgroundColor: Colors.red),
                                  );
                                }
                              }
                            },
                            child: const Text('Save'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _MiniStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Text(
                  title,
                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
