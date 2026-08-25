import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/environment.dart';

class PasswordResetService {
  static const String baseUrl = Environment.apiBaseUrl;

  static Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/forgot-password'),
        headers: {"Content-Type": "application/json", "Accept": "application/json"},
        body: jsonEncode({"email": email}),
      );

      final data = jsonDecode(response.body);
      return {
        "success": data['success'] ?? false,
        "message": data['message'] ?? 'Something went wrong',
      };
    } catch (e) {
      return {"success": false, "message": "Server error: $e"};
    }
  }

  static Future<Map<String, dynamic>> verifyOtp(String email, String otp) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/verify-otp'),
        headers: {"Content-Type": "application/json", "Accept": "application/json"},
        body: jsonEncode({"email": email, "otp": otp}),
      );

      final data = jsonDecode(response.body);
      return {
        "success": data['success'] ?? false,
        "message": data['message'] ?? 'Something went wrong',
      };
    } catch (e) {
      return {"success": false, "message": "Server error: $e"};
    }
  }

  static Future<Map<String, dynamic>> resetPassword(
      String email, String otp, String password, String passwordConfirmation) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reset-password'),
        headers: {"Content-Type": "application/json", "Accept": "application/json"},
        body: jsonEncode({
          "email": email,
          "otp": otp,
          "password": password,
          "password_confirmation": passwordConfirmation,
        }),
      );

      final data = jsonDecode(response.body);
      return {
        "success": data['success'] ?? false,
        "message": data['message'] ?? 'Something went wrong',
      };
    } catch (e) {
      return {"success": false, "message": "Server error: $e"};
    }
  }
}