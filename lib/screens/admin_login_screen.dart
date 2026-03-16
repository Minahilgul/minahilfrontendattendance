import 'package:flutter/material.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void login() {

    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if(email == "admin@davs.com" && password == "123456"){

      Navigator.pushNamed(context, "/dashboard");

    }else{

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Invalid Admin Email or Password"),
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
                        Icon(Icons.shield, color: Colors.blue),
                        SizedBox(width: 8),
                        Text(
                          "Admin Portal",
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
                    "Admin Secure Login",
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87),
                  ),
                ),

                const SizedBox(height: 8),

                const Center(
                  child: Text(
                    "Enter your institutional credentials to\nmanage campus attendance and records.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ),

                const SizedBox(height: 30),

              
                const Text(
                  "Admin Email",
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),

                const SizedBox(height: 8),

                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    hintText: "name@college.edu",
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

              
                const Text(
                  "Security Password",
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),

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

                const SizedBox(height: 10),

                const Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    "Forgot password?",
                    style: TextStyle(color: Colors.blue),
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

                    icon: const Icon(Icons.security),
                    label: const Text(
                      "Secure Login",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),

                const SizedBox(height: 25),

              
                const Center(
                  child: Column(
                    children: [
                      Text(
                        "AUTHORIZED PERSONNEL ONLY",
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey),
                      ),
                      SizedBox(height: 6),
                      Text(
                        "This is a secure system. Activities are logged and\nmonitored for compliance and security purposes.",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}