import 'dart:ui';

import 'package:divo/app/modules/auth/views/login_screen.dart';
import 'package:divo/app/modules/auth/views/otp_screen.dart';
import 'package:divo/app/modules/auth/views/signup_screen.dart';
import 'package:divo/app/modules/dial/views/dial_screen.dart';
import 'package:divo/app/modules/splash/views/splash_screen.dart';
import 'package:divo/app/routes/app_routes.dart';
import 'package:get/get.dart';

class AppPages {
  static final routes = [
    GetPage(name: AppRoutes.splash, page: () => SplashScreen()),
    GetPage(name: AppRoutes.signup, page: () => SignupScreen()),
    GetPage(name: AppRoutes.login, page: () => LoginScreen()),
    GetPage(name: AppRoutes.dial, page: () => DialScreen()),
    GetPage(name: AppRoutes.otp, page: () {
      final arguments = Get.arguments ?? {};
      final email = arguments['email'] as String;
      final onVerifiedCallBack = arguments['onVerifiedCallBack'] as VoidCallback?;
      if (email.isEmpty) {
        throw Exception("Email is required");
      }
      return OtpScreen(email: email, onVerifiedCallBack: onVerifiedCallBack);
    }),
  ];
}
