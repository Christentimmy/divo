import 'dart:async';
import 'package:divo/app/data/services/linphone_native_service.dart';
import 'package:divo/app/widgets/snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class LinphoneService {
  static final LinphoneService _instance = LinphoneService._internal();
  factory LinphoneService() => _instance;

  final _linphone = LinphoneNativeService();
  final _callStateController = StreamController<Map<String, dynamic>>.broadcast();
  final _registrationStateController = StreamController<Map<String, dynamic>>.broadcast();
  StreamSubscription<Map<String, dynamic>>? _callStateSubscription;
  StreamSubscription<Map<String, dynamic>>? _registrationSubscription;

  LinphoneService._internal() {
    _initialize();
  }

  Future<void> _initialize() async {
    await _linphone.initialize();
  }

  LinphoneNativeService get plugin => _linphone;

  Future<bool> login({
    required String username,
    required String password,
    required String domain,
  }) async {
    try {
      final result = await _linphone.login(
        username: username,
        password: password,
        domain: domain,
      );

      return result;
    } catch (e) {
      debugPrint('Login error: ${e.toString()}');
      return false;
    }
  }

  // Initialize call state listener (called once after login)
  void initializeCallStateListener() {
    // Cancel existing subscription if any
    _callStateSubscription?.cancel();
    _registrationSubscription?.cancel();
    
    debugPrint("✅ Initializing native Linphone listeners");

    // Set up call state listener
    _callStateSubscription = _linphone.callStateStream.listen(
      (callData) {
        final state = callData['state'] as String?;
        final remoteAddress = callData['remoteAddress'] as String?;
        final direction = callData['direction'] as String?;
        
        debugPrint('📞 Call state: $state, Remote: $remoteAddress, Direction: $direction');
        _callStateController.add(callData);
        
        // Show notification for important states
        if (state == 'IncomingReceived') {
          
          CustomSnackbar.showSuccessToast('Incoming call from $remoteAddress');
        } else if (state == 'Connected' || state == 'StreamsRunning') {
          CustomSnackbar.showSuccessToast('Call connected');
        } else if (state == 'End' || state == 'Released') {
          CustomSnackbar.showErrorToast('Call ended');
        }
      },
      onError: (error) {
        debugPrint('❌ Call state listener error: $error');
        CustomSnackbar.showErrorToast(error.toString());
      },
    );

    // Set up registration state listener
    _registrationSubscription = _linphone.registrationStateStream.listen(
      (regData) {
        final state = regData['state'] as String?;
        final message = regData['message'] as String?;
        
        debugPrint('📡 Registration state: $state, Message: $message');
        _registrationStateController.add(regData);
      },
      onError: (error) {
        debugPrint('❌ Registration listener error: $error');
      },
    );
  }

  // Make call
  Future<bool> call(String number) async {
    try {
      // Request microphone permission first
      final micStatus = await Permission.microphone.request();

      if (micStatus != PermissionStatus.granted) {
        throw Exception('Microphone permission is not granted.');
      }

      // Camera permission for potential video calls
      final cameraStatus = await Permission.camera.request();
      if (cameraStatus != PermissionStatus.granted) {
        debugPrint('⚠️ Camera permission not granted, proceeding with audio only');
      }

      final result = await _linphone.makeCall(number);
      
      if (!result) {
        CustomSnackbar.showErrorToast('Failed to initiate call');
      }

      return result;
    } catch (e) {
      CustomSnackbar.showErrorToast(e.toString());
      debugPrint('❌ Call error: ${e.toString()}');
      return false;
    }
  }

  // Answer call
  Future<void> acceptCall() async {
    try {
      Permission.microphone.request();
      await _linphone.answerCall();
    } catch (e) {
      debugPrint('❌ Accept call error: $e');
      CustomSnackbar.showErrorToast('Failed to answer call');
    }
  }

  // Hangup
  Future<void> hangUp() async {
    try {
      await _linphone.hangUp();
    } catch (e) {
      debugPrint('❌ Hangup error: $e');
    }
  }

  // Toggle Mute
  Future<bool> toggleMute() async {
    try {
      return await _linphone.toggleMute();
    } catch (e) {
      debugPrint('❌ Toggle mute error: $e');
      return false;
    }
  }

  // Check if muted
  Future<bool> isMuted() async {
    try {
      return await _linphone.isMicMuted();
    } catch (e) {
      debugPrint('❌ Is muted error: $e');
      return false;
    }
  }

  // Toggle speaker
  Future<bool> toggleSpeaker() async {
    try {
      return await _linphone.toggleSpeaker();
    } catch (e) {
      debugPrint('❌ Toggle speaker error: $e');
      return false;
    }
  }

  // Get registration state
  Future<String> getRegistrationState() async {
    try {
      return await _linphone.getRegistrationState();
    } catch (e) {
      debugPrint('❌ Get registration state error: $e');
      return 'None';
    }
  }

  // Listen to call state (broadcast stream that can be listened to multiple times)
  Stream<Map<String, dynamic>> get callStateStream => _callStateController.stream;
  
  // Listen to registration state
  Stream<Map<String, dynamic>> get registrationStateStream => _registrationStateController.stream;

  // Dispose method to clean up resources
  void dispose() {
    _callStateSubscription?.cancel();
    _registrationSubscription?.cancel();
    _callStateController.close();
    _registrationStateController.close();
    _linphone.dispose();
  }
}
