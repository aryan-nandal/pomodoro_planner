import 'package:audioplayers/audioplayers.dart';

class AudioService {
  AudioPlayer? _player;

  AudioService() {
    const isTesting = bool.fromEnvironment('USE_EMULATOR', defaultValue: false);
    if (!isTesting) {
      _player = AudioPlayer();
      _player!.setReleaseMode(ReleaseMode.release);
    }
  }

  Future<void> playSuccessChime() async {
    if (_player == null) return;
    try {
      await _player!.play(UrlSource('https://actions.google.com/sounds/v1/interfaces/simple_click.ogg'));
    } catch (e) {
      // Fail silently in testing/without connection
    }
  }

  Future<void> playAlarmBell() async {
    if (_player == null) return;
    try {
      await _player!.play(UrlSource('https://actions.google.com/sounds/v1/alarms/beep_short.ogg'));
    } catch (e) {
      // Fail silently
    }
  }

  void dispose() {
    _player?.dispose();
  }
}
