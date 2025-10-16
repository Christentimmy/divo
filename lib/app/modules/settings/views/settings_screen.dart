import 'package:divo/app/modules/settings/controller/settings_controller.dart';
import 'package:divo/app/resources/app_colors.dart';
import 'package:divo/app/routes/app_routes.dart';
import 'package:divo/app/widgets/custom_button.dart';
import 'package:divo/app/widgets/staggered_column_animation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsScreen extends StatelessWidget {
  SettingsScreen({super.key});

  final SettingsController controller = Get.put(SettingsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: StaggeredColumnAnimation(
          children: [
            CustomButton(
              ontap: () {},
              isLoading: false.obs,
              child: Text(
                "Top Up",
                style: GoogleFonts.fredoka(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildSectionHeader('SIP Configuration'),
            _buildSIPConfigSection(),
            const SizedBox(height: 24),

            _buildSectionHeader('Audio Settings'),
            _buildAudioSettingsSection(),
            const SizedBox(height: 24),

            _buildSectionHeader('Account'),
            _buildAccountSection(),
            const SizedBox(height: 24),

            CustomButton(
              ontap: () => Get.offAllNamed(AppRoutes.login),
              isLoading: false.obs,
              bgColor: Colors.red,
              child: Text(
                "Logout",
                style: GoogleFonts.fredoka(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      centerTitle: true,
      title: Text(
        'Settings',
        style: GoogleFonts.fredoka(
          fontSize: 25,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Text(
        title,
        style: GoogleFonts.fredoka(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSIPConfigSection() {
    return _buildSettingsCard([
      _buildTextField(
        label: 'SIP Server',
        hint: 'sip.example.com',
        value: controller.sipServer,
        icon: Icons.dns,
        isReadOnly: true,
      ),
      _buildTextField(
        label: 'Port',
        hint: '5060',
        value: controller.sipPort,
        icon: Icons.settings_input_antenna,
        keyboardType: TextInputType.number,
        isReadOnly: true,
      ),
      _buildDropdown(
        label: 'Transport Protocol',
        value: controller.transportProtocol,
        items: controller.protocolOptions,
        icon: Icons.swap_horiz,
      ),
      _buildDropdown(
        label: 'Audio Codec',
        value: controller.audioCodec,
        items: controller.codecOptions,
        icon: Icons.audiotrack,
      ),
    ]);
  }

  Widget _buildAudioSettingsSection() {
    return _buildSettingsCard([
      Obx(
        () => _buildSlider(
          label: 'Speaker Volume',
          value: controller.speakerVolume.value,
          onChanged: (val) => controller.speakerVolume.value = val,
          icon: Icons.volume_up,
        ),
      ),
      Obx(
        () => _buildSlider(
          label: 'Microphone Volume',
          value: controller.microphoneVolume.value,
          onChanged: (val) => controller.microphoneVolume.value = val,
          icon: Icons.mic,
        ),
      ),
      Obx(
        () => _buildSlider(
          label: 'Ringtone Volume',
          value: controller.ringtoneVolume.value,
          onChanged: (val) => controller.ringtoneVolume.value = val,
          icon: Icons.ring_volume,
        ),
      ),
      const Divider(color: Colors.grey, height: 32),
      Obx(
        () => _buildSwitch(
          label: 'Echo Cancellation',
          value: controller.echoCancellation.value,
          onChanged: (val) => controller.echoCancellation.value = val,
          icon: Icons.hearing,
        ),
      ),
      Obx(
        () => _buildSwitch(
          label: 'Noise Suppression',
          value: controller.noiseSuppression.value,
          onChanged: (val) => controller.noiseSuppression.value = val,
          icon: Icons.noise_control_off,
        ),
      ),
      Obx(
        () => _buildSwitch(
          label: 'Auto Gain Control',
          value: controller.autoGainControl.value,
          onChanged: (val) => controller.autoGainControl.value = val,
          icon: Icons.tune,
        ),
      ),
    ]);
  }

  Widget _buildAccountSection() {
    return _buildSettingsCard([
      _buildTextField(
        label: 'Username',
        hint: 'john doe',
        value: controller.username,
        icon: Icons.person,
      ),
      _buildTextField(
        label: 'Email',
        hint: 'john.doe@example.com',
        value: RxString(''),
        icon: Icons.email,
      ),
      _buildTextField(
        label: 'Balance',
        hint: "0.00",
        value: RxString(''),
        icon: Icons.attach_money,
      ),
    ]);
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.neonPurple.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(children: children),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required RxString value,
    required IconData icon,
    TextInputType? keyboardType,
    bool isReadOnly = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, color: AppColors.neonPurple, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.fredoka(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Obx(
                  () => TextFormField(
                    readOnly: isReadOnly,
                    style: GoogleFonts.fredoka(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: hint,
                      hintStyle: GoogleFonts.fredoka(color: Colors.white30),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white24),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: AppColors.neonPurple),
                      ),
                    ),
                    keyboardType: keyboardType,
                    onChanged: (val) => value.value = val,
                    controller: TextEditingController(text: value.value)
                      ..selection = TextSelection.collapsed(
                        offset: value.value.length,
                      ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required RxString value,
    required List<String> items,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, color: AppColors.neonPurple, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.fredoka(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Obx(
                  () => DropdownButton<String>(
                    value: value.value,
                    isExpanded: true,
                    dropdownColor: const Color(0xFF2A2A2A),
                    style: GoogleFonts.fredoka(color: Colors.white),
                    underline: Container(height: 1, color: Colors.white24),
                    items: items.map((String item) {
                      return DropdownMenuItem<String>(
                        value: item,
                        child: Text(item),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        value.value = newValue;
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlider({
    required String label,
    required double value,
    required Function(double) onChanged,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.neonPurple, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.fredoka(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Text(
                '${value.toInt()}%',
                style: GoogleFonts.fredoka(
                  color: AppColors.neonPurpleBright,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppColors.neonPurple,
              inactiveTrackColor: Colors.white24,
              thumbColor: AppColors.neonPurpleBright,
              overlayColor: AppColors.neonPurple.withOpacity(0.3),
            ),
            child: Slider(value: value, min: 0, max: 100, onChanged: onChanged),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitch({
    required String label,
    required bool value,
    required Function(bool) onChanged,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: AppColors.neonPurple, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.fredoka(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Transform.scale(
            scale: 0.75,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeColor: AppColors.neonPurpleBright,
              activeTrackColor: const Color.fromARGB(255, 75, 17, 122),
            ),
          ),
        ],
      ),
    );
  }
}
