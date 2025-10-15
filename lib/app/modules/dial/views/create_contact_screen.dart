import 'package:divo/app/resources/app_colors.dart';
import 'package:divo/app/widgets/custom_textfield.dart';
import 'package:divo/app/widgets/staggered_column_animation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class CreateContactScreen extends StatelessWidget {
  final String phoneNumber;
  CreateContactScreen({super.key, required this.phoneNumber});

  final phoneNumberController = TextEditingController();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final addressController = TextEditingController();
  final notesController = TextEditingController();
  final relationshipController = TextEditingController();

  final showMoreOptions = false.obs;

  @override
  Widget build(BuildContext context) {
    phoneNumberController.text = phoneNumber;
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: StaggeredColumnAnimation(
          children: [
            SizedBox(height: Get.height * 0.04),
            Row(
              children: [
                InkWell(
                  onTap: () => Get.back(),
                  child: Icon(Icons.arrow_back, color: Colors.grey.shade300),
                ),
                SizedBox(width: Get.width * 0.04),
                Text(
                  "Create Contact",
                  style: GoogleFonts.fredoka(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            SizedBox(height: Get.height * 0.1),
            CustomTextField(
              controller: nameController,
              hintText: 'Enter name',
              prefixIcon: Icons.person,
              prefixIconColor: const Color.fromARGB(255, 174, 144, 201),
            ),
            SizedBox(height: Get.height * 0.02),
            CustomTextField(
              controller: phoneNumberController,
              hintText: 'Enter phone number',
              prefixIcon: Icons.phone,
              prefixIconColor: const Color.fromARGB(255, 174, 144, 201),
            ),
            SizedBox(height: Get.height * 0.02),
            Obx(() {
              if (showMoreOptions.value) {
                return SizedBox.shrink();
              }
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      showMoreOptions.value = !showMoreOptions.value;
                    },
                    child: Text(
                      "View More",
                      style: GoogleFonts.fredoka(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Icon(Icons.keyboard_arrow_down_sharp, color: Colors.white),
                ],
              );
            }),
            Obx(() {
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                child: showMoreOptions.value
                    ? Column(
                        children: [
                          CustomTextField(
                            controller: emailController,
                            hintText: 'Email',
                            prefixIcon: Icons.email,
                            prefixIconColor: const Color.fromARGB(
                              255,
                              174,
                              144,
                              201,
                            ),
                          ),
                          SizedBox(height: Get.height * 0.02),
                          CustomTextField(
                            controller: addressController,
                            hintText: 'Address',
                            prefixIcon: Icons.location_on,
                            prefixIconColor: const Color.fromARGB(
                              255,
                              174,
                              144,
                              201,
                            ),
                          ),
                          SizedBox(height: Get.height * 0.02),
                          CustomTextField(
                            controller: notesController,
                            hintText: 'Notes',
                            prefixIcon: Icons.note,
                            prefixIconColor: const Color.fromARGB(
                              255,
                              174,
                              144,
                              201,
                            ),
                          ),
                          SizedBox(height: Get.height * 0.02),
                          CustomTextField(
                            controller: relationshipController,
                            hintText: 'Relationship',
                            prefixIcon: Icons.verified_user,
                            prefixIconColor: const Color.fromARGB(
                              255,
                              174,
                              144,
                              201,
                            ),
                          ),
                        ],
                      )
                    : const SizedBox.shrink(key: ValueKey('empty')),
              );
            }),
            SizedBox(height: Get.height * 0.15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: Text(
                    "Cancel",
                    style: GoogleFonts.fredoka(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => Get.back(),
                  child: Text(
                    "Save",
                    style: GoogleFonts.fredoka(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: Get.height * 0.02),
          ],
        ),
      ),
    );
  }
}
