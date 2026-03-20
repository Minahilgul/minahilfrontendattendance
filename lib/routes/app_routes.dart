import 'package:get/get.dart';
import 'package:attendence_verification/screens/splash_screen.dart';
import 'package:attendence_verification/screens/login_screen.dart';
import 'package:attendence_verification/screens/admin_dashboard_screen.dart';

class AppRoutes {
  static const splash = "/";
  static const login = "/login";
  static const dashboard = "/dashboard";

  static List<GetPage> routes = [
    GetPage(name: splash, page: () => const SplashScreen()),

    GetPage(name: login, page: () => const LoginScreen()),

    GetPage(name: dashboard, page: () => const AdminDashboardScreen()),
  ];
}
