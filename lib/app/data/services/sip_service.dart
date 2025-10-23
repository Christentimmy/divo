import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:sip_ua/sip_ua.dart';

class SipService implements SipUaHelperListener {
  final SIPUAHelper _sipHelper = SIPUAHelper();

  // Stream controllers for reactive updates
  final _callStateController = StreamController<CallStateEnum>.broadcast();
  final _registrationStateController =
      StreamController<RegistrationState>.broadcast();

  Call? _currentCall;
  MediaStream? _localStream;
  MediaStream? _remoteStream;

  // Getters
  SIPUAHelper get sipHelper => _sipHelper;
  Call? get currentCall => _currentCall;
  MediaStream? get localStream => _localStream;
  MediaStream? get remoteStream => _remoteStream;
  Stream<CallStateEnum> get callStateStream => _callStateController.stream;
  Stream<RegistrationState> get registrationStateStream =>
      _registrationStateController.stream;

  // SipService() {
  //   _sipHelper.addSipUaHelperListener(this);
  // }

  /// Initialize and connect to SIP server
  Future<bool> connect({
    required String wsUrl,
    required String username,
    required String password,
    required String displayName,
    String? authorizationUser,
  }) async {
    try {
      final settings = UaSettings();
      settings.webSocketUrl = wsUrl;
      settings.uri = '$username@${_extractDomain(wsUrl)}';
      settings.authorizationUser = username;
      settings.password = password;
      settings.displayName = displayName;
      settings.userAgent = 'Divo App';
      settings.webSocketSettings.allowBadCertificate = true;

      _sipHelper.addSipUaHelperListener(this);
      await _sipHelper.start(settings);
      return _sipHelper.connected;
    } catch (e) {
      debugPrint("Error From Sip Service: ${e.toString()}");
      return false;
    }
  }

  /// Make an outgoing call
  Future<void> call(String destination, {bool voiceOnly = true}) async {
    Map<String, dynamic> callOptions = {
      'mediaConstraints': {'audio': true, 'video': !voiceOnly},
      'pcConfig': {
        'iceServers': [
          {'urls': 'stun:stun.l.google.com:19302'},
        ],
      },
    };

    bool success = await _sipHelper.call(
      destination,
      customOptions: callOptions,
    );

    if (!success) {
      print('Failed to initiate call');
    }
  }

  /// Answer an incoming call
  void answer() {
    if (_currentCall != null) {
      final callOptions = {
        'mediaConstraints': {'audio': true, 'video': false},
      };
      _currentCall!.answer(callOptions);
    }
  }

  /// Hangup the current call
  void hangup() {
    if (_currentCall != null) {
      _currentCall!.hangup();
    }
  }

  /// Mute/unmute the microphone
  void toggleMute() {
    if (_localStream != null) {
      final audioTracks = _localStream!.getAudioTracks();
      if (audioTracks.isNotEmpty) {
        final isMuted = !audioTracks[0].enabled;
        for (var track in audioTracks) {
          track.enabled = isMuted;
        }
      }
    }
  }

  /// Hold/unhold the call
  void toggleHold() {
    if (_currentCall != null) {
      if (_currentCall!.state == CallStateEnum.HOLD) {
        _currentCall!.unhold();
      } else {
        _currentCall!.hold();
      }
    }
  }

  /// Send DTMF tones
  void sendDtmf(String tone) {
    if (_currentCall != null) {
      _currentCall!.sendDTMF(tone);
    }
  }

  /// Check if currently in a call
  bool get isInCall => _currentCall != null;

  /// Check if microphone is muted
  bool get isMuted {
    if (_localStream != null) {
      final audioTracks = _localStream!.getAudioTracks();
      if (audioTracks.isNotEmpty) {
        return !audioTracks[0].enabled;
      }
    }
    return false;
  }

  /// Disconnect from SIP server
  Future<void> disconnect() async {
    hangup();
    _sipHelper.stop();
  }

  String _extractDomain(String wsUrl) {
    final uri = Uri.parse(wsUrl);
    return uri.host;
  }

  // SipUaHelperListener implementations
  @override
  void callStateChanged(Call call, CallState state) {
    _currentCall = call;
    _callStateController.add(state.state);

    switch (state.state) {
      case CallStateEnum.STREAM:
        _localStream = state.stream;
        break;
      case CallStateEnum.CONFIRMED:
      case CallStateEnum.ACCEPTED:
        if (state.stream != null) {
          _remoteStream = state.stream;
        }
        break;
      case CallStateEnum.ENDED:
      case CallStateEnum.FAILED:
        _cleanup();
        break;
      default:
        break;
    }
  }

  @override
  void registrationStateChanged(RegistrationState state) {
    debugPrint("Registration state: ${state.state}");
    _registrationStateController.add(state);
  }

  @override
  void transportStateChanged(TransportState state) {
    debugPrint('Transport state changed: ${state.state}');
    // if (state.state == TransportStateEnum.ERROR) {
    //   debugPrint('Transport error: ${state.error}');
    // }
  }

  @override
  void onNewMessage(SIPMessageRequest msg) {
    // Handle incoming messages if needed
  }

  @override
  void onNewNotify(Notify ntf) {
    // Handle notifications if needed
  }

  @override
  void onNewReinvite(ReInvite event) {
    print("Event from onNewReinvite: $event");
  }

  void _cleanup() {
    _localStream?.dispose();
    _remoteStream?.dispose();
    _localStream = null;
    _remoteStream = null;
    _currentCall = null;
  }

  void dispose() {
    _callStateController.close();
    _registrationStateController.close();
    _sipHelper.removeSipUaHelperListener(this);
    disconnect();
  }
}
