import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../services/token_service.dart';
import '../../core/theme.dart';
import '../../core/admin_network_config.dart';

// ── Data Models ───────────────────────────────────────────────────────────────

class HotNewsTierConfig {
  final bool enabled;
  final int itemCount;
  final String model;

  HotNewsTierConfig({
    required this.enabled,
    required this.itemCount,
    required this.model,
  });

  factory HotNewsTierConfig.fromJson(Map<String, dynamic> j) =>
      HotNewsTierConfig(
        enabled:   j['enabled'] as bool?   ?? true,
        itemCount: j['itemCount'] as int?   ?? 3,
        model:     j['model'] as String?    ?? 'gpt-4o-mini',
      );

  Map<String, dynamic> toJson() => {
    'enabled':   enabled,
    'itemCount': itemCount,
    'model':     model,
  };
}

class HotNewsSettings {
  bool globalEnabled;
  List<String> enabledTiers;
  Map<String, HotNewsTierConfig> tierSettings;
  int maxUsersPerRun;
  int delayBetweenUsersMs;

  HotNewsSettings({
    required this.globalEnabled,
    required this.enabledTiers,
    required this.tierSettings,
    required this.maxUsersPerRun,
    required this.delayBetweenUsersMs,
  });

  factory HotNewsSettings.fromJson(Map<String, dynamic> j) {
    final raw = j['tierSettings'] as Map<String, dynamic>? ?? {};
    return HotNewsSettings(
      globalEnabled:       j['globalEnabled'] as bool?     ?? true,
      enabledTiers:        (j['enabledTiers'] as List?)?.cast<String>() ?? ['standard', 'premium', 'enterprise'],
      tierSettings: {
        'standard':   HotNewsTierConfig.fromJson(raw['standard']   as Map<String, dynamic>? ?? {}),
        'premium':    HotNewsTierConfig.fromJson(raw['premium']    as Map<String, dynamic>? ?? {}),
        'enterprise': HotNewsTierConfig.fromJson(raw['enterprise'] as Map<String, dynamic>? ?? {}),
      },
      maxUsersPerRun:      j['maxUsersPerRun']      as int? ?? 100,
      delayBetweenUsersMs: j['delayBetweenUsersMs'] as int? ?? 250,
    );
  }

  Map<String, dynamic> toJson() => {
    'globalEnabled':       globalEnabled,
    'enabledTiers':        enabledTiers,
    'tierSettings':        tierSettings.map((k, v) => MapEntry(k, v.toJson())),
    'maxUsersPerRun':      maxUsersPerRun,
    'delayBetweenUsersMs': delayBetweenUsersMs,
  };
}

// ── Screen ────────────────────────────────────────────────────────────────────

class HotNewsScreen extends StatefulWidget {
  const HotNewsScreen({super.key});

  @override
  State<HotNewsScreen> createState() => _HotNewsScreenState();
}

