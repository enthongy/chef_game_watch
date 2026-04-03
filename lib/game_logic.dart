import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'audio_service.dart';

// ─────────────────────────────────────────────
// Enums
// ─────────────────────────────────────────────

enum GameMode { a, b }

enum GamePhase { menu, playing, gameOver }

// ─────────────────────────────────────────────
// GridPos — logical game coordinate
// x : 0=Left  1=Center  2=Right
// y : 0=Peak             4=Catch zone (bottom)
// ─────────────────────────────────────────────

class GridPos {
  final int x;
  final int y;

  const GridPos(this.x, this.y);

  @override
  bool operator ==(Object other) =>
      other is GridPos && other.x == x && other.y == y;

  @override
  int get hashCode => Object.hash(x, y);

  @override
  String toString() => 'GridPos($x,$y)';
}

// ─────────────────────────────────────────────
// Arc path builder
// Predefined discrete parabolic trajectory.
// Each step is one game tick.
// ─────────────────────────────────────────────

const int kPeakIndex = 0; // top point where cat can intercept
const int kCatHoldTicks = 2;

// 9-step path dropping down vertically.
List<GridPos> buildArcPath(int col) => [
      GridPos(col, 0), // 0 - spawn / peak
      GridPos(col, 1),
      GridPos(col, 2),
      GridPos(col, 3),
      GridPos(col, 4),
      GridPos(col, 5),
      GridPos(col, 6),
      GridPos(col, 7),
      GridPos(col, 8), // 8 - CATCH POINT (last index)
    ];

/// Every unique position food can ever occupy (used by ghost layer).
/// Now covers 9 rows (y: 0–8) to match the expanded path.
final List<GridPos> allFoodGhostPositions = [
  for (int col = 0; col < 3; col++)
    for (int row = 0; row < 9; row++) GridPos(col, row),
];

// ─────────────────────────────────────────────
// FoodItem
// ─────────────────────────────────────────────

class FoodItem {
  final int id;
  final int column;
  final List<GridPos> path;

  int pathIndex = 0;
  bool heldByCat = false;
  int catHoldRemaining = 0;

  FoodItem(this.id, this.column) : path = buildArcPath(column);

  GridPos get position => path[pathIndex];

  bool get atCatchPoint => pathIndex == path.length - 1;
  bool get atPeak => pathIndex == kPeakIndex;

  /// Advances by one step. Returns false if still held by cat.
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

// ─────────────────────────────────────────────
// GameLogic — ChangeNotifier (Provider root)
// ─────────────────────────────────────────────

class GameLogic extends ChangeNotifier {
  static const int maxLives = 4;
  static const List<int> bonusRestoreScores = [200, 500];

  // ── State ──
  GameMode mode;
  GamePhase phase;
  int chefPosition; // 0=Left  1=Center  2=Right
  List<FoodItem> foodItems;
  int score;
  int lives;
  int tickCounter;

  // ── Cat state ──
  bool catActive;
  int catColumn; // 0=Left edge  2=Right edge

  // ── Internals ──
  Timer? _gameTimer;
  int _idCounter = 0;
  int _spawnCooldown = 0;
  int _lastSpeedScore = -1;
  final Random _rng = Random();

  GameLogic({
    this.mode = GameMode.a,
    this.phase = GamePhase.menu,
    this.chefPosition = 1,
    List<FoodItem>? foodItems,
    this.score = 0,
    this.lives = maxLives,
    this.tickCounter = 0,
    this.catActive = false,
    this.catColumn = 0,
  }) : foodItems = foodItems ?? [];

  // ── Computed ──

  int get maxFoodItems => mode == GameMode.a ? 3 : 4;

  Duration get _tickDuration {
    // Path now has 9 steps (vertically down), tick duration adjusted
    // to keep the same real-time catch pace.
    final int baseMs = mode == GameMode.a ? 480 : 350;
    final int reduction = (score ~/ 10) * 12;
    final int minMs = mode == GameMode.a ? 180 : 120;
    return Duration(milliseconds: max(minMs, baseMs - reduction));
  }

  String get formattedScore => score.toString().padLeft(4, '0');

  // ── Public API ──

  void startGame(GameMode selectedMode) {
    _gameTimer?.cancel();
    mode = selectedMode;
    phase = GamePhase.playing;
    score = 0;
    lives = maxLives;
    chefPosition = 1;
    foodItems = [];
    tickCounter = 0;
    catActive = false;
    _idCounter = 0;
    _spawnCooldown = 0;
    _lastSpeedScore = -1;
    _startTimer();
    notifyListeners();
  }

  void moveChef(int delta) {
    if (phase != GamePhase.playing) return;
    final next = (chefPosition + delta).clamp(0, 2);
    if (next != chefPosition) {
      chefPosition = next;
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

  // ── Timer ──

  void _startTimer() {
    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(_tickDuration, (_) => _onTick());
  }

  // ── Core tick ──

  void _onTick() {
    if (phase != GamePhase.playing) return;
    tickCounter++;

    // 1. Advance all food items
    for (final food in foodItems) {
      food.tick();
    }

    // 2. Resolve catch / miss
    final List<FoodItem> resolved = [];
    for (final food in foodItems) {
      if (food.atCatchPoint) {
        resolved.add(food);
        if (chefPosition == food.column) {
          _onCatch();
        } else {
          _onMiss();
        }
      }
    }
    if (resolved.isNotEmpty) {
      foodItems = foodItems.where((f) => !resolved.contains(f)).toList();
    }

    if (lives <= 0) {
      phase = GamePhase.gameOver;
      _gameTimer?.cancel();
      AudioService.instance.playGameOver();
      notifyListeners();
      return;
    }

    // 3. Recalibrate speed every 10 points
    final int speedTier = score ~/ 10;
    if (score != _lastSpeedScore && speedTier != (_lastSpeedScore ~/ 10)) {
      _lastSpeedScore = score;
      _startTimer();
    }

    // 4. Spawn
    _trySpawn();

    // 5. Cat
    _updateCat();

    notifyListeners();
  }

  void _onCatch() {
    score++;
    if (bonusRestoreScores.contains(score)) {
      lives = maxLives; // clear all Miss markers
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
    if (foodItems.length >= maxFoodItems) return;

    final occupied = foodItems.map((f) => f.column).toSet();
    final free = [0, 1, 2].where((c) => !occupied.contains(c)).toList();
    if (free.isEmpty) return;

    final double chance = foodItems.isEmpty ? 0.95 : 0.60;
    if (_rng.nextDouble() < chance) {
      final col = free[_rng.nextInt(free.length)];
      foodItems = [...foodItems, FoodItem(_idCounter++, col)];
      _spawnCooldown = 1;
    }
  }

  void _updateCat() {
    // Disabled: The cat was a feature from the original 1981 Chef game that 
    // appeared from the left/right walls to grab and hold food. 
    // Since we've moved to a clean, straight-falling game, this is no longer needed.
    catActive = false;
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    super.dispose();
  }
}
