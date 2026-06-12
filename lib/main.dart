import 'package:flutter/material.dart';
import 'routes/app_routes.dart';
import 'core/services/auth_service.dart'; // ✅ Import add karo

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // ✅ Flutter init karna lazmi hai
  
  await AuthService.loadToken(); // ✅ Token + User load karo app start pe
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
    );
  }
}