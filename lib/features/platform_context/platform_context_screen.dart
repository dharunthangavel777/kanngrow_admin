import 'package:flutter/material.dart';
import 'platform_context_service.dart';

class PlatformContextScreen extends StatefulWidget {
  const PlatformContextScreen({super.key});

  @override
  State<PlatformContextScreen> createState() => _PlatformContextScreenState();
}

class _PlatformContextScreenState extends State<PlatformContextScreen> {
  bool _isLoading = false;
  List<PlatformContextPin> _pins = [];
  final TextEditingController _textController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchPins();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _fetchPins() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final pins = await PlatformContextService.getPins();
      setState(() {
        _pins = pins;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading platform context: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Future<void> _handleAddPin() async {
    final text = _textController.text.trim();
    if (text.length < 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Factual context text must be at least 5 characters long.'),
          backgroundColor: Colors.orangeAccent,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });
    try {
      await PlatformContextService.addPin(text);
      _textController.clear();
      if (mounted) {
        Navigator.of(context).pop(); // Close dialog
      }
      _fetchPins();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Context pin added successfully!'),
            backgroundColor: Colors.green,
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
            content: Text('Failed to add pin: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Future<void> _handleTogglePin(PlatformContextPin pin, bool value) async {
    try {
      await PlatformContextService.togglePin(pin.id, value);
      _fetchPins();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to toggle pin: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Future<void> _handleDeletePin(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Platform Context Pin'),
        content: const Text(
          'Are you sure you want to delete this context pin? It will immediately stop being injected into AI prompts.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _isLoading = true;
      });
      try {
        await PlatformContextService.deletePin(id);
        _fetchPins();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Platform context pin deleted.'),
              backgroundColor: Colors.green,
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
              content: Text('Failed to delete pin: $e'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    }
  }

  void _showAddPinDialog() {
    _textController.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pin New Platform Context'),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter short, factual information (e.g. GST updates, supplier guidelines, market policies) to inject directly into AI conversations.',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _textController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'e.g. Budget 2025 reduced GST on online food sales to 5%',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(12),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _handleAddPin,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Pin Context'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredPins = _pins.where((pin) {
      return pin.text.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          pin.createdBy.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    final activeCount = _pins.where((p) => p.isActive).length;
    final totalCount = _pins.length;

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
                      'Platform Context Manager',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 28),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Pin important platform updates, GST info, or market policies directly to AI prompts (V2 Context Injection)',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      tooltip: 'Refresh pins',
                      onPressed: _fetchPins,
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: _showAddPinDialog,
                      icon: const Icon(Icons.pin_invoke, size: 18),
                      label: const Text('Pin New Context'),
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

          // Statistics Overview Cards
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Row(
              children: [
                _buildStatCard(
                  title: 'Total Injected Pins',
                  value: totalCount.toString(),
                  icon: Icons.push_pin,
                  color: Colors.blue,
                ),
                const SizedBox(width: 16),
                _buildStatCard(
                  title: 'Active Injectors',
                  value: activeCount.toString(),
                  icon: Icons.check_circle_outline,
                  color: Colors.green,
                ),
                const SizedBox(width: 16),
                _buildStatCard(
                  title: 'Muted Injectors',
                  value: (totalCount - activeCount).toString(),
                  icon: Icons.pause_circle_outline,
                  color: Colors.orange,
                ),
              ],
            ),
          ),

          // Search / Filter row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search context pins by content or creator...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              ),
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                });
              },
            ),
          ),

          const SizedBox(height: 8),

          // Main body table / list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredPins.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.push_pin_outlined, size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isEmpty ? 'No platform context pins found.' : 'No matching pins found.',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
                            ),
                            const SizedBox(height: 8),
                            if (_searchQuery.isEmpty)
                              ElevatedButton(
                                onPressed: _showAddPinDialog,
                                child: const Text('Add your first context pin'),
                              ),
                          ],
                        ),
                      )
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          // Desktop Table view
                          if (constraints.maxWidth >= 800) {
                            return SingleChildScrollView(
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              child: Card(
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(color: Colors.grey[200]!),
                                ),
                                child: DataTable(
                                  columnSpacing: 24,
                                  dataRowMaxHeight: 80,
                                  columns: const [
                                    DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                                    DataColumn(label: Expanded(child: Text('Factual Context Pin Text', style: TextStyle(fontWeight: FontWeight.bold)))),
                                    DataColumn(label: Text('Pinned By', style: TextStyle(fontWeight: FontWeight.bold))),
                                    DataColumn(label: Text('Created At', style: TextStyle(fontWeight: FontWeight.bold))),
                                    DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                                  ],
                                  rows: filteredPins.map((pin) {
                                    return DataRow(
                                      cells: [
                                        DataCell(
                                          Switch(
                                            value: pin.isActive,
                                            onChanged: (val) => _handleTogglePin(pin, val),
                                            activeColor: Colors.green,
                                          ),
                                        ),
                                        DataCell(
                                          SizedBox(
                                            width: constraints.maxWidth * 0.45,
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                                              child: Text(
                                                pin.text,
                                                maxLines: 3,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(fontSize: 14),
                                              ),
                                            ),
                                          ),
                                        ),
                                        DataCell(Text(pin.createdBy, style: const TextStyle(fontSize: 13))),
                                        DataCell(Text(pin.createdAt.split('T')[0], style: const TextStyle(fontSize: 13))),
                                        DataCell(
                                          IconButton(
                                            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                            onPressed: () => _handleDeletePin(pin.id),
                                          ),
                                        ),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              ),
                            );
                          }

                          // Mobile Card/List view
                          return ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            itemCount: filteredPins.length,
                            itemBuilder: (context, index) {
                              final pin = filteredPins[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(color: Colors.grey[200]!),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Pinned By: ${pin.createdBy}',
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                          ),
                                          Switch(
                                            value: pin.isActive,
                                            onChanged: (val) => _handleTogglePin(pin, val),
                                            activeColor: Colors.green,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        pin.text,
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Created: ${pin.createdAt.split('T')[0]}',
                                            style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                                            onPressed: () => _handleDeletePin(pin.id),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
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
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
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
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
