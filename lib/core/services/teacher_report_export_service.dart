import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import '../config/environment.dart';
import 'file_saver_stub.dart'
    if (dart.library.html) 'file_saver_web.dart'
    if (dart.library.io) 'file_saver_io.dart' as file_saver;

class TeacherReportExportService {
  static const String _baseUrl = Environment.apiBaseUrl;

  static Map<String, String> _headers() {
    final token = GetStorage().read<String>('token');
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

    if (response.statusCode == 403) {
      throw Exception('Unauthorized Access');
    }
    if (response.statusCode != 200) {
      throw Exception('Export failed (status ${response.statusCode})');
    }

    final fileName = '${fileNamePrefix}_${DateTime.now().millisecondsSinceEpoch}.$extension';
    await file_saver.saveAndOpenBytes(response.bodyBytes, fileName);
  }

  // Full class report, OR pass studentIds to restrict to selected students
  static Future<void> downloadClassPdf({List<int>? studentIds, Map<String, dynamic>? filters}) {
    return _downloadAndOpen(
      endpoint: '/teacher/reports/export/pdf',
      filters: {
        ...?filters,
        if (studentIds != null && studentIds.isNotEmpty) 'student_ids': studentIds.join(','),
      },
      extension: 'pdf',
      fileNamePrefix: 'class_attendance_report',
    );
  }

  static Future<void> downloadClassExcel({List<int>? studentIds, Map<String, dynamic>? filters}) {
    return _downloadAndOpen(
      endpoint: '/teacher/reports/export/excel',
      filters: {
        ...?filters,
        if (studentIds != null && studentIds.isNotEmpty) 'student_ids': studentIds.join(','),
      },
      extension: 'xlsx',
      fileNamePrefix: 'class_attendance_report',
    );
  }

  static Future<void> downloadStudentPdf(int studentId, {String? startDate, String? endDate}) {
    return _downloadAndOpen(
      endpoint: '/teacher/reports/student/$studentId/export/pdf',
      filters: {'start_date': startDate, 'end_date': endDate},
      extension: 'pdf',
      fileNamePrefix: 'student_report_$studentId',
    );
  }

  static Future<void> downloadStudentExcel(int studentId, {String? startDate, String? endDate}) {
    return _downloadAndOpen(
      endpoint: '/teacher/reports/student/$studentId/export/excel',
      filters: {'start_date': startDate, 'end_date': endDate},
      extension: 'xlsx',
      fileNamePrefix: 'student_report_$studentId',
    );
  }
}