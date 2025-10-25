import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum CallState {
  idle,
  incomingReceived,
  outgoingInit,
  outgoingProgress,
  outgoingRinging,
  connected,
  streamsRunning,
  pausing,
  paused,
  resuming,
  refered,
  error,
  end,
  pausedByRemote,
  updatedByRemote,
  incomingEarlyMedia,
  updating,
  released,
  earlyUpdatedByRemote,
  earlyUpdating,
}

enum RegistrationState {
  none,
  progress,
  ok,
  cleared,
  failed,
}

class LinphoneNativeService {
  static final LinphoneNativeService _instance = LinphoneNativeService._internal();
  factory LinphoneNativeService() => _instance;

  static const MethodChannel _methodChannel = MethodChannel('com.divo.linphone/methods');
  static const EventChannel _callStateChannel = EventChannel('com.divo.linphone/call_state');
  static const EventChannel _registrationChannel = EventChannel('com.divo.linphone/registration_state');

  final _callStateController = StreamController<Map<String, dynamic>>.broadcast();
  final _registrationStateController = StreamController<Map<String, dynamic>>.broadcast();

  StreamSubscription? _callStateSubscription;
  StreamSubscription? _registrationSubscription;

  bool _initialized = false;

  LinphoneNativeService._internal() {
    _setupEventChannels();
  }

  void _setupEventChannels() {
    _callStateSubscription = _callStateChannel.receiveBroadcastStream().listen(
      (event) {
        debugPrint('📞 Call state event: $event');
        if (event is Map) {
          _callStateController.add(Map<String, dynamic>.from(event));
        }
      },
      onError: (error) {
        debugPrint('❌ Call state error: $error');
      },
    );

    // Listen to registration state changes
    _registrationSubscription = _registrationChannel.receiveBroadcastStream().listen(
      (event) {
        debugPrint('📡 Registration state event: $event');
        if (event is Map) {
          _registrationStateController.add(Map<String, dynamic>.from(event));
        }
      },
      onError: (error) {
        debugPrint('❌ Registration state error: $error');
      },
    );
  }

  Future<bool> initialize() async {
    if (_initialized) {
      debugPrint('✅ Linphone already initialized');
      return true;
    }

    try {
      final result = await _methodChannel.invokeMethod<bool>('initialize');
      _initialized = result ?? false;
      
      if (_initialized) {
        debugPrint('✅ Linphone initialized successfully');
      } else {
        debugPrint('❌ Linphone initialization failed');
      }
      
      return _initialized;
    } catch (e) {
      debugPrint('❌ Linphone initialization error: $e');
      return false;
    }
  }

  Future<bool> login({
    required String username,
    required String password,
    required String domain,
  }) async {
    try {
      // Ensure initialized
      if (!_initialized) {
        await initialize();
      }

      final result = await _methodChannel.invokeMethod<bool>('login', {
        'username': username,
        'password': password,
        'domain': domain,
      });

      if (result == true) {
        debugPrint('✅ Login initiated for $username@$domain');
      } else {
        debugPrint('❌ Login failed for $username@$domain');
      }

      return result ?? false;
    } catch (e) {
      debugPrint('❌ Login error: $e');
      return false;
    }
  }

  Future<bool> makeCall(String address) async {
    try {
      final result = await _methodChannel.invokeMethod<bool>('makeCall', {
        'address': address,
      });

      if (result == true) {
        debugPrint('✅ Call initiated to $address');
      } else {
        debugPrint('❌ Call failed to $address');
      }

      return result ?? false;
    } catch (e) {
      debugPrint('❌ Make call error: $e');
      return false;
    }
  }

  Future<bool> answerCall() async {
    try {
      final result = await _methodChannel.invokeMethod<bool>('answerCall');
      
      if (result == true) {
        debugPrint('✅ Call answered');
      } else {
        debugPrint('❌ Answer call failed');
      }

      return result ?? false;
    } catch (e) {
      debugPrint('❌ Answer call error: $e');
      return false;
    }
  }

  Future<bool> acceptCall() async {
    try {
      final result = await _methodChannel.invokeMethod<bool>('acceptCall');
      
      if (result == true) {
        debugPrint('✅ Call accepted');
      } else {
        debugPrint('❌ Accept call failed');
      }

      return result ?? false;
    } catch (e) {
      debugPrint('❌ Accept call error: $e');
      return false;
    }
  }

  Future<bool> hangUp() async {
    try {
      final result = await _methodChannel.invokeMethod<bool>('hangUp');
      
      if (result == true) {
        debugPrint('✅ Call hung up');
      } else {
        debugPrint('❌ Hang up failed');
      }

      return result ?? false;
    } catch (e) {
      debugPrint('❌ Hang up error: $e');
      return false;
    }
  }

  Future<bool> toggleMute() async {
    try {
      final isMuted = await _methodChannel.invokeMethod<bool>('toggleMute');
      debugPrint('🎤 Microphone ${isMuted == true ? "muted" : "unmuted"}');
      return isMuted ?? false;
    } catch (e) {
      debugPrint('❌ Toggle mute error: $e');
      return false;
    }
  }

  Future<bool> toggleSpeaker() async {
    try {
      final isSpeakerOn = await _methodChannel.invokeMethod<bool>('toggleSpeaker');
      debugPrint('🔊 Speaker ${isSpeakerOn == true ? "on" : "off"}');
      return isSpeakerOn ?? false;
    } catch (e) {
      debugPrint('❌ Toggle speaker error: $e');
      return false;
    }
  }

  Future<bool> isMicMuted() async {
    try {
      final isMuted = await _methodChannel.invokeMethod<bool>('isMicMuted');
      return isMuted ?? false;
    } catch (e) {
      debugPrint('❌ Is mic muted error: $e');
      return false;
    }
  }

  Future<String> getRegistrationState() async {
    try {
      final state = await _methodChannel.invokeMethod<String>('getRegistrationState');
      return state ?? 'None';
    } catch (e) {
      debugPrint('❌ Get registration state error: $e');
      return 'None';
    }
  }

  Stream<Map<String, dynamic>> get callStateStream => _callStateController.stream;

  Stream<Map<String, dynamic>> get registrationStateStream => _registrationStateController.stream;

  void dispose() {
    _callStateSubscription?.cancel();
    _registrationSubscription?.cancel();
    _callStateController.close();
    _registrationStateController.close();
  }
}
