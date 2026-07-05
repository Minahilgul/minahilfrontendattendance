import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import 'file_saver_stub.dart'
    if (dart.library.html) 'file_saver_web.dart'
    if (dart.library.io) 'file_saver_io.dart' as file_saver;

class AdminReportExportService {
  static const String _baseUrl = 'http://localhost:8000/api';

  static String? _getToken() => GetStorage().read('token');

  static Map<String, String> _headers() {
    final token = _getToken();
    return {
      'Accept': 'application/octet-stream',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static String _buildQuery(Map<String, dynamic> filters) {
    final params = <String, String>{};
    filters.forEach((key, value) {
      if (value != null && value.toString().isNotEmpty) {
        params[key] = value.toString();
      }
    });
    return Uri(queryParameters: params).query;
  }

  static Future<void> _downloadAndOpen({
    required String endpoint,
    required Map<String, dynamic> filters,
    required String extension,
    required String fileNamePrefix,
  }) async {
    final query = _buildQuery(filters);
    final url = Uri.parse('$_baseUrl$endpoint${query.isNotEmpty ? '?$query' : ''}');

    final response = await http.get(url, headers: _headers());

    if (response.statusCode != 200) {
      throw Exception('Export failed (status ${response.statusCode})');
    }

    final fileName = '${fileNamePrefix}_${DateTime.now().millisecondsSinceEpoch}.$extension';
    await file_saver.saveAndOpenBytes(response.bodyBytes, fileName);
  }

  static Future<void> downloadPdf(Map<String, dynamic> filters) {
    return _downloadAndOpen(
      endpoint: '/admin/reports/export/pdf',
      filters: filters,
      extension: 'pdf',
      fileNamePrefix: 'attendance_report',
    );
  }

  static Future<void> downloadExcel(Map<String, dynamic> filters) {
    return _downloadAndOpen(
      endpoint: '/admin/reports/export/excel',
      filters: filters,
      extension: 'xlsx',
      fileNamePrefix: 'attendance_report',
    );
  }

  static Future<void> downloadStudentPdf(int studentId) {
    return _downloadAndOpen(
      endpoint: '/admin/reports/student/$studentId/export/pdf',
      filters: const {},
      extension: 'pdf',
      fileNamePrefix: 'student_report_$studentId',
    );
  }

  static Future<void> downloadStudentExcel(int studentId) {
    return _downloadAndOpen(
      endpoint: '/admin/reports/student/$studentId/export/excel',
      filters: const {},
      extension: 'xlsx',
      fileNamePrefix: 'student_report_$studentId',
    );
  }
}