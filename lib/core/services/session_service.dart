import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class SessionService {
  static Future<Map<String, dynamic>> createSession({
    required int teacherId,
    required int classId,
    required double latitude,
    required double longitude,
    // required String deviceMacAddress,
  }) async {
    final response = await http.post(
      Uri.parse('${AuthService.baseUrl}/create-session'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'teacher_id': teacherId,
        'class_id': classId,
        'latitude': latitude,
        'longitude': longitude,
        // 'device_mac_address': deviceMacAddress, 
      }),
    );

    print("CREATE SESSION STATUS: ${response.statusCode}");
    print("CREATE SESSION RESPONSE: ${response.body}");

    final data = jsonDecode(response.body);
    if (response.statusCode == 201 && data['success'] == true) {
      return {
        'success': true,
        'message': data['message'],
        'data': data['data']
      };
    } else {
      return {
        'success': false,
        'message': data['message'] ?? 'Failed to create session'
      };
    }
  }

  static Future<Map<String, dynamic>> endSession(int sessionId) async {
    final response = await http.post(
      Uri.parse('${AuthService.baseUrl}/logout-session/$sessionId'),
      headers: {
        'Accept': 'application/json',
      },
    );

    print("END SESSION STATUS: ${response.statusCode}");
    print("END SESSION RESPONSE: ${response.body}");

    final data = jsonDecode(response.body);
    if (response.statusCode == 200 && data['success'] == true) {
      return {
        'success': true,
        'message': data['message'] ?? 'Session ended successfully'
      };
    } else {
      return {
        'success': false,
        'message': data['message'] ?? 'Failed to end session'
      };
    }
  }
}
