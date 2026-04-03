// Stub for platforms without dart:ffi (e.g., Web).
import 'dart:js_interop';

@JS('playWebBeep')
external void _playWebBeep(int freq, int durationMs);

class AudioService {
  AudioService._();
  static final AudioService instance = AudioService._();

  bool _enabled = true;
  bool get enabled => _enabled;
  set enabled(bool v) => _enabled = v;

  Future<void> _beep(int freq, int durationMs) async {
    try { _playWebBeep(freq, durationMs); } catch (_) {}
  }

  // Ring collect: two quick high notes (Sega-style)
  Future<void> playCatch() async {
    if (!_enabled) return;
    _beep(1760, 40);
    await Future.delayed(const Duration(milliseconds: 55));
    _beep(2093, 55);
  }

  // Crisp zip for movement
  Future<void> playMove() async {
    if (!_enabled) return;
    _beep(880, 20);
  }

  // Low thud for goal (miss)
  Future<void> playMiss() async {
    if (!_enabled) return;
    _beep(110, 200);
  }

  Future<void> playGameOver() async {
    if (!_enabled) return;
    for (final pair in [(440, 120), (330, 120), (220, 250)]) {
      _beep(pair.$1, pair.$2);
      await Future.delayed(Duration(milliseconds: pair.$2 + 30));
    }
  }

  Future<void> playBonus() async {
    if (!_enabled) return;
    for (final pair in [(1047, 50), (1319, 50), (1568, 50), (2093, 100)]) {
      _beep(pair.$1, pair.$2);
      await Future.delayed(Duration(milliseconds: pair.$2 + 15));
    }
  }

  // Super Sonic boost trigger sound
  Future<void> playSuperSonic() async {
    if (!_enabled) return;
    for (final pair in [(880, 30), (1047, 30), (1319, 30), (1760, 60)]) {
      _beep(pair.$1, pair.$2);
      await Future.delayed(Duration(milliseconds: pair.$2 + 10));
    }
  }
}
