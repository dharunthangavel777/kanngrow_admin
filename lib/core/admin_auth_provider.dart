import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class AdminAuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  String? _email;
  String? _error;
  bool _isLoading = false;

  bool get isLoggedIn => _isLoggedIn;
  String? get email => _email;
  String? get error => _error;
  bool get isLoading => _isLoading;

  AdminAuthProvider() {
    _init();
  }

  void _init() {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      _isLoggedIn = user != null;
      _email = user?.email;
      notifyListeners();
    });
  }

  String get _baseUrl {
    return 'https://kanngrowbackend-production.up.railway.app/api/v1/admin/auth';
  }

  Future<bool> sendOtp(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/send-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        _email = email;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = data['message'] ?? 'Failed to send OTP';
      }
    } catch (e) {
      _error = 'Network error: Make sure backend is running. ($e)';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> verifyOtp(String email, String otp) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'otp': otp}),
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final customToken = data['data']['customToken'];
        
        // Sign in with Firebase Custom Token
        final cred = await FirebaseAuth.instance.signInWithCustomToken(customToken);
        
        _isLoggedIn = true;
        _email = cred.user?.email ?? email;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = data['message'] ?? 'Failed to verify OTP';
      }
    } on FirebaseAuthException catch (e) {
      _error = e.message ?? 'Firebase Auth failed';
    } catch (e) {
      _error = 'Network error occurred: $e';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  void logout() async {
    await FirebaseAuth.instance.signOut();
    _isLoggedIn = false;
    _email = null;
    _error = null;
    notifyListeners();
  }
}
