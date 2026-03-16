import 'package:flutter/material.dart';

class LoginSelectionScreen extends StatelessWidget {
  const LoginSelectionScreen({super.key});

  Widget loginButton(
      BuildContext context, String text, Color color, String route) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushNamed(context, route);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f7fa),

      body: SafeArea(
        child: Center(
          child: Container(
            width: 380, // Card width control
            padding: const EdgeInsets.all(30),

            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),

            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                /// Title
                const Text(
                  "Login As",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  "Select your role to continue",
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),

                const SizedBox(height: 35),

                /// Admin
                loginButton(
                  context,
                  "Admin Login",
                  const Color(0xff1d4f8c),
                  "/adminLogin",
                ),

                const SizedBox(height: 18),

                /// Teacher
                loginButton(
                  context,
                  "Teacher Login",
                  const Color(0xff2c7be5),
                  "/teacherLogin",
                ),

                const SizedBox(height: 18),

                /// Student
                loginButton(
                  context,
                  "Student Login",
                  const Color.fromARGB(255, 118, 183, 226),
                  "/studentLogin",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}