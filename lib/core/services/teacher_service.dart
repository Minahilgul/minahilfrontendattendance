import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import 'package:device_info_plus/device_info_plus.dart';

class TeacherService {

  // FETCH ALL TEACHERS
  
  static Future<List<Map<String, dynamic>>> fetchTeachers() async {
    try {
      final token = await AuthService.getToken();

      final response = await http.get(
        Uri.parse('${AuthService.baseUrl}/teachers'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token', 
        },
      );

      print("FETCH TEACHERS STATUS: ${response.statusCode}");
      print("FETCH TEACHERS RESPONSE: ${response.body}");

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final List data = jsonData['data'] ?? jsonData;
        return List<Map<String, dynamic>>.from(data);
      }
      return [];
    } catch (e) {
      print("FETCH TEACHERS SERVICE ERROR: $e");
      return [];
    }
  }

  
  // ADD TEACHER
  
  static Future<Map<String, dynamic>> addTeacher({
    required String username,
    required String email,
    required String password,
    required String phone,
    String? deviceId,
    int? status, // NEW: 1 = active, 0 = inactive. Backend defaults to 1 if omitted.
  }) async {
    try {
      final token = await AuthService.getToken();

      final body = {
        'username': username,
        'email': email,
        'password': password,
        'phone': phone,
        if (deviceId != null && deviceId.isNotEmpty) 'device_id': deviceId,
        if (status != null) 'status': status, // NEW
      };

      final response = await http.post(
        Uri.parse('${AuthService.baseUrl}/teachers'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      print("ADD TEACHER STATUS: ${response.statusCode}");
      print("ADD TEACHER RESPONSE: ${response.body}");

      final jsonData = jsonDecode(response.body);

      //  return full response so UI can show specific validation errors
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'message': jsonData['message'] ?? 'Teacher added'};
      }

      // Extract Laravel validation errors for display
      String errorMessage = jsonData['message'] ?? 'Failed to add teacher';
      if (jsonData['errors'] != null) {
        final errors = jsonData['errors'] as Map<String, dynamic>;
        errorMessage = errors.values
            .expand((e) => e is List ? e : [e])
            .join('\n');
      }

      return {'success': false, 'message': errorMessage};
    } catch (e) {
      print("ADD TEACHER SERVICE ERROR: $e");
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // ─────────────────────────────
  // UPDATE TEACHER
  // ─────────────────────────────
  static Future<Map<String, dynamic>> updateTeacher({
    required int id,
    required String username,
    required String email,
    required String phone,
    String? deviceId,
    String? password,
    int? status, // NEW: 1 = active, 0 = inactive. Backend preserves current value if omitted.
  }) async {
    try {
      final token = await AuthService.getToken();

      final body = <String, dynamic>{
        'username': username,
        'email': email,
        'phone': phone,
        'password': password,
        // send null instead of empty string so Laravel treats it as nullable
         if (deviceId != null && deviceId.isNotEmpty)
             'device_id': deviceId,
        if (status != null) 'status': status, // NEW
      };

      //  Only include password if user typed a new one
      if (password != null && password.isNotEmpty) {
        body['password'] = password;
      }

      final response = await http.put(
        Uri.parse('${AuthService.baseUrl}/teachers/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      print("UPDATE TEACHER STATUS: ${response.statusCode}");
      print("UPDATE TEACHER RESPONSE: ${response.body}");

      final jsonData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'message': jsonData['message'] ?? 'Teacher updated'};
      }

      // ✅ Extract Laravel validation errors for display
      String errorMessage = jsonData['message'] ?? 'Failed to update teacher';
      if (jsonData['errors'] != null) {
        final errors = jsonData['errors'] as Map<String, dynamic>;
        errorMessage = errors.values
            .expand((e) => e is List ? e : [e])
            .join('\n');
      }

      return {'success': false, 'message': errorMessage};
    } catch (e) {
      print("UPDATE TEACHER SERVICE ERROR: $e");
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // ─────────────────────────────
  // DELETE TEACHER
  // ─────────────────────────────
  static Future<bool> deleteTeacher(int id) async {
    try {
      final token = await AuthService.getToken();

      final response = await http.delete(
        Uri.parse('${AuthService.baseUrl}/teachers/$id'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print("DELETE TEACHER STATUS: ${response.statusCode}");
      print("DELETE TEACHER RESPONSE: ${response.body}");

      return response.statusCode == 200;
    } catch (e) {
      print("DELETE TEACHER SERVICE ERROR: $e");
      return false;
    }
  }

  // ─────────────────────────────
  // SELF-REGISTER TEACHER
  // ─────────────────────────────
  static Future<Map<String, dynamic>> registerTeacher({
    required String username,
    required String email,
    required String password,
    required String phone,
    required String deviceId,
  }) async {
    try {
      final body = {
        'username': username,
        'email': email,
        'password': password,
        'phone': phone,
        'device_id': deviceId,
      };

      final response = await http.post(
        Uri.parse('${AuthService.baseUrl}/register-teacher'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(body),
      );

      print("REGISTER TEACHER STATUS: ${response.statusCode}");
      print("REGISTER TEACHER RESPONSE: ${response.body}");

      final jsonData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'message': jsonData['message'] ?? 'Registration successful!'};
      }

      String errorMessage = jsonData['message'] ?? 'Failed to register';
      if (jsonData['errors'] != null) {
        final errors = jsonData['errors'] as Map<String, dynamic>;
        errorMessage = errors.values
            .expand((e) => e is List ? e : [e])
            .join('\n');
      }

      return {'success': false, 'message': errorMessage};
    } catch (e) {
      print("REGISTER TEACHER SERVICE ERROR: $e");
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // APPROVE TEACHER
  
  static Future<bool> approveTeacher(int id) async {
    try {
      final token = await AuthService.getToken();

      final response = await http.post(
        Uri.parse('${AuthService.baseUrl}/teachers/approve/$id'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print("APPROVE TEACHER STATUS: ${response.statusCode}");
      print("APPROVE TEACHER RESPONSE: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      print("APPROVE TEACHER SERVICE ERROR: $e");
      return false;
    }
  }
}