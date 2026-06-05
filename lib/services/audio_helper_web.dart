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
