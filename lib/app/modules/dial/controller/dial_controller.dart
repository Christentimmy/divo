import 'package:divo/app/data/services/liphone_service.dart';
import 'package:divo/app/modules/contacts/controller/contact_controller.dart';
import 'package:divo/app/routes/app_routes.dart';
import 'package:divo/app/widgets/snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:get/get.dart';

class DialController extends GetxController {
  final contactController = Get.find<ContactController>();
  final service = LinphoneService();

  final RxString input = ''.obs;
  final RxBool isLoading = false.obs;
  final RxList contacts = <Contact>[].obs;
  final RxList filterContacts = <Contact>[].obs;
  final List<Map<String, String>> keys = [
    {'number': '1', 'letters': '-'},
    {'number': '2', 'letters': 'ABC'},
    {'number': '3', 'letters': 'DEF'},
    {'number': '4', 'letters': 'GHI'},
    {'number': '5', 'letters': 'JKL'},
    {'number': '6', 'letters': 'MNO'},
    {'number': '7', 'letters': 'PQRS'},
    {'number': '8', 'letters': 'TUV'},
    {'number': '9', 'letters': 'WXYZ'},
    {'number': '+', 'letters': ''},
    {'number': '0', 'letters': ''},
    {'number': '#', 'letters': ''},
  ];

  void onKeyTap(String value) {
    HapticFeedback.lightImpact();
    input.value += value;
  }

  @override
  onInit() {
    super.onInit();
    loadContacts();
    ever<String>(input, (value) {
      searchContactWithNumber(contact: value);
    });
  }

  Future<void> searchContactWithNumber({required String contact}) async {
    if (contact.isEmpty) return;

    final result = contacts.where((element) {
      final List<Phone> phones = element.phones ?? [];

      if (phones.isEmpty) return false;
      return phones.any((phone) {
        final number = (phone.number).toString().trim();
        return number.isNotEmpty && number.contains(contact);
      });
    }).toList();

    filterContacts.value = result;
  }

  Future<void> loadContacts() async {
    await contactController.loadContacts(showLoader: false);
    contacts.value = contactController.contacts;
  }

  void onBackspace() {
    if (input.isNotEmpty) {
      input.value = input.value.substring(0, input.value.length - 1);
    }
  }

  Future<void> makeCall() async {
    isLoading.value = true;
    try {
      
      final success = await service.call("sip:gsukuna@sip.linphone.org");
      // final success = await service.call("sip:2233592973@sip2sip.info");
      if (!success) {
        CustomSnackbar.showErrorToast("Call failed");
        return;
      }
      Get.toNamed(AppRoutes.call);
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
