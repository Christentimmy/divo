import 'package:divo/app/resources/app_colors.dart';
import 'package:divo/app/widgets/custom_textfield.dart';
import 'package:divo/app/widgets/staggered_column_animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class ContactsScreen extends StatelessWidget {
  const ContactsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text(
          "Contacts",
          style: GoogleFonts.fredoka(
            fontSize: 25,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: StaggeredColumnAnimation(
          children: [
            SizedBox(height: Get.height * 0.02),
            CustomTextField(
              hintText: "Search",
              prefixIcon: Icons.search,
              prefixIconColor: const Color.fromARGB(255, 174, 144, 201),
            ),
            SizedBox(height: Get.height * 0.05),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 10,
              itemBuilder: (context, index) {
                return buildContactCard();
              },
            ),
          ],
        ),
      ),
    );
  }

  Container buildContactCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: AppColors.neonPurpleGlow.withValues(alpha: 0.22),
            spreadRadius: 0,
            blurRadius: 10,
          ),
        ],
      ),
      child: ListTile(
        onTap: () {
          HapticFeedback.lightImpact();
        },
        title: Text(
          "John Doe",
          style: GoogleFonts.fredoka(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        subtitle: Text(
          "+81 90 1234 5678",
          style: GoogleFonts.fredoka(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Colors.white,
          ),
        ),
        trailing: CircleAvatar(
          radius: 20,
          backgroundColor: AppColors.primaryColor,
          child: Icon(Icons.call, color: Colors.white),
        ),
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
