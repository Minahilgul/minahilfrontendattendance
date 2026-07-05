import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class AttendanceService {
  static Future<Map<String, dynamic>> saveAttendance({
    required int sessionId,
    required int studentId,
    required double latitude,
    required double longitude,
    required String status,
    String? reason, // optional: only relevant when status == 'absent'
  }) async {
    try {
      final body = {
        'session_id': sessionId,
        'student_id': studentId,
        'latitude': latitude,
        'longitude': longitude,
        'status': status,
      };
      if (reason != null && reason.isNotEmpty) {
        body['reason'] = reason;
      }

      final response = await http.post(
        Uri.parse('${AuthService.baseUrl}/mark-attendance'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(body),
      );

      print("MARK ATTENDANCE STATUS: ${response.statusCode}");
      print("MARK ATTENDANCE RESPONSE: ${response.body}");

      final Map<String, dynamic> data = jsonDecode(response.body);
      return {
        'success': response.statusCode == 200 || response.statusCode == 201,
        'message': data['message'] ?? 'Unknown response from server'
      };
    } catch (e) {
      print("SAVE ATTENDANCE SERVICE ERROR: $e");
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }
}