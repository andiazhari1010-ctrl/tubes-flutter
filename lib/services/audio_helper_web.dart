// Implementasi khusus Flutter Web (dimuat lewat conditional import). dart:html
// dipakai sengaja untuk memutar <audio> sederhana di web; aman karena file ini
// tidak pernah ikut ter-compile di platform native.
// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter
import 'dart:html' as html;

class AudioHelper {
  static html.AudioElement? _bgMusic;

  static void playSfx() {
    try {
      final audio = html.AudioElement('https://assets.mixkit.co/active_storage/sfx/2568/2568-84.wav');
      audio.volume = 0.5;
      audio.play();
    } catch (e) {
      // Audio context warning placeholder
    }
  }

  static void startBgm() {
    try {
      _bgMusic ??= html.AudioElement('https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3')
        ..loop = true
        ..volume = 0.15;
      _bgMusic!.play();
    } catch (e) {
      // Audio context warning placeholder
    }
  }

  static void stopBgm() {
    try {
      _bgMusic?.pause();
    } catch (e) {
      // Ignore
    }
  }
}
