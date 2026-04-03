import 'dart:ffi';
import 'dart:isolate';
import 'package:flutter/foundation.dart';

// FFI type signatures
typedef _BeepNative = Bool Function(Uint32 freq, Uint32 duration);
typedef _BeepDart = bool Function(int freq, int duration);

Future<void> _beepAsync(int freq, int durationMs) async {
  await Isolate.run(() {
    try {
      final kernel32 = DynamicLibrary.open('kernel32.dll');
      final beep = kernel32.lookupFunction<_BeepNative, _BeepDart>('Beep');
      beep(freq, durationMs);
    } catch (_) {
    }
  });
}

class AudioService {
  AudioService._();
  static final AudioService instance = AudioService._();

  bool _enabled = true;
  bool get enabled => _enabled;
  set enabled(bool v) => _enabled = v;

  Future<void> playCatch() async {
    if (!_enabled || !defaultTargetPlatform.isWindows) return;
    _beepAsync(880, 55);
    await Future.delayed(const Duration(milliseconds: 70));
    _beepAsync(1175, 55);
  }

  Future<void> playMiss() async {
    if (!_enabled || !defaultTargetPlatform.isWindows) return;
    _beepAsync(300, 80);
    await Future.delayed(const Duration(milliseconds: 90));
    _beepAsync(220, 120);
  }

  Future<void> playGameOver() async {
    if (!_enabled || !defaultTargetPlatform.isWindows) return;
    for (final pair in [
      (440, 120),
      (330, 120),
      (220, 250),
    ]) {
      _beepAsync(pair.$1, pair.$2);
      await Future.delayed(Duration(milliseconds: pair.$2 + 30));
    }
  }

  Future<void> playBonus() async {
    if (!_enabled || !defaultTargetPlatform.isWindows) return;
    for (final pair in [
      (523, 60),
      (659, 60),
      (784, 60),
      (1047, 100),
    ]) {
      _beepAsync(pair.$1, pair.$2);
      await Future.delayed(Duration(milliseconds: pair.$2 + 20));
    }
  }
}

extension on TargetPlatform {
  bool get isWindows => this == TargetPlatform.windows;
}
