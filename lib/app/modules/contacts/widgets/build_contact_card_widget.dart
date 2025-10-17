import 'package:divo/app/resources/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:google_fonts/google_fonts.dart';

Widget buildContactCard({required Contact contact}) {
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
        contact.displayName,
        style: GoogleFonts.fredoka(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      subtitle: Text(
        contact.phones.isNotEmpty ? contact.phones.first.number : "",
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
