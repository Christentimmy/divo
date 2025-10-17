

import 'package:divo/app/modules/contacts/controller/contact_controller.dart';
import 'package:get/get.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(ContactController());
  }
}