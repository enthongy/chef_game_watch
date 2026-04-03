# 🍳 Game & Watch: Chef (Falling Objects Edition)

A faithful Flutter recreation and mechanical twist on Nintendo's 1981 *Game & Watch: Chef* — the wide-screen LCD handheld — built entirely with pure Flutter (no game engines, no external assets).

> **Note:** This version features modernized mechanics by switching the game's classic parabolic "tossing" trajectory into a purely falling, reflex-oriented "drop down" mechanic.

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)
![Platform](https://img.shields.io/badge/Platform-Web%20%7C%20Windows-0078D6?logo=googlechrome)
![License](https://img.shields.io/badge/License-MIT-green)

---

## 📺 Preview

> The game renders a dark-navy handheld shell with a gold brushed-metal bezel around a `#94A88E` olive-green LCD panel — straight out of 1981.

**LCD Ghost Effect** — every possible sprite position is always visible at 5% opacity, just like a real LCD display. Active sprites render at 90% opacity in solid black.

---

## 🎮 Gameplay

Help the chef catch the food falling from the top of the screen! Food items drop straight downward in discrete "ticks", increasing in speed as you score points.

### ⌨️ Keyboard Controls

| Key(s) | Action |
|---|---|
| `←` &nbsp;/&nbsp; `A` &nbsp;/&nbsp; `Z` | Move chef **left** |
| `→` &nbsp;/&nbsp; `D` &nbsp;/&nbsp; `X` | Move chef **right** |
| `1` | Start / restart **Game A** (3 items, normal speed) |
| `2` | Start / restart **Game B** (4 items, fast speed) |
| `Enter` &nbsp;/&nbsp; `Space` | **Confirm** — start game from menu; return to menu from Game Over |
| `Esc` | **Menu** — abort current game and return to title |

### 🖱️ On-Screen Buttons

| Button | Action |
|---|---|
| `‹` `›` | Move chef left / right (mouse or touch - instant `onTapDown` triggered!) |
| **GAME A** | Start Game A |
| **GAME B** | Start Game B |
| **START** (▶) | Return to menu after Game Over |

### Rules
- Each caught pancake = **+1 point**
- Miss a pancake = **−1 life** (4 lives total, shown as MISS diamonds)
- At **200** and **500** points — all MISS markers clear (bonus lives)
- Speed increases every **10 points**

---

## ✨ Features

### Physics
- **Discrete drop physics** — food follows a predefined straight `List<GridPos>` path falling through 9 distinct grid spaces. Authentic LCD screen stutter mechanics.
- **Game tick clock** — a single `Timer.periodic` drives everything; all objects subscribe to the same clock tick.

### Visuals
- **LCD ghost layer** — `CustomPaint` renders all 27 possible food positions (3 cols × 9 rows) + 3 chef positions at `opacity: 0.05` at all times.
- **Active sprite layer** — current state painted at `opacity: 0.90`.
- **Brushed-metal bezel** — 5-stop gold `LinearGradient` wrapping the screen.
- **Seven-segment score display** — segments A–G drawn as rounded `RRect`s; ghost segments at 7% opacity.
- **Ultra-responsive Neumorphic buttons** — dual `BoxShadow` (light top-left / dark bottom-right) trigger instantaneous `onTapDown` movement commands with press animation (`scale: 0.95`, 80 ms).

### Sound
- **Web Audio Context API Synth** — Uses `dart:js_interop` (JS Interop) to bind to an injected HTML5 `<script>` element containing `window.playWebBeep`. This uses raw browser `AudioContext` and an `OscillatorNode` (`square` wave) to mimic Game & Watch piezos on the web!
- **Native Windows Beep** — via `dart:ffi` → `kernel32.dll Beep()`, fired in a background `Isolate` so the UI never stutters holding the audio frequency loop on actual desktop PCs.
- No audio MP3/WAV files, no external audio packages — 100% self-contained synthesized sounds!

| Event | Sound |
|---|---|
| Catch | Two ascending blips (880 Hz → 1175 Hz) |
| Miss | Descending buzz (300 Hz → 220 Hz) |
| Game Over | Three descending tones |
| Bonus (200/500 pts) | Four-note ascending fanfare |

### Architecture
```text
ChangeNotifierProvider<GameLogic>
└── ChefGameScreen
    └── Stack
        ├── _GhostLayerPainter   (CustomPaint — opacity 0.05)
        ├── _ActiveLayerPainter  (CustomPaint — opacity 0.90)
        └── Overlay              (Menu / Game Over card)
```

---

## 🗂 Project Structure

```text
lib/
├── main.dart                 # App entry — ChangeNotifierProvider root
├── game_logic.dart           # GameLogic (ChangeNotifier), FoodItem, GridPos,
│                             #   vertical drop paths, tick logic, Game A/B modes
├── chef_game_screen.dart     # Full UI: device shell, LCD layers, seven-segment
│                             #   score, neumorphic controls, overlays
├── audio_service.dart        # Conditional export bridge (Native vs Web)
├── audio_service_stub.dart   # Web-compatible Audio Synthesizer (dart:js_interop)
└── audio_service_native.dart # Desktop-friendly kernel32.dll FFI Beep wrapper
```

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK `≥ 3.0`
- Configured to build locally to Windows, or deploy virtually to Vercel/Web.

### Web Deployment (Vercel)
If you're looking to run this on **Vercel** with the `build.sh` script included in the codebase:
1. Ensure your framework preset on Vercel is set to **Other**.
2. Build command: `bash build.sh`
3. Output Directory: `build/web`
4. Install Command: Make this inherently block (e.g., `echo "skip"` or handled via `build.sh`).

---

## 🛠 Technical Notes

### Vertical Grid Path
Each `FoodItem` falls over a **fixed 9-step `List<GridPos>`** dropping from index 0 straight to 8.

```text
index  0 → GridPos(col, 0)  SPAWN & STARTING POINT
index  1 → GridPos(col, 1)
index  2 → GridPos(col, 2)
index  3 → GridPos(col, 3)
index  4 → GridPos(col, 4)
index  5 → GridPos(col, 5)
index  6 → GridPos(col, 6)
index  7 → GridPos(col, 7)
index  8 → GridPos(col, 8)  CATCH POINT (last index)
```

> **Collision is checked at index 8 only.** If `chefPosition == food.column` at that single frame → catch is awarded. Any other frame or column → ignored resulting in a miss. This is intentional: it forces the player to *commit* to a position, not just hover blindly.

*(Note: The retro cat element from the original game has been cleanly disabled via `#catActive = false` to preserve the visual flow of purely top-to-bottom gravity mechanics.)*

### Speed Scaling
```dart
// Game A
baseMs    = 480 
reduction = (score ~/ 10) * 12
minMs     = 180

// Game B
baseMs    = 350
reduction = (score ~/ 10) * 12
minMs     = 120

duration  = max(minMs, baseMs - reduction)
```

---

## 📦 Dependencies

| Package | Version | Purpose |
|---|---|---|
| `provider` | `^6.x` | State management (`ChangeNotifier`) |

No audio packages. No game engines. No image assets.

---

## 🙏 Credits

- Inspired by Nintendo's *Game & Watch: Chef* (1981, Wide Screen series)
- Built as a Flutter architecture exercise showcasing pure Dart performance.

---

## 📄 License

MIT — see [LICENSE](LICENSE) for details.
