import 'package:go_router/go_router.dart';
import '../core/services/auth_service.dart';

import '../screens/class_roaster.dart';


import '../screens/splash_screen.dart';
import '../screens/login_screen.dart';
import '../screens/admin_dashboard_screen.dart';
import '../screens/teacher_dashboard.dart';
import '../screens/classes_screen.dart';
import '../screens/teacher_directory_screen.dart';
import '../screens/pending_approvals_screen.dart';
import '../screens/reports_screen.dart';
import '../screens/role_screen.dart'; 
import '../screens/create_session_page.dart';
import '../screens/settings_screen.dart';
import '../screens/student_directory_screen.dart';
import '../screens/student_dashboard_screen.dart';
import '../screens/register_teacher_screen.dart';
import '../screens/teacher_report.dart';
import '../screens/admin_profile_screen.dart';
import '../screens/teacher_profile_screen.dart';


final GoRouter appRouter = GoRouter(
  initialLocation: '/',

  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    
    
    GoRoute(
      path: '/admin-dashboard', 
      builder: (context, state) => const AdminDashboardScreen()
    ),
    GoRoute(
  path: '/settings',
  builder: (context, state) => const SettingsScreen(),
    ),
    
    
    GoRoute(
      path: '/teacher-dashboard', 
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        final int userId = extra['userId'] ?? AuthService.currentUser?['id'] ?? 1;
        final String role = extra['role'] ?? AuthService.currentUser?['role'] ?? 'teacher';
        return TeacherDashboardScreen(
          userId: userId, 
          role: role,
        );
      }
    ),
    
    
    GoRoute(path: '/dashboard', builder: (context, state) => const AdminDashboardScreen()), 
    
    GoRoute(path: '/classes', builder: (context, state) => const ClassesScreen()),
    
    
    GoRoute(
      path: '/teachers',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        final int userId = extra['userId'] ?? AuthService.currentUser?['id'] ?? 1;
        final String role = extra['role'] ?? AuthService.currentUser?['role'] ?? 'teacher';
        return TeacherDirectoryScreen(
          userId: userId,
          role: role,
        );
      }
    ),
    
    GoRoute(path: '/pending', builder: (context, state) => const ApprovalsScreen()),
    GoRoute(path: '/reports', builder: (context, state) => const ReportsAuditScreen()),
    GoRoute(path: '/teacher-reports', builder: (context, state) => const TeacherReportScreen()),
    GoRoute(path: '/roles', builder: (context, state) => const RoleScreen()), 

    GoRoute(path: '/create-session', builder: (context, state) => const CreateSessionPage()),
    GoRoute(path: '/add-student', builder: (context, state) => const StudentDirectoryScreen()),
    GoRoute(path: '/register-teacher', builder: (context, state) => const RegisterTeacherScreen()),
    GoRoute(path: '/profile', builder: (context, state) => const AdminProfileScreen()),

    GoRoute(
  path: '/teacher-profile',
  builder: (context, state) => const TeacherProfileScreen(),
),
    GoRoute(
      path: '/student-dashboard',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        final int userId = extra['userId'] ?? AuthService.currentUser?['id'] ?? 1;
        final String role = extra['role'] ?? AuthService.currentUser?['role'] ?? 'student';
        final String name = extra['name'] ?? AuthService.currentUser?['username'] ?? 'Student';
        return StudentDashboardScreen(
          userId: userId,
          role: role,
          name: name,
        );
      },
    ),
  ],
);
