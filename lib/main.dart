import 'package:divo/app/resources/app_colors.dart';
import 'package:divo/app/routes/app_pages.dart';
import 'package:divo/app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get/get_navigation/src/routes/transitions_type.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: "Divo",
      initialRoute: AppRoutes.splash,
      getPages: AppPages.routes,
      debugShowCheckedModeBanner: false,
      defaultTransition: Transition.fadeIn,
      // initialBinding: AppBindings(),
      theme: ThemeData(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        scaffoldBackgroundColor: AppColors.background,
        splashFactory: NoSplash.splashFactory,
        primaryColor: AppColors.primaryColor,
        textTheme: GoogleFonts.poppinsTextTheme(),
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: AppColors.primaryColor,
          selectionHandleColor: AppColors.primaryColor,
        ),
      ),
    );
  }
}
