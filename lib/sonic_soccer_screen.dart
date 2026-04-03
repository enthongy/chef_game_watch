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
class ShellTheme {
  final String name;
  final Color shellLight;
  final Color shellBase;
  final Color shellShadow;
  final Color btnBase;
  final Color btnAccent;
  const ShellTheme(this.name, this.shellLight, this.shellBase, this.shellShadow, this.btnBase, this.btnAccent);
}

const List<ShellTheme> kShellThemes = [
  ShellTheme('Sonic Blue', Color(0xFF1A6FD4), Color(0xFF0054B4), Color(0xFF003080), Color(0xFFFFD700), Color(0xFFCC0000)),
  ShellTheme('Tails Yellow', Color(0xFFFFD54F), Color(0xFFFFB300), Color(0xFFE65100), Color(0xFFD32F2F), Color(0xFFFFD700)),
  ShellTheme('Knuckles Red', Color(0xFFEF5350), Color(0xFFD32F2F), Color(0xFFB71C1C), Color(0xFFFFD700), Color(0xFF1565C0)),
  ShellTheme('Shadow Black', Color(0xFF5A5A5A), Color(0xFF2C2C2C), Color(0xFF0A0A0A), Color(0xFFFFD700), Color(0xFFCC0000)),
  ShellTheme('Emerald Green', Color(0xFF66BB6A), Color(0xFF388E3C), Color(0xFF1B5E20), Color(0xFFCC0000), Color(0xFFFFD700)),
];

// ═══════════════════════════════════════════════
// MAIN SCREEN
// ═══════════════════════════════════════════════

class SonicSoccerScreen extends StatelessWidget {
  const SonicSoccerScreen({super.key});

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
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ThemeBar(),
                const SizedBox(height: 16),
                _GameDevice(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ThemeBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<GameLogic>(
      builder: (_, logic, __) => Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(kShellThemes.length, (i) {
          final theme = kShellThemes[i];
          final isActive = logic.shellThemeIndex == i;
          return GestureDetector(
            onTap: () => logic.setShellTheme(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 6),
              width: isActive ? 32 : 24,
              height: isActive ? 32 : 24,
              decoration: BoxDecoration(
                color: theme.shellBase,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isActive ? Colors.white : Colors.white38,
                  width: isActive ? 2.5 : 1.5,
                ),
                boxShadow: isActive
                    ? [BoxShadow(color: theme.shellBase, blurRadius: 10, spreadRadius: 1)]
                    : null,
              ),
            ),
          );
        }),
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
    final theme = kShellThemes[context.watch<GameLogic>().shellThemeIndex];
    
