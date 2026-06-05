import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../services/token_service.dart';

// ── Data Models ──────────────────────────────────────────────────────────────

class AiUsageSummary {
  final double totalCost;
  final int totalTokens;
  final int totalCalls;
  final double avgCostPerCall;
  final int avgTokensPerCall;
  final int periodDays;

  const AiUsageSummary({
    required this.totalCost,
    required this.totalTokens,
    required this.totalCalls,
    required this.avgCostPerCall,
    required this.avgTokensPerCall,
    required this.periodDays,
  });

  factory AiUsageSummary.fromJson(Map<String, dynamic> j) => AiUsageSummary(
        totalCost: (j['totalCost'] as num).toDouble(),
        totalTokens: (j['totalTokens'] as num).toInt(),
        totalCalls: (j['totalCalls'] as num).toInt(),
        avgCostPerCall: (j['avgCostPerCall'] as num).toDouble(),
        avgTokensPerCall: (j['avgTokensPerCall'] as num).toInt(),
        periodDays: (j['periodDays'] as num).toInt(),
      );
}

class DailyChartPoint {
  final String date;
  final double cost;
  final int tokens;
  final int calls;

  const DailyChartPoint({
    required this.date,
    required this.cost,
    required this.tokens,
    required this.calls,
  });

  factory DailyChartPoint.fromJson(Map<String, dynamic> j) => DailyChartPoint(
        date: j['date'] as String,
        cost: (j['cost'] as num).toDouble(),
        tokens: (j['tokens'] as num).toInt(),
        calls: (j['calls'] as num).toInt(),
      );
}

class FeatureBreakdown {
  final String feature;
  final double cost;
  final int tokens;
  final int calls;

  const FeatureBreakdown({
    required this.feature,
    required this.cost,
    required this.tokens,
    required this.calls,
  });

  factory FeatureBreakdown.fromJson(Map<String, dynamic> j) => FeatureBreakdown(
        feature: j['feature'] as String,
        cost: (j['cost'] as num).toDouble(),
        tokens: (j['tokens'] as num).toInt(),
        calls: (j['calls'] as num).toInt(),
      );
}

class ModelDistribution {
  final String model;
  final int calls;

  const ModelDistribution({required this.model, required this.calls});

  factory ModelDistribution.fromJson(Map<String, dynamic> j) => ModelDistribution(
        model: j['model'] as String,
        calls: (j['calls'] as num).toInt(),
      );
}

class TopUser {
  final String uid;
  final double cost;
  final int tokens;
  final int calls;

  const TopUser({
    required this.uid,
    required this.cost,
    required this.tokens,
    required this.calls,
  });

  factory TopUser.fromJson(Map<String, dynamic> j) => TopUser(
        uid: j['uid'] as String,
        cost: (j['cost'] as num).toDouble(),
        tokens: (j['tokens'] as num).toInt(),
        calls: (j['calls'] as num).toInt(),
      );
}

class OpenAISettings {
  final int maxHistoryLimit;
  final double maxTokensMultiplier;
  final bool tierDownModel;

  const OpenAISettings({
    required this.maxHistoryLimit,
    required this.maxTokensMultiplier,
    required this.tierDownModel,
  });

  factory OpenAISettings.fromJson(Map<String, dynamic> j) => OpenAISettings(
        maxHistoryLimit: (j['maxHistoryLimit'] as num?)?.toInt() ?? 6,
        maxTokensMultiplier: (j['maxTokensMultiplier'] as num?)?.toDouble() ?? 1.0,
        tierDownModel: (j['tierDownModel'] as bool?) ?? false,
      );
}

class AiUsageReport {
  final AiUsageSummary summary;
  final List<DailyChartPoint> dailyChart;
  final List<FeatureBreakdown> featureBreakdown;
  final List<ModelDistribution> modelDistribution;
  final List<TopUser> topUsers;
  final OpenAISettings currentSettings;

  const AiUsageReport({
    required this.summary,
    required this.dailyChart,
    required this.featureBreakdown,
    required this.modelDistribution,
    required this.topUsers,
    required this.currentSettings,
  });

  factory AiUsageReport.fromJson(Map<String, dynamic> j) => AiUsageReport(
        summary: AiUsageSummary.fromJson(j['summary'] as Map<String, dynamic>),
        dailyChart: (j['dailyChart'] as List)
            .map((e) => DailyChartPoint.fromJson(e as Map<String, dynamic>))
            .toList(),
        featureBreakdown: (j['featureBreakdown'] as List)
            .map((e) => FeatureBreakdown.fromJson(e as Map<String, dynamic>))
            .toList(),
        modelDistribution: (j['modelDistribution'] as List)
            .map((e) => ModelDistribution.fromJson(e as Map<String, dynamic>))
            .toList(),
        topUsers: (j['topUsers'] as List)
            .map((e) => TopUser.fromJson(e as Map<String, dynamic>))
            .toList(),
        currentSettings:
            OpenAISettings.fromJson(j['currentSettings'] as Map<String, dynamic>),
      );
}

// ── Service ──────────────────────────────────────────────────────────────────

class AiManagementService {
  static const String _baseUrl = String.fromEnvironment(
    'BACKEND_URL',
    defaultValue: 'https://kanngrowbackend-production.up.railway.app/api/v1',
  );

  Future<Map<String, String>> _headers() async {
    final token = await TokenService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<AiUsageReport> getUsageStats({int days = 30}) async {
    final headers = await _headers();
    final uri = Uri.parse('$_baseUrl/admin/ai-usage?days=$days');
    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      return AiUsageReport.fromJson(body['data'] as Map<String, dynamic>);
    }
    throw Exception('Failed to load AI usage stats: ${response.statusCode}');
  }

  Future<void> updateSettings({
    int? maxHistoryLimit,
    double? maxTokensMultiplier,
    bool? tierDownModel,
  }) async {
    final headers = await _headers();
    final uri = Uri.parse('$_baseUrl/admin/ai-settings');
    final body = <String, dynamic>{};
    if (maxHistoryLimit != null) body['maxHistoryLimit'] = maxHistoryLimit;
    if (maxTokensMultiplier != null) body['maxTokensMultiplier'] = maxTokensMultiplier;
    if (tierDownModel != null) body['tierDownModel'] = tierDownModel;

    final response = await http.post(
      uri,
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update settings: ${response.statusCode}');
    }
  }
}
