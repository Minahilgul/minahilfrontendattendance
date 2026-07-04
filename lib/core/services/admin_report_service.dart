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

  static Future<Map<String, dynamic>> getStats({
    int? classId,
    int? teacherId,
    int? days,
    String? date,
    String? startDate,
    String? endDate,
    String? status,
    int? sessionId,
    String? studentName,
    int? studentId,
  }) async {
    try {
      final params = {
        if (days != null) 'days': days.toString(),
        if (classId != null) 'class_id': classId.toString(),
        if (teacherId != null) 'teacher_id': teacherId.toString(),
        if (date != null) 'date': date,
        if (startDate != null) 'start_date': startDate,
        if (endDate != null) 'end_date': endDate,
        if (status != null) 'status': status,
        if (sessionId != null) 'session_id': sessionId.toString(),
        if (studentName != null) 'student_name': studentName,
        if (studentId != null) 'student_id': studentId.toString(),
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

  static Future<List<Map<String, dynamic>>> getChartData({
    int? classId,
    int? teacherId,
    int? days,
    String? date,
    String? startDate,
    String? endDate,
    String? status,
    int? sessionId,
    String? studentName,
    int? studentId,
  }) async {
    try {
      final params = {
        if (days != null) 'days': days.toString(),
        if (classId != null) 'class_id': classId.toString(),
        if (teacherId != null) 'teacher_id': teacherId.toString(),
        if (date != null) 'date': date,
        if (startDate != null) 'start_date': startDate,
        if (endDate != null) 'end_date': endDate,
        if (status != null) 'status': status,
        if (sessionId != null) 'session_id': sessionId.toString(),
        if (studentName != null) 'student_name': studentName,
        if (studentId != null) 'student_id': studentId.toString(),
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

  static Future<List<Map<String, dynamic>>> getStudentsList({
    int? classId,
    int? teacherId,
    int? days,
    String? date,
    String? startDate,
    String? endDate,
    String? status,
    int? sessionId,
    String? studentName,
    int? studentId,
  }) async {
    try {
      final params = {
        if (days != null) 'days': days.toString(),
        if (classId != null) 'class_id': classId.toString(),
        if (teacherId != null) 'teacher_id': teacherId.toString(),
        if (date != null) 'date': date,
        if (startDate != null) 'start_date': startDate,
        if (endDate != null) 'end_date': endDate,
        if (status != null) 'status': status,
        if (sessionId != null) 'session_id': sessionId.toString(),
        if (studentName != null) 'student_name': studentName,
        if (studentId != null) 'student_id': studentId.toString(),
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

  static Future<Map<String, dynamic>> getStudentReport(int studentId) async {
    try {
      final res = await http.get(Uri.parse('$_baseUrl/admin/reports/student/$studentId'),
          headers: _headers());
      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
      return {};
    } catch (e) {
      return {};
    }
  }

  static Future<Map<String, dynamic>> updateAttendance(int attendanceId, String status) async {
    try {
      final res = await http.put(
        Uri.parse('$_baseUrl/admin/reports/attendance/$attendanceId'),
        headers: _headers(),
        body: jsonEncode({'status': status.toLowerCase()}),
      );
      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
      return {'success': false, 'message': 'HTTP Status ${res.statusCode}'};
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  // ── NEW: Sessions list (for Total Sessions card tap) ──
  static Future<List<Map<String, dynamic>>> getSessions() async {
    try {
      final res = await http.get(Uri.parse('$_baseUrl/sessions'), headers: _headers());
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return List<Map<String, dynamic>>.from(data['data'] ?? []);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // ── NEW: Toggle a session's active/inactive status ──
  static Future<Map<String, dynamic>> toggleSessionStatus(int sessionId) async {
    try {
      final res = await http.post(
        Uri.parse('$_baseUrl/sessions/$sessionId/toggle-status'),
        headers: _headers(),
      );
      if (res.statusCode == 200) return jsonDecode(res.body);
      return {'success': false, 'message': 'HTTP Status ${res.statusCode}'};
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }
}