import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/services/auth_service.dart';

class AuthMiddleware extends GetMiddleware {
  final List<String>? allowedRoles;

  AuthMiddleware({this.allowedRoles});

  @override
  RouteSettings? redirect(String? route) {
    final token = AuthService.token;
    if (token == null || token.isEmpty) {
      return const RouteSettings(name: '/login');
    }
    
    if (allowedRoles != null && allowedRoles!.isNotEmpty) {
      final currentUser = AuthService.currentUser;
      if (currentUser == null) {
        return const RouteSettings(name: '/login');
      }

      final String userRole = currentUser['role'] ?? '';
      
      if (!allowedRoles!.contains(userRole)) {
        
        if (userRole == 'admin') return const RouteSettings(name: '/admin-dashboard');
        if (userRole == 'teacher') return const RouteSettings(name: '/teacher-dashboard');
        if (userRole == 'student') return const RouteSettings(name: '/student-dashboard');
        
        return const RouteSettings(name: '/login');
      }
    }

    //  allow access
    return null;
  }
}
