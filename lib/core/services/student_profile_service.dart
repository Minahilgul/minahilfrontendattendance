import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';

class StudentProfileService {
  static const String baseUrl = 'http://localhost:8000/api';
  final _storage = GetStorage();

  Future<String?> _getToken() async {
    return _storage.read<String>('token');
  }

  Future<void> _clearSession() async {
    await _storage.remove('token');
    await _storage.remove('user');
  }

  Map<String, String> _headers(String token) => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

  void _handleError(http.Response response) {
    final body = jsonDecode(response.body);
    final message = body['message'] ?? 'Something went wrong';
    if (body['errors'] != null) {
      final errors = body['errors'] as Map<String, dynamic>;
      final firstError = errors.values.first;
      if (firstError is List && firstError.isNotEmpty)
        throw Exception(firstError.first);
    }
    throw Exception(message);
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final token = await _getToken();
    if (token == null) throw Exception('Not authenticated');

    final response = await http.post(
      Uri.parse(
          '$baseUrl/student/profile/change-password'), //  student endpoint
      headers: _headers(token),
      body: jsonEncode({
        'current_password': currentPassword,
        'new_password': newPassword,
        'new_password_confirmation': confirmPassword,
      }),
    );

    if (response.statusCode == 200) return;
    _handleError(response);
  }

  Future<void> logout() async {
    final token = await _getToken();
    if (token != null) {
      try {
        await http.post(
          Uri.parse('$baseUrl/student/logout'),
          headers: _headers(token),
        );
      } catch (_) {}
    }
    await _clearSession();
  }
}
