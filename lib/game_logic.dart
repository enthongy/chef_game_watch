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

const int kPeakIndex = 8;
const int kCatHoldTicks = 5; // increased from 3 — pause is more obvious to player

List<GridPos> buildArcPath(int col) {
  return [
    GridPos(col, 8), GridPos(col, 7), GridPos(col, 6), GridPos(col, 5),
    GridPos(col, 4), GridPos(col, 3), GridPos(col, 2), GridPos(col, 1),
    GridPos(col, 0), // peak = index 8
    GridPos(col, 1), GridPos(col, 2), GridPos(col, 3), GridPos(col, 4),
    GridPos(col, 5), GridPos(col, 6), GridPos(col, 7), GridPos(col, 8),
  ];
}

final List<GridPos> allFoodGhostPositions = [
  for (int col = 0; col < 4; col++)
    for (int row = 0; row < 9; row++) GridPos(col, row),
];

class FoodItem {
  final int id;
  int column;
  List<GridPos> path;

  int pathIndex = 0;
  bool heldByCat = false;
  int catHoldRemaining = 0;

  FoodItem(this.id, this.column) : path = buildArcPath(column);

  GridPos get position => path[pathIndex];
  bool get atCatchPoint => pathIndex == path.length - 1;
  bool get atPeak => pathIndex == kPeakIndex;

  bool tick() {
    if (heldByCat) {
      if (catHoldRemaining > 0) {
        catHoldRemaining--;
        if (catHoldRemaining == 0) heldByCat = false;
      }
      return false;
    }
    if (pathIndex < path.length - 1) {
      pathIndex++;
      return true;
    }
    return false;
  }

  void applyCatHold() {
    if (!heldByCat) {
      heldByCat = true;
      catHoldRemaining = kCatHoldTicks;
    }
  }
}

class GameLogic extends ChangeNotifier {
  static const int maxLives = 4;
  static const List<int> bonusRestoreScores = [200, 500];

  /// Grace period: only 1 food item for first 3 ticks after game start.
  static const int kGracePeriodTicks = 3;

  GameMode mode = GameMode.a;
  GamePhase phase = GamePhase.menu;
  int chefPosition = 1; // 0..3
  List<FoodItem> foodItems = [];
  int score = 0;
  int lives = maxLives;
  int tickCounter = 0;

  bool catActive = false;
  int catColumn = 0;

  Timer? _gameTimer;
  int _idCounter = 0;
  int _spawnCooldown = 0;
  int _lastSpeedScore = -1;
  final Random _rng = Random();

  GameLogic();

  /// Score-based cap on concurrent food items on screen.
  int get _effectiveMaxFoodItems {
    if (tickCounter <= kGracePeriodTicks) return 1; // grace period
    if (score < 10) return 1;
    if (score < 30) return 2;
    return mode == GameMode.a ? 3 : 4; // full Game A / B capacity
  }

  // Keep for ghost-layer painters that need the absolute max.
  int get maxFoodItems => mode == GameMode.a ? 3 : 4;

  Duration get _tickDuration {
    // Game A: 650ms → 320ms floor, ramps every 20 pts
    // Game B: 500ms → 280ms floor, ramps every 20 pts
    final int baseMs = mode == GameMode.a ? 650 : 500;
    final int reduction = (score ~/ 20) * 8;
    final int minMs = mode == GameMode.a ? 320 : 280;
    return Duration(milliseconds: max(minMs, baseMs - reduction));
  }

  String get formattedScore => score.toString().padLeft(4, '0');

  void startGame(GameMode selectedMode) {
    _gameTimer?.cancel();
    mode = selectedMode;
    phase = GamePhase.playing;
    score = 0;
    lives = maxLives;
    chefPosition = 1;
    foodItems = []; // start empty — _trySpawn handles everything
    tickCounter = 0;
    catActive = false;
    _spawnCooldown = 0; // first item spawns almost immediately
    _lastSpeedScore = -1;
    _startTimer();
    notifyListeners();
  }

  void moveChef(int delta) {
    if (phase != GamePhase.playing) return;
    final next = (chefPosition + delta).clamp(0, 3);
    if (next != chefPosition) {
      chefPosition = next;
      AudioService.instance.playMove();
      notifyListeners();
    }
  }

  void goToMenu() {
    _gameTimer?.cancel();
    phase = GamePhase.menu;
    foodItems = [];
    score = 0;
    lives = maxLives;
    notifyListeners();
  }

  void _startTimer() {
    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(_tickDuration, (_) => _onTick());
  }

  void _onTick() {
    if (phase != GamePhase.playing) return;
    tickCounter++;

    for (final food in foodItems) food.tick();

    final List<FoodItem> caught = [];
    final List<FoodItem> missed = [];

    for (final food in foodItems) {
      if (food.atCatchPoint) {
        if (chefPosition == food.column) caught.add(food);
        else missed.add(food);
      }
    }

    // Caught: rebound immediately from index 0 on a new random track.
    for (final c in caught) {
      _onCatch();
      c.column = _rng.nextInt(4);
      c.pathIndex = 0;
      c.path = buildArcPath(c.column);
    }

    // Missed: lose a life and remove the item (it will be re-spawned later).
    if (missed.isNotEmpty) {
      for (final _ in missed) _onMiss();
      foodItems.removeWhere((f) => missed.contains(f));
    }

    if (lives <= 0) {
      phase = GamePhase.gameOver;
      _gameTimer?.cancel();
      AudioService.instance.playGameOver();
      notifyListeners();
      return;
    }

    // Speed tier upgrade check.
    final int speedTier = score ~/ 20;
    if (speedTier != (_lastSpeedScore ~/ 20)) {
      _lastSpeedScore = score;
      _startTimer();
    }

    _trySpawn();
    _updateCat();
    notifyListeners();
  }

  void _onCatch() {
    score++;
    if (bonusRestoreScores.contains(score)) {
      lives = maxLives;
      AudioService.instance.playBonus();
    } else {
      AudioService.instance.playCatch();
    }
  }

  void _onMiss() {
    lives = max(0, lives - 1);
    AudioService.instance.playMiss();
  }

  void _trySpawn() {
    if (_spawnCooldown > 0) {
      _spawnCooldown--;
      return;
    }

    // Respect the score-based effective cap (includes grace period).
    if (foodItems.length >= _effectiveMaxFoodItems) return;

    final occupied = foodItems.map((f) => f.column).toSet();
    final free = [0, 1, 2, 3].where((c) => !occupied.contains(c)).toList();
    if (free.isEmpty) return;

    // Higher probability when the screen is empty.
    final double chance = foodItems.isEmpty ? 0.90 : 0.55;
    if (_rng.nextDouble() < chance) {
      final col = free[_rng.nextInt(free.length)];
      foodItems.add(FoodItem(_idCounter++, col));
      // Stagger: next item won't spawn for 8–10 ticks.
      _spawnCooldown = 8 + _rng.nextInt(3);
    }
  }

  void _updateCat() {
    // Cat only appears after score > 20 (player needs to find their rhythm first).
    if (score <= 20) {
      catActive = false;
      return;
    }

    if (!catActive) {
      if (_rng.nextDouble() < 0.015) {
        catActive = true;
        catColumn = _rng.nextBool() ? 0 : 3;
        for (final food in foodItems) {
          if (food.column == catColumn && food.atPeak) {
            food.applyCatHold();
            break;
          }
        }
      }
    } else {
      if (_rng.nextDouble() < 0.08) {
        catActive = false;
      }
    }
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    super.dispose();
  }
}
