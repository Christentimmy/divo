


import 'package:divo/app/modules/auth/login_screen.dart';
import 'package:divo/app/modules/auth/signup_screen.dart';
import 'package:divo/app/modules/splash/views/splash_screen.dart';
import 'package:divo/app/routes/app_routes.dart';
import 'package:get/get.dart';

class AppPages {
  static final routes = [
    GetPage(
      name: AppRoutes.splash,
      page: () =>  SplashScreen(),
    ),
    GetPage(
      name: AppRoutes.signup,
      page: () =>  SignupScreen(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () =>  LoginScreen(),
    ),
  ];
}