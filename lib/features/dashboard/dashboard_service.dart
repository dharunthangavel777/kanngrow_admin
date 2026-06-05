import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../services/token_service.dart';

class DashboardStats {
  final int totalUsers;
  final int totalChats;
  final int ideasCount;
  final int vendorsCount;
  final int schemesCount;
  final int reportsCount;

  DashboardStats({
    required this.totalUsers,
    required this.totalChats,
    required this.ideasCount,
    required this.vendorsCount,
    required this.schemesCount,
    required this.reportsCount,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    final kb = data['knowledgeBase'] as Map<String, dynamic>? ?? {};
    return DashboardStats(
      totalUsers: data['totalUsers'] as int? ?? 0,
      totalChats: data['totalChats'] as int? ?? 0,
      ideasCount: kb['ideas'] as int? ?? 0,
      vendorsCount: kb['vendors'] as int? ?? 0,
      schemesCount: kb['govtSchemes'] as int? ?? 0,
      reportsCount: kb['marketReports'] as int? ?? 0,
    );
  }
}

class DashboardService {
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

  static Future<DashboardStats> getStats() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/admin/dashboard'),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      return DashboardStats.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load dashboard stats: ${response.body}');
    }
  }
}
