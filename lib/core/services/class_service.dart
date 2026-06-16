import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class ClassService {
  // ─────────────────────────────────────────────
  // FETCH ALL CLASSES
  // ─────────────────────────────────────────────
  static Future<List<Map<String, dynamic>>> fetchClasses() async {
    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse('${AuthService.baseUrl}/classes'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final List data = jsonData['data'] ?? jsonData;
        return List<Map<String, dynamic>>.from(data);
      }
      return [];
    } catch (e) {
      print("FETCH CLASSES SERVICE ERROR: $e");
      return [];
    }
  }

  // ─────────────────────────────────────────────
  // FETCH ALL TEACHERS (for dropdown)
  // ─────────────────────────────────────────────
  static Future<List<Map<String, dynamic>>> fetchTeachers() async {
    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse('${AuthService.baseUrl}/teachers'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
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

  // ─────────────────────────────────────────────
  // CREATE CLASS
  // ─────────────────────────────────────────────
  static Future<bool> createClass({
    required String name,
    required String className,
    required String students,
  }) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.post(
        Uri.parse('${AuthService.baseUrl}/classes'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'name': name,
          'class_name': className,
          'students_count': int.tryParse(students) ?? 0,
          'status': 'active',
        }),
      );
      print("CREATE CLASS STATUS: ${response.statusCode}");
      print("CREATE CLASS RESPONSE: ${response.body}");
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("CREATE CLASS SERVICE ERROR: $e");
      return false;
    }
  }

  // ─────────────────────────────────────────────
  // UPDATE CLASS
  // ─────────────────────────────────────────────
  static Future<bool> updateClass({
    required int id,
    required String name,
    required String className,
    required String students,
    String status = 'active',
  }) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.put(
        Uri.parse('${AuthService.baseUrl}/classes/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'name': name,
          'class_name': className,
          'students_count': int.tryParse(students) ?? 0,
          'status': status,
        }),
      );
      print("UPDATE CLASS STATUS: ${response.statusCode}");
      print("UPDATE CLASS RESPONSE: ${response.body}");
      return response.statusCode == 200;
    } catch (e) {
      print("UPDATE CLASS SERVICE ERROR: $e");
      return false;
    }
  }

  // ─────────────────────────────────────────────
  // DELETE CLASS
  // ─────────────────────────────────────────────
  static Future<bool> deleteClass(int id) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.delete(
        Uri.parse('${AuthService.baseUrl}/classes/$id'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      print("DELETE CLASS STATUS: ${response.statusCode}");
      return response.statusCode == 200;
    } catch (e) {
      print("DELETE CLASS SERVICE ERROR: $e");
      return false;
    }
  }
}