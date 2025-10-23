import 'package:divo/app/controller/auth_controller.dart';
import 'package:divo/app/data/services/sip_service.dart';
import 'package:divo/app/modules/call/controller/call_controller.dart';
import 'package:divo/app/modules/contacts/controller/contact_controller.dart';
import 'package:get/get.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(SipService(), permanent: true);
    Get.put(AuthController());
    Get.put(ContactController());
    // Make CallController permanent so it always listens for incoming calls
    Get.put(CallController(), permanent: true);
  }
}
