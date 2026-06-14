import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  // 🔥 BASE URL - Web ke liye localhost nahi, 127.0.0.1 rakho
  static const String baseUrl = 'http://localhost:8000/api';
  // static const String baseUrl = 'http://attia.ddev.site/api';

  static Map<String, dynamic>? currentUser;
  static String? token;
  static const FlutterSecureStorage storage = FlutterSecureStorage();

  // ───────────────── LOGIN ─────────────────
  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({"email": email, "password": password}),
      );

      print("LOGIN STATUS: ${response.statusCode}");
      print("LOGIN BODY: ${response.body}");

      final contentType = response.headers['content-type'] ?? '';
      if (!contentType.contains('application/json')) {
        return {
          "success": false,
          "message": "Server error (${response.statusCode})"
        };
      }

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final result = data['result'] ?? {};
        token = result['token'] ?? '';
        currentUser = result;
        await storage.write(key: 'token', value: token);
        await storage.write(key: 'user', value: jsonEncode(currentUser));
        print("Token saved: $token");
        return data;
      } else {
        return {
          "success": false,
          "message": data['message'] ?? 'Login failed'
        };
      }
    } catch (e) {
      print("LOGIN ERROR: $e");
      return {"success": false, "message": "Server error: $e"};
    }
  }

  // ───────────────── REGISTER ─────────────────
  static Future<Map<String, dynamic>> register(
      Map<String, dynamic> body) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/signup'),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode(body),
      );

      print("REGISTER STATUS: ${response.statusCode}");
      print("REGISTER BODY: ${response.body}");

      final contentType = response.headers['content-type'] ?? '';
      if (!contentType.contains('application/json')) {
        return {
          "success": false,
          "message": "Server error (${response.statusCode})"
        };
      }

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {"success": true};
      } else {
        return {
          "success": false,
          "message": data['message'] ?? 'Registration failed'
        };
      }
    } catch (e) {
      print("REGISTER ERROR: $e");
      return {"success": false, "message": "Server error: $e"};
    }
  }

  // ───────────────── GET TOKEN ─────────────────
  static Future<String?> getToken() async {
    if (token == null) {
      token = await storage.read(key: 'token');
    }
    print("GET TOKEN: $token");
    return token;
  }

  // ───────────────── LOAD TOKEN ─────────────────
  static Future<void> loadToken() async {
    token = await storage.read(key: 'token');
    final String? userJson = await storage.read(key: 'user');
    if (userJson != null) {
      currentUser = jsonDecode(userJson);
    }
    print("Token Loaded: $token");
    print("User Loaded: $currentUser");
  }

  // ───────────────── LOGOUT ─────────────────
  static Future<void> logout() async {
    token = null;
    currentUser = null;
    await storage.delete(key: 'token');
    await storage.delete(key: 'user');
  }
}