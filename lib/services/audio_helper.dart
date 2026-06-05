import 'package:flutter/services.dart';

class AudioHelper {
  static void playSfx() {
    SystemSound.play(SystemSoundType.click);
  }

  static void startBgm() {
    // No-op on native platforms
  }

  static void stopBgm() {
    // No-op on native platforms
  }
}
