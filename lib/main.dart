import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'routes/app_routes.dart';
import 'core/services/auth_service.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); //  Flutter init karna lazmi hai
  await GetStorage.init(); //  GetStorage initialize 
  await AuthService.loadToken(); //  Token + User load karna app start pe
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/splash',
      getPages: AppRoutes.routes,
    );
  }
}