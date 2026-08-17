import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class StudentReportService {
  static Future<Map<String, dynamic>> getMyReport({
    String? startDate,
    String? endDate,
  }) async {
    final token = await AuthService.getToken();

    final params = <String, String>{};
    if (startDate != null) params['start_date'] = startDate;
    if (endDate != null) params['end_date'] = endDate;

    final uri = Uri.parse('${AuthService.baseUrl}/student/reports/my-report')
        .replace(queryParameters: params.isNotEmpty ? params : null);

    final response = await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      return Map<String, dynamic>.from(data['data'] ?? {});
    } else {
      throw Exception(data['message'] ?? 'Failed to load report');
    }
  }
}