import 'package:divo/app/resources/app_colors.dart';
import 'package:divo/app/routes/app_routes.dart';
import 'package:divo/app/widgets/custom_button.dart';
import 'package:divo/app/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final formKey = GlobalKey<FormState>();
  final isPasswordVisible = true.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            SizedBox(height: Get.height * 0.16),
            buildLogoText(),
            Center(
              child: Text(
                "Welcome back!!!",
                style: GoogleFonts.fredoka(
                  fontSize: 17,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Center(
              child: Text(
                "Fill the form below to login",
                style: GoogleFonts.fredoka(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(height: Get.height * 0.05),
            buildFormFields(),
            SizedBox(height: Get.height * 0.1),
            CustomButton(
              ontap: () {},
              isLoading: false.obs,
              child: Text(
                "Login",
                style: GoogleFonts.fredoka(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: Get.height * 0.05),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Don't have an account?  ",
                  style: GoogleFonts.fredoka(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                InkWell(
                  onTap: () => Get.toNamed(AppRoutes.signup),
                  child: Text(
                    "Register",
                    style: GoogleFonts.fredoka(
                      fontSize: 14,
                      color: AppColors.neonPurpleBright,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Form buildFormFields() {
    return Form(
      key: formKey,
      child: Column(
        children: [
          CustomTextField(
            hintText: "Email",
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icons.email,
            prefixIconColor: const Color.fromARGB(255, 174, 144, 201),
          ),
          SizedBox(height: Get.height * 0.02),
          Obx(() {
            return CustomTextField(
              hintText: "Password",
              prefixIcon: Icons.lock,
              prefixIconColor: const Color.fromARGB(255, 174, 144, 201),
              isObscure: isPasswordVisible.value,
              onSuffixTap: () => isPasswordVisible.value = !isPasswordVisible.value,
              suffixIcon: isPasswordVisible.value ? Icons.visibility : Icons.visibility_off,
            );
          }),
        ],
      ),
    );
  }

  Center buildLogoText() {
    return Center(
      child: Text(
        "Divo",
        style: GoogleFonts.orbitron(
          fontSize: 35,
          fontWeight: FontWeight.w900,
          color: AppColors.neonPurpleBright,
          letterSpacing: 4,
          shadows: [
            Shadow(color: AppColors.neonPurple, blurRadius: 20),
            Shadow(color: AppColors.neonPurpleGlow, blurRadius: 40),
            Shadow(color: AppColors.neonPurpleBright, blurRadius: 10),
          ],
        ),
      ),
    );
  }
}
