import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import '../config/environment.dart';

class StudentReportService {
  static const String _baseUrl = Environment.apiBaseUrl;

  static Map<String, String> _headers() {
    final token = GetStorage().read<String>('token');
    return {
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // GET /api/student/reports/my-report — identity comes from token, no student_id sent
  static Future<Map<String, dynamic>> getMyReport({
    String? startDate,
    String? endDate,
  }) async {
    final params = <String, String>{};
    if (startDate != null) params['start_date'] = startDate;
    if (endDate != null) params['end_date'] = endDate;

    final uri = Uri.parse('$_baseUrl/student/reports/my-report').replace(queryParameters: params);
    final res = await http.get(uri, headers: _headers());

    if (res.statusCode == 200) return jsonDecode(res.body);
    if (res.statusCode == 403) throw Exception('Unauthorized Access');
    return {};
  }
}