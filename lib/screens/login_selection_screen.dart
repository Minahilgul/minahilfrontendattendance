import 'package:flutter/material.dart';

class LoginSelectionScreen extends StatelessWidget {
  const LoginSelectionScreen({super.key});

  Widget roleCard(
      BuildContext context,
      String title,
      String subtitle,
      IconData icon,
      Color color,
      String route) {

    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, route);
      },

      borderRadius: BorderRadius.circular(18),

      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 20,
              offset: const Offset(0, 8),
            )
          ],
        ),

        child: Row(
          children: [

            Container(
              padding: const EdgeInsets.all(14),

              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),

              child: Icon(
                icon,
                color: color,
                size: 30,
              ),
            ),

            const SizedBox(width: 18),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            const Icon(Icons.arrow_forward_ios, size: 18)
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Container(

        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xffe3f2fd),
              Color(0xffffffff),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(25),

              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  const Icon(
                    Icons.lock,
                    size: 55,
                    color: Color(0xff1f4e79),
                  ),

                  const SizedBox(height: 15),

                  const Text(
                    "Login Portal",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff1f4e79),
                    ),
                  ),

                  const SizedBox(height: 6),

                  const Text(
                    "Select your role to continue",
                    style: TextStyle(color: Colors.grey),
                  ),

                  const SizedBox(height: 40),

                  roleCard(
                    context,
                    "Admin Login",
                    "Manage system & attendance records",
                    Icons.admin_panel_settings,
                    const Color.fromARGB(255, 60, 132, 221),
                    "/adminLogin",
                  ),

                  const SizedBox(height: 20),

                  roleCard(
                    context,
                    "Teacher Login",
                    "Manage classes and student attendance",
                    Icons.school,
                    const Color(0xff2c7be5),
                    "/teacherLogin",
                  ),

                  const SizedBox(height: 20),

                  roleCard(
                    context,
                    "Student Login",
                    "View attendance and academic info",
                    Icons.person,
                    const Color.fromARGB(255, 62, 148, 206),
                    "/studentLogin",
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}