import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class StudentService {
  // AuthService.baseUrl = 'http://127.0.0.1:8000/api' rakho Flutter Web ke liye

  static Future<Map<String, dynamic>> fetchApprovedStudents(String teacherId) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse('${AuthService.baseUrl}/teacher/$teacherId/approved-students'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {'students': []};
    } catch (e) {
      print("FETCH APPROVED STUDENTS SERVICE ERROR: ${e.toString()}");
      return {'students': []};
    }
  }

  static Future<List<Map<String, dynamic>>> fetchClasses() async {
    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse('${AuthService.baseUrl}/classes'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final List data = jsonData['classes'] ?? jsonData['data'] ?? jsonData;
        return List<Map<String, dynamic>>.from(data);
      }
      return [];
    } catch (e, stackTrace) {
      print('FETCH CLASSES SERVICE ERROR: ${e.toString()}'); 
      print(stackTrace);
      return [];
    }
  }

  static Future<Map<String, dynamic>> submitForApproval({
    required String name,
    required String cls,
    required String roll,
    required String status,
    required String teacherId,
  }) async {
    try {
      final token = await AuthService.getToken();
      final body = {
        "name": name,
        "class": cls,
        "roll_no": roll,
        "student_status": status,
        "teacher_id": teacherId == 'null' ? null : teacherId, // ✅ teacher_id sahi key, null handle
        "approval_status": "pending"
      };

      final response = await http.post(
        Uri.parse('${AuthService.baseUrl}/pending-students'),
        body: jsonEncode(body),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json", // ✅ Accept add kiya
          "Authorization": "Bearer $token",
        },
      );

      print("SUBMIT STUDENT STATUS: ${response.statusCode}");
      print("SUBMIT STUDENT RESPONSE: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true};
      } else {
        return {'success': false, 'message': response.body};
      }
    } catch (e) {
      print("SUBMIT STUDENT SERVICE ERROR: ${e.toString()}");
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<List<dynamic>> fetchPendingStudents() async {
    try {
      final token = await AuthService.getToken();
      print("Token sending: $token"); // Debug
      
      final response = await http.get(
        Uri.parse('${AuthService.baseUrl}/pending-students'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token', // ✅ 403 fix
        },
      );
      print("FETCH PENDING STATUS: ${response.statusCode}");
      print("FETCH PENDING BODY: ${response.body}"); // Debug
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data is List ? data : [];
      }
      return [];
    } catch (e) {
      print("FETCH PENDING STUDENTS SERVICE ERROR: ${e.toString()}");
      return [];
    }
  }

  static Future<bool> approveStudent(String id) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.post(
        Uri.parse('${AuthService.baseUrl}/pending-students/approve/$id'),
        headers: {
          'Accept': 'application/json', // ✅ Accept add
          'Authorization': 'Bearer $token',
        },
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("APPROVE STUDENT SERVICE ERROR: ${e.toString()}");
      return false;
    }
  }

  static Future<bool> rejectStudent(String id) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.post(
        Uri.parse('${AuthService.baseUrl}/pending-students/reject/$id'),
        headers: {
          'Accept': 'application/json', // ✅ Accept add
          'Authorization': 'Bearer $token',
        },
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("REJECT STUDENT SERVICE ERROR: ${e.toString()}");
      return false;
    }
  }

  static Future<bool> approveAllStudents(List<String> ids) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.post(
        Uri.parse('${AuthService.baseUrl}/pending-students/approve-all'),
        body: jsonEncode({'ids': ids}),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json', // ✅ Accept add
          'Authorization': 'Bearer $token',
        },
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("APPROVE ALL STUDENTS SERVICE ERROR: ${e.toString()}");
      return false;
    }
  }

  static Future<List<Map<String, dynamic>>> fetchStudents() async {
    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse('${AuthService.baseUrl}/students'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final List data = jsonData['data'] ?? jsonData;
        return List<Map<String, dynamic>>.from(data);
      }
      return [];
    } catch (e) {
      print("FETCH STUDENTS SERVICE ERROR: ${e.toString()}");
      return [];
    }
  }

  static Future<bool> addStudent({
    required String name,
    required String cls,
  }) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.post(
        Uri.parse('${AuthService.baseUrl}/students/'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "name": name,
          "class": cls,
          "is_present": false,
        }),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("ADD STUDENT SERVICE ERROR: ${e.toString()}");
      return false;
    }
  }

  static Future<Map<String, dynamic>> createStudent({
    required String username,
    required String email,
    required String password,
    required String phone,
    required String cls,
    required String rollNo,
  }) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.post(
        Uri.parse('${AuthService.baseUrl}/students'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
          'phone': phone,
          'class': cls,
          'roll_no': rollNo,
        }),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': data['success'] ?? true, 'message': data['message'] ?? 'Success'};
      }
      return {'success': false, 'message': data['message'] ?? 'Failed to add student'};
    } catch (e) {
      print("CREATE STUDENT SERVICE ERROR: ${e.toString()}");
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<bool> updateStudent({
    required int id,
    required String username,
    required String email,
    required String phone,
  }) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.put(
        Uri.parse('${AuthService.baseUrl}/students/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'username': username,
          'email': email,
          'phone': phone,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      print("UPDATE STUDENT SERVICE ERROR: ${e.toString()}");
      return false;
    }
  }

  static Future<bool> deleteStudent(int id) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.delete(
        Uri.parse('${AuthService.baseUrl}/students/$id'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      print("DELETE STUDENT SERVICE ERROR: ${e.toString()}");
      return false;
    }
  }
}