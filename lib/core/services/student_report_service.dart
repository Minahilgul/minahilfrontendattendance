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

  static Future<Map<String, dynamic>> getMyReport({
    String? startDate,
    String? endDate,
  }) async {
    final params = <String, String>{};
    if (startDate != null) params['start_date'] = startDate;
    if (endDate != null) params['end_date'] = endDate;

    final uri = Uri.parse('$_baseUrl/student/reports/my-report')
        .replace(queryParameters: params.isNotEmpty ? params : null);

    final response = await http.get(uri, headers: _headers());

    if (response.statusCode == 403) throw Exception('Unauthorized Access');

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(data);
    } else {
      throw Exception(data['message'] ?? 'Failed to load report');
    }
  }
}