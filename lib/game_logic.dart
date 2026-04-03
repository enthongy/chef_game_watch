import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'audio_service.dart';

enum GameMode { a, b }
enum GamePhase { menu, playing, gameOver }

class GridPos {
  final int x;
  final int y;
  const GridPos(this.x, this.y);
  @override
  bool operator ==(Object other) => other is GridPos && other.x == x && other.y == y;
  @override
  int get hashCode => Object.hash(x, y);
}

const int kCatHoldTicks = 5;

// 9-step straight vertical drop per column.
List<GridPos> buildDropPath(int col) => [
      GridPos(col, 0),
      GridPos(col, 1),
      GridPos(col, 2),
      GridPos(col, 3),
      GridPos(col, 4),
      GridPos(col, 5),
      GridPos(col, 6),
      GridPos(col, 7),
      GridPos(col, 8), // index 8 = SAVE / GOAL row
    ];

final List<GridPos> allBallGhostPositions = [
  for (int col = 0; col < 4; col++)
    for (int row = 0; row < 9; row++) GridPos(col, row),
];

class SoccerBall {
  final int id;
  int column;
  List<GridPos> path;
  int pathIndex = 0;

  SoccerBall(this.id, this.column) : path = buildDropPath(column);

  GridPos get position => path[pathIndex];
  bool get atSavePoint => pathIndex == path.length - 1; // index 8

  void tick() {
    if (pathIndex < path.length - 1) pathIndex++;
  }
}

class GameLogic extends ChangeNotifier {
  static const int maxLives = 4;
  static const List<int> bonusRestoreScores = [200, 500];
  static const int kGracePeriodTicks = 3;
  static const int kSuperSonicScore = 50;  // trigger every 50 pts
  static const int kSuperSonicDuration = 5; // seconds

  GameMode mode = GameMode.a;
  GamePhase phase = GamePhase.menu;

  int sonicPosition = 1; // 0..3
  int sonicDirection = 1; // 1 (right) or -1 (left)
  List<SoccerBall> balls = [];
  int score = 0;
  int lives = maxLives;
  int tickCounter = 0;

  // Super Sonic state
  bool superSonicActive = false;
  int _superSonicTicksRemaining = 0;
  int _lastSuperSonicTrigger = -1;

  // Cat
  bool catActive = false;
  int catColumn = 0;

  Timer? _gameTimer;
  int _idCounter = 0;
  int _spawnCooldown = 0;
  int _lastSpeedScore = -1;
  final Random _rng = Random();

  GameLogic();

  int get maxBalls => mode == GameMode.a ? 3 : 4;

  int get _effectiveMaxBalls {
    if (tickCounter <= kGracePeriodTicks) return 1;
    if (score < 10) return 1;
    if (score < 30) return 2;
    return maxBalls;
  }

  Duration get _tickDuration {
    final int baseMs = mode == GameMode.a ? 600 : 450;
    // Ramps up speed by decreasing tick duration by 12ms every 10 points
    final int reduction = (score ~/ 10) * 12;
    final int minMs = mode == GameMode.a ? 280 : 220;
    final int raw = max(minMs, baseMs - reduction);
    // Super Sonic: ticks happen at half the normal interval (twice the speed).
    return superSonicActive
        ? Duration(milliseconds: raw ~/ 2)
        : Duration(milliseconds: raw);
  }

  String get formattedScore => score.toString().padLeft(4, '0');

  void startGame(GameMode selectedMode) {
    _gameTimer?.cancel();
    mode = selectedMode;
    phase = GamePhase.playing;
    score = 0;
    lives = maxLives;
    sonicPosition = 1;
    balls = [];
    tickCounter = 0;
    catActive = false;
    superSonicActive = false;
    _superSonicTicksRemaining = 0;
    _lastSuperSonicTrigger = -1;
    _spawnCooldown = 0;
    _lastSpeedScore = -1;
    _startTimer();
    notifyListeners();
  }

  void moveSonic(int delta) {
    if (phase != GamePhase.playing) return;
    sonicDirection = delta > 0 ? 1 : -1;
    final next = (sonicPosition + delta).clamp(0, 3);
    if (next != sonicPosition) {
      sonicPosition = next;
      AudioService.instance.playMove();
      notifyListeners();
    } else {
      // Still notify so the flip happens even if at the edge
      notifyListeners();
    }
  }

