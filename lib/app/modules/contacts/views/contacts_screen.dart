import 'dart:async';
import 'package:divo/app/data/services/liphone_service.dart';
import 'package:divo/app/modules/contacts/controller/contact_controller.dart';
import 'package:divo/app/modules/contacts/widgets/build_contact_card_widget.dart';
import 'package:divo/app/resources/app_colors.dart';
import 'package:divo/app/widgets/custom_textfield.dart';
import 'package:divo/app/widgets/staggered_column_animation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:linphone_flutter_plugin/call_state.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  final contactController = Get.find<ContactController>();
  final linphoneService = LinphoneService();
  StreamSubscription<CallState>? _callStateSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (contactController.contacts.isNotEmpty) return;
      contactController.loadContacts();
    });
  }

  @override
  void dispose() {
    _callStateSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
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
              onChanged: (value) {
                contactController.searchContactWithName(contact: value);
                if (value.isEmpty) {
                  contactController.loadContacts(showLoader: false);
                }
              },
            ),
            SizedBox(height: Get.height * 0.05),
            Obx(() {
              if (contactController.isLoading.value) {
                return SizedBox(
                  height: Get.height * 0.45,
                  width: Get.width,
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryColor,
                    ),
                  ),
                );
              }
              if (contactController.contacts.isEmpty) {
                return SizedBox(
                  height: Get.height * 0.45,
                  width: Get.width,
                  child: Center(
                    child: Text(
                      "No contacts found",
                      style: GoogleFonts.fredoka(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                      ),
                    ),
                  ),
                );
              }
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: contactController.contacts.length,
                itemBuilder: (context, index) {
                  final contact = contactController.contacts[index];
                  return buildContactCard(contact: contact);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
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
