import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';



class AuthService {
  static const String baseUrl = 'https://wholesaleapp.sandbox.pk/api/login';

  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('https://wholesaleapp.sandbox.pk/api/login'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "email": email, 
          "password": password
          }),
      );

      print("Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 && data['message'] == 'Login successful') {
           final box = GetStorage();
    box.write('token', data['token']); 
        return {
          "success": true,
          "data": data,
        };
      } else {
        return {'success': false, 'message': data['message'] ?? 'Login failed'};
      }
    } catch (e) {
      return {"success": false, "message": "Server error"};
    }
  }
    static Future<Map<String, dynamic>> register(Map<String, dynamic> body) async {
      try {
        final response = await http.post(
          Uri.parse('$baseUrl/signup'),
          headers: {"Content-Type": "application/json"},
          body: json.encode(body),
        );
        final data = json.decode(response.body);
        if (response.statusCode == 200) {
          return {
            "success": true,
          };
        } else {
          return {"success": false, "message": data['message']};
        }
      } catch (e) {
        return {"success": false, "message": "Server error"};
      }
  }

  static Future<String?> getToken() async {
    final box = GetStorage();
    return box.read('token');
  }

}


  // static Future<bool> login(String email, String password) async {

  //   if (email.isEmpty || password.isEmpty) {
  //     print("❌ Empty fields");
  //     return false;
  //   }

  //   if ((email == "admin@davs.com" && password == "123456") ||
  //       (email == "teacher@davs.com" && password == "123456") ||
  //       (email == "student@davs.com" && password == "123456")) {

  //     String token = _generateToken();

  //     SharedPreferences prefs = await SharedPreferences.getInstance();

      
  //   await prefs.setString("token", token);
      
  //     String? savedToken = prefs.getString("token");

  //     print("✅ New Token Generated: $token");
  //     print("💾 Token Saved: $savedToken");

  //     return true;
  //   }

  //   print("❌ Invalid credentials");
  //   return false;
  // }

  // static String _generateToken() {
  //   const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
  //   Random rand = Random();

  //   return List.generate(32, (index) => chars[rand.nextInt(chars.length)]).join();
  // }

  // static Future<String?> getToken() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();

  //   String? token = prefs.getString("token");

  //   print("📦 Get Token: $token");

  //   return token;
  // }

  // static Future<void> logout() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();

  //   await prefs.remove("token");

  //   print("🚪 Token removed (Logout)");
  // }

// }