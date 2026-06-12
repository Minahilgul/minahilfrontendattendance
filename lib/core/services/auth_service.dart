import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  // 🔥 BASE URL - Web ke liye localhost nahi, 127.0.0.1 rakho
  // static const String baseUrl = 'http://localhost:8000/api';
  static const String baseUrl = 'http://attia.ddev.site/api';

  // ✅ Static variables add kiye
  static Map<String, dynamic>? currentUser;
  static String? token;
  static const FlutterSecureStorage storage = FlutterSecureStorage();

  // ───────────────── LOGIN ─────────────────
  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "password": password,
        }),
      );

      print("LOGIN STATUS: ${response.statusCode}");
      print("LOGIN RESPONSE: ${response.body}");

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        token = data['result']['token'];
        currentUser = data['user']; // ✅ User data save kar diya
        
        // Dono secure storage me save
        await storage.write(key: 'token', value: token);
        await storage.write(key: 'user', value: jsonEncode(currentUser));

        print("USER DATA: $currentUser");
        print("Token saved securely");
        return data;
      } else {
        return {"success": false, "message": data['message'] ?? 'Login failed'};
      }
    } catch (e) {
      print("LOGIN ERROR: $e");
      return {"success": false, "message": "Server error"};
    }
  }

  // ───────────────── REGISTER ─────────────────
  static Future<Map<String, dynamic>> register(
      Map<String, dynamic> body) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/signup'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      print("REGISTER STATUS: ${response.statusCode}");
      print("REGISTER RESPONSE: ${response.body}");

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
      return {"success": false, "message": "Server error"};
    }
  }

  // ───────────────── TOKEN ─────────────────
  static Future<String?> getToken() async {
    if (token == null) {
      token = await storage.read(key: 'token');
    }
    return token;
  }

  // ✅ NAYA FUNCTION: App start pe user bhi load karo
  static Future<void> loadToken() async {
    token = await storage.read(key: 'token');
    String? userJson = await storage.read(key: 'user');
    if (userJson != null) {
      currentUser = jsonDecode(userJson);
    }
    print("Secure Token Loaded: $token");
    print("User Loaded: $currentUser");
  }

  // ✅ LOGOUT
  static Future<void> logout() async {
    token = null;
    currentUser = null;
    await storage.delete(key: 'token');
    await storage.delete(key: 'user');
  }
}   