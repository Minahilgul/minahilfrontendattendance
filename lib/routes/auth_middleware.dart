import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/services/auth_service.dart';

class AuthMiddleware extends GetMiddleware {
  final List<String>? allowedRoles;

  AuthMiddleware({this.allowedRoles});

  @override
  RouteSettings? redirect(String? route) {
    // 1. Check if token exists
    final token = AuthService.token;
    if (token == null || token.isEmpty) {
      return const RouteSettings(name: '/login');
    }
    
    // 2. Check role if allowedRoles is provided
    if (allowedRoles != null && allowedRoles!.isNotEmpty) {
      final currentUser = AuthService.currentUser;
      if (currentUser == null) {
        return const RouteSettings(name: '/login');
      }

      final String userRole = currentUser['role'] ?? '';
      
      if (!allowedRoles!.contains(userRole)) {
        // Redirect unauthorized users to their respective dashboards
        if (userRole == 'admin') return const RouteSettings(name: '/admin-dashboard');
        if (userRole == 'teacher') return const RouteSettings(name: '/teacher-dashboard');
        if (userRole == 'student') return const RouteSettings(name: '/student-dashboard');
        
        return const RouteSettings(name: '/login');
      }
    }

    // 3. Allow access
    return null;
  }
}
