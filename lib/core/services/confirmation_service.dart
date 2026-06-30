import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class ConfirmationService {
  // Teacher: send request
  static Future<Map<String, dynamic>> requestConfirmation(int sessionId) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.post(
        Uri.parse('${AuthService.baseUrl}/confirmation/request'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'session_id': sessionId}),
      );
      print("REQUEST CONFIRMATION STATUS: ${response.statusCode}");
      print("REQUEST CONFIRMATION RESPONSE: ${response.body}");
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  // Teacher: get results
  static Future<Map<String, dynamic>> getResults(int sessionId) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse('${AuthService.baseUrl}/confirmation/results')
            .replace(queryParameters: {'session_id': sessionId.toString()}),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      print("RESULTS STATUS: ${response.statusCode}");
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  // Student: poll for pending confirmation
  static Future<Map<String, dynamic>> getPending(int studentId) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse('${AuthService.baseUrl}/confirmation/pending')
            .replace(queryParameters: {'student_id': studentId.toString()}),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'pending': false};
    }
  }

  // Student: submit YES/NO
  static Future<Map<String, dynamic>> submitResponse({
    required int requestId,
    required int studentId,
    required String response, // 'yes' or 'no'
  }) async {
    try {
      final token = await AuthService.getToken();
      final res = await http.post(
        Uri.parse('${AuthService.baseUrl}/confirmation/respond'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'request_id': requestId,
          'student_id': studentId,
          'response':   response,
        }),
      );
      print("SUBMIT RESPONSE STATUS: ${res.statusCode}");
      print("SUBMIT RESPONSE BODY: ${res.body}");
      return jsonDecode(res.body);
    } catch (e) {
          print("SUBMIT RESPONSE ERROR: $e");
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }
  // Teacher: get full response directory
static Future<Map<String, dynamic>> getDirectory(int sessionId) async {
  try {
    final token = await AuthService.getToken();
    final response = await http.get(
      Uri.parse('${AuthService.baseUrl}/confirmation/directory')
          .replace(queryParameters: {'session_id': sessionId.toString()}),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    print("DIRECTORY STATUS: ${response.statusCode}");
    return jsonDecode(response.body);
  } catch (e) {
    return {'success': false, 'message': 'Connection error: $e'};
  }
}
}