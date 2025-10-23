
import 'package:divo/app/modules/contacts/views/contacts_screen.dart';
import 'package:divo/app/modules/contacts/views/history_screen.dart';
import 'package:divo/app/modules/dial/views/dial_screen.dart';
import 'package:divo/app/modules/settings/views/settings_screen.dart';
import 'package:divo/app/resources/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BottomNavigationWidget extends StatelessWidget {
  BottomNavigationWidget({super.key});

  final List<Widget> pages = [
    ContactsScreen(),
    DialScreen(),
    HistoryScreen(),
    SettingsScreen(),
  ];

  final RxInt currentIndex = 0.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0F0D15),
      body: Obx(() => pages[currentIndex.value]),
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          unselectedItemColor: Colors.grey,
          selectedItemColor: AppColors.primaryColor,
          backgroundColor: Color(0xFF0F0D15),
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.call), label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.history), label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.settings), label: ''),
          ],
          currentIndex: currentIndex.value,
          onTap: (index) => currentIndex.value = index,
        ),
      ),
    );
  }
}
