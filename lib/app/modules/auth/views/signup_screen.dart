import 'package:divo/app/resources/app_colors.dart';
import 'package:divo/app/routes/app_routes.dart';
import 'package:divo/app/widgets/custom_button.dart';
import 'package:divo/app/widgets/custom_textfield.dart';
import 'package:divo/app/widgets/staggered_column_animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class SignupScreen extends StatelessWidget {
  SignupScreen({super.key});

  final formKey = GlobalKey<FormState>();
  final isPasswordVisible = true.obs;
  final isConfirmPasswordVisible = true.obs;
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final countryController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: StaggeredColumnAnimation(
          children: [
            SizedBox(height: Get.height * 0.1),
            buildLogoText(),
            Center(
              child: Text(
                "Create Account",
                style: GoogleFonts.fredoka(
                  fontSize: 17,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Center(
              child: Text(
                "Fill the form below to create an account",
                style: GoogleFonts.fredoka(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(height: Get.height * 0.05),
            buildFormFields(),
            SizedBox(height: Get.height * 0.05),
            CustomButton(
              ontap: () {
                HapticFeedback.lightImpact();
                if (formKey.currentState?.validate() == false) return;
                Get.toNamed(
                  AppRoutes.otp,
                  arguments: {'email': emailController.text},
                );
              },
              isLoading: false.obs,
              child: Text(
                "Register",
                style: GoogleFonts.fredoka(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: Get.height * 0.02),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Already have an account?  ",
                  style: GoogleFonts.fredoka(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                InkWell(
                  onTap: () => Get.toNamed(AppRoutes.login),
                  child: Text(
                    "Login",
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
            controller: usernameController,
            hintText: "Username",
            prefixIcon: Icons.verified_user,
            prefixIconColor: const Color.fromARGB(255, 174, 144, 201),
          ),
          SizedBox(height: Get.height * 0.02),
          CustomTextField(
            controller: emailController,
            hintText: "Email",
            prefixIcon: Icons.email,
            prefixIconColor: const Color.fromARGB(255, 174, 144, 201),
          ),
          SizedBox(height: Get.height * 0.02),
          CustomTextField(
            controller: phoneController,
            hintText: "Phone Number",
            prefixIcon: Icons.phone,
            prefixIconColor: const Color.fromARGB(255, 174, 144, 201),
          ),
          SizedBox(height: Get.height * 0.02),
          CustomTextField(
            controller: countryController,
            hintText: "Country",
            prefixIcon: Icons.flag,
            prefixIconColor: const Color.fromARGB(255, 174, 144, 201),
          ),
          SizedBox(height: Get.height * 0.02),
          Obx(() {
            return CustomTextField(
              controller: passwordController,
              hintText: "Password",
              prefixIcon: Icons.lock,
              prefixIconColor: const Color.fromARGB(255, 174, 144, 201),
              isObscure: isPasswordVisible.value,
              onSuffixTap: () =>
                  isPasswordVisible.value = !isPasswordVisible.value,
              suffixIcon: isPasswordVisible.value
                  ? Icons.visibility
                  : Icons.visibility_off,
            );
          }),
          SizedBox(height: Get.height * 0.02),
          Obx(() {
            return CustomTextField(
              hintText: "Confirm Password",
              prefixIcon: Icons.lock,
              prefixIconColor: const Color.fromARGB(255, 174, 144, 201),
              isObscure: isConfirmPasswordVisible.value,
              onSuffixTap: () => isConfirmPasswordVisible.value =
                  !isConfirmPasswordVisible.value,
              suffixIcon: isConfirmPasswordVisible.value
                  ? Icons.visibility
                  : Icons.visibility_off,
              validator: (value) {
                if (value!.isEmpty) {
                  return "Confirm Password is required";
                }
                if (value != passwordController.text) {
                  return "Passwords do not match";
                }
                return null;
              },
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
