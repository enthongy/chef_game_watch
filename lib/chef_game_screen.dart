import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'game_logic.dart';

// ═══════════════════════════════════════════════
// COLOUR PALETTE
// ═══════════════════════════════════════════════

const Color kLcdBg = Color(0xFF94A88E);
const Color kLcdActive = Color(0xFF0A0F08);
const Color kShell = Color(0xFF0A192F);
const Color kShellLight = Color(0xFF1A2744);
const Color kShellShadow = Color(0xFF050D1A);
const Color kAccentGold = Color(0xFF7F8C8D);
const Color kAccentGoldLight = Color(0xFFBDC3C7);
const Color kBtnBase = Color(0xFF112240);
const Color kBtnLight = Color(0xFF1E3A5F);
const Color kBtnShadow = Color(0xFF050D1A);
const Color kRedBtn = Color(0xFFB02030);

// ═══════════════════════════════════════════════
// MAIN SCREEN
// ═══════════════════════════════════════════════

class ChefGameScreen extends StatelessWidget {
  const ChefGameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0F14),
      body: Focus(
        autofocus: true,
        onKeyEvent: (node, event) {
          if (event is! KeyDownEvent) return KeyEventResult.ignored;
          final logic = context.read<GameLogic>();
          final key = event.logicalKey;

          // ── Move Left: ← A Z ──────────────────────────
          if (key == LogicalKeyboardKey.arrowLeft ||
              key == LogicalKeyboardKey.keyA ||
              key == LogicalKeyboardKey.keyZ) {
            logic.moveChef(-1);
            return KeyEventResult.handled;
          }
          // ── Move Right: → D X ─────────────────────────
          if (key == LogicalKeyboardKey.arrowRight ||
              key == LogicalKeyboardKey.keyD ||
              key == LogicalKeyboardKey.keyX) {
            logic.moveChef(1);
            return KeyEventResult.handled;
          }
          // ── Game A: 1 ─────────────────────────────────
          if (key == LogicalKeyboardKey.digit1) {
            logic.startGame(GameMode.a);
            return KeyEventResult.handled;
          }
          // ── Game B: 2 ─────────────────────────────────
          if (key == LogicalKeyboardKey.digit2) {
            logic.startGame(GameMode.b);
            return KeyEventResult.handled;
          }
          // ── Start / Confirm: Enter Space ───────────────
          if (key == LogicalKeyboardKey.enter ||
              key == LogicalKeyboardKey.space) {
            if (logic.phase == GamePhase.menu) {
              logic.startGame(logic.mode);
            } else if (logic.phase == GamePhase.gameOver) {
              logic.goToMenu();
            }
            return KeyEventResult.handled;
          }
          // ── Menu / Quit: Escape ────────────────────────
          if (key == LogicalKeyboardKey.escape) {
            if (logic.phase != GamePhase.menu) {
              logic.goToMenu();
            }
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
        child: Center(
          child: SingleChildScrollView(
            child: _GameDevice(),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════
// DEVICE BODY
// ═══════════════════════════════════════════════

class _GameDevice extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 340,
      decoration: BoxDecoration(
        color: kShell,
        borderRadius: BorderRadius.circular(36),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.7),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
          BoxShadow(
            color: kShellLight.withOpacity(0.20),
            blurRadius: 1,
            offset: const Offset(-1, -1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _BrandHeader(),
            const SizedBox(height: 12),
            _LcdScreen(),
            const SizedBox(height: 20),
            _ControlsSection(),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════
// BRAND HEADER
// ═══════════════════════════════════════════════

class _BrandHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'GAME & WATCH®',
              style: TextStyle(
                color: kAccentGoldLight,
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: 2.5,
              ),
            ),
            Text(
              'CHEF',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: 4,
              ),
            ),
          ],
        ),
        Consumer<GameLogic>(
          builder: (_, logic, __) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: kAccentGold.withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: kAccentGold.withOpacity(0.4)),
            ),
            child: Text(
              logic.mode == GameMode.a ? 'GAME-A' : 'GAME-B',
              style: TextStyle(
                color: kAccentGoldLight,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════
// LCD SCREEN with brushed-metal bezel
// ═══════════════════════════════════════════════

class _LcdScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFBDC3C7),
            Color(0xFFECF0F1),
            Color(0xFF95A5A6),
            Color(0xFFBDC3C7),
            Color(0xFF2C3E50),
          ],
          stops: [0.0, 0.25, 0.5, 0.75, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(8),
      child: Container(
        decoration: BoxDecoration(
          color: kLcdBg,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: const Color(0xFF7A9474), width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              _ScoreRow(),
              const SizedBox(height: 8),
              _GameArea(),
              const SizedBox(height: 8),
              _MissRow(),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════
// SCORE ROW
// ═══════════════════════════════════════════════

class _ScoreRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<GameLogic>(
      builder: (_, logic, __) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '1UP',
            style: TextStyle(
              color: kLcdActive.withOpacity(0.5),
              fontSize: 9,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          SevenSegmentScore(score: logic.score),
          Text(
            logic.phase == GamePhase.playing
                ? (logic.mode == GameMode.a ? 'A' : 'B')
                : '--',
            style: TextStyle(
              color: kLcdActive.withOpacity(0.5),
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════
// GAME AREA — Stack: Ghost + Active + Overlay
// ═══════════════════════════════════════════════

class _GameArea extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<GameLogic>(
      builder: (_, logic, __) {
        return AspectRatio(
          aspectRatio: 1.6,
          child: Stack(
            children: [
              // ── Layer 0: Ghost (all possible positions) ──
              Positioned.fill(
                child: CustomPaint(
                  painter: _GhostLayerPainter(),
                ),
              ),
              // ── Layer 1: Active sprites ──
              Positioned.fill(
                child: CustomPaint(
                  painter: _ActiveLayerPainter(logic: logic),
                ),
              ),
              // ── Layer 2: Menu overlay ──
              if (logic.phase == GamePhase.menu)
                Positioned.fill(child: _MenuOverlay()),
              // ── Layer 3: Game Over overlay ──
              if (logic.phase == GamePhase.gameOver)
                Positioned.fill(child: _GameOverOverlay()),
            ],
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════
// GHOST LAYER PAINTER
// Renders all 15 food positions + 3 chef positions at 5% opacity
// ═══════════════════════════════════════════════

class _GhostLayerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = kLcdActive.withOpacity(0.05)
      ..style = PaintingStyle.fill;

    for (final pos in allFoodGhostPositions) {
      final offset = _gridToCanvas(pos, size);
      _drawFood(canvas, offset, paint, atPeak: pos.y == 0);
    }

    // Chef ghosts at all 4 positions (row below grid)
    for (int col = 0; col < 4; col++) {
      final offset = _chefOffset(col, size);
      _drawChef(canvas, offset, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ═══════════════════════════════════════════════
// ACTIVE LAYER PAINTER
// Renders live food, chef, and cat at full opacity
// ═══════════════════════════════════════════════

class _ActiveLayerPainter extends CustomPainter {
  final GameLogic logic;
  const _ActiveLayerPainter({required this.logic});

  @override
  void paint(Canvas canvas, Size size) {
    final activePaint = Paint()
      ..color = kLcdActive.withOpacity(0.90)
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = kLcdActive.withOpacity(0.90)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;

    // Draw food items
    for (final food in logic.foodItems) {
      final offset = _gridToCanvas(food.position, size);
      _drawFood(canvas, offset, activePaint, atPeak: food.atPeak);
    }

    // Draw chef
    final chefOffset = _chefOffset(logic.chefPosition, size);
    _drawChef(canvas, chefOffset, activePaint);

    // Draw cat if active
    if (logic.catActive) {
      final catX = logic.catColumn == 0 ? -size.width * 0.04 : size.width * 1.04;
      final catY = size.height * 0.15;
      _drawCat(canvas, Offset(catX, catY), activePaint, strokePaint, size);
    }
  }

  @override
  bool shouldRepaint(covariant _ActiveLayerPainter old) =>
      old.logic.foodItems != logic.foodItems ||
      old.logic.chefPosition != logic.chefPosition ||
      old.logic.catActive != logic.catActive;
}

// ─── Shared coordinate helpers ───────────────

// Food movement spans y: 0 (peak) → 8 (catch zone).
// Chef is drawn at the same pixel row as y=8 so food
// visually lands exactly on top of the pan.
const double _kTopPct    = 0.04;  // y=0 (peak)
const double _kBottomPct = 0.86;  // y=8 (catch / chef)

/// Maps a GridPos (x:0-3, y:0-8) to canvas pixel centre.
Offset _gridToCanvas(GridPos pos, Size size) {
  final double cx = size.width * (pos.x * 2 + 1) / 8;
  final double cy = size.height *
      (_kTopPct + (pos.y / 8) * (_kBottomPct - _kTopPct));
  return Offset(cx, cy);
}

/// Chef is fixed at the catch row (y=8 equivalent).
Offset _chefOffset(int col, Size size) {
  return Offset(
    size.width * (col * 2 + 1) / 8,
    size.height * _kBottomPct,
  );
}

// ─── Sprite painters ─────────────────────────

void _drawFood(Canvas canvas, Offset center, Paint paint, {bool atPeak = false}) {
  final double scale = atPeak ? 0.7 : 1.0;
  // Pancake: filled ellipse
  canvas.drawOval(
    Rect.fromCenter(center: center, width: 16 * scale, height: 9 * scale),
    paint,
  );
  // Stack line on top
  final linePaint = Paint()
    ..color = paint.color
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.2 * scale;
  canvas.drawLine(
    center + Offset(-6 * scale, -2 * scale),
    center + Offset(6 * scale, -2 * scale),
    linePaint,
  );
}

void _drawChef(Canvas canvas, Offset center, Paint paint) {
  // Hat
  final hat = Rect.fromCenter(
    center: Offset(center.dx, center.dy - 13),
    width: 14,
    height: 8,
  );
  canvas.drawRect(hat, paint);
  // Hat brim
  canvas.drawRect(
    Rect.fromCenter(
      center: Offset(center.dx, center.dy - 8),
      width: 18,
      height: 3,
    ),
    paint,
  );
  // Head
  canvas.drawCircle(Offset(center.dx, center.dy - 2), 6, paint);
  // Body
  final bodyPath = Path()
    ..moveTo(center.dx - 8, center.dy + 4)
    ..lineTo(center.dx + 8, center.dy + 4)
    ..lineTo(center.dx + 10, center.dy + 17)
    ..lineTo(center.dx - 10, center.dy + 17)
    ..close();
  canvas.drawPath(bodyPath, paint);
  // Pan (arm extended)
  final panPaint = Paint()
    ..color = paint.color
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2
    ..strokeCap = StrokeCap.round;
  canvas.drawLine(
    Offset(center.dx + 8, center.dy + 6),
    Offset(center.dx + 16, center.dy),
    panPaint,
  );
  canvas.drawOval(
    Rect.fromCenter(
      center: Offset(center.dx + 19, center.dy - 2),
      width: 10,
      height: 5,
    ),
    paint,
  );
}

void _drawCat(
    Canvas canvas, Offset center, Paint fill, Paint stroke, Size size) {
  // Body
  canvas.drawCircle(center, 9, fill);
  // Ears
  final earPath = Path()
    ..moveTo(center.dx - 6, center.dy - 8)
    ..lineTo(center.dx - 10, center.dy - 16)
    ..lineTo(center.dx - 2, center.dy - 10)
    ..close();
  canvas.drawPath(earPath, fill);
  final earPath2 = Path()
    ..moveTo(center.dx + 6, center.dy - 8)
    ..lineTo(center.dx + 10, center.dy - 16)
    ..lineTo(center.dx + 2, center.dy - 10)
    ..close();
  canvas.drawPath(earPath2, fill);
  // Whiskers
  canvas.drawLine(center + const Offset(-9, 0), center + const Offset(-15, -2), stroke);
  canvas.drawLine(center + const Offset(-9, 2), center + const Offset(-15, 4), stroke);
  canvas.drawLine(center + const Offset(9, 0), center + const Offset(15, -2), stroke);
  canvas.drawLine(center + const Offset(9, 2), center + const Offset(15, 4), stroke);
}

// ═══════════════════════════════════════════════
// MISS ROW
// ═══════════════════════════════════════════════

class _MissRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<GameLogic>(
      builder: (_, logic, __) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                'MISS ',
                style: TextStyle(
                  color: kLcdActive.withOpacity(0.5),
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              ...List.generate(
                GameLogic.maxLives,
                (i) => Padding(
                  padding: const EdgeInsets.only(right: 3),
                  child: _MissDiamond(
                    active: i < (GameLogic.maxLives - logic.lives),
                  ),
                ),
              ),
            ],
          ),
          Text(
            'NINTENDO',
            style: TextStyle(
              color: kLcdActive.withOpacity(0.25),
              fontSize: 7,
              letterSpacing: 1.5,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _MissDiamond extends StatelessWidget {
  final bool active;
  const _MissDiamond({required this.active});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(8, 8),
      painter: _DiamondPainter(active: active),
    );
  }
}

class _DiamondPainter extends CustomPainter {
  final bool active;
  const _DiamondPainter({required this.active});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = kLcdActive.withOpacity(active ? 0.90 : 0.06)
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height / 2)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(0, size.height / 2)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _DiamondPainter old) => old.active != active;
}

// ═══════════════════════════════════════════════
// SEVEN-SEGMENT SCORE DISPLAY
// ═══════════════════════════════════════════════

class SevenSegmentScore extends StatelessWidget {
  final int score;
  const SevenSegmentScore({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    final digits = score.toString().padLeft(4, '0').split('');
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: digits
          .map((d) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1),
                child: SevenSegmentDigit(digit: int.parse(d)),
              ))
          .toList(),
    );
  }
}

class SevenSegmentDigit extends StatelessWidget {
  final int digit;
  const SevenSegmentDigit({super.key, required this.digit});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(12, 20),
      painter: _SegmentPainter(digit: digit),
    );
  }
}

// Segment map: A=top B=top-right C=bot-right D=bot E=bot-left F=top-left G=mid
const _segMap = {
  0: [true, true, true, true, true, true, false],
  1: [false, true, true, false, false, false, false],
  2: [true, true, false, true, true, false, true],
  3: [true, true, true, true, false, false, true],
  4: [false, true, true, false, false, true, true],
  5: [true, false, true, true, false, true, true],
  6: [true, false, true, true, true, true, true],
  7: [true, true, true, false, false, false, false],
  8: [true, true, true, true, true, true, true],
  9: [true, true, true, true, false, true, true],
};

class _SegmentPainter extends CustomPainter {
  final int digit;
  const _SegmentPainter({required this.digit});

  @override
  void paint(Canvas canvas, Size size) {
    final segs = _segMap[digit] ?? _segMap[8]!;
    const stk = 2.0;
    const gap = 0.5;
    final w = size.width;
    final h = size.height;
    final half = h / 2;

    final activePaint = Paint()
      ..color = kLcdActive.withOpacity(0.88)
      ..style = PaintingStyle.fill;
    final ghostPaint = Paint()
      ..color = kLcdActive.withOpacity(0.07)
      ..style = PaintingStyle.fill;

    void seg(bool on, Rect r) =>
        canvas.drawRRect(RRect.fromRectAndRadius(r, const Radius.circular(1)),
            on ? activePaint : ghostPaint);

    // A – top
    seg(segs[0], Rect.fromLTWH(stk + gap, 0, w - stk * 2 - gap * 2, stk));
    // B – top-right
    seg(segs[1], Rect.fromLTWH(w - stk, stk + gap, stk, half - stk - gap * 2));
    // C – bot-right
    seg(segs[2], Rect.fromLTWH(w - stk, half + gap, stk, half - stk - gap * 2));
    // D – bottom
    seg(segs[3], Rect.fromLTWH(stk + gap, h - stk, w - stk * 2 - gap * 2, stk));
    // E – bot-left
    seg(segs[4], Rect.fromLTWH(0, half + gap, stk, half - stk - gap * 2));
    // F – top-left
    seg(segs[5], Rect.fromLTWH(0, stk + gap, stk, half - stk - gap * 2));
    // G – middle
    seg(segs[6],
        Rect.fromLTWH(stk + gap, half - stk / 2, w - stk * 2 - gap * 2, stk));
  }

  @override
  bool shouldRepaint(covariant _SegmentPainter old) => old.digit != digit;
}

// ═══════════════════════════════════════════════
// CONTROLS SECTION
// ═══════════════════════════════════════════════

class _ControlsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // D-pad row + action buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _DPad(),
            _CenterButtons(),
            _ActionCluster(),
          ],
        ),
        const SizedBox(height: 16),
        // Bottom decorative row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _SmallButton(label: 'TIME'),
            const SizedBox(width: 24),
            _SmallButton(label: 'ALARM'),
          ],
        ),
      ],
    );
  }
}

// ─── D-Pad ────────────────────────────────────

class _DPad extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            NeumorphicButton(
              size: 44,
              onPressed: () => context.read<GameLogic>().moveChef(-1),
              child: const Icon(Icons.chevron_left, color: Colors.white70, size: 22),
            ),
            const SizedBox(width: 6),
            NeumorphicButton(
              size: 44,
              onPressed: () => context.read<GameLogic>().moveChef(1),
              child: const Icon(Icons.chevron_right, color: Colors.white70, size: 22),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'MOVE',
          style: TextStyle(
            color: Colors.white.withOpacity(0.25),
            fontSize: 8,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }
}

// ─── Centre mode buttons ──────────────────────

class _CenterButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<GameLogic>(
      builder: (_, logic, __) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              _ModeButton(
                label: 'A',
                active: logic.mode == GameMode.a &&
                    logic.phase == GamePhase.playing,
                onPressed: () => logic.startGame(GameMode.a),
              ),
              const SizedBox(width: 8),
              _ModeButton(
                label: 'B',
                active: logic.mode == GameMode.b &&
                    logic.phase == GamePhase.playing,
                onPressed: () => logic.startGame(GameMode.b),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'GAME',
            style: TextStyle(
              color: Colors.white.withOpacity(0.3),
              fontSize: 8,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onPressed;

  const _ModeButton({
    required this.label,
    required this.active,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: active ? kAccentGold : kBtnBase,
          boxShadow: [
            BoxShadow(
              color: kBtnLight.withOpacity(0.5),
              offset: const Offset(-2, -2),
              blurRadius: 4,
            ),
            BoxShadow(
              color: kBtnShadow.withOpacity(0.8),
              offset: const Offset(2, 2),
              blurRadius: 4,
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: active ? Colors.black : Colors.white54,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Action cluster (right side) ──────────────

class _ActionCluster extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<GameLogic>(
      builder: (_, logic, __) => Column(
        children: [
          NeumorphicButton(
            size: 44,
            baseColor: kRedBtn,
            onPressed: () {
              if (logic.phase == GamePhase.menu) {
                logic.startGame(GameMode.a);
              } else if (logic.phase == GamePhase.gameOver) {
                logic.goToMenu();
              }
            },
            child: const Icon(Icons.play_arrow, color: Colors.white, size: 22),
          ),
          const SizedBox(height: 8),
          Text(
            'START',
            style: TextStyle(
              color: Colors.white.withOpacity(0.25),
              fontSize: 8,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }
}

class _SmallButton extends StatelessWidget {
  final String label;
  const _SmallButton({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 18,
      decoration: BoxDecoration(
        color: kBtnBase,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(color: kBtnLight.withOpacity(0.4), offset: const Offset(-1, -1), blurRadius: 2),
          BoxShadow(color: kBtnShadow.withOpacity(0.7), offset: const Offset(1, 1), blurRadius: 2),
        ],
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.3),
            fontSize: 7,
            letterSpacing: 1.5,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════
// NEUMORPHIC BUTTON
// ═══════════════════════════════════════════════

class NeumorphicButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final double size;
  final Color baseColor;

  const NeumorphicButton({
    super.key,
    required this.child,
    this.onPressed,
    this.size = 48,
    this.baseColor = kBtnBase,
  });

  @override
  State<NeumorphicButton> createState() => _NeumorphicButtonState();
}

class _NeumorphicButtonState extends State<NeumorphicButton> {
  bool _pressed = false;
  DateTime? _lastTap;

  void _handleTap() {
    final now = DateTime.now();
    if (_lastTap != null &&
        now.difference(_lastTap!) < const Duration(milliseconds: 50)) {
      return; // 50ms input buffer — drop ghost double-taps
    }
    _lastTap = now;
    widget.onPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _pressed = true);
        _handleTap();
      },
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        width: widget.size,
        height: widget.size,
        transform: _pressed
            ? (Matrix4.identity()..scale(0.95))
            : Matrix4.identity(),
        transformAlignment: Alignment.center,
        decoration: BoxDecoration(
          color: widget.baseColor,
          shape: BoxShape.circle,
          boxShadow: _pressed
              ? [
                  BoxShadow(
                    color: kBtnShadow.withOpacity(0.6),
                    offset: const Offset(-2, -2),
                    blurRadius: 4,
                  ),
                  BoxShadow(
                    color: kBtnLight.withOpacity(0.3),
                    offset: const Offset(2, 2),
                    blurRadius: 4,
                  ),
                ]
              : [
                  BoxShadow(
                    color: kBtnLight.withOpacity(0.4),
                    offset: const Offset(-3, -3),
                    blurRadius: 6,
                  ),
                  BoxShadow(
                    color: kBtnShadow.withOpacity(0.8),
                    offset: const Offset(3, 3),
                    blurRadius: 6,
                  ),
                ],
        ),
        child: Center(child: widget.child),
      ),
    );
  }
}

// ═══════════════════════════════════════════════
// OVERLAYS
// ═══════════════════════════════════════════════

class _MenuOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kLcdBg.withOpacity(0.88),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: Consumer<GameLogic>(
          builder: (_, logic, __) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'CHEF',
                style: TextStyle(
                  color: kLcdActive.withOpacity(0.85),
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 6,
                ),
              ),
              const SizedBox(height: 12),
              _OverlayButton(
                label: 'GAME A',
                onTap: () => logic.startGame(GameMode.a),
              ),
              const SizedBox(height: 8),
              _OverlayButton(
                label: 'GAME B',
                onTap: () => logic.startGame(GameMode.b),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GameOverOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kLcdBg.withOpacity(0.90),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: Consumer<GameLogic>(
          builder: (_, logic, __) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'GAME OVER',
                style: TextStyle(
                  color: kLcdActive.withOpacity(0.85),
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'SCORE: ${logic.score}',
                style: TextStyle(
                  color: kLcdActive.withOpacity(0.55),
                  fontSize: 10,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 14),
              _OverlayButton(
                label: 'MENU',
                onTap: () => logic.goToMenu(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OverlayButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _OverlayButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: kLcdActive.withOpacity(0.4)),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: kLcdActive.withOpacity(0.75),
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }
}
