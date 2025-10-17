// import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/widgets.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:get/get.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

class ContactController extends GetxController {
  var contacts = <Contact>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadContacts();
  }

  Future<void> loadContacts() async {
    isLoading.value = true;

    try {
      final status = await Permission.contacts.status;
      if (!status.isGranted || status.isPermanentlyDenied) {
        final newSatus = await Permission.contacts.request();
        if (!newSatus.isGranted) return;
      }
      Iterable<Contact> contacts = await FlutterContacts.getContacts(withProperties: true);
      this.contacts.assignAll(contacts.toList());
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
