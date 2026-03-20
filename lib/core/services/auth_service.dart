import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {

  static Future<bool> login(String email, String password) async {

    if (email.isEmpty || password.isEmpty) {
      print("❌ Empty fields");
      return false;
    }

    if ((email == "admin@davs.com" && password == "123456") ||
        (email == "teacher@davs.com" && password == "123456") ||
        (email == "student@davs.com" && password == "123456")) {

      String token = _generateToken();

      SharedPreferences prefs = await SharedPreferences.getInstance();

      
    await prefs.setString("token", token);
      
      String? savedToken = prefs.getString("token");

      print("✅ New Token Generated: $token");
      print("💾 Token Saved: $savedToken");

      return true;
    }

    print("❌ Invalid credentials");
    return false;
  }

  static String _generateToken() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    Random rand = Random();

    return List.generate(32, (index) => chars[rand.nextInt(chars.length)]).join();
  }

  static Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? token = prefs.getString("token");

    print("📦 Get Token: $token");

    return token;
  }

  static Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.remove("token");

    print("🚪 Token removed (Logout)");
  }
}