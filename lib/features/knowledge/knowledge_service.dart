import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../services/token_service.dart';

class KnowledgeService {
  static const String _baseUrl = 'https://kanngrowbackend-production.up.railway.app/api/v1/knowledge';

  // Helper to construct headers with the auth token
  static Future<Map<String, String>> _getHeaders() async {
    final token = await TokenService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ── BUSINESS IDEAS ──

  static Future<List<dynamic>> getIdeas({String? category, double? investmentMax}) async {
    final queryParams = <String, String>{};
    if (category != null) queryParams['category'] = category;
    if (investmentMax != null) queryParams['investmentMax'] = investmentMax.toString();

    final uri = Uri.parse('$_baseUrl/ideas').replace(queryParameters: queryParams);
    final response = await http.get(uri, headers: await _getHeaders());

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['data'] as List<dynamic>;
    } else {
      throw Exception('Failed to fetch business ideas: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> createIdea(Map<String, dynamic> data) async {
    final uri = Uri.parse('$_baseUrl/ideas');
    final response = await http.post(
      uri,
      headers: await _getHeaders(),
      body: jsonEncode(data),
    );

    if (response.statusCode == 201) {
      final json = jsonDecode(response.body);
      return json['data'] as Map<String, dynamic>;
    } else {
      throw Exception('Failed to create business idea: ${response.body}');
    }
  }

  static Future<void> updateIdea(String id, Map<String, dynamic> data) async {
    final uri = Uri.parse('$_baseUrl/ideas/$id');
    final response = await http.put(
      uri,
      headers: await _getHeaders(),
      body: jsonEncode(data),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update business idea: ${response.body}');
    }
  }

  static Future<void> deleteIdea(String id) async {
    final uri = Uri.parse('$_baseUrl/ideas/$id');
    final response = await http.delete(uri, headers: await _getHeaders());

    if (response.statusCode != 200) {
      throw Exception('Failed to delete business idea: ${response.body}');
    }
  }

  // ── VENDORS ──

  static Future<List<dynamic>> getVendors({String? category}) async {
    final queryParams = <String, String>{};
    if (category != null) queryParams['category'] = category;

    final uri = Uri.parse('$_baseUrl/vendors').replace(queryParameters: queryParams);
    final response = await http.get(uri, headers: await _getHeaders());

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['data'] as List<dynamic>;
    } else {
      throw Exception('Failed to fetch vendors: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> createVendor(Map<String, dynamic> data) async {
    final uri = Uri.parse('$_baseUrl/vendors');
    final response = await http.post(
      uri,
      headers: await _getHeaders(),
      body: jsonEncode(data),
    );

    if (response.statusCode == 201) {
      final json = jsonDecode(response.body);
      return json['data'] as Map<String, dynamic>;
    } else {
      throw Exception('Failed to create vendor: ${response.body}');
    }
  }

  static Future<void> updateVendor(String id, Map<String, dynamic> data) async {
    final uri = Uri.parse('$_baseUrl/vendors/$id');
    final response = await http.put(
      uri,
      headers: await _getHeaders(),
      body: jsonEncode(data),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update vendor: ${response.body}');
    }
  }

  static Future<void> deleteVendor(String id) async {
    final uri = Uri.parse('$_baseUrl/vendors/$id');
    final response = await http.delete(uri, headers: await _getHeaders());

    if (response.statusCode != 200) {
      throw Exception('Failed to delete vendor: ${response.body}');
    }
  }

  // ── GOVT SCHEMES ──

  static Future<List<dynamic>> getSchemes({String? state, String? category}) async {
    final queryParams = <String, String>{};
    if (state != null) queryParams['state'] = state;
    if (category != null) queryParams['category'] = category;

    final uri = Uri.parse('$_baseUrl/schemes').replace(queryParameters: queryParams);
    final response = await http.get(uri, headers: await _getHeaders());

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['data'] as List<dynamic>;
    } else {
      throw Exception('Failed to fetch government schemes: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> createScheme(Map<String, dynamic> data) async {
    final uri = Uri.parse('$_baseUrl/schemes');
    final response = await http.post(
      uri,
      headers: await _getHeaders(),
      body: jsonEncode(data),
    );

    if (response.statusCode == 201) {
      final json = jsonDecode(response.body);
      return json['data'] as Map<String, dynamic>;
    } else {
      throw Exception('Failed to create government scheme: ${response.body}');
    }
  }

  static Future<void> updateScheme(String id, Map<String, dynamic> data) async {
    final uri = Uri.parse('$_baseUrl/schemes/$id');
    final response = await http.put(
      uri,
      headers: await _getHeaders(),
      body: jsonEncode(data),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update government scheme: ${response.body}');
    }
  }

  static Future<void> deleteScheme(String id) async {
    final uri = Uri.parse('$_baseUrl/schemes/$id');
    final response = await http.delete(uri, headers: await _getHeaders());

    if (response.statusCode != 200) {
      throw Exception('Failed to delete government scheme: ${response.body}');
    }
  }

  // ── MARKET REPORTS ──

  static Future<List<dynamic>> getMarketReports({String? type}) async {
    final queryParams = <String, String>{};
    if (type != null) queryParams['type'] = type;

    final uri = Uri.parse('$_baseUrl/market').replace(queryParameters: queryParams);
    final response = await http.get(uri, headers: await _getHeaders());

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['data'] as List<dynamic>;
    } else {
      throw Exception('Failed to fetch market reports: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> createMarketReport(Map<String, dynamic> data) async {
    final uri = Uri.parse('$_baseUrl/market');
    final response = await http.post(
      uri,
      headers: await _getHeaders(),
      body: jsonEncode(data),
    );

    if (response.statusCode == 201) {
      final json = jsonDecode(response.body);
      return json['data'] as Map<String, dynamic>;
    } else {
      throw Exception('Failed to create market report: ${response.body}');
    }
  }

  static Future<void> updateMarketReport(String id, Map<String, dynamic> data) async {
    final uri = Uri.parse('$_baseUrl/market/$id');
    final response = await http.put(
      uri,
      headers: await _getHeaders(),
      body: jsonEncode(data),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update market report: ${response.body}');
    }
  }

  static Future<void> deleteMarketReport(String id) async {
    final uri = Uri.parse('$_baseUrl/market/$id');
    final response = await http.delete(uri, headers: await _getHeaders());

    if (response.statusCode != 200) {
      throw Exception('Failed to delete market report: ${response.body}');
    }
  }

  // ── KNOWLEDGE BASE STATS ──

  static Future<Map<String, dynamic>> getStats() async {
    final uri = Uri.parse('$_baseUrl/stats');
    final response = await http.get(uri, headers: await _getHeaders());

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['data'] as Map<String, dynamic>;
    } else {
      throw Exception('Failed to fetch knowledge base stats: ${response.body}');
    }
  }

  // ── WEBSITE SYNC & HTML INGESTION ──

  static Future<Map<String, dynamic>> syncFromWebsite() async {
    final uri = Uri.parse('$_baseUrl/sync');
    final response = await http.post(uri, headers: await _getHeaders());

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['data'] as Map<String, dynamic>;
    } else {
      throw Exception('Failed to sync from website: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> importLocalHtml() async {
    final adminUrl = _baseUrl.replaceAll('/knowledge', '/admin');
    final uri = Uri.parse('$adminUrl/import-local-html');
    final response = await http.post(uri, headers: await _getHeaders());

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['data'] as Map<String, dynamic>;
    } else {
      throw Exception('Failed to import local HTML: ${response.body}');
    }
  }
}
