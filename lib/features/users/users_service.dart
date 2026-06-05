import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../services/token_service.dart';

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
}
