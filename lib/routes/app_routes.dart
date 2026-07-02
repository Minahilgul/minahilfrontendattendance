import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/services/auth_service.dart';

import '../screens/splash_screen.dart';
import '../screens/login_screen.dart';
import '../screens/admin_dashboard_screen.dart';
import '../screens/teacher_dashboard.dart';
import '../screens/admin/classes_screen.dart'; // folder is lib/screens/admin/
import '../screens/teacher_directory_screen.dart';
import '../screens/pending_approvals_screen.dart';
import '../screens/admin_report_screen.dart';
import '../screens/role_screen.dart';
import '../screens/create_session_page.dart';
import '../screens/settings_screen.dart';
import '../screens/student_directory_screen.dart';
import '../screens/student_dashboard_screen.dart';
import '../screens/register_teacher_screen.dart';
import '../screens/teacher_report.dart';
import '../screens/admin_profile_screen.dart';
import '../screens/teacher_profile_screen.dart';
import '../screens/class_roaster.dart';
import '../screens/mark_attendance.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final token = AuthService.token;
    if (token == null || token.isEmpty) {
      return const RouteSettings(name: '/login');
    }
    return null;
  }
}

class AppRoutes {
  static final routes = [
    GetPage(
      name: '/splash',
      page: () => const SplashScreen(),
    ),
    GetPage(
      name: '/login',
      page: () => const LoginScreen(),
    ),
    GetPage(
      name: '/admin-dashboard',
      page: () => const AdminDashboardScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: '/teacher-dashboard',
      page: () {
        final args = Get.arguments as Map<String, dynamic>? ?? {};
        final int userId = args['userId'] ?? AuthService.currentUser?['id'] ?? 1;
        final String role = args['role'] ?? AuthService.currentUser?['role'] ?? 'teacher';
        return TeacherDashboardScreen(
          userId: userId,
          role: role,
        );
      },
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: '/student-dashboard',
      page: () {
        final args = Get.arguments as Map<String, dynamic>? ?? {};
        final int userId = args['userId'] ?? AuthService.currentUser?['id'] ?? 1;
        final String role = args['role'] ?? AuthService.currentUser?['role'] ?? 'student';
        final String name = args['name'] ?? AuthService.currentUser?['username'] ?? 'Student';
        return StudentDashboardScreen(
          userId: userId,
          role: role,
          name: name,
        );
      },
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: '/classes',
      page: () => const ClassesScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: '/teacher-directory',
      page: () {
        final args = Get.arguments as Map<String, dynamic>? ?? {};
        final int userId = args['userId'] ?? AuthService.currentUser?['id'] ?? 1;
        final String role = args['role'] ?? AuthService.currentUser?['role'] ?? 'teacher';
        return TeacherDirectoryScreen(
          userId: userId,
          role: role,
        );
      },
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: '/approvals',
      page: () => const ApprovalsScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: '/reports',
      page: () => const ReportsAuditScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: '/teacher-report',
      page: () => const TeacherReportScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: '/create-session',
      page: () => const CreateSessionPage(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: '/student-directory',
      page: () => const StudentDirectoryScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: '/register-teacher',
      page: () => const RegisterTeacherScreen(),
    ),
    GetPage(
      name: '/admin-profile',
      page: () => const AdminProfileScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: '/teacher-profile',
      page: () => const TeacherProfileScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: '/mark-attendance',
      page: () => const MarkAttendanceScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: '/roster',
      page: () => const RosterScreen(),
      middlewares: [AuthMiddleware()],
    ),
    // Legacy support
    GetPage(
      name: '/settings',
      page: () => const SettingsScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: '/roles',
      page: () => const RoleScreen(),
      middlewares: [AuthMiddleware()],
    ),
  ];
}
