import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class SystemSettingService {
  static Future<List<dynamic>> fetchSettings(String token) async {
    try {
      final res = await http.get(
        Uri.parse('${AuthService.baseUrl}/settings'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (res.statusCode == 200) {
        return jsonDecode(res.body)['data'] ?? [];
      }
      return [];
    } catch (e) {
      print("FETCH SETTINGS SERVICE ERROR: $e");
      return [];
    }
  }

  static Future<bool> updateSetting({
    required int id,
    required String value,
    required String token,
  }) async {
    try {
      final res = await http.put(
        Uri.parse('${AuthService.baseUrl}/settings/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'value': value}),
      );
      return res.statusCode == 200;
    } catch (e) {
      print("UPDATE SETTING SERVICE ERROR: $e");
      return false;
    }
  }
}
