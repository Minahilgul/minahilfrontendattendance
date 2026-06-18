import 'package:flutter/material.dart';
import '../core/services/auth_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // 👈 GetStorage hatao
import 'package:go_router/go_router.dart';
import '../core/services/device_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _isLoading = false;
  final storage = FlutterSecureStorage(); //  GetStorage ki jagah ye

  Future<void> _login() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email and password cannot be empty")),
      );
      return;
    }
    // DEVICE ID GET KARO
  final deviceId = await DeviceService.getDeviceId();
  print("DEVICE ID = $deviceId");

  setState(() {
    _isLoading = true;
  });

  final result = await AuthService.login(
    emailController.text,
    passwordController.text,
  );

  setState(() {
    _isLoading = false;
  });

    if (result['success']) {
      
      final user = result['result'] ??{};
      int userId = user['id'] ?? 0; 
      String role = user['role'] ?? 'student';
      String userName = user['username'] ?? emailController.text;
      String token = user['token'] ?? ''; //  token variable me lo
      print("FULL RESPONSE: $result"); 
      print("USER DATA: $user");
      print("Final UserID: $userId"); 
      
      //  Bas ye 5 line change - await lagao + .toString()
      await storage.write(key: 'isLoggedIn', value: 'true');
      await storage.write(key: 'userName', value: userName);
      await storage.write(key: 'role', value: role);
      await storage.write(key: 'userId', value: userId.toString());
      await storage.write(key: 'token', value: token);
      
      print("Token saved securely");

      
      if (role == 'admin') {
        context.go('/admin-dashboard', extra: {'userId': userId, 'role': role, 'name': userName});
      } else if (role == 'teacher') {
        context.go('/teacher-dashboard', extra: {'userId': userId, 'role': role, 'name': userName});
      } else {
        context.go('/student-dashboard', extra: {'userId': userId, 'role': role, 'name': userName});
      }
      
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'])),
      );
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
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
                ),
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
                          "Login Portal",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    Icon(Icons.info_outline, color: Colors.grey),
                  ],
                ),
                const SizedBox(height: 25),
                const Center(
                  child: Text(
                    "Login",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Center(
                  child: Text(
                    "Enter your credentials to continue",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  "Email",
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
                  "Password",
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
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff1f4e79),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            "Login",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 25),
                const Center(
                  child: Column(
                    children: [
                      Text(
                        "AUTHORIZED USERS ONLY",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        "This is a secure system. Activities are monitored.",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
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