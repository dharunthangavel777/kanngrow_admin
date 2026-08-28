import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../services/token_service.dart';
import '../../core/admin_network_config.dart';

class PlatformContextPin {
  final String id;
  final String text;
  final bool isActive;
  final String createdBy;
  final String createdAt;

  PlatformContextPin({
    required this.id,
    required this.text,
    required this.isActive,
    required this.createdBy,
    required this.createdAt,
  });

  factory PlatformContextPin.fromJson(Map<String, dynamic> json) {
    return PlatformContextPin(
      id: json['id'] as String? ?? '',
      text: json['text'] as String? ?? '',
      isActive: json['isActive'] as bool? ?? true,
      createdBy: json['createdBy'] as String? ?? 'admin',
      createdAt: json['createdAt'] as String? ?? '',
    );
  }
}

class PlatformContextService {
  static String get _baseUrl => AdminNetworkConfig.baseUrl;

  static Future<Map<String, String>> _headers() async {
    final token = await TokenService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<List<PlatformContextPin>> getPins() async {
    final uri = Uri.parse('$_baseUrl/admin/platform-context');
    final response = await http.post(
      uri,
      headers: await _headers(),
      body: jsonEncode({'action': 'list'}),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final list = body['data'] as List<dynamic>? ?? [];
      return list.map((e) => PlatformContextPin.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to load platform context pins: ${response.body}');
    }
  }

  static Future<PlatformContextPin> addPin(String text) async {
    final uri = Uri.parse('$_baseUrl/admin/platform-context');
    final response = await http.post(
      uri,
      headers: await _headers(),
      body: jsonEncode({
        'action': 'add',
        'text': text,
      }),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return PlatformContextPin.fromJson(body['data'] as Map<String, dynamic>);
    } else {
      throw Exception('Failed to add platform context pin: ${response.body}');
    }
  }

  static Future<void> togglePin(String id, bool isActive) async {
    final uri = Uri.parse('$_baseUrl/admin/platform-context');
    final response = await http.post(
      uri,
      headers: await _headers(),
      body: jsonEncode({
        'action': 'toggle',
        'id': id,
        'isActive': isActive,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to toggle platform context pin: ${response.body}');
    }
  }

  static Future<void> deletePin(String id) async {
    final uri = Uri.parse('$_baseUrl/admin/platform-context');
    final response = await http.post(
      uri,
      headers: await _headers(),
      body: jsonEncode({
        'action': 'delete',
        'id': id,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete platform context pin: ${response.body}');
    }
  }
}
