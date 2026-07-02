import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';

class AdminReportService {
  static const String _baseUrl = 'http://localhost:8000/api';

  static String? _getToken() => GetStorage().read('token');

  static Map<String, String> _headers() {
    final token = _getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<Map<String, dynamic>> getStats(
      {int? classId, int? teacherId, int days = 7}) async {
    try {
      final params = {
        'days': days.toString(),
        if (classId != null) 'class_id': classId.toString(),
        if (teacherId != null) 'teacher_id': teacherId.toString(),
      };
      final uri = Uri.parse('$_baseUrl/admin/reports/stats')
          .replace(queryParameters: params);
      final res = await http.get(uri, headers: _headers());
      if (res.statusCode == 200) return jsonDecode(res.body);
      return {};
    } catch (e) {
      return {};
    }
  }

  static Future<List<Map<String, dynamic>>> getChartData(
      {int? classId, int? teacherId, int days = 7}) async {
    try {
      final params = {
        'days': days.toString(),
        if (classId != null) 'class_id': classId.toString(),
        if (teacherId != null) 'teacher_id': teacherId.toString(),
      };
      final uri = Uri.parse('$_baseUrl/admin/reports/chart')
          .replace(queryParameters: params);
      final res = await http.get(uri, headers: _headers());
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return List<Map<String, dynamic>>.from(data['chart'] ?? []);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getStudentsList(
      {int? classId, int? teacherId, int days = 7}) async {
    try {
      final params = {
        'days': days.toString(),
        if (classId != null) 'class_id': classId.toString(),
        if (teacherId != null) 'teacher_id': teacherId.toString(),
      };
      final uri = Uri.parse('$_baseUrl/admin/reports/students')
          .replace(queryParameters: params);
      final res = await http.get(uri, headers: _headers());
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return List<Map<String, dynamic>>.from(data['students'] ?? []);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getClasses() async {
    try {
      final res = await http.get(Uri.parse('$_baseUrl/admin/reports/classes'),
          headers: _headers());
      if (res.statusCode == 200) {
        return List<Map<String, dynamic>>.from(
            jsonDecode(res.body)['classes'] ?? []);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getTeachers() async {
    try {
      final res = await http.get(Uri.parse('$_baseUrl/admin/reports/teachers'),
          headers: _headers());
      if (res.statusCode == 200) {
        return List<Map<String, dynamic>>.from(
            jsonDecode(res.body)['teachers'] ?? []);
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
