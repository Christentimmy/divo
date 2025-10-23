import 'package:divo/app/modules/call/controller/call_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class CallScreen extends GetView<CallController> {
  const CallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // controller.listenToCallState();
    return Scaffold(
      backgroundColor: Colors.black87,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),

            // Avatar
            const CircleAvatar(
              radius: 60,
              backgroundColor: Colors.grey,
              child: Icon(Icons.person, size: 60, color: Colors.white),
            ),
            const SizedBox(height: 20),

            // Remote address
            Obx(() {
              final remote = controller.remoteAddress.value;
              if (remote != null && remote.isNotEmpty) {
                return Text(
                  remote.replaceAll('sip:', ''),
                  style: GoogleFonts.fredoka(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                );
              }
              return const SizedBox.shrink();
            }),
            const SizedBox(height: 10),

            // Call state
            Obx(() => getCallStateText()),

            const Spacer(),

            // Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Obx(
                  () => _buildButton(
                    icon: controller.isMuted.value ? Icons.mic_off : Icons.mic,
                    label: 'Mute',
                    onPressed: controller.toggleMute,
                  ),
                ),
                _buildButton(
                  icon: Icons.volume_up,
                  label: 'Speaker',
                  onPressed: controller.toggleSpeaker,
                ),
              ],
            ),
            const SizedBox(height: 40),

            // Hangup
            InkWell(
              onTap: controller.hangup,
              child: Container(
                width: 70,
                height: 70,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red,
                ),
                child: const Icon(
                  Icons.call_end,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget getCallStateText() {
    final state = controller.callState.value;
    String stateText = "";
    
    switch (state) {
      case 'OutgoingRinging':
        stateText = "Ringing...";
        break;
      case 'OutgoingProgress':
      case 'OutgoingInit':
        stateText = "Calling...";
        break;
      case 'IncomingReceived':
        stateText = "Incoming Call";
        break;
      case 'Paused':
      case 'Pausing':
      case 'PausedByRemote':
        stateText = "Paused";
        break;
      case 'Connected':
      case 'StreamsRunning':
        stateText = "Connected";
        break;
      case 'Released':
      case 'End':
        stateText = "Call Ended";
        break;
      case 'Error':
        stateText = "Error";
        break;
      case 'Updating':
      case 'Resuming':
        stateText = "Updating...";
        break;
      default:
        stateText = state ?? "Idle";
    }
    
    return Text(
      stateText,
      style: GoogleFonts.fredoka(
        color: Colors.white,
        fontSize: 22,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onPressed,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.2),
            ),
            child: Icon(icon, color: Colors.white),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: Colors.white)),
      ],
    );
  }
}
