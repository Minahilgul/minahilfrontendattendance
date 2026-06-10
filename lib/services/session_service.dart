import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class SessionService {
  static Future<void> createSession(
    double latitude,
    double longitude,
  ) async {
    final response = await http.post(
      Uri.parse('http://localhost:8000/api/create-session'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'user_id': 1,
        'latitude': latitude,
        'longitude': longitude,
      }),
    );

    print(response.body);
  }
}