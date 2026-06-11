import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class AttendanceService {
  static Future<bool> saveAttendance({
    required int sessionId,
    required int studentId,
    required double latitude,
    required double longitude,
    required String status,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${AuthService.baseUrl}/mark-attendance'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'session_id': sessionId,
          'student_id': studentId,
          'latitude': latitude,
          'longitude': longitude,
          'status': status,
        }),
      );

      print("MARK ATTENDANCE STATUS: ${response.statusCode}");
      print("MARK ATTENDANCE RESPONSE: ${response.body}");

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("SAVE ATTENDANCE SERVICE ERROR: $e");
      return false;
    }
  }
}
