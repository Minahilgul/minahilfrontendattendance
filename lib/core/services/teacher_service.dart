import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class TeacherService {
  static Future<List<Map<String, dynamic>>> fetchTeachers() async {
    try {
      final response = await http.get(
        Uri.parse('${AuthService.baseUrl}/teachers'),
        headers: {'Accept': 'application/json'},
      );
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final List data = jsonData['data'] ?? jsonData;
        return List<Map<String, dynamic>>.from(data);
      }
      return [];
    } catch (e) {
      print("FETCH TEACHERS SERVICE ERROR: $e");
      return [];
    }
  }

  static Future<bool> addTeacher({
    required String username,
    required String email,
    required String password,
    required String phone,
  }) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.post(
        Uri.parse('${AuthService.baseUrl}/teachers'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
          'phone': phone,
        }),
      );

      print("ADD TEACHER STATUS: ${response.statusCode}");
      print("ADD TEACHER RESPONSE: ${response.body}");

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("ADD TEACHER SERVICE ERROR: $e");
      return false;
    }
  }

  static Future<bool> updateTeacher({
    required int id,
    required String username,
    required String email,
    required String phone,
  }) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.put(
        Uri.parse('${AuthService.baseUrl}/teachers/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'username': username,
          'email': email,
          'phone': phone,
        }),
      );

      print("UPDATE TEACHER STATUS: ${response.statusCode}");
      print("UPDATE TEACHER RESPONSE: ${response.body}");

      return response.statusCode == 200;
    } catch (e) {
      print("UPDATE TEACHER SERVICE ERROR: $e");
      return false;
    }
  }

  static Future<bool> deleteTeacher(int id) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.delete(
        Uri.parse('${AuthService.baseUrl}/teachers/$id'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      print("DELETE TEACHER STATUS: ${response.statusCode}");
      return response.statusCode == 200;
    } catch (e) {
      print("DELETE TEACHER SERVICE ERROR: $e");
      return false;
    }
  }
}
