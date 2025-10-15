import 'dart:ui';

import 'package:divo/app/modules/auth/views/login_screen.dart';
import 'package:divo/app/modules/auth/views/otp_screen.dart';
import 'package:divo/app/modules/auth/views/signup_screen.dart';
import 'package:divo/app/modules/contacts/views/contacts_screen.dart';
import 'package:divo/app/modules/dial/views/create_contact_screen.dart';
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
    GetPage(name: AppRoutes.createContact, page: () {
      final arguments = Get.arguments ?? {};
      final phoneNumber = arguments['phoneNumber'] as String;
      if (phoneNumber.isEmpty) {
        throw Exception("Phone number is required");
      }
      return CreateContactScreen(phoneNumber: phoneNumber);
    }),
    GetPage(name: AppRoutes.contacts, page: () => ContactsScreen()),
  ];
}
