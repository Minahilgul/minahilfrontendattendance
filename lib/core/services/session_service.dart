import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class SessionService {
  // ─────────────────────────────────────────────
  // CREATE SESSION
  // ─────────────────────────────────────────────
  static Future<Map<String, dynamic>> createSession({
    required int teacherId,
    required int classId,
    required double latitude,
    required double longitude,
  }) async {


    try {
      final token = await AuthService.getToken();
      final response = await http.post(
        Uri.parse('${AuthService.baseUrl}/create-session'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'teacher_id': teacherId,
          'class_id': classId,
          'latitude': latitude,
          'longitude': longitude,
        }),
      );
      print("CREATE SESSION STATUS: ${response.statusCode}");
      print("CREATE SESSION RESPONSE: ${response.body}");
      final data = jsonDecode(response.body);
      if (response.statusCode == 201 && data['success'] == true) {
        return {
          'success': true,
          'message': data['message'] ?? 'Session created successfully',
          'data': data['data'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to create session',
        };
      }
    } catch (e) {
      print("CREATE SESSION ERROR: $e");
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  // ─────────────────────────────────────────────
  // GET ALL STUDENTS
  // ─────────────────────────────────────────────
  static Future<Map<String, dynamic>> getStudents() async {
    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse('${AuthService.baseUrl}/students'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      print("GET STUDENTS STATUS: ${response.statusCode}");
      print("GET STUDENTS RESPONSE: ${response.body}");
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'data': data['data']};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to fetch students',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  // ─────────────────────────────────────────────
  // GET ATTENDANCE REPORT
  // ─────────────────────────────────────────────
  static Future<Map<String, dynamic>> getAttendanceReport() async {
    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse('${AuthService.baseUrl}/attendance-report'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      print("ATTENDANCE REPORT STATUS: ${response.statusCode}");
      print("ATTENDANCE REPORT RESPONSE: ${response.body}");
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'data': data['data']};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to fetch report',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  // ─────────────────────────────────────────────
  // SAVE SELECTED STUDENTS
  // ─────────────────────────────────────────────
  static Future<Map<String, dynamic>> saveSessionStudents({
    required int sessionId,
    required List<int> studentIds,
  }) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.post(
        Uri.parse('${AuthService.baseUrl}/session-students'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'session_id': sessionId,
          'student_ids': studentIds,
        }),
      );
      print("SAVE STUDENTS STATUS: ${response.statusCode}");
      print("SAVE STUDENTS RESPONSE: ${response.body}");
      final data = jsonDecode(response.body);
      if (response.statusCode == 201 && data['success'] == true) {
        return {'success': true, 'message': data['message']};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to save students',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  // ─────────────────────────────────────────────
  // MARK ATTENDANCE
  // ─────────────────────────────────────────────
  static Future<Map<String, dynamic>> markAttendance({
    required int sessionId,
    required Map<int, String> attendance,
  }) async {
    try {
      final token = await AuthService.getToken();
      final List<Map<String, dynamic>> records = attendance.entries
          .map((e) => {'student_id': e.key, 'status': e.value})
          .toList();
      final response = await http.post(
        Uri.parse('${AuthService.baseUrl}/mark-attendance'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'session_id': sessionId,
          'attendance': records,
        }),
      );
      print("MARK ATTENDANCE STATUS: ${response.statusCode}");
      print("MARK ATTENDANCE RESPONSE: ${response.body}");
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'message': data['message']};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to mark attendance',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  // ─────────────────────────────────────────────
  // END SESSION
  // ─────────────────────────────────────────────
  static Future<Map<String, dynamic>> endSession(int sessionId) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.post(
        Uri.parse('${AuthService.baseUrl}/end-session/$sessionId'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      print("END SESSION STATUS: ${response.statusCode}");
      print("END SESSION RESPONSE: ${response.body}");
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'message': data['message'] ?? 'Session ended successfully',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to end session',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }
}

