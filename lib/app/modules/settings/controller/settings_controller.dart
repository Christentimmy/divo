

// settings_controller.dart
import 'package:get/get.dart';

class SettingsController extends GetxController {
  // Audio Settings
  var audioCodec = 'PCMU'.obs;
  var echoCancellation = true.obs;
  var noiseSuppression = true.obs;
  var autoGainControl = true.obs;
  var speakerVolume = 80.0.obs;
  var microphoneVolume = 80.0.obs;
  var ringtoneVolume = 70.0.obs;
  
  // Network Settings
  var sipServer = ''.obs;
  var sipPort = '5060'.obs;
  var transportProtocol = 'UDP'.obs;
  
  // Call Settings
  var autoAnswer = false.obs;
  var callRecording = false.obs;
  var vibrationOnCall = true.obs;
  var showCallDuration = true.obs;
  
  // Account Settings
  var username = ''.obs;
  var displayName = ''.obs;
  
  final List<String> codecOptions = ['PCMU', 'PCMA', 'G729', 'Opus'];
  final List<String> protocolOptions = ['UDP', 'TCP', 'TLS'];
  
  @override
  void onInit() {
    super.onInit();
    loadSettings();
  }
  
  void loadSettings() {
    // TODO: Load from SharedPreferences or secure storage
  }
  
  void saveSettings() {
    // TODO: Save to SharedPreferences or secure storage
    Get.snackbar(
      'Settings Saved',
      'Your settings have been updated',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }
  
  void resetToDefaults() {
    echoCancellation.value = true;
    noiseSuppression.value = true;
    autoGainControl.value = true;
    speakerVolume.value = 80.0;
    microphoneVolume.value = 80.0;
    ringtoneVolume.value = 70.0;
    audioCodec.value = 'PCMU';
    transportProtocol.value = 'UDP';
    sipPort.value = '5060';
    autoAnswer.value = false;
    callRecording.value = false;
    vibrationOnCall.value = true;
    showCallDuration.value = true;
    
    Get.snackbar(
      'Reset Complete',
      'Settings restored to defaults',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }
}