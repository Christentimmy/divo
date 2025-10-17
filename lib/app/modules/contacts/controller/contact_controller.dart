import 'package:flutter/widgets.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:get/get.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

class ContactController extends GetxController {
  var contacts = <Contact>[].obs;
  var isLoading = false.obs;
  RxString searchText = "".obs;

  @override
  void onInit() {
    super.onInit();
    loadContacts();
  }

  Future<void> loadContacts({bool showLoader = true}) async {
    isLoading.value = showLoader;

    try {
      final status = await Permission.contacts.status;
      if (!status.isGranted || status.isPermanentlyDenied) {
        final newSatus = await Permission.contacts.request();
        if (!newSatus.isGranted) return;
      }
      Iterable<Contact> contacts = await FlutterContacts.getContacts(
        withProperties: true,
      );
      this.contacts.assignAll(contacts.toList());
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void searchContact({required String contact}) async {
    final result = contacts
        .where(
          (element) =>
              element.displayName.toLowerCase().contains(contact.toLowerCase()),
        )
        .toList();
    contacts.assignAll(result);
  }
}
