import 'package:cherry_toast/cherry_toast.dart';
import 'package:cherry_toast/resources/arrays.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomSnackbar {
  static void showErrorToast(
    String message, {
    Position position = Position.top,
  }) {
    CherryToast.error(
      toastPosition: position,
      title: Text(
        "Error",
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      description: Text(
        message,
        style: GoogleFonts.poppins(color: Colors.white),
      ),
      backgroundColor: const Color.fromARGB(216, 244, 67, 54),
      animationDuration: const Duration(milliseconds: 300),
      autoDismiss: true,
      shadowColor: Colors.transparent,
      borderRadius: 14,
      iconWidget: Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: CircleAvatar(
          backgroundColor: Colors.white,
          child: Icon(Icons.error, size: 23, color: Colors.red),
        ),
      ),
      enableIconAnimation: true,
    ).show(Get.context!);
  }

  static void showSuccessToast(
    String message, {
    Duration toastDuration = const Duration(milliseconds: 3000),
  }) {
    CherryToast.success(
      title: Text(
        "Success",
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      description: Text(
        message,
        style: GoogleFonts.poppins(color: Colors.white),
      ),
      backgroundColor: Colors.green,
      animationDuration: const Duration(milliseconds: 300),
      autoDismiss: true,
      shadowColor: Colors.transparent,
      borderRadius: 14,
      iconWidget: Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: CircleAvatar(
          backgroundColor: Colors.white,
          child: Icon(Icons.check_circle, size: 23, color: Colors.green),
        ),
      ),
      toastDuration: toastDuration,
      enableIconAnimation: true,
    ).show(Get.context!);
  }
}
