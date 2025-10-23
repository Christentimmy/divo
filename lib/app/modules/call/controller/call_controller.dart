import 'dart:async';
import 'package:divo/app/data/services/liphone_service.dart';
import 'package:divo/app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CallController extends GetxController {
  final LinphoneService _service = LinphoneService();

  final callState = Rx<String?>(null);
  final remoteAddress = Rx<String?>(null);
  final callDirection = Rx<String?>(null);
  final isMuted = false.obs;
  final isSpeakerOn = false.obs;

  StreamSubscription? _callStateSubscription;

  @override
  void onInit() {
    super.onInit();
    listenToCallState();
  }

  void listenToCallState() {
    _callStateSubscription = _service.callStateStream.listen((callData) async {
      final state = callData['state'] as String?;
      final remote = callData['remoteAddress'] as String?;
      final direction = callData['direction'] as String?;
      
      debugPrint("📞 Call state: $state, Remote: $remote, Direction: $direction");
      
      callState.value = state;
      remoteAddress.value = remote;
      callDirection.value = direction;
      
      if (state == 'IncomingReceived') {
        Get.toNamed(AppRoutes.call);
      }
      
      if (state == 'Released' || state == 'End' || state == 'Error') {
        await Future.delayed(const Duration(seconds: 2), () {
          if (Get.currentRoute == AppRoutes.call) {
            Get.back();
          }
        });
      }
    });
  }

  Future<void> hangup() async {
    await _service.hangUp();
    Get.back();
  }

  Future<void> toggleMute() async {
    final muted = await _service.toggleMute();
    isMuted.value = muted;
  }

  Future<void> toggleSpeaker() async {
    final speakerOn = await _service.toggleSpeaker();
    isSpeakerOn.value = speakerOn;
  }

  @override
  void onClose() {
    _callStateSubscription?.cancel();
    super.onClose();
  }
}
