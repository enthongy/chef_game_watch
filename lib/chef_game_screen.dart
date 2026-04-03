import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'game_logic.dart';

// ═══════════════════════════════════════════════
// SONIC SOCCER COLOUR PALETTE
// ═══════════════════════════════════════════════

const Color kLcdBg = Color(0xFF94C89A);        // slightly warmer green for football pitch feel
const Color kLcdBgBoost = Color(0xFFD4F080);   // Super Sonic flash
const Color kLcdActive = Color(0xFF0A0F08);
const Color kShell = Color(0xFF0054B4);         // Sonic Blue
const Color kShellLight = Color(0xFF1A6FD4);
const Color kShellShadow = Color(0xFF003080);
const Color kAccentGold = Color(0xFFFFD700);
const Color kAccentRed = Color(0xFFCC0000);
const Color kBtnBase = Color(0xFFFFD700);       // Gold buttons
const Color kBtnLight = Color(0xFFFFF176);
const Color kBtnShadow = Color(0xFFC8A000);

// ═══════════════════════════════════════════════
// MAIN SCREEN
// ═══════════════════════════════════════════════

class ChefGameScreen extends StatelessWidget {
  const ChefGameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF001840),
      body: Focus(
        autofocus: true,
        onKeyEvent: (node, event) {
          if (event is! KeyDownEvent) return KeyEventResult.ignored;
          final logic = context.read<GameLogic>();
          final key = event.logicalKey;

          if (key == LogicalKeyboardKey.arrowLeft ||
              key == LogicalKeyboardKey.keyA ||
              key == LogicalKeyboardKey.keyZ) {
            logic.moveSonic(-1);
            return KeyEventResult.handled;
          }
          if (key == LogicalKeyboardKey.arrowRight ||
              key == LogicalKeyboardKey.keyD ||
              key == LogicalKeyboardKey.keyX) {
            logic.moveSonic(1);
            return KeyEventResult.handled;
          }
          if (key == LogicalKeyboardKey.digit1) {
            logic.startGame(GameMode.a);
            return KeyEventResult.handled;
          }
          if (key == LogicalKeyboardKey.digit2) {
            logic.startGame(GameMode.b);
            return KeyEventResult.handled;
          }
          if (key == LogicalKeyboardKey.enter ||
              key == LogicalKeyboardKey.space) {
            if (logic.phase == GamePhase.menu) {
              logic.startGame(logic.mode);
            } else if (logic.phase == GamePhase.gameOver) {
              logic.goToMenu();
            }
            return KeyEventResult.handled;
          }
          if (key == LogicalKeyboardKey.escape) {
            if (logic.phase != GamePhase.menu) logic.goToMenu();
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
        child: Center(
          child: SingleChildScrollView(child: _GameDevice()),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════
// DEVICE BODY — Sonic Blue shell
// ═══════════════════════════════════════════════

class _GameDevice extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 360,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A6FD4), Color(0xFF0054B4), Color(0xFF003080)],
        ),
        borderRadius: BorderRadius.circular(36),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.7),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
          BoxShadow(
            color: kShellLight.withOpacity(0.25),
            blurRadius: 2,
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
                color: kAccentGold,
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: 2.5,
              ),
            ),
            Text(
              'SONIC SOCCER',
              style: TextStyle(
                color: Colors.white.withOpacity(0.95),
                fontSize: 14,
                fontWeight: FontWeight.w900,
                letterSpacing: 3,
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
              border: Border.all(color: kAccentGold.withOpacity(0.6)),
            ),
            child: Text(
              logic.superSonicActive ? '⚡ BOOST' :
              (logic.mode == GameMode.a ? 'GAME-A' : 'GAME-B'),
              style: TextStyle(
                color: logic.superSonicActive ? Colors.yellowAccent : kAccentGold,
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
// LCD SCREEN — Chrome bezel + pitch-green interior
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
      child: Consumer<GameLogic>(builder: (_, logic, __) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: logic.superSonicActive ? kLcdBgBoost : kLcdBg,
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
        );
      }),
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
            'SAVES',
            style: TextStyle(
              color: kLcdActive.withOpacity(0.5),
              fontSize: 8,
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
// GAME AREA
// ═══════════════════════════════════════════════

class _GameArea extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<GameLogic>(
      builder: (_, logic, __) => AspectRatio(
        aspectRatio: 1.6,
        child: Stack(
          children: [
            Positioned.fill(child: CustomPaint(painter: _GhostLayerPainter())),
            Positioned.fill(child: CustomPaint(painter: _ActiveLayerPainter(logic: logic))),
            if (logic.phase == GamePhase.menu)
              Positioned.fill(child: _MenuOverlay()),
            if (logic.phase == GamePhase.gameOver)
              Positioned.fill(child: _GameOverOverlay()),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════
// GHOST LAYER
// ═══════════════════════════════════════════════

class _GhostLayerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = kLcdActive.withOpacity(0.05)
      ..style = PaintingStyle.fill;

    for (final pos in allBallGhostPositions) {
      _drawBall(canvas, _gridToCanvas(pos, size), paint);
    }
    for (int col = 0; col < 4; col++) {
      _drawSonic(canvas, _sonicOffset(col, size), paint, false);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}

// ═══════════════════════════════════════════════
// ACTIVE LAYER
// ═══════════════════════════════════════════════

class _ActiveLayerPainter extends CustomPainter {
  final GameLogic logic;
  const _ActiveLayerPainter({required this.logic});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = kLcdActive.withOpacity(0.90)
      ..style = PaintingStyle.fill;

    for (final ball in logic.balls) {
      _drawBall(canvas, _gridToCanvas(ball.position, size), paint);
    }

    _drawSonic(canvas, _sonicOffset(logic.sonicPosition, size), paint,
        logic.superSonicActive);

    if (logic.catActive) {
      final strokePaint = Paint()
        ..color = kLcdActive.withOpacity(0.90)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..strokeCap = StrokeCap.round;
      final catX = logic.catColumn == 0 ? -size.width * 0.04 : size.width * 1.04;
      _drawCat(canvas, Offset(catX, size.height * 0.12), paint, strokePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ActiveLayerPainter old) =>
      old.logic.balls != logic.balls ||
      old.logic.sonicPosition != logic.sonicPosition ||
      old.logic.catActive != logic.catActive ||
      old.logic.superSonicActive != logic.superSonicActive;
}

// ─── Coordinate helpers ───────────────────────

const double _kTopPct    = 0.04;
const double _kBottomPct = 0.85;

Offset _gridToCanvas(GridPos pos, Size size) {
  final double cx = size.width * (pos.x * 2 + 1) / 8;
  final double cy = size.height *
      (_kTopPct + (pos.y / 8) * (_kBottomPct - _kTopPct));
  return Offset(cx, cy);
}

Offset _sonicOffset(int col, Size size) => Offset(
      size.width * (col * 2 + 1) / 8,
      size.height * _kBottomPct,
    );

// ─── Soccer Ball sprite ───────────────────────

void _drawBall(Canvas canvas, Offset center, Paint paint) {
  // Outer circle
  canvas.drawCircle(center, 8, paint);
  // Hex pattern lines (simplified white pentagon lines over dark fill)
  final linePaint = Paint()
    ..color = (paint.color == kLcdActive.withOpacity(0.90))
        ? const Color(0xFF94C89A) // contrast lines on active
        : Colors.transparent
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.0;
  // Draw 3 crossing lines to suggest a hex seam pattern
  canvas.drawLine(center + const Offset(-4, -3), center + const Offset(4, -3), linePaint);
  canvas.drawLine(center + const Offset(-5, 1), center + const Offset(0, 5), linePaint);
  canvas.drawLine(center + const Offset(5, 1), center + const Offset(0, 5), linePaint);
}

// ─── Sonic sprite ─────────────────────────────

void _drawSonic(Canvas canvas, Offset center, Paint basePaint, bool boosted) {
  // Body (blue circle)
  final bodyPaint = Paint()
    ..color = boosted ? const Color(0xFF00E5FF) : basePaint.color
    ..style = PaintingStyle.fill;
  canvas.drawCircle(Offset(center.dx, center.dy - 4), 9, bodyPaint);

  // Spikes (abstract triangles on top)
  final spikePaint = Paint()
    ..color = basePaint.color
    ..style = PaintingStyle.fill;
  final spikePath = Path()
    ..moveTo(center.dx - 6, center.dy - 10)
    ..lineTo(center.dx - 2, center.dy - 18)
    ..lineTo(center.dx + 1, center.dy - 10)
    ..close();
  canvas.drawPath(spikePath, spikePaint);
  final spikePath2 = Path()
    ..moveTo(center.dx + 1, center.dy - 10)
    ..lineTo(center.dx + 5, center.dy - 17)
    ..lineTo(center.dx + 8, center.dy - 10)
    ..close();
  canvas.drawPath(spikePath2, spikePaint);

  // Red feet
  final feetPaint = Paint()
    ..color = boosted ? Colors.yellowAccent : const Color(0xFFCC0000)
    ..style = PaintingStyle.fill;
  // Left foot
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(center.dx - 5, center.dy + 7), width: 8, height: 4),
      const Radius.circular(2),
    ),
    feetPaint,
  );
  // Right foot
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(center.dx + 5, center.dy + 7), width: 8, height: 4),
      const Radius.circular(2),
    ),
    feetPaint,
  );

  // White eye
  canvas.drawCircle(Offset(center.dx + 3, center.dy - 5), 3,
      Paint()..color = Colors.white.withOpacity(0.9));
  canvas.drawCircle(Offset(center.dx + 4, center.dy - 5), 1.2,
      Paint()..color = kLcdActive.withOpacity(0.9));
}

// ─── Cat sprite ───────────────────────────────

void _drawCat(Canvas canvas, Offset center, Paint fill, Paint stroke) {
  canvas.drawCircle(center, 9, fill);
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
  canvas.drawLine(center + const Offset(-9, 0), center + const Offset(-15, -2), stroke);
  canvas.drawLine(center + const Offset(-9, 2), center + const Offset(-15, 4), stroke);
  canvas.drawLine(center + const Offset(9, 0), center + const Offset(15, -2), stroke);
  canvas.drawLine(center + const Offset(9, 2), center + const Offset(15, 4), stroke);
}

// ═══════════════════════════════════════════════
// MISS (GOALS CONCEDED) ROW
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
                'GOAL ',
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
            'SEGA',
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
  Widget build(BuildContext context) =>
      CustomPaint(size: const Size(8, 8), painter: _DiamondPainter(active: active));
}

