import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'app_routes.dart';

class AuthMiddleware extends GetMiddleware {
  @override


  RouteSettings? redirect(String? route) {
    if (GetStorage().read('token') == null) {
      return RouteSettings(name: AppRoutes.login);
    }
    return null;
  }
}