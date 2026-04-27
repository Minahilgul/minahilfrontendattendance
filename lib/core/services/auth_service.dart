import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';

class AuthService {
  // 🔥 BASE URL (👇 YAHAN CHANGE KARNA HAI)
  static const String baseUrl = 'https://wholesaleapp.sandbox.pk/api';

  // ───────────────── LOGIN ─────────────────
  static Future<Map<String, dynamic>> login(String email, String password) async {
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

      if (response.statusCode == 200) {
        final box = GetStorage();
        box.write('token', data['token']); // save token

        return {"success": true, "data": data};
      } else {
        return {
          "success": false,
          "message": data['message'] ?? 'Login failed'
        };
      }
    } catch (e) {
      print("LOGIN ERROR: $e");
      return {"success": false, "message": "Server error"};
    }
  }

  // ───────────────── REGISTER ─────────────────
  static Future<Map<String, dynamic>> register(Map<String, dynamic> body) async {
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

  // ───────────────── CREATE CLASS ─────────────────
  static Future<bool> createClass({
    required String name,
    required String className,
    required String students,
  }) async {
    try {
      final token = await getToken();

      final response = await http.post(
        Uri.parse('$baseUrl/classes'), // 👈 🔥 YAHAN REAL API ENDPOINT DALNA
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "name": name,
          "class_name": className,
          "students": students,
        }),
      );

      print("CREATE CLASS STATUS: ${response.statusCode}");
      print("CREATE CLASS RESPONSE: ${response.body}");

      return response.statusCode == 200 || response.statusCode == 201;

    } catch (e) {
      print("CREATE CLASS ERROR: $e");
      return false;
    }
  }

  // ───────────────── ADD TEACHER ─────────────────
  static Future<bool> addTeacher({
    required String username,
    required String email,
    required String password,
    required String phone,
  }) async {
    try {
      final token = await getToken();

      final response = await http.post(
        Uri.parse('$baseUrl/teachers'), // 👈 🔥 YAHAN REAL API ENDPOINT DALNA
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "username": username,
          "email": email,
          "password": password,
          "phone": phone,
        }),
      );

      print("ADD TEACHER STATUS: ${response.statusCode}");
      print("ADD TEACHER RESPONSE: ${response.body}");

      return response.statusCode == 200 || response.statusCode == 201;

    } catch (e) {
      print("ADD TEACHER ERROR: $e");
      return false;
    }
  }

  // ───────────────── TOKEN ─────────────────
  static Future<String?> getToken() async {
    final box = GetStorage();
    return box.read('token');
  }
}