class _HotNewsScreenState extends State<HotNewsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  HotNewsSettings? _settings;
  bool _loading   = true;
  bool _saving    = false;
  String? _error;

  // Stats
  int    _totalSends  = 0;
  int    _totalTokens = 0;
  List<Map<String, dynamic>> _dailyChart  = [];
  List<Map<String, dynamic>> _recentLogs  = [];
  bool   _statsLoading = true;

  // Manual trigger
  final _uidController = TextEditingController();
  bool _triggering = false;

  // Job run
  bool _jobRunning = false;

  static String get _baseUrl => AdminNetworkConfig.baseUrl;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadSettings();
    _loadStats();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _uidController.dispose();
    super.dispose();
  }

  Future<Map<String, String>> _authHeaders() async {
    final token = await TokenService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<void> _loadSettings() async {
    setState(() { _loading = true; _error = null; });
    try {
      final resp = await http.get(
        Uri.parse('$_baseUrl/admin/hot-news/settings'),
        headers: await _authHeaders(),
      );
      final body = jsonDecode(resp.body) as Map<String, dynamic>;
      if (resp.statusCode == 200 && body['success'] == true) {
        setState(() {
          _settings = HotNewsSettings.fromJson(body['data'] as Map<String, dynamic>);
          _loading  = false;
        });
      } else {
        throw Exception(body['error'] ?? 'Failed to load settings');
      }
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _saveSettings() async {
    if (_settings == null) return;
    setState(() => _saving = true);
    try {
      final resp = await http.post(
        Uri.parse('$_baseUrl/admin/hot-news/settings'),
        headers: await _authHeaders(),
        body: jsonEncode(_settings!.toJson()),
      );
      final body = jsonDecode(resp.body) as Map<String, dynamic>;
      if (resp.statusCode == 200 && body['success'] == true) {
        _showSnack('Hot News settings applied ✅', AdminTheme.successGreen);
      } else {
        throw Exception(body['error'] ?? 'Save failed');
      }
    } catch (e) {
      _showSnack('Failed: $e', AdminTheme.errorRed);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _loadStats() async {
    setState(() => _statsLoading = true);
    try {
      final resp = await http.get(
        Uri.parse('$_baseUrl/admin/hot-news/stats?days=30'),
        headers: await _authHeaders(),
      );
      final body = jsonDecode(resp.body) as Map<String, dynamic>;
      if (resp.statusCode == 200 && body['success'] == true) {
        final data = body['data'] as Map<String, dynamic>;
        setState(() {
          _totalSends  = data['totalSends']  as int? ?? 0;
          _totalTokens = data['totalTokens'] as int? ?? 0;
          _dailyChart  = (data['dailyChart']  as List?)?.cast<Map<String, dynamic>>() ?? [];
          _recentLogs  = (data['recentLogs']  as List?)?.cast<Map<String, dynamic>>() ?? [];
          _statsLoading = false;
        });
      }
    } catch (_) {
      setState(() => _statsLoading = false);
    }
  }

  Future<void> _triggerForUser() async {
    final uid = _uidController.text.trim();
    if (uid.isEmpty) { _showSnack('Enter a user UID', AdminTheme.warningOrange); return; }
    setState(() => _triggering = true);
    try {
      final resp = await http.post(
        Uri.parse('$_baseUrl/admin/hot-news/trigger/$uid'),
        headers: await _authHeaders(),
      );
      final body = jsonDecode(resp.body) as Map<String, dynamic>;
      if (resp.statusCode == 200 && body['success'] == true) {
        _showSnack('Hot News sent to $uid ✅', AdminTheme.successGreen);
        _uidController.clear();
      } else {
        throw Exception(body['error'] ?? 'Trigger failed');
      }
    } catch (e) {
      _showSnack('Failed: $e', AdminTheme.errorRed);
    } finally {
      if (mounted) setState(() => _triggering = false);
    }
  }

  Future<void> _runJobNow({required bool force}) async {
    setState(() => _jobRunning = true);
    try {
      final resp = await http.post(
        Uri.parse('$_baseUrl/admin/hot-news/run-job'),
        headers: await _authHeaders(),
        body: jsonEncode({'force': force}),
      );
      final body = jsonDecode(resp.body) as Map<String, dynamic>;
      if (body['success'] == true) {
        _showSnack(
          force ? 'Forced job started in background 🔥' : 'Job started in background 🔥',
          AdminTheme.successGreen,
        );
      }
    } catch (e) {
      _showSnack('Job trigger failed: $e', AdminTheme.errorRed);
    } finally {
      if (mounted) setState(() => _jobRunning = false);
    }
  }

  Future<void> _confirmRunJob() async {
    bool? proceed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF151821),
        title: const Text('Run Hot News Job Now?', style: TextStyle(color: Colors.white)),
        content: const Text(
          'This will trigger the daily Hot News generation pipeline for all eligible users.\n\n'
          'Would you like to bypass the "once-per-day" sending limit and force regeneration for everyone?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, false),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E293B)),
            child: const Text('Run (Normal)', style: TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF6B00)),
            child: const Text('Run (Force Bypass)', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (proceed != null) {
      _runJobNow(force: proceed);
    }
  }

  void _showSnack(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF6B00), Color(0xFFFFC107)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.local_fire_department_rounded,
                  color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            const Text('Hot News Control Centre'),
          ],
        ),
        actions: [
          ElevatedButton.icon(
            onPressed: _jobRunning ? null : _confirmRunJob,
            icon: _jobRunning
                ? const SizedBox(
                    width: 14, height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.play_arrow_rounded, size: 16),
            label: Text(_jobRunning ? 'Running...' : 'Run Job Now'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B00),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          const SizedBox(width: 16),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'CONTROLS'),
            Tab(text: 'DELIVERY LOGS'),
            Tab(text: 'AI COST TRACKING'),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF6B00)))
          : _error != null
              ? _buildError()
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildControlsTab(),
                    _buildLogsTab(),
                    _buildStatsTab(),
                  ],
                ),
    );
  }

  Widget _buildError() => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(Icons.error_outline, size: 48, color: AdminTheme.errorRed),
      const SizedBox(height: 12),
      Text(_error!, style: const TextStyle(color: AdminTheme.textSecondary)),
      const SizedBox(height: 20),
      ElevatedButton(onPressed: _loadSettings, child: const Text('Retry')),
    ]),
  );

  // ── Tab 1: Controls ─────────────────────────────────────────────────────────

  Widget _buildControlsTab() {
    final s = _settings!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: LayoutBuilder(builder: (context, constraints) {
        final isWide = constraints.maxWidth > 900;
        if (isWide) {
          return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(flex: 2, child: Column(children: [
              _buildGlobalToggle(s),
              const SizedBox(height: 20),
              _buildTierCard('Standard', s.tierSettings['standard']!, const Color(0xFF60A5FA)),
              const SizedBox(height: 16),
              _buildTierCard('Premium', s.tierSettings['premium']!, const Color(0xFFA78BFA)),
              const SizedBox(height: 16),
              _buildTierCard('Enterprise', s.tierSettings['enterprise']!, const Color(0xFF34D399)),
            ])),
            const SizedBox(width: 24),
            Expanded(child: Column(children: [
              _buildRunSettingsCard(s),
              const SizedBox(height: 20),
              _buildManualTriggerCard(),
              const SizedBox(height: 20),
              _buildSaveButton(),
            ])),
          ]);
        }
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _buildGlobalToggle(s),
          const SizedBox(height: 20),
          _buildTierCard('Standard', s.tierSettings['standard']!, const Color(0xFF60A5FA)),
          const SizedBox(height: 16),
          _buildTierCard('Premium', s.tierSettings['premium']!, const Color(0xFFA78BFA)),
          const SizedBox(height: 16),
          _buildTierCard('Enterprise', s.tierSettings['enterprise']!, const Color(0xFF34D399)),
          const SizedBox(height: 20),
          _buildRunSettingsCard(s),
          const SizedBox(height: 20),
          _buildManualTriggerCard(),
          const SizedBox(height: 20),
          _buildSaveButton(),
        ]);
      }),
    );
  }

  Widget _buildGlobalToggle(HotNewsSettings s) => Card(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFFFF6B00), Color(0xFFFFC107)]),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.local_fire_department_rounded, color: Colors.white, size: 22),
        ),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Global Hot News',
              style: TextStyle(color: AdminTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 4),
          Text(
            s.globalEnabled ? 'Active — generating daily for eligible tiers' : 'Paused globally — no news will be generated',
            style: const TextStyle(color: AdminTheme.textSecondary, fontSize: 12),
          ),
        ])),
        Switch(
          value: s.globalEnabled,
          activeColor: AdminTheme.successGreen,
          onChanged: (v) => setState(() => _settings!.globalEnabled = v),
        ),
      ]),
    ),
  );

  Widget _buildTierCard(String tierName, HotNewsTierConfig config, Color accent) => Card(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: BorderSide(color: config.enabled ? accent.withOpacity(0.4) : AdminTheme.borderSubtle),
    ),
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 10, height: 10,
            decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(tierName,
              style: TextStyle(color: accent, fontWeight: FontWeight.bold, fontSize: 15)),
          const Spacer(),
          Switch(
            value: config.enabled,
            activeColor: accent,
            onChanged: (v) => setState(() {
              final key = tierName.toLowerCase();
              _settings!.tierSettings[key] = HotNewsTierConfig(
                enabled: v, itemCount: config.itemCount, model: config.model,
              );
            }),
          ),
        ]),
        if (config.enabled) ...[
          const Divider(height: 20),
          // Item count
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('News Items', style: TextStyle(color: AdminTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 13)),
            Text('${config.itemCount}', style: TextStyle(color: accent, fontWeight: FontWeight.bold, fontSize: 14)),
          ]),
          Slider(
            value: config.itemCount.toDouble(),
            min: 1, max: 5, divisions: 4,
            activeColor: accent,
            inactiveColor: AdminTheme.surfaceHighlight,
            label: '${config.itemCount} items',
            onChanged: (v) => setState(() {
              final key = tierName.toLowerCase();
              _settings!.tierSettings[key] = HotNewsTierConfig(
                enabled: config.enabled, itemCount: v.round(), model: config.model,
              );
            }),
          ),
          const SizedBox(height: 8),
          // Model selector
          const Text('AI Model', style: TextStyle(color: AdminTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 8),
          Row(children: [
            _ModelChip(
              label: 'gpt-4o-mini',
              subtitle: 'Fast · Cheap',
              selected: config.model == 'gpt-4o-mini',
              color: const Color(0xFF60A5FA),
              onTap: () => setState(() {
                final key = tierName.toLowerCase();
                _settings!.tierSettings[key] = HotNewsTierConfig(
                  enabled: config.enabled, itemCount: config.itemCount, model: 'gpt-4o-mini',
                );
              }),
            ),
            const SizedBox(width: 8),
            _ModelChip(
              label: 'gpt-4o',
              subtitle: 'Smart · Premium',
              selected: config.model == 'gpt-4o',
              color: const Color(0xFFA78BFA),
              onTap: () => setState(() {
                final key = tierName.toLowerCase();
                _settings!.tierSettings[key] = HotNewsTierConfig(
                  enabled: config.enabled, itemCount: config.itemCount, model: 'gpt-4o',
                );
              }),
            ),
          ]),
        ],
      ]),
    ),
  );

  Widget _buildRunSettingsCard(HotNewsSettings s) => Card(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Job Settings', style: TextStyle(
            color: AdminTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 16),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Max Users / Run', style: TextStyle(color: AdminTheme.textPrimary, fontSize: 13)),
          Text('${s.maxUsersPerRun}', style: const TextStyle(color: AdminTheme.primaryBlue, fontWeight: FontWeight.bold)),
        ]),
        Slider(
          value: s.maxUsersPerRun.toDouble(),
          min: 10, max: 500, divisions: 49,
          activeColor: AdminTheme.primaryBlue,
          inactiveColor: AdminTheme.surfaceHighlight,
          label: '${s.maxUsersPerRun}',
          onChanged: (v) => setState(() => _settings!.maxUsersPerRun = v.round()),
        ),
        const Divider(height: 20),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Delay Between Users', style: TextStyle(color: AdminTheme.textPrimary, fontSize: 13)),
          Text('${s.delayBetweenUsersMs}ms',
              style: const TextStyle(color: AdminTheme.primaryBlue, fontWeight: FontWeight.bold)),
        ]),
        Slider(
          value: s.delayBetweenUsersMs.toDouble(),
          min: 100, max: 2000, divisions: 38,
          activeColor: AdminTheme.primaryBlue,
          inactiveColor: AdminTheme.surfaceHighlight,
          label: '${s.delayBetweenUsersMs}ms',
          onChanged: (v) => setState(() => _settings!.delayBetweenUsersMs = v.round()),
        ),
        const SizedBox(height: 4),
        const Text(
          'Schedule: Daily at 06:30 IST (01:00 UTC)',
          style: TextStyle(color: AdminTheme.textSecondary, fontSize: 12),
        ),
      ]),
    ),
  );

  Widget _buildManualTriggerCard() => Card(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Manual Trigger (Test)',
            style: TextStyle(color: AdminTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 6),
        const Text('Send Hot News to a specific user immediately.',
            style: TextStyle(color: AdminTheme.textSecondary, fontSize: 12)),
        const SizedBox(height: 16),
        TextField(
          controller: _uidController,
          style: const TextStyle(color: AdminTheme.textPrimary),
          decoration: InputDecoration(
            labelText: 'User UID',
            labelStyle: const TextStyle(color: AdminTheme.textSecondary),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AdminTheme.borderSubtle),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _triggering ? null : _triggerForUser,
            icon: _triggering
                ? const SizedBox(width: 14, height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.send_rounded, size: 16),
            label: Text(_triggering ? 'Sending...' : 'Send to User'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B00),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
      ]),
    ),
  );

  Widget _buildSaveButton() => SizedBox(
    width: double.infinity,
    height: 50,
    child: ElevatedButton.icon(
      onPressed: _saving ? null : _saveSettings,
      icon: _saving
          ? const SizedBox(width: 18, height: 18,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
          : const Icon(Icons.save_rounded),
      label: Text(_saving ? 'Applying...' : 'Apply Hot News Settings'),
      style: ElevatedButton.styleFrom(
        backgroundColor: AdminTheme.primaryBlue,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
      ),
    ),
  );

  // ── Tab 2: Delivery Logs ─────────────────────────────────────────────────────

  Widget _buildLogsTab() => _statsLoading
      ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF6B00)))
      : _recentLogs.isEmpty
          ? const Center(child: Text('No delivery logs yet.', style: TextStyle(color: AdminTheme.textSecondary)))
          : RefreshIndicator(
              onRefresh: _loadStats,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text('Recent AI Usage — Hot News Feature',
                            style: TextStyle(color: AdminTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 16),
                        // Table header
                        _logRow('UID', 'Model', 'Tokens', 'Date', isHeader: true),
                        const Divider(),
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _recentLogs.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, i) {
                            final l = _recentLogs[i];
                            final uid    = (l['uid'] as String? ?? '').length > 12
                                ? '${(l['uid'] as String).substring(0, 12)}...'
                                : l['uid'] as String? ?? '—';
                            final model  = l['model'] as String? ?? '—';
                            final tokens = '${l['totalTokens'] ?? 0}';
                            final date   = (l['createdAt'] as String? ?? '').length >= 10
                                ? (l['createdAt'] as String).substring(0, 10)
                                : '—';
                            return _logRow(uid, model, tokens, date);
                          },
                        ),
                      ]),
                    ),
                  ),
                ]),
              ),
            );

  Widget _logRow(String a, String b, String c, String d, {bool isHeader = false}) {
    final style = TextStyle(
      color: isHeader ? AdminTheme.textSecondary : AdminTheme.textPrimary,
      fontSize: isHeader ? 11 : 13,
      fontWeight: isHeader ? FontWeight.w600 : FontWeight.normal,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(children: [
        Expanded(child: Text(a, style: style, overflow: TextOverflow.ellipsis)),
        Expanded(child: Text(b, style: style)),
        SizedBox(width: 80, child: Text(c, style: style)),
        SizedBox(width: 90, child: Text(d, style: style)),
      ]),
    );
  }

  // ── Tab 3: AI Cost Tracking ───────────────────────────────────────────────────

  Widget _buildStatsTab() => _statsLoading
      ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF6B00)))
      : RefreshIndicator(
          onRefresh: _loadStats,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(children: [
              // Summary cards
              Row(children: [
                _StatCard(
                  title: 'Total Sends (30d)',
                  value: '$_totalSends',
                  icon: Icons.send_rounded,
                  color: const Color(0xFFFF6B00),
                ),
                const SizedBox(width: 16),
                _StatCard(
                  title: 'Total Tokens (30d)',
                  value: _formatNum(_totalTokens),
                  icon: Icons.token_rounded,
                  color: AdminTheme.primaryBlue,
                ),
              ]),
              const SizedBox(height: 20),
              // Daily chart
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Daily Send Count — Last 30 Days',
                        style: TextStyle(color: AdminTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 20),
                    if (_dailyChart.isEmpty)
                      const Center(child: Text('No data yet', style: TextStyle(color: AdminTheme.textSecondary)))
                    else
                      SizedBox(
                        height: 180,
                        child: _SimpleBarChart(data: _dailyChart),
                      ),
                  ]),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('How Hot News Costs Are Tracked',
                        style: TextStyle(color: AdminTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 12),
                    const Text(
                      'All Hot News AI calls are logged to the same OpenAI Usage Logs collection with feature = "hot-news". '
                      'You can also see the hot-news feature row in the main AI Management → Feature Breakdown section.',
                      style: TextStyle(color: AdminTheme.textSecondary, fontSize: 13, height: 1.5),
                    ),
                  ]),
                ),
              ),
            ]),
          ),
        );

  String _formatNum(int n) {
    final r = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return n.toString().replaceAllMapped(r, (m) => '${m[1]},');
  }
}

