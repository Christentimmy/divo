import 'package:divo/app/modules/splash/controller/splash_controller.dart';
import 'package:divo/app/resources/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatelessWidget {
  SplashScreen({super.key});

  final splashController = Get.put(SplashController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: AnimatedBuilder(
          animation: splashController.controller,
          builder: (context, child) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(splashController.appName.length, (index) {
                return AnimatedBuilder(
                  animation: splashController.letterAnimations[index],
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(
                        0,
                        20 * (1 - splashController.letterAnimations[index].value),
                      ),
                      child: Opacity(
                        opacity: splashController.letterAnimations[index].value,
                        child: Text(
                          splashController.appName[index],
                          style: GoogleFonts.orbitron(
                            fontSize: 72, 
                            fontWeight: FontWeight.w900,
                            color: AppColors.neonPurpleBright,
                            letterSpacing: 4,
                            shadows: [
                              Shadow(
                                color: AppColors.neonPurple,
                                blurRadius: 20,
                              ),
                              Shadow(
                                color: AppColors.neonPurpleGlow,
                                blurRadius: 40,
                              ),
                              Shadow(
                                color: AppColors.neonPurpleBright,
                                blurRadius: 10,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),
            );
          },
        ),
      ),
    );
  }
}
