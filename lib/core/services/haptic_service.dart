import 'package:flutter/services.dart';

class HapticService {
  static const _isTesting = bool.fromEnvironment('USE_EMULATOR', defaultValue: false);

  Future<void> lightImpact() async {
    if (_isTesting) return;
    await HapticFeedback.lightImpact();
  }

  Future<void> mediumImpact() async {
    if (_isTesting) return;
    await HapticFeedback.mediumImpact();
  }

  Future<void> heavyImpact() async {
    if (_isTesting) return;
    await HapticFeedback.heavyImpact();
  }

  Future<void> successFeedback() async {
    if (_isTesting) return;
    await HapticFeedback.vibrate();
  }
}
