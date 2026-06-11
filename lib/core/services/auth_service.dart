import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  // 🔥 BASE URL (👇 YAHAN CHANGE KARNA HAI)
  static const String baseUrl = 'http://attia.ddev.site/api';

  // ───────────────── LOGIN ─────────────────
  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'), // 👈 endpoint
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
        const storage = FlutterSecureStorage();
        await storage.write(key: 'token', value: data['result']['token']); 

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
        Uri.parse('$baseUrl/signup'), // 👈 endpoint
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
    const storage = FlutterSecureStorage();
    return await storage.read(key: 'token');
  }
}
