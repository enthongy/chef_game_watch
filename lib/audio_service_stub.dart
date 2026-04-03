import 'dart:js_interop';

@JS('playWebBeep')
external void _playWebBeep(int freq, int durationMs);

class AudioService {
  AudioService._();
  static final AudioService instance = AudioService._();

  bool _enabled = true;
  bool get enabled => _enabled;
  set enabled(bool v) => _enabled = v;

  Future<void> _beepAsync(int freq, int durationMs) async {
    try {
      _playWebBeep(freq, durationMs);
    } catch (_) {}
  }

  Future<void> playCatch() async {
    if (!_enabled) return;
    _beepAsync(1046, 50);
  }

  Future<void> playMove() async {
    if (!_enabled) return;
    _beepAsync(440, 30);
  }

  Future<void> playMiss() async {
    if (!_enabled) return;
    for (int i = 0; i < 5; i++) {
       _beepAsync(150 - (i * 10), 40);
       await Future.delayed(const Duration(milliseconds: 40));
    }
  }

  Future<void> playGameOver() async {
    if (!_enabled) return;
    for (final pair in [(440, 120), (330, 120), (220, 250)]) {
      _beepAsync(pair.$1, pair.$2);
      await Future.delayed(Duration(milliseconds: pair.$2 + 30));
    }
  }

  Future<void> playBonus() async {
    if (!_enabled) return;
    for (final pair in [(523, 60), (659, 60), (784, 60), (1047, 100)]) {
      _beepAsync(pair.$1, pair.$2);
      await Future.delayed(Duration(milliseconds: pair.$2 + 20));
    }
  }
}