class _DiamondPainter extends CustomPainter {
  final bool active;
  const _DiamondPainter({required this.active});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = kLcdActive.withOpacity(active ? 0.90 : 0.06)
      ..style = PaintingStyle.fill;
    canvas.drawPath(
      Path()
        ..moveTo(size.width / 2, 0)
        ..lineTo(size.width, size.height / 2)
        ..lineTo(size.width / 2, size.height)
        ..lineTo(0, size.height / 2)
        ..close(),
      paint,
    );
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
  Widget build(BuildContext context) =>
      CustomPaint(size: const Size(12, 20), painter: _SegmentPainter(digit: digit));
}

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

    final activePaint = Paint()..color = kLcdActive.withOpacity(0.88)..style = PaintingStyle.fill;
    final ghostPaint  = Paint()..color = kLcdActive.withOpacity(0.07)..style = PaintingStyle.fill;

    void seg(bool on, Rect r) => canvas.drawRRect(
        RRect.fromRectAndRadius(r, const Radius.circular(1)), on ? activePaint : ghostPaint);

    seg(segs[0], Rect.fromLTWH(stk + gap, 0,              w - stk * 2 - gap * 2, stk));
    seg(segs[1], Rect.fromLTWH(w - stk,   stk + gap,      stk, half - stk - gap * 2));
    seg(segs[2], Rect.fromLTWH(w - stk,   half + gap,     stk, half - stk - gap * 2));
    seg(segs[3], Rect.fromLTWH(stk + gap, h - stk,        w - stk * 2 - gap * 2, stk));
    seg(segs[4], Rect.fromLTWH(0,         half + gap,     stk, half - stk - gap * 2));
    seg(segs[5], Rect.fromLTWH(0,         stk + gap,      stk, half - stk - gap * 2));
    seg(segs[6], Rect.fromLTWH(stk + gap, half - stk / 2, w - stk * 2 - gap * 2, stk));
  }

  @override
  bool shouldRepaint(covariant _SegmentPainter old) => old.digit != digit;
}

