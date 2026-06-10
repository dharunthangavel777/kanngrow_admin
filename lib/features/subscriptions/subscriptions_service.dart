import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../services/token_service.dart';

class PlanPricing {
  final double monthlyUsd;
  final double annualUsd;
  final String stripePriceIdMonthly;
  final String stripePriceIdAnnual;

  PlanPricing({
    required this.monthlyUsd,
    required this.annualUsd,
    required this.stripePriceIdMonthly,
    required this.stripePriceIdAnnual,
  });

  factory PlanPricing.fromJson(Map<String, dynamic> json) {
    return PlanPricing(
      monthlyUsd: (json['monthlyUsd'] as num?)?.toDouble() ?? 0.0,
      annualUsd: (json['annualUsd'] as num?)?.toDouble() ?? 0.0,
      stripePriceIdMonthly: json['stripePriceIdMonthly'] as String? ?? '',
      stripePriceIdAnnual: json['stripePriceIdAnnual'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'monthlyUsd': monthlyUsd,
        'annualUsd': annualUsd,
        'stripePriceIdMonthly': stripePriceIdMonthly,
        'stripePriceIdAnnual': stripePriceIdAnnual,
      };
}

class PlanLimits {
  final int dailyRequests;
  final int monthlyTokens;
  final int maxUploadSizeMb;
  final int maxDocumentUploads;
  final int maxStoreCount;
  final String priorityQueue;

  PlanLimits({
    required this.dailyRequests,
    required this.monthlyTokens,
    required this.maxUploadSizeMb,
    required this.maxDocumentUploads,
    required this.maxStoreCount,
    required this.priorityQueue,
  });

  factory PlanLimits.fromJson(Map<String, dynamic> json) {
    return PlanLimits(
      dailyRequests: (json['dailyRequests'] as num?)?.toInt() ?? 0,
      monthlyTokens: (json['monthlyTokens'] as num?)?.toInt() ?? 0,
      maxUploadSizeMb: (json['maxUploadSizeMb'] as num?)?.toInt() ?? 0,
      maxDocumentUploads: (json['maxDocumentUploads'] as num?)?.toInt() ?? 0,
      maxStoreCount: (json['maxStoreCount'] as num?)?.toInt() ?? 0,
      priorityQueue: json['priorityQueue'] as String? ?? 'basic',
    );
  }

  Map<String, dynamic> toJson() => {
        'dailyRequests': dailyRequests,
        'monthlyTokens': monthlyTokens,
        'maxUploadSizeMb': maxUploadSizeMb,
        'maxDocumentUploads': maxDocumentUploads,
        'maxStoreCount': maxStoreCount,
        'priorityQueue': priorityQueue,
      };
}

class PlanFeatures {
  final bool chat;
  final bool competitorResearch;
  final bool seoOptimizations;
  final bool trendAnalysis;
  final bool marketingStrategy;
  final bool contentGenerationSuite;
  final bool customKnowledgeBase;
  final bool apiAccess;
  final bool whiteLabel;

  PlanFeatures({
    required this.chat,
    required this.competitorResearch,
    required this.seoOptimizations,
    required this.trendAnalysis,
    required this.marketingStrategy,
    required this.contentGenerationSuite,
    required this.customKnowledgeBase,
    required this.apiAccess,
    required this.whiteLabel,
  });

  factory PlanFeatures.fromJson(Map<String, dynamic> json) {
    return PlanFeatures(
      chat: json['chat'] as bool? ?? false,
      competitorResearch: json['competitorResearch'] as bool? ?? false,
      seoOptimizations: json['seoOptimizations'] as bool? ?? false,
      trendAnalysis: json['trendAnalysis'] as bool? ?? false,
      marketingStrategy: json['marketingStrategy'] as bool? ?? false,
      contentGenerationSuite: json['contentGenerationSuite'] as bool? ?? false,
      customKnowledgeBase: json['customKnowledgeBase'] as bool? ?? false,
      apiAccess: json['apiAccess'] as bool? ?? false,
      whiteLabel: json['whiteLabel'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'chat': chat,
        'competitorResearch': competitorResearch,
        'seoOptimizations': seoOptimizations,
        'trendAnalysis': trendAnalysis,
        'marketingStrategy': marketingStrategy,
        'contentGenerationSuite': contentGenerationSuite,
        'customKnowledgeBase': customKnowledgeBase,
        'apiAccess': apiAccess,
        'whiteLabel': whiteLabel,
      };
}

class SubscriptionPlan {
  final String id;
  final String name;
  final String description;
  final PlanPricing pricing;
  final PlanLimits limits;
  final PlanFeatures features;
  final List<String> allowedModels;
  final bool isActive;

  SubscriptionPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.pricing,
    required this.limits,
    required this.features,
    required this.allowedModels,
    required this.isActive,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      pricing: PlanPricing.fromJson(json['pricing'] as Map<String, dynamic>? ?? {}),
      limits: PlanLimits.fromJson(json['limits'] as Map<String, dynamic>? ?? {}),
      features: PlanFeatures.fromJson(json['features'] as Map<String, dynamic>? ?? {}),
      allowedModels: (json['allowedModels'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      isActive: json['isActive'] as bool? ?? true,
    );
  }
}

class SubscriptionsService {
  static const String _baseUrl = String.fromEnvironment(
    'BACKEND_URL',
    defaultValue: 'https://kanngrowbackend-production.up.railway.app/api/v1',
  );

  static Future<Map<String, String>> _headers() async {
    final token = await TokenService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<List<SubscriptionPlan>> getPlans() async {
    final uri = Uri.parse('$_baseUrl/admin/plans');
    final response = await http.get(uri, headers: await _headers());

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final list = body['data'] as List<dynamic>? ?? [];
      return list.map((e) => SubscriptionPlan.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to load subscription plans: ${response.body}');
    }
  }

  static Future<void> updatePlan(String planId, Map<String, dynamic> updateData) async {
    final uri = Uri.parse('$_baseUrl/admin/plans/$planId');
    final response = await http.put(
      uri,
      headers: await _headers(),
      body: jsonEncode(updateData),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update plan: ${response.body}');
    }
  }
}
