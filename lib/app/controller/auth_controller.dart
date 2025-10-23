import 'dart:async';
import 'package:divo/app/data/services/liphone_service.dart';
import 'package:divo/app/data/services/sip_service.dart';
import 'package:divo/app/routes/app_routes.dart';
import 'package:divo/app/widgets/snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  final SipService sipService = Get.find<SipService>();
  final isloading = false.obs;
  final LinphoneService _service = LinphoneService();
  StreamSubscription? _registrationSubscription;

  Future<void> sipConnect() async {
    isloading.value = true;
    try {
      // Initialize call state listener first
      _service.initializeCallStateListener();
      
      // Listen to registration state changes
      _registrationSubscription?.cancel();
      _registrationSubscription = _service.registrationStateStream.listen((regData) {
        final state = regData['state'] as String?;
        final message = regData['message'] as String?;
        
        debugPrint('📡 Registration state: $state, Message: $message');
        
        if (state == 'Ok') {
          // Registration successful
          CustomSnackbar.showSuccessToast('Login successful');
          isloading.value = false;
          Get.offNamed(AppRoutes.bottomNavigation);
        } else if (state == 'Failed') {
          // Registration failed
          CustomSnackbar.showErrorToast('Login failed: $message');
          isloading.value = false;
        } else if (state == 'Progress') {
          // Registration in progress
          debugPrint('Registration in progress...');
        } else if (state == 'Cleared') {
          // Registration cleared
          debugPrint('Registration cleared');
          isloading.value = false;
        }
      });

      // Attempt login
      final success = await _service.login(
        username: 'timmychris09',
        password: 'Timileyin',
        domain: 'sip.linphone.org',
      );

      if (!success) {
        CustomSnackbar.showErrorToast('Failed to initiate login');
        isloading.value = false;
      }

    } catch (e) {
      debugPrint('❌ Login error: ${e.toString()}');
      CustomSnackbar.showErrorToast(e.toString());
      isloading.value = false;
    }
  }

  @override
  void onClose() {
    _registrationSubscription?.cancel();
    super.onClose();
  }
}
