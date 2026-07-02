import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';

class AdminProfileService {
  static const String baseUrl = 'http://localhost:8000/api';
  final _storage = GetStorage();

  Future<String?> _getToken() async {
    final token = _storage.read<String>('token');
    print('Profile token: $token');
    return token;
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
      if (firstError is List && firstError.isNotEmpty) throw Exception(firstError.first);
    }
    throw Exception(message);
  }

  Future<Map<String, dynamic>> getProfile() async {
    final token = await _getToken();
    if (token == null) throw Exception('Not authenticated');

    final response = await http.get(
      Uri.parse('$baseUrl/admin/profile'),
      headers: _headers(token),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return body['data'] ?? body;
    }
    if (response.statusCode == 401) throw Exception('Session expired. Please login again.');
    _handleError(response);
    throw Exception('Failed to load profile');
  }

  Future<void> updateProfile({required String name, String? phone}) async {
    final token = await _getToken();
    if (token == null) throw Exception('Not authenticated');

    final response = await http.put(
      Uri.parse('$baseUrl/admin/profile'),
      headers: _headers(token),
      body: jsonEncode({'name': name, 'phone': phone ?? ''}),
    );

    if (response.statusCode == 200) return;
    _handleError(response);
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final token = await _getToken();
    if (token == null) throw Exception('Not authenticated');

    final response = await http.post(
      Uri.parse('$baseUrl/admin/profile/change-password'),
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

  Future<void> changeEmail({
    required String currentPassword,
    required String newEmail,
  }) async {
    final token = await _getToken();
    if (token == null) throw Exception('Not authenticated');

    final response = await http.post(
      Uri.parse('$baseUrl/admin/profile/change-email'),
      headers: _headers(token),
      body: jsonEncode({
        'current_password': currentPassword,
        'new_email': newEmail,
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
          Uri.parse('$baseUrl/admin/logout'),
          headers: _headers(token),
        );
      } catch (_) {}
    }
    await _clearSession();
  }

  Future<void> logoutAllDevices() async {
    final token = await _getToken();
    if (token == null) throw Exception('Not authenticated');

    final response = await http.post(
      Uri.parse('$baseUrl/admin/logout-all'),
      headers: _headers(token),
    );

    if (response.statusCode == 200) {
      await _clearSession();
      return;
    }
    _handleError(response);
  }
}