import 'package:go_router/go_router.dart';

import '../screens/splash_screen.dart';
import '../screens/login_screen.dart';
import '../screens/admin_dashboard_screen.dart';
import '../screens/classes_screen.dart';
import '../screens/teacher_directory_screen.dart';
import '../screens/pending_approvals_screen.dart';
import '../screens/reports_screen.dart';
import '../screens/role_screen.dart'; 

final GoRouter appRouter = GoRouter(
  initialLocation: '/',

  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/dashboard', builder: (context, state) => const AdminDashboardScreen()),
    GoRoute(path: '/classes', builder: (context, state) => const ClassesScreen()),
    GoRoute(path: '/teachers', builder: (context, state) => const TeacherDirectoryScreen()),
    GoRoute(path: '/pending', builder: (context, state) => const ApprovalsScreen()),
    GoRoute(path: '/reports', builder: (context, state) => const ReportsAuditScreen()),
    GoRoute(path: '/roles', builder: (context, state) => const RoleScreen()), 
  ],
);