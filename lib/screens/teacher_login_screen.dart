import 'package:flutter/material.dart';

class TeacherLoginScreen extends StatefulWidget {
  const TeacherLoginScreen({super.key});

  @override
  State<TeacherLoginScreen> createState() => _TeacherLoginScreenState();
}

class _TeacherLoginScreenState extends State<TeacherLoginScreen> {

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void login() {

    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if(email == "teacher@davs.com" && password == "123456"){

      Navigator.pushNamed(context, "/dashboard");

    }else{

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Invalid Teacher Email or Password"),
        ),
      );

    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffeef2f6),

      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 380,
            padding: const EdgeInsets.all(25),

            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                )
              ],
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Row(
                      children: [
                        Icon(Icons.school, color: Colors.blue),
                        SizedBox(width: 8),
                        Text(
                          "Teacher Portal",
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 16),
                        ),
                      ],
                    ),
                    Icon(Icons.info_outline, color: Colors.grey)
                  ],
                ),

                const SizedBox(height: 25),

                const Center(
                  child: Text(
                    "Teacher Login",
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold),
                  ),
                ),

                const SizedBox(height: 8),

                const Center(
                  child: Text(
                    "Login to manage your classes and\nattendance records.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ),

                const SizedBox(height: 30),

                const Text("Teacher Email",
                    style: TextStyle(fontWeight: FontWeight.w500)),

                const SizedBox(height: 8),

                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    hintText: "teacher@college.edu",
                    prefixIcon: const Icon(Icons.email_outlined),
                    filled: true,
                    fillColor: const Color(0xfff5f6f8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                const Text("Password",
                    style: TextStyle(fontWeight: FontWeight.w500)),

                const SizedBox(height: 8),

                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: const Icon(Icons.visibility_outlined),
                    filled: true,
                    fillColor: const Color(0xfff5f6f8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff1f4e79),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),

                    onPressed: login,

                    icon: const Icon(Icons.login),
                    label: const Text(
                      "Login",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}