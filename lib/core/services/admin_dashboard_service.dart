import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class DashboardService {
  // GET /api/admin/dashboard-stats
  // Returns: total_students, total_teachers, total_classes,
  // active_classes, inactive_classes, pending_approvals
  static Future<Map<String, dynamic>> fetchAdminStats() async {
    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse('${AuthService.baseUrl}/admin/dashboard-stats'),
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
      print("FETCH ADMIN DASHBOARD STATS ERROR: ${e.toString()}");
      return {};
    }
  }
}