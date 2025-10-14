import 'package:divo/app/routes/app_routes.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class SplashController extends GetxController with GetTickerProviderStateMixin {
  final String _appName = "divo";

  late AnimationController _controller;
  late List<AnimationController> _letterControllers;
  late List<Animation<double>> _letterAnimations;

  AnimationController get controller => _controller;
  List<AnimationController> get letterControllers => _letterControllers;
  List<Animation<double>> get letterAnimations => _letterAnimations;
  String get appName => _appName;

  @override
  void onInit() {
    super.onInit();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Individual letter controllers
    _letterControllers = List.generate(
      _appName.length,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 600),
        vsync: this,
      ),
    );

    // Staggered letter animations
    _letterAnimations = _letterControllers.map((controller) {
      return CurvedAnimation(parent: controller, curve: Curves.easeOutCubic);
    }).toList();

    _startAnimation();
  }

  void _startAnimation() async {
    for (int i = 0; i < _letterControllers.length; i++) {
      await Future.delayed(const Duration(milliseconds: 100));
      _letterControllers[i].forward();
    }
    _controller.forward();
    Future.delayed(const Duration(seconds: 3), () {
      _navigateToOnboarding();
    });
  }

  void _navigateToOnboarding() {
    Get.offNamed(AppRoutes.signup);
  }

  @override
  void onClose() {
    _controller.dispose();
    for (var controller in _letterControllers) {
      controller.dispose();
    }
    super.onClose();
  }
}
