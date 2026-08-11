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

  // GET /api/teacher/reports/stats
  static Future<Map<String, dynamic>> getMyStats({
    String? date,
    String? startDate,
    String? endDate,
    int? days,
    String? status,
  }) async {
    final uri = Uri.parse('$_baseUrl/teacher/reports/stats').replace(
      queryParameters: _cleanParams({
        'date': date,
        'start_date': startDate,
        'end_date': endDate,
        'days': days,
        'status': status,
      }),
    );
    final res = await http.get(uri, headers: _headers());
    if (res.statusCode == 200) return jsonDecode(res.body);
    if (res.statusCode == 403) throw Exception('Unauthorized Access');
    return {};
  }

  // GET /api/teacher/reports/students  — supports class_id, student_id, student_ids, date range
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

  // GET /api/teacher/reports/student/{id}  — supports optional start_date/end_date
  static Future<Map<String, dynamic>> getStudentReport(
    int studentId, {
    String? startDate,
    String? endDate,
  }) async {
    final uri = Uri.parse('$_baseUrl/teacher/reports/student/$studentId').replace(
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
}