  void goToMenu() {
    _gameTimer?.cancel();
    phase = GamePhase.menu;
    balls = [];
    score = 0;
    lives = maxLives;
    superSonicActive = false;
    notifyListeners();
  }

  void _startTimer() {
    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(_tickDuration, (_) => _onTick());
  }

  void _onTick() {
    if (phase != GamePhase.playing) return;
    tickCounter++;

    // --- Super Sonic countdown ---
    if (superSonicActive) {
      _superSonicTicksRemaining--;
      if (_superSonicTicksRemaining <= 0) {
        superSonicActive = false;
        _startTimer(); // restore normal tick speed
      }
    }

    for (final ball in balls) ball.tick();

    final List<SoccerBall> saved = [];
    final List<SoccerBall> goaled = [];

    for (final ball in balls) {
      if (ball.atSavePoint) {
        if (sonicPosition == ball.column) saved.add(ball);
        else goaled.add(ball);
      }
    }

    // Saved balls disappear (kicked away) — they get re-spawned naturally.
    for (final s in saved) {
      _onSave();
      balls.remove(s);
    }

    // Goaled balls: Miss, also removed and re-spawned.
    if (goaled.isNotEmpty) {
      for (final _ in goaled) _onGoal();
      balls.removeWhere((b) => goaled.contains(b));
    }

    if (lives <= 0) {
      phase = GamePhase.gameOver;
      _gameTimer?.cancel();
      AudioService.instance.playGameOver();
      notifyListeners();
      return;
    }

    // Speed tier upgrade.
    final int speedTier = score ~/ 20;
    if (speedTier != (_lastSpeedScore ~/ 20)) {
      _lastSpeedScore = score;
      _startTimer();
    }

    _checkSuperSonic();
    _trySpawn();
    _updateCat();
    notifyListeners();
  }

  void _onSave() {
    score++;
    if (bonusRestoreScores.contains(score)) {
      lives = maxLives;
      AudioService.instance.playBonus();
    } else {
      AudioService.instance.playCatch(); // Ring collect sound
    }
  }

  void _onGoal() {
    lives = max(0, lives - 1);
    AudioService.instance.playMiss(); // Thud
  }

  void _checkSuperSonic() {
    final int tier = score ~/ kSuperSonicScore;
    if (tier > 0 && tier != _lastSuperSonicTrigger) {
      _lastSuperSonicTrigger = tier;
      superSonicActive = true;
      // Ticks are faster now, so multiply duration in ticks proportionally.
      // At half tick interval, 5 seconds ≈ 5000ms / (tickDuration/2) ticks.
      final int fullTickMs = _tickDuration.inMilliseconds * 2;
      _superSonicTicksRemaining = max(5, 5000 ~/ fullTickMs);
      _startTimer(); // restart timer at boosted speed
    }
  }

  void _trySpawn() {
    if (_spawnCooldown > 0) {
      _spawnCooldown--;
      return;
    }
    if (balls.length >= _effectiveMaxBalls) return;

    final occupied = balls.map((b) => b.column).toSet();
    final free = [0, 1, 2, 3].where((c) => !occupied.contains(c)).toList();
    if (free.isEmpty) return;

    final double chance = balls.isEmpty ? 0.90 : 0.55;
    if (_rng.nextDouble() < chance) {
      final col = free[_rng.nextInt(free.length)];
      balls.add(SoccerBall(_idCounter++, col));
      // Stagger: next item won't spawn for 3-5 ticks (allows overlapping drops, but not simultaneous)
      _spawnCooldown = 3 + _rng.nextInt(3);
    }
  }

  void _updateCat() {
    if (score <= 20) { catActive = false; return; }
    if (!catActive) {
      if (_rng.nextDouble() < 0.015) {
        catActive = true;
        catColumn = _rng.nextBool() ? 0 : 3;
      }
    } else {
      if (_rng.nextDouble() < 0.08) catActive = false;
    }
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    super.dispose();
  }
}