    return Container(
      width: 360,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [theme.shellLight, theme.shellBase, theme.shellShadow],
        ),
        borderRadius: BorderRadius.circular(36),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.7),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
          BoxShadow(
            color: theme.shellLight.withOpacity(0.25),
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
    final theme = kShellThemes[context.watch<GameLogic>().shellThemeIndex];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'GAME & WATCH®',
              style: TextStyle(
                color: theme.btnBase,
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
              color: theme.btnBase.withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: theme.btnBase.withOpacity(0.6)),
            ),
            child: Text(
              logic.superSonicActive ? '⚡ BOOST' :
              (logic.mode == GameMode.a ? 'GAME-A' : 'GAME-B'),
              style: TextStyle(
                color: logic.superSonicActive ? Colors.yellowAccent : theme.btnBase,
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
        return Container(
          decoration: BoxDecoration(
            color: kLcdBg.withOpacity(0.6), // Fallback if image isn't loaded
            image: const DecorationImage(
              image: AssetImage('assets/bg.png'),
              fit: BoxFit.cover,
            ),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: const Color(0xFF7A9474), width: 1),
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            color: logic.superSonicActive 
                ? kLcdBgBoost.withOpacity(0.7) 
                : const Color.fromRGBO(255, 255, 255, 0.4), // light overlay to make sprites pop
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
          clipBehavior: Clip.none,
          children: [
            // GHOST LAYER - BALLS
            for (final pos in allBallGhostPositions)
              Align(
                alignment: Alignment(-0.75 + (pos.x * 0.5), -0.92 + (pos.y / 8 * 1.62)),
                child: Image.asset('assets/ball.png', width: 22, height: 22, color: kLcdActive.withOpacity(0.05)),
              ),
            // GHOST LAYER - SONIC
            for (int col = 0; col < 4; col++)
              Align(
                alignment: Alignment(-0.75 + (col * 0.5), 0.70),
                child: Image.asset('assets/sonic.png', width: 34, height: 34, color: kLcdActive.withOpacity(0.05)),
              ),

            // ACTIVE LAYER - BALLS
            for (final ball in logic.balls)
              Align(
                alignment: Alignment(-0.75 + (ball.column * 0.5), -0.92 + (ball.position.y / 8 * 1.62)),
                child: Image.asset('assets/ball.png', width: 22, height: 22, color: kLcdActive.withOpacity(0.90)),
              ),

            // ACTIVE LAYER - SONIC
            Align(
              alignment: Alignment(-0.75 + (logic.sonicPosition * 0.5), 0.70),
              child: Transform(
                alignment: Alignment.center,
                // The AI generated Sonic asset faces left naturally, so we invert the flip factor
                transform: Matrix4.identity()..scale(-logic.sonicDirection.toDouble(), 1.0, 1.0),
                child: Image.asset(
                  'assets/sonic.png', 
                  width: 34, 
                  height: 34,
                  color: logic.superSonicActive ? Colors.yellow : kLcdActive.withOpacity(0.90)
                ),
              ),
            ),

            // ACTIVE LAYER - CAT (OBSTACLE)
            if (logic.catActive)
              Align(
                alignment: Alignment(logic.catColumn == 0 ? -1.0 : 1.0, -0.76),
                child: CustomPaint(
                  size: const Size(20, 20),
                  painter: _CatPainter(color: kLcdActive.withOpacity(0.90)),
                ),
              ),

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

class _CatPainter extends CustomPainter {
  final Color color;
  _CatPainter({required this.color});
  
  @override
  void paint(Canvas canvas, Size size) {
    final fill = Paint()..color = color..style = PaintingStyle.fill;
    final stroke = Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 1.4..strokeCap = StrokeCap.round;
    final center = Offset(size.width/2, size.height/2);
    canvas.drawCircle(center, 9, fill);
    final earPath = Path()
      ..moveTo(center.dx - 6, center.dy - 8)..lineTo(center.dx - 10, center.dy - 16)..lineTo(center.dx - 2, center.dy - 10)..close();
    canvas.drawPath(earPath, fill);
    final earPath2 = Path()
      ..moveTo(center.dx + 6, center.dy - 8)..lineTo(center.dx + 10, center.dy - 16)..lineTo(center.dx + 2, center.dy - 10)..close();
    canvas.drawPath(earPath2, fill);
    canvas.drawLine(center + const Offset(-9, 0), center + const Offset(-15, -2), stroke);
    canvas.drawLine(center + const Offset(-9, 2), center + const Offset(-15, 4), stroke);
    canvas.drawLine(center + const Offset(9, 0), center + const Offset(15, -2), stroke);
    canvas.drawLine(center + const Offset(9, 2), center + const Offset(15, 4), stroke);
  }
  @override
  bool shouldRepaint(covariant _CatPainter old) => old.color != color;
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
    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height / 2)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(0, size.height / 2)
      ..close();

    final paint = Paint()
      ..color = kLcdActive.withOpacity(active ? 0.90 : 0.12)
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, paint);

    if (!active) {
      final strokePaint = Paint()
        ..color = kLcdActive.withOpacity(0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;
      canvas.drawPath(path, strokePaint);
    }
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
              baseColor: kShellThemes[context.watch<GameLogic>().shellThemeIndex].btnBase,
              onPressed: () => context.read<GameLogic>().moveSonic(-1),
              child: const Icon(Icons.chevron_left, color: Colors.black87, size: 22),
            ),
            const SizedBox(width: 6),
            NeumorphicButton(
              size: 44,
              baseColor: kShellThemes[context.watch<GameLogic>().shellThemeIndex].btnBase,
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
    final theme = kShellThemes[context.watch<GameLogic>().shellThemeIndex];
    return NeumorphicButton(
      size: 36,
      baseColor: active ? theme.btnAccent : theme.btnBase,
      onPressed: onPressed,
      child: Text(
        label,
        style: TextStyle(
          color: active ? Colors.white : Colors.black87,
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
            baseColor: kShellThemes[logic.shellThemeIndex].btnAccent,
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
    final theme = kShellThemes[context.watch<GameLogic>().shellThemeIndex];
    return GestureDetector(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: theme.shellShadow,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: theme.btnBase.withOpacity(0.4)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: theme.btnBase.withOpacity(0.7),
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
    final theme = kShellThemes[context.watch<GameLogic>().shellThemeIndex];
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
                color: theme.shellBase,
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
    final theme = kShellThemes[context.watch<GameLogic>().shellThemeIndex];
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
                  color: theme.btnAccent,
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
    this.baseColor = const Color(0xFFFFD700),
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
