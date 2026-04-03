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
const int kCatHoldTicks = 3;

List<GridPos> buildArcPath(int col) {
  return [
    GridPos(col, 8), GridPos(col, 7), GridPos(col, 6), GridPos(col, 5),
    GridPos(col, 4), GridPos(col, 3), GridPos(col, 2), GridPos(col, 1),
    GridPos(col, 0), // peak = 8
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

  int get maxFoodItems => mode == GameMode.a ? 3 : 4;

  Duration get _tickDuration {
    // Game A: 650ms base → floors at 250ms, drops 8ms per 10 pts
    // Game B: 500ms base → floors at 250ms, drops 8ms per 10 pts
    final int baseMs = mode == GameMode.a ? 650 : 500;
    final int reduction = (score ~/ 10) * 8;
    const int minMs = 250; // hard floor — never faster than this
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
    foodItems = [];
    
    int count = mode == GameMode.a ? 3 : 4;
    int spacing = (17 ~/ count); // 17 path steps / items
    for (int i = 0; i < count; i++) {
        FoodItem f = FoodItem(_idCounter++, i % 4);
        f.pathIndex = i * spacing; 
        foodItems.add(f);
    }
    
    tickCounter = 0;
    catActive = false;
    _spawnCooldown = 0;
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

    for (final c in caught) {
      _onCatch();
      c.column = _rng.nextInt(4);
      c.pathIndex = 0;
      c.path = buildArcPath(c.column);
    }

    if (missed.isNotEmpty) {
      for (final m in missed) _onMiss();
      foodItems.removeWhere((f) => missed.contains(f));
    }

    if (lives <= 0) {
      phase = GamePhase.gameOver;
      _gameTimer?.cancel();
      AudioService.instance.playGameOver();
      notifyListeners();
      return;
    }

    final int speedTier = score ~/ 10;
    if (score != _lastSpeedScore && speedTier != (_lastSpeedScore ~/ 10)) {
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
    if (foodItems.length >= maxFoodItems) return;

    final occupied = foodItems.map((f) => f.column).toSet();
    final free = [0, 1, 2, 3].where((c) => !occupied.contains(c)).toList();
    if (free.isEmpty) return;

    final double chance = foodItems.isEmpty ? 0.95 : 0.60;
    if (_rng.nextDouble() < chance) {
      final col = free[_rng.nextInt(free.length)];
      foodItems.add(FoodItem(_idCounter++, col));
      _spawnCooldown = 2;
    }
  }

  void _updateCat() {
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
