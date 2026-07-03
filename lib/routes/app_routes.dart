
import 'package:get/get.dart';
import '../core/services/auth_service.dart';

import '../screens/splash_screen.dart';
import '../screens/login_screen.dart';
import '../screens/admin/admin_dashboard_screen.dart';
import '../screens/teacher/teacher_dashboard.dart';
import '../screens/admin/classes_screen.dart'; // folder is lib/screens/admin/
import '../screens/teacher_directory_screen.dart';
import '../screens/admin/pending_approvals_screen.dart';
import '../screens/admin/admin_report_screen.dart';
import '../screens/role_screen.dart';
import '../screens/teacher/create_session_page.dart';
import '../screens/settings_screen.dart';
import '../screens/student_directory_screen.dart';
import '../screens/student/student_dashboard_screen.dart';
import '../screens/admin/register_teacher_screen.dart';
import '../screens/teacher/teacher_report.dart';
import '../screens/admin/admin_profile_screen.dart';
import '../screens/teacher/teacher_profile_screen.dart';
import '../screens/teacher/class_roaster.dart';
import '../screens/teacher/mark_attendance.dart';

import './auth_middleware.dart';



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
      middlewares: [AuthMiddleware(allowedRoles:['admin'])],
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
      middlewares: [AuthMiddleware(allowedRoles:['teacher', 'admin'])],
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
      middlewares: [AuthMiddleware(allowedRoles:['student'])],
    ),
    GetPage(
      name: '/classes',
      page: () => const ClassesScreen(),
      middlewares: [AuthMiddleware(allowedRoles:['admin'])],
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
      middlewares: [AuthMiddleware(allowedRoles:['admin'])],
    ),
    GetPage(
      name: '/approvals',
      page: () => const ApprovalsScreen(),
      middlewares: [AuthMiddleware(allowedRoles:['admin'])],
    ),
    GetPage(
      name: '/reports',
      page: () => const ReportsAuditScreen(),
      middlewares: [AuthMiddleware(allowedRoles:['admin'])],
    ),
    GetPage(
      name: '/teacher-report',
      page: () => const TeacherReportScreen(),
      middlewares: [AuthMiddleware(allowedRoles:['teacher', 'admin'])],
    ),
    GetPage(
      name: '/create-session',
      page: () => const CreateSessionPage(),
      middlewares: [AuthMiddleware(allowedRoles:['teacher', 'admin'])],
    ),
    GetPage(
      name: '/student-directory',
      page: () => const StudentDirectoryScreen(),
      middlewares: [AuthMiddleware(allowedRoles:['teacher', 'admin'])],
    ),
    GetPage(
      name: '/register-teacher',
      page: () => const RegisterTeacherScreen(),
    ),
    GetPage(
      name: '/admin-profile',
      page: () => const AdminProfileScreen(),
      middlewares: [AuthMiddleware(allowedRoles:['admin'])],
    ),
    GetPage(
      name: '/teacher-profile',
      page: () => const TeacherProfileScreen(),
      middlewares: [AuthMiddleware(allowedRoles:['teacher', 'admin'])],
    ),
    GetPage(
      name: '/mark-attendance',
      page: () => const MarkAttendanceScreen(),
      middlewares: [AuthMiddleware(allowedRoles: ['teacher', 'admin'])],
    ),
    GetPage(
      name: '/roster',
      page: () => const RosterScreen(),
      middlewares: [AuthMiddleware(allowedRoles: ['teacher', 'admin'])],
    ),
    // Legacy support
    GetPage(
      name: '/settings',
      page: () => const SettingsScreen(),
      middlewares: [AuthMiddleware(allowedRoles: ['admin'])],
    ),
    GetPage(
      name: '/roles',
      page: () => const RoleScreen(),
      middlewares: [AuthMiddleware(allowedRoles: ['admin'])],
    ),
  ];
}
