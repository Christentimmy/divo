import 'package:divo/app/resources/app_colors.dart';
import 'package:divo/app/routes/app_routes.dart';
import 'package:divo/app/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class DialScreen extends StatelessWidget {
  DialScreen({super.key});

  final RxString _input = ''.obs;

  final List<Map<String, String>> _keys = [
    {'number': '1', 'letters': '-'},
    {'number': '2', 'letters': 'ABC'},
    {'number': '3', 'letters': 'DEF'},
    {'number': '4', 'letters': 'GHI'},
    {'number': '5', 'letters': 'JKL'},
    {'number': '6', 'letters': 'MNO'},
    {'number': '7', 'letters': 'PQRS'},
    {'number': '8', 'letters': 'TUV'},
    {'number': '9', 'letters': 'WXYZ'},
    {'number': '*', 'letters': ''},
    {'number': '0', 'letters': '+'},
    {'number': '#', 'letters': ''},
  ];

  void _onKeyTap(String value) {
    HapticFeedback.lightImpact();
    _input.value += value;
  }

  void _onBackspace() {
    if (_input.isNotEmpty) {
      _input.value = _input.value.substring(0, _input.value.length - 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      body: Column(
        children: [
          Center(
            child: Text(
              "\$2.25",
              style: GoogleFonts.fredoka(
                fontSize: 22,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(height: Get.height * 0.05),
          Obx(() {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: CustomTextField(
                hintText: _input.value,
                readOnly: true,
                hintStyle: GoogleFonts.fredoka(
                  fontSize: 22,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
                contentPadding: EdgeInsets.only(
                  left: Get.width * 0.15,
                  top: 10,
                  bottom: 10,
                ),
              ),
            );
          }),

          const SizedBox(height: 40),

          // Number grid
          Expanded(
            child: GridView.builder(
              itemCount: _keys.length,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 50),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 15,
                crossAxisSpacing: 20,
                childAspectRatio: 1,
              ),
              itemBuilder: (context, index) {
                final key = _keys[index];
                return _DialButton(
                  number: key['number']!,
                  letters: key['letters']!,
                  onTap: () => _onKeyTap(key['number']!),
                );
              },
            ),
          ),

          // Bottom row (call + delete)
          Obx(() {
            if (_input.isEmpty) {
              return SizedBox.shrink();
            }
            return Padding(
              padding: const EdgeInsets.only(bottom: 40, top: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Call button
                  InkWell(
                    onTap: () {
                      debugPrint('Calling $_input...');
                    },
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
                    onTap: _onBackspace,
                    onLongPress: () {
                      _input.value = '';
                    },
                    borderRadius: BorderRadius.circular(40),
                    splashColor: Colors.redAccent.withOpacity(0.4),
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
              ),
            );
          }),
        ],
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
      actions: [
        IconButton(
          onPressed: () {
            HapticFeedback.lightImpact();
            if (_input.value.isEmpty) return;
            Get.toNamed(
              AppRoutes.createContact,
              arguments: {'phoneNumber': _input.value},
            );
          },
          icon: Icon(Icons.add, color: Colors.grey.shade300),
        ),
      ],
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
