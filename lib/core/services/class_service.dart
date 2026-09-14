import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class ClassService {
  // ============================================================
  // FETCH ALL CLASSES (subject-offerings: one entry per class+subject+teacher)
  // Use this for: session creation, teacher's own class list.
  // ============================================================

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

      print('FETCH CLASSES STATUS: ${response.statusCode}');
      print('FETCH CLASSES RESPONSE: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        final List data = jsonData is Map
            ? (jsonData['data'] ?? [])
            : (jsonData is List ? jsonData : []);

        return data
            .map<Map<String, dynamic>>(
              (item) => Map<String, dynamic>.from(item),
            )
            .toList();
      }

      return [];
    } catch (e) {
      print('FETCH CLASSES SERVICE ERROR: $e');
      return [];
    }
  }

  // ============================================================
  // FETCH ALL CLASS GROUPS (physical classes, e.g. "BS Zoology")
  // Use this for: student enrollment / editing a student's class —
  // NOT fetchClasses() above, since that returns one row per subject
  // and would double-list the same physical class.
  // ============================================================

  static Future<List<Map<String, dynamic>>> fetchClassGroups() async {
    try {
      final token = await AuthService.getToken();

      final response = await http.get(
        Uri.parse('${AuthService.baseUrl}/class-groups'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('FETCH CLASS GROUPS STATUS: ${response.statusCode}');
      print('FETCH CLASS GROUPS RESPONSE: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        final List data = jsonData is Map
            ? (jsonData['data'] ?? [])
            : (jsonData is List ? jsonData : []);

        return data
            .map<Map<String, dynamic>>(
              (item) => Map<String, dynamic>.from(item),
            )
            .toList();
      }

      return [];
    } catch (e) {
      print('FETCH CLASS GROUPS SERVICE ERROR: $e');
      return [];
    }
  }


  // FETCH ALL TEACHERS


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

      print('FETCH TEACHERS STATUS: ${response.statusCode}');
      print('FETCH TEACHERS RESPONSE: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        final List data = jsonData is Map
            ? (jsonData['data'] ?? [])
            : (jsonData is List ? jsonData : []);

        return data
            .map<Map<String, dynamic>>(
              (item) => Map<String, dynamic>.from(item),
            )
            .toList();
      }

      return [];
    } catch (e) {
      print('FETCH TEACHERS SERVICE ERROR: $e');
      return [];
    }
  }

  // ============================================================
  // CREATE CLASS
  // ============================================================

  static Future<bool> createClass({
    required String name,
    int? teacherId,
    required String className,
    required String students,
    String subject = '',
    String status = 'active',
  }) async {
    try {
      final token = await AuthService.getToken();

      final Map<String, dynamic> body = {
        'name': name,
        'class_name': className,
        'students_count': int.tryParse(students) ?? 0,
        'status': status,
      };

      // Teacher
      if (teacherId != null) {
        body['teacher_id'] = teacherId;
      }

      // Subject
      body['subject'] = subject.trim();

      print('CREATE CLASS BODY: ${jsonEncode(body)}');

      final response = await http.post(
        Uri.parse('${AuthService.baseUrl}/classes'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      print('CREATE CLASS STATUS: ${response.statusCode}');
      print('CREATE CLASS RESPONSE: ${response.body}');

      return response.statusCode == 200 ||
          response.statusCode == 201;
    } catch (e) {
      print('CREATE CLASS SERVICE ERROR: $e');
      return false;
    }
  }

  // ============================================================
  // UPDATE CLASS
  // ============================================================

  static Future<bool> updateClass({
    required int id,
    required String name,
    int? teacherId,
    required String className,
    required String students,
    String subject = '',
    String status = 'active',
  }) async {
    try {
      final token = await AuthService.getToken();

      final Map<String, dynamic> body = {
        'name': name,
        'class_name': className,
        'students_count': int.tryParse(students) ?? 0,
        'status': status,
      };

      // Teacher
      if (teacherId != null) {
        body['teacher_id'] = teacherId;
      }

      // Subject
      body['subject'] = subject.trim();

      print('UPDATE CLASS BODY: ${jsonEncode(body)}');

      final response = await http.put(
        Uri.parse('${AuthService.baseUrl}/classes/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      print('UPDATE CLASS STATUS: ${response.statusCode}');
      print('UPDATE CLASS RESPONSE: ${response.body}');

      return response.statusCode == 200;
    } catch (e) {
      print('UPDATE CLASS SERVICE ERROR: $e');
      return false;
    }
  }

  // ============================================================
  // DELETE CLASS
  // ============================================================

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

      print('DELETE CLASS STATUS: ${response.statusCode}');
      print('DELETE CLASS RESPONSE: ${response.body}');

      return response.statusCode == 200 ||
          response.statusCode == 204;
    } catch (e) {
      print('DELETE CLASS SERVICE ERROR: $e');
      return false;
    }
  }
}