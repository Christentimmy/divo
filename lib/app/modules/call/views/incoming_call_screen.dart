import 'package:divo/app/modules/call/controller/call_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class IncomingCallScreen extends StatelessWidget {
  IncomingCallScreen({super.key});

  final controller = Get.find<CallController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircleAvatar(
            radius: 60,
            backgroundColor: Colors.grey,
            child: Icon(Icons.person, size: 60, color: Colors.white),
          ),
          const SizedBox(height: 20),
          Obx(() {
            final remote = controller.remoteAddress.value;
            if (remote != null && remote.isNotEmpty) {
              return Text(
                remote.replaceAll('sip:', ''),
                style: GoogleFonts.fredoka(color: Colors.white70, fontSize: 16),
              );
            }
            return const SizedBox.shrink();
          }),
          const SizedBox(height: 10),
          // Call state
          Obx(() => getCallStateText()),
          SizedBox(height: Get.height * 0.2),
          // const Spacer(),

          // Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildButton(
                icon: Icons.call,
                label: 'Answer',
                onPressed: controller.acceptCall,
              ),
              _buildButton(
                icon: Icons.call_end,
                label: 'Reject',
                onPressed: controller.hangup,
              ),
            ],
          ),
        ],
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
}
