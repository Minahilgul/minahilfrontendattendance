import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class SessionService {
  
  // CREATE SESSION
  
  static Future<Map<String, dynamic>> createSession({
    required int teacherId,
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
      return {
        'success': false,
        'message': 'Connection error: $e',
      };
    }
  }

// GET ACTIVE SESSION (restore state on app load)

static Future<Map<String, dynamic>> getActiveSession(int teacherId) async {
  try {
    final token = await AuthService.getToken();

    final response = await http.get(
      Uri.parse('${AuthService.baseUrl}/active-session/$teacherId'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print("ACTIVE SESSION STATUS: ${response.statusCode}");
    print("ACTIVE SESSION RESPONSE: ${response.body}");

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      return {
        'success': true,
        'active': data['active'],
        'data': data['data'],
      };
    } else {
      return {'success': false, 'active': false, 'data': null};
    }
  } catch (e) {
    return {'success': false, 'active': false, 'data': null};
  }
}

// GET STUDENTS FOR SESSION
static Future<Map<String, dynamic>> getStudents(int sessionId) async {
  try {
    final token = await AuthService.getToken();

    final response = await http.get(
      Uri.parse('${AuthService.baseUrl}/sessions/$sessionId/students'),
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
  
  // SAVE SELECTED STUDENTS
  
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
        String errorMsg = data['message'] ?? 'Failed to save students';
        if (data['errors'] != null && data['errors'] is Map) {
          final errs = data['errors'] as Map;
          if (errs.isNotEmpty) {
            final firstError = errs.values.first;
            if (firstError is List && firstError.isNotEmpty) {
              errorMsg = firstError.first.toString();
            } else {
              errorMsg = firstError.toString();
            }
          }
        }
        return {
          'success': false,
          'message': errorMsg,
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }
  // END SESSION
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
      return {
        'success': false,
        'message': 'Connection error: $e',
      };
    }
  }
}