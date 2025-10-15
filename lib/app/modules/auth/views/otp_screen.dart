import 'package:divo/app/modules/auth/controller/timer_controller.dart';
import 'package:divo/app/resources/app_colors.dart';
import 'package:divo/app/routes/app_routes.dart';
import 'package:divo/app/widgets/custom_button.dart';
import 'package:divo/app/widgets/staggered_column_animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';

// ignore: must_be_immutable
class OtpScreen extends StatefulWidget {
  String email;
  VoidCallback? onVerifiedCallBack;
  OtpScreen({super.key, required this.email, this.onVerifiedCallBack});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    _timerController.startTimer();
  }

  final _timerController = Get.put(TimerController());
  // final _authController = Get.find<AuthController>();
  final _otpController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        child: StaggeredColumnAnimation(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: Get.height * 0.02),
            Row(
              children: [
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
                SizedBox(width: Get.width * 0.18),
                Text(
                  "Verification",
                  style: GoogleFonts.fredoka(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: Get.height * 0.07),
            richTextWidget(),
            const SizedBox(height: 15),
            Text(
              "A Verification code has been sent to\n${widget.email}",
              style: GoogleFonts.fredoka(
                fontSize: 16,
                height: 1.1,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 15),
            SizedBox(height: Get.height * 0.0375),
            Center(
              child: Pinput(
                controller: _otpController,
                length: 4,
                focusedPinTheme: PinTheme(
                  width: 65,
                  height: 65,
                  textStyle: GoogleFonts.fredoka(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                    color: AppColors.neonPurpleGlow,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.neonPurpleGlow,
                      width: 1,
                    ),
                    // color: const Color.fromARGB(255, 37, 37, 37),
                  ),
                ),
                defaultPinTheme: PinTheme(
                  width: 65,
                  height: 65,
                  textStyle: GoogleFonts.fredoka(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                    color: Colors.white,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                    // color: const Color.fromARGB(255, 37, 37, 37),
                  ),
                ),
              ),
            ),
            SizedBox(height: Get.height * 0.0375),
            CustomButton(
              isLoading: false.obs,
              child: Text(
                "Continue",
                style: GoogleFonts.fredoka(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              ontap: () {
                HapticFeedback.lightImpact();
                Get.offNamed(AppRoutes.bottomNavigation);
              },
            ),
            SizedBox(height: Get.height * 0.028),
            resendOtpRow(),
          ],
        ),
      ),
    );
  }

  Row resendOtpRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Didn't receive the code? ",
          style: GoogleFonts.fredoka(fontSize: 16, color: Colors.white),
        ),
        Obx(
          () => InkWell(
            onTap: () {},
            child: _timerController.secondsRemaining.value == 0
                ? Text(
                    "Resend",
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : Text(
                    "(${_timerController.secondsRemaining.value.toString()})",
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  RichText richTextWidget() {
    return RichText(
      text: TextSpan(
        style: GoogleFonts.roboto(fontSize: 24),
        children: [
          const TextSpan(
            text: "Enter your ",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text: "OTP",
            style: TextStyle(
              color: AppColors.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