// ── Helper Widgets ────────────────────────────────────────────────────────────

class _ModelChip extends StatelessWidget {
  final String label;
  final String subtitle;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _ModelChip({
    required this.label,
    required this.subtitle,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          decoration: BoxDecoration(
            color: selected ? color.withOpacity(0.15) : AdminTheme.surfaceHighlight,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected ? color : AdminTheme.borderSubtle,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: TextStyle(
              color: selected ? color : AdminTheme.textSecondary,
              fontSize: 12, fontWeight: FontWeight.bold,
            )),
            Text(subtitle, style: TextStyle(
              color: selected ? color.withOpacity(0.7) : AdminTheme.textSecondary,
              fontSize: 10,
            )),
          ]),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title, value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title, required this.value,
    required this.icon, required this.color,
  });

  @override
  Widget build(BuildContext context) => Expanded(
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(color: AdminTheme.textSecondary, fontSize: 12)),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.bold)),
          ]),
        ]),
      ),
    ),
  );
}

class _SimpleBarChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  const _SimpleBarChart({required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox.shrink();
    final maxVal = data.fold<int>(1, (m, e) => (e['sends'] as int? ?? 0) > m ? (e['sends'] as int) : m);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: data.map((point) {
        final sends  = point['sends'] as int? ?? 0;
        final height = (sends / maxVal) * 120;
        final label  = (point['date'] as String? ?? '').length >= 5
            ? (point['date'] as String).substring(5) : '';
        return Expanded(
          child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
            Container(
              height: height.clamp(2.0, 120.0),
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF6B00), Color(0xFFFFC107)],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: AdminTheme.textSecondary, fontSize: 8),
                overflow: TextOverflow.ellipsis),
          ]),
        );
      }).toList(),
    );
  }
}
