import 'package:divo/app/modules/contacts/widgets/build_contact_card_widget.dart';
import 'package:divo/app/modules/dial/controller/dial_controller.dart';
import 'package:divo/app/resources/app_colors.dart';
import 'package:divo/app/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class DialScreen extends StatelessWidget {
  DialScreen({super.key});

  final dialController = Get.put(DialController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      body: Column(
        children: [
          buildBalanceWidget(),
          buildLikelyContacts(),
          const SizedBox(height: 15),
          buildInputField(),
          const SizedBox(height: 15),
          buildKeyPads(),
          buildActionButtons(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Obx buildActionButtons() {
    return Obx(() {
      if (dialController.input.isEmpty) {
        return SizedBox.shrink();
      }
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Call button
          InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(40),
            child: CircleAvatar(
              radius: 35,
              backgroundColor: AppColors.neonPurpleGlow,
              child: Icon(Icons.phone, color: Colors.white, size: 32),
            ),
          ),
          const SizedBox(width: 40),
          // Backspace button
          InkWell(
            onTap: dialController.onBackspace,
            onLongPress: () async {
              dialController.input.value = '';
            },
            borderRadius: BorderRadius.circular(40),
            splashColor: Colors.redAccent.withValues(alpha: 0.4),
            child: const CircleAvatar(
              radius: 35,
              backgroundColor: Colors.redAccent,
              child: Icon(
                Icons.backspace_outlined,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        ],
      );
    });
  }

  Expanded buildKeyPads() {
    return Expanded(
      flex: 3,
      child: GridView.builder(
        itemCount: dialController.keys.length,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 50),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 10,
          crossAxisSpacing: 25,
          childAspectRatio: 1,
        ),
        itemBuilder: (context, index) {
          final key = dialController.keys[index];
          return _DialButton(
            number: key['number']!,
            letters: key['letters']!,
            onTap: () => dialController.onKeyTap(key['number']!),
          );
        },
      ),
    );
  }

  Obx buildInputField() {
    return Obx(() {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: CustomTextField(
          hintText: dialController.input.value,
          readOnly: true,
          hintStyle: GoogleFonts.fredoka(fontSize: 22, color: Colors.white),
          textAlign: TextAlign.center,
          contentPadding: EdgeInsets.only(
            left: Get.width * 0.15,
            top: 10,
            bottom: 10,
          ),
        ),
      );
    });
  }

  Expanded buildLikelyContacts() {
    return Expanded(
      child: Obx(() {
        if (dialController.input.isEmpty) {
          return SizedBox.shrink();
        }
        return ListView.builder(
          itemCount: dialController.filterContacts.length,
          itemBuilder: (context, index) {
            final contact = dialController.filterContacts[index];
            return buildContactCard(contact: contact);
          },
        );
      }),
    );
  }

  Center buildBalanceWidget() {
    return Center(
      child: Text(
        "\$2.25",
        style: GoogleFonts.fredoka(
          fontSize: 22,
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      title: buildLogoText(),
      centerTitle: true,
      backgroundColor: AppColors.background,
      elevation: 0,
      automaticallyImplyLeading: false,
      // actions: [
      //   IconButton(
      //     onPressed: () {
      //       HapticFeedback.lightImpact();
      //       if (_input.value.isEmpty) {
      //         CustomSnackbar.showErrorToast("Enter number to save");
      //         return;
      //       }
      //       Get.toNamed(
      //         AppRoutes.createContact,
      //         arguments: {'phoneNumber': _input.value},
      //       );
      //     },
      //     icon: Icon(Icons.add, color: Colors.grey.shade300),
      //   ),
      // ],
    );
  }

  Widget buildLogoText() {
    return Text(
      "divo",
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
    );
  }
}

class _DialButton extends StatelessWidget {
  final String number;
  final String letters;
  final VoidCallback onTap;

  const _DialButton({
    required this.number,
    required this.letters,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(50),
        splashColor: Colors.white24,
        highlightColor: Colors.white12,
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white30, width: 1.5),
          ),
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (letters.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    letters,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
