import 'package:divo/app/resources/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class HistoryScreen extends StatelessWidget {
  HistoryScreen({super.key});

  final expandIndex = (-1).obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        child: ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 10,
          itemBuilder: (context, index) {
            return buildContactCard(index);
          },
        ),
      ),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.background,
      title: Text(
        "History",
        style: GoogleFonts.fredoka(
          fontSize: 25,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.more_vert),
          color: Colors.white,
          onPressed: () {},
        ),
      ],
    );
  }

  Widget buildContactCard(int index) {
    return Obx(() {
      return AnimatedSize(
        duration: const Duration(milliseconds: 300),
        child: Container(
          margin: const EdgeInsets.only(bottom: 26),
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                onTap: () {
                  HapticFeedback.lightImpact();
                  if (expandIndex.value == index) {
                    expandIndex.value = -1;
                    return;
                  }
                  expandIndex.value = index;
                },
                leading: index == 1
                    ? Icon(Icons.call_missed, color: Colors.redAccent)
                    : Icon(Icons.phone, color: Colors.white),
                title: Text(
                  "+81 90 1234 5678",
                  style: GoogleFonts.fredoka(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                trailing: Text(
                  "12:34 PM",
                  style: GoogleFonts.fredoka(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                  ),
                ),
              ),
              if (expandIndex.value == index) ...[
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Text(
                    "Incoming call, 0 mins 22 sec",
                    style: GoogleFonts.fredoka(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Divider(
                    color: AppColors.neonPurpleGlow.withValues(alpha: 0.3),
                    thickness: 1,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.primaryColor,
                      child: Icon(Icons.call, color: Colors.white),
                    ),
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.redAccent,
                      child: Icon(Icons.delete, color: Colors.white),
                    ),
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.redAccent,
                      child: Icon(Icons.block, color: Colors.white),
                    ),
                  ],
                ),
              ],
              SizedBox(height: 20),
            ],
          ),
        ),
      );
    });
  }
}