// ═══════════════════════════════════════════════
// CONTROLS SECTION — Gold neumorphic buttons
// ═══════════════════════════════════════════════

class _ControlsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [_DPad(), _CenterButtons(), _ActionCluster()],
        ),
        const SizedBox(height: 16),
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

class _DPad extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            NeumorphicButton(
              size: 44,
              onPressed: () => context.read<GameLogic>().moveSonic(-1),
              child: const Icon(Icons.chevron_left, color: Colors.black87, size: 22),
            ),
            const SizedBox(width: 6),
            NeumorphicButton(
              size: 44,
              onPressed: () => context.read<GameLogic>().moveSonic(1),
              child: const Icon(Icons.chevron_right, color: Colors.black87, size: 22),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text('MOVE', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 8, letterSpacing: 2)),
      ],
    );
  }
}

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
                active: logic.mode == GameMode.a && logic.phase == GamePhase.playing,
                onPressed: () => logic.startGame(GameMode.a),
              ),
              const SizedBox(width: 8),
              _ModeButton(
                label: 'B',
                active: logic.mode == GameMode.b && logic.phase == GamePhase.playing,
                onPressed: () => logic.startGame(GameMode.b),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('GAME', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 8, letterSpacing: 2)),
        ],
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onPressed;
  const _ModeButton({required this.label, required this.active, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return NeumorphicButton(
      size: 36,
      baseColor: active ? kAccentRed : kBtnBase,
      onPressed: onPressed,
      child: Text(
        label,
        style: TextStyle(
          color: active ? Colors.white : kAccentGold,
          fontSize: 13,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _ActionCluster extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<GameLogic>(
      builder: (_, logic, __) => Column(
        children: [
          NeumorphicButton(
            size: 48,
            baseColor: kAccentRed,
            onPressed: () {
              if (logic.phase == GamePhase.menu) logic.startGame(logic.mode);
              else if (logic.phase == GamePhase.gameOver) logic.goToMenu();
            },
            child: const Icon(Icons.sports_soccer, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 6),
          Text('START', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 8, letterSpacing: 1.5)),
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
    return GestureDetector(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: kShellShadow,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: kAccentGold.withOpacity(0.4)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: kAccentGold.withOpacity(0.7),
            fontSize: 8,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('⚡', style: TextStyle(fontSize: 32)),
            const SizedBox(height: 6),
            Text(
              'SONIC SOCCER',
              style: TextStyle(
                color: kShell,
                fontSize: 13,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Press GAME A / B\nor [1] / [2]',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: kLcdActive.withOpacity(0.6),
                fontSize: 9,
                letterSpacing: 1,
              ),
            ),
          ],
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
        color: kLcdBg.withOpacity(0.92),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Consumer<GameLogic>(
        builder: (_, logic, __) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'GOAL!!',
                style: TextStyle(
                  color: kAccentRed,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'SAVES: ${logic.score}',
                style: TextStyle(
                  color: kLcdActive.withOpacity(0.8),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Press START or [Enter]',
                style: TextStyle(
                  color: kLcdActive.withOpacity(0.5),
                  fontSize: 8,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════
// NEUMORPHIC BUTTON — Gold with input debounce
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
        now.difference(_lastTap!) < const Duration(milliseconds: 50)) return;
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
        transform: _pressed ? (Matrix4.identity()..scale(0.93)) : Matrix4.identity(),
        transformAlignment: Alignment.center,
        decoration: BoxDecoration(
          color: widget.baseColor,
          shape: BoxShape.circle,
          boxShadow: _pressed
              ? [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 2, offset: const Offset(1, 1))]
              : [
                  BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 6, offset: const Offset(3, 3)),
                  BoxShadow(color: Colors.white.withOpacity(0.15), blurRadius: 4, offset: const Offset(-2, -2)),
                ],
        ),
        child: Center(child: widget.child),
      ),
    );
  }
}
