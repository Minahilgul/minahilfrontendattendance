import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/services/auth_service.dart';

class SessionService {
  static Future<Map<String, dynamic>> createSession({
    required int teacherId,
    required int classId,
    required double latitude,
    required double longitude,
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
}