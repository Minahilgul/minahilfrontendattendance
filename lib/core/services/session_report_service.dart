import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/session_report_model.dart';
import 'auth_service.dart';

class SessionReportService {
  static Future<List<SessionReportItem>> fetchReport({
    String? status,
    String? search,
    String? dateFrom,
    String? dateTo,
  }) async {
    final queryParams = <String, String>{};
    if (status != null && status.isNotEmpty) queryParams['status'] = status;
    if (search != null && search.isNotEmpty) queryParams['search'] = search;
    if (dateFrom != null) queryParams['date_from'] = dateFrom;
    if (dateTo != null) queryParams['date_to'] = dateTo;

    final uri = Uri.parse('${AuthService.baseUrl}/sessions/report')
        .replace(queryParameters: queryParams);

    final response = await http.get(uri, headers: {
      'Accept': 'application/json',
    });

    print("SESSION REPORT STATUS: ${response.statusCode}");
    print("SESSION REPORT RESPONSE: ${response.body}");

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final List data = body['data'];
      return data.map((e) => SessionReportItem.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load session report');
    }
  }
}