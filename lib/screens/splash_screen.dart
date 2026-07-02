import 'package:flutter/material.dart';
import 'dart:async';
import 'package:get_storage/get_storage.dart';
import '../core/services/auth_service.dart';
import 'package:get/get.dart';
import '../core/theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _controller.forward();


    _checkLogin();
  }

  
  void _checkLogin() async {
    await Future.delayed(const Duration(seconds: 3));

    final storage = GetStorage();
    String? token = storage.read<String>('token');
    String? role = storage.read<String>('role');
    String? userIdStr = storage.read<String>('userId');
    String? userName = storage.read<String>('userName');

    if (token != null && role != null) {
      int userId = int.tryParse(userIdStr ?? '') ?? 0;
      if (role == 'admin') {
        Get.offAllNamed('/admin-dashboard', arguments: {'userId': userId, 'role': role, 'name': userName});
      } else if (role == 'teacher') {
        Get.offAllNamed('/teacher-dashboard', arguments: {'userId': userId, 'role': role, 'name': userName});
      } else {
        Get.offAllNamed('/student-dashboard', arguments: {'userId': userId, 'role': role, 'name': userName});
      }
    } else {
      Get.offAllNamed('/login');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,

        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.background,
              AppColors.surface,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: FadeTransition(
          opacity: _animation,

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 30,
                      spreadRadius: 5,
                    )
                  ],
                ),
                child: Image.asset(
                  "assets/images/davs_logo.png",
                  width: 260,
                ),
              ),

              const SizedBox(height: 40),

              Text(
                "DAVS",
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryDark,
                  letterSpacing: 2,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                "Distributed Attendance Verification System",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 50),

              const CircularProgressIndicator(),

              const SizedBox(height: 10),

              Text(
                "Initializing System...",
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}