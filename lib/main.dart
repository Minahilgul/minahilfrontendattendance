import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/login_selection_screen.dart';
import 'screens/admin_login_screen.dart';
import 'screens/teacher_login_screen.dart';
import 'screens/student_login_screen.dart';
import 'screens/admin_dashboard_screen.dart';

void main() {
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      initialRoute: "/",

      routes: {

        "/": (context) => const SplashScreen(),

        "/loginSelection": (context) => const LoginSelectionScreen(),

        "/adminLogin": (context) => const AdminLoginScreen(),

        "/teacherLogin": (context) => const TeacherLoginScreen(),

        "/studentLogin": (context) => const StudentLoginScreen(),

        "/dashboard": (context) => const AdminDashboardScreen(),
      },
    );
  }
}