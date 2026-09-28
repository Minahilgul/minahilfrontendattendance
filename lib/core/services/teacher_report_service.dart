import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import '../config/environment.dart';

class TeacherReportService {
  static const String _baseUrl = Environment.apiBaseUrl;

  static Map<String, String> _headers() {
    final token = GetStorage().read<String>('token');
    return {
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Map<String, String> _cleanParams(Map<String, dynamic> raw) {
    final p = <String, String>{};
    raw.forEach((k, v) {
      if (v != null && v.toString().isNotEmpty) p[k] = v.toString();
    });
    return p;
  }

  // Generic GET used by the summary endpoints below.
  static Future<dynamic> _getJson(String path, Map<String, dynamic> params) async {
    final uri = Uri.parse('$_baseUrl$path')
        .replace(queryParameters: _cleanParams(params));
    final res = await http.get(uri, headers: _headers());
    if (res.statusCode == 200) return jsonDecode(res.body);
    if (res.statusCode == 403) throw Exception('Unauthorized Access');
    return null;
  }

  // The summary endpoints share the admin controller's response shape.
  // Accept a bare list, or a list under a common key, or the first list found.
  static List<Map<String, dynamic>> _extractList(dynamic body, List<String> keys) {
    List<Map<String, dynamic>> toList(List l) =>
        l.map((e) => Map<String, dynamic>.from(e as Map)).toList();

    if (body is List) return toList(body);
    if (body is Map) {
      for (final k in keys) {
        final v = body[k];
        if (v is List) return toList(v);
      }
      for (final v in body.values) {
        if (v is List) return toList(v);
      }
    }
    return [];
  }

  // GET /api/teacher/reports/stats
  static Future<Map<String, dynamic>> getMyStats({
    int? classId,
    String? date,
    String? startDate,
    String? endDate,
    int? days,
    String? status,
    int? sessionId,
    String? studentName,
  }) async {
    final uri = Uri.parse('$_baseUrl/teacher/reports/stats').replace(
      queryParameters: _cleanParams({
        'class_id': classId,
        'date': date,
        'start_date': startDate,
        'end_date': endDate,
        'days': days,
        'status': status,
        'session_id': sessionId,
        'student_name': studentName,
      }),
    );
    final res = await http.get(uri, headers: _headers());
    if (res.statusCode == 200) return jsonDecode(res.body);
    if (res.statusCode == 403) throw Exception('Unauthorized Access');
    return {};
  }

  // GET /api/teacher/reports/chart
  static Future<List<Map<String, dynamic>>> getChartData({
    int? classId,
    String? date,
    String? startDate,
    String? endDate,
    int? days,
    String? status,
    int? sessionId,
    String? studentName,
  }) async {
    final uri = Uri.parse('$_baseUrl/teacher/reports/chart').replace(
      queryParameters: _cleanParams({
        'class_id': classId,
        'date': date,
        'start_date': startDate,
        'end_date': endDate,
        'days': days,
        'status': status,
        'session_id': sessionId,
        'student_name': studentName,
      }),
    );
    final res = await http.get(uri, headers: _headers());
    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      return List<Map<String, dynamic>>.from(body['chart'] ?? []);
    }
    if (res.statusCode == 403) throw Exception('Unauthorized Access');
    return [];
  }

  // GET /api/teacher/reports/students supports class_id, student_id, student_ids, date range
  static Future<List<Map<String, dynamic>>> getMyStudents({
    int? classId,
    int? studentId,
    List<int>? studentIds,
    String? studentName,
    String? date,
    String? startDate,
    String? endDate,
    int? days,
    String? status,
    int? sessionId,
  }) async {
    final uri = Uri.parse('$_baseUrl/teacher/reports/students').replace(
      queryParameters: _cleanParams({
        'class_id': classId,
        'student_id': studentId,
        'student_ids': studentIds?.join(','),
        'student_name': studentName,
        'date': date,
        'start_date': startDate,
        'end_date': endDate,
        'days': days,
        'status': status,
        'session_id': sessionId,
      }),
    );
    final res = await http.get(uri, headers: _headers());
    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      return List<Map<String, dynamic>>.from(body['students'] ?? []);
    }
    if (res.statusCode == 403) throw Exception('Unauthorized Access');
    return [];
  }

  // GET /api/teacher/reports/student/{id}
  static Future<Map<String, dynamic>> getStudentReport(
    int studentId, {
    String? startDate,
    String? endDate,
  }) async {
    final uri =
        Uri.parse('$_baseUrl/teacher/reports/student/$studentId').replace(
      queryParameters: _cleanParams({
        'start_date': startDate,
        'end_date': endDate,
      }),
    );
    final res = await http.get(uri, headers: _headers());
    if (res.statusCode == 200) return jsonDecode(res.body);
    if (res.statusCode == 403) throw Exception('Unauthorized Access');
    return {};
  }

  // GET /api/teacher/reports/sessions-summary  (was missing on the Flutter side)
  static Future<List<Map<String, dynamic>>> getSessionsSummary({
    int? classId,
    int? days,
    String? date,
    String? startDate,
    String? endDate,
    String? status,
  }) async {
    final body = await _getJson('/teacher/reports/sessions-summary', {
      'class_id': classId,
      'days': days,
      'date': date,
      'start_date': startDate,
      'end_date': endDate,
      'status': status,
    });
    return _extractList(body, ['sessions', 'data', 'summary']);
  }

  // GET /api/teacher/reports/classes-summary  (was missing on the Flutter side)
  static Future<List<Map<String, dynamic>>> getClassesSummary({
    int? days,
    String? date,
    String? startDate,
    String? endDate,
  }) async {
    final body = await _getJson('/teacher/reports/classes-summary', {
      'days': days,
      'date': date,
      'start_date': startDate,
      'end_date': endDate,
    });
    return _extractList(body, ['classes', 'data', 'summary']);
  }
}