// Stub for platforms without dart:ffi (e.g., Web).
class AudioService {
  AudioService._();
  static final AudioService instance = AudioService._();

  bool _enabled = true;
  bool get enabled => _enabled;
  set enabled(bool v) => _enabled = v;

  Future<void> playCatch() async {}
  Future<void> playMiss() async {}
  Future<void> playGameOver() async {}
  Future<void> playBonus() async {}
}
