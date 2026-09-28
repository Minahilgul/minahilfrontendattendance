import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class TeacherDashboardService {
  // GET /api/teacher/{teacher_id}/dashboard-stats
  // Returns: my_total_students, active_sessions_today,
  // today_attendance_pct, pending_confirmations
  static Future<Map<String, dynamic>> fetchStats(int teacherId) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse('${AuthService.baseUrl}/teacher/$teacherId/dashboard-stats'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(jsonDecode(response.body));
      }
      return {};
    } catch (e) {
      print("FETCH TEACHER DASHBOARD STATS ERROR: ${e.toString()}");
      return {};
    }
  }
}