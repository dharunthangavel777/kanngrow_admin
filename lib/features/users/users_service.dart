import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../services/token_service.dart';
import '../../core/admin_network_config.dart';

class AdminUser {
  final String id;
  final String name;
  final String email;
  final String createdAt;
  final bool isActive;

  AdminUser({
    required this.id,
    required this.name,
    required this.email,
    required this.createdAt,
    required this.isActive,
  });

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    return AdminUser(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Unknown',
      email: json['email'] as String? ?? '',
      createdAt: json['createdAt'] as String? ?? '',
      isActive: json['isActive'] as bool? ?? true,
    );
  }
}

class UsersService {
  static String get _baseUrl => AdminNetworkConfig.baseUrl;

  static Future<Map<String, String>> _headers() async {
    final token = await TokenService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<List<AdminUser>> getUsers({int limit = 50, String? startAfter}) async {
    final queryParams = <String, String>{
      'limit': limit.toString(),
      if (startAfter != null) 'startAfter': startAfter,
    };
    final uri = Uri.parse('$_baseUrl/admin/users').replace(queryParameters: queryParams);
    final response = await http.get(uri, headers: await _headers());

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final list = body['data'] as List<dynamic>? ?? [];
      return list.map((e) => AdminUser.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to load users: ${response.body}');
    }
  }

  static Future<void> suspendUser(String id) async {
    final uri = Uri.parse('$_baseUrl/admin/users/$id/suspend');
    final response = await http.post(uri, headers: await _headers());
    if (response.statusCode != 200) {
      throw Exception('Failed to suspend user: ${response.body}');
    }
  }

  static Future<void> restoreUser(String id) async {
    final uri = Uri.parse('$_baseUrl/admin/users/$id/restore');
    final response = await http.post(uri, headers: await _headers());
    if (response.statusCode != 200) {
      throw Exception('Failed to restore user: ${response.body}');
    }
  }

  static Future<void> deleteUser(String id) async {
    final uri = Uri.parse('$_baseUrl/admin/users/$id');
    final response = await http.delete(uri, headers: await _headers());
    if (response.statusCode != 200) {
      throw Exception('Failed to delete user: ${response.body}');
    }
  }

  static Future<void> overrideUserLimits(
    String id, {
    Map<String, dynamic>? limitOverrides,
    Map<String, bool>? featuresEnabled,
    String? reason,
  }) async {
    final uri = Uri.parse('$_baseUrl/admin/users/$id/override');
    final response = await http.post(
      uri,
      headers: await _headers(),
      body: jsonEncode({
        if (limitOverrides != null) 'limitOverrides': limitOverrides,
        if (featuresEnabled != null) 'featuresEnabled': featuresEnabled,
        if (reason != null) 'reason': reason,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to override user limits: ${response.body}');
    }
  }

  static Future<void> assignUserPlan(
    String id, {
    required String tier,
    String status = 'active',
    required String sourceType,
    required bool isLifetime,
    String? expiryDate,
    String? notes,
  }) async {
    final uri = Uri.parse('$_baseUrl/admin/users/$id/assign-plan');
    final response = await http.post(
      uri,
      headers: await _headers(),
      body: jsonEncode({
        'tier': tier,
        'status': status,
        'source_type': sourceType,
        'is_lifetime': isLifetime,
        if (expiryDate != null) 'expiry_date': expiryDate,
        if (notes != null) 'notes': notes,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to assign user plan: ${response.body}');
    }
  }

  static Future<List<AdminAuditLog>> getAuditLogs({int limit = 50, String? startAfter}) async {
    final queryParams = <String, String>{
      'limit': limit.toString(),
      if (startAfter != null) 'startAfter': startAfter,
    };
    final uri = Uri.parse('$_baseUrl/admin/audit-logs').replace(queryParameters: queryParams);
    final response = await http.get(uri, headers: await _headers());

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final list = body['data'] as List<dynamic>? ?? [];
      return list.map((e) => AdminAuditLog.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to load audit logs: ${response.body}');
    }
  }
}

class AdminAuditLog {
  final String id;
  final String adminId;
  final String adminName;
  final String userId;
  final String userName;
  final String previousPlan;
  final String newPlan;
  final String timestamp;
  final String reason;
  final String sourceType;

  AdminAuditLog({
    required this.id,
    required this.adminId,
    required this.adminName,
    required this.userId,
    required this.userName,
    required this.previousPlan,
    required this.newPlan,
    required this.timestamp,
    required this.reason,
    required this.sourceType,
  });

  factory AdminAuditLog.fromJson(Map<String, dynamic> json) {
    return AdminAuditLog(
      id: json['id'] as String? ?? '',
      adminId: json['adminId'] as String? ?? '',
      adminName: json['adminName'] as String? ?? 'Admin',
      userId: json['userId'] as String? ?? '',
      userName: json['userName'] as String? ?? 'User',
      previousPlan: json['previousPlan'] as String? ?? 'free',
      newPlan: json['newPlan'] as String? ?? 'free',
      timestamp: json['timestamp'] as String? ?? '',
      reason: json['reason'] as String? ?? '',
      sourceType: json['sourceType'] as String? ?? 'admin_assignment',
    );
  }
}
