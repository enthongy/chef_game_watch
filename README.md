# 🍳 Game & Watch: Chef

A faithful Flutter recreation of Nintendo's 1981 *Game & Watch: Chef* — the wide-screen LCD handheld — built entirely with pure Flutter (no game engines, no external assets).

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)
![Platform](https://img.shields.io/badge/Platform-Windows-0078D6?logo=windows)
![License](https://img.shields.io/badge/License-MIT-green)

---

## 📺 Preview

> The game renders a dark-navy handheld shell with a gold brushed-metal bezel around a `#94A88E` olive-green LCD panel — straight out of 1981.

**LCD Ghost Effect** — every possible sprite position is always visible at 5% opacity, just like a real LCD display. Active sprites render at 90% opacity in solid black.

---

## 🎮 Gameplay

Help the chef keep his pancakes in the air! Food items arc upward in discrete "ticks" and must be caught on the way back down.

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
| `‹` `›` | Move chef left / right (mouse or touch) |
| **GAME A** | Start Game A |
| **GAME B** | Start Game B |
| **START** (▶) | Return to menu after Game Over |


### Rules
- Each caught pancake = **+1 point**
- Miss a pancake = **−1 life** (4 lives total, shown as MISS diamonds)
- At **200** and **500** points — all MISS markers clear (bonus lives)
- Speed increases every **10 points**
- Occasionally a **cat** appears at the edge and holds your food in mid-air for 2 extra ticks

---

## ✨ Features

### Physics
- **Discrete parabolic arcs** — food follows a predefined `List<GridPos>` path, one step per game tick. No interpolation, no tweening — authentic LCD feel.
- **Game tick counter** — a single `Timer.periodic` drives everything; all objects subscribe to the same clock.

### Visuals
- **LCD ghost layer** — `CustomPaint` renders all 27 possible food positions (3 cols × 9 rows) + 3 chef positions at `opacity: 0.05` at all times.
- **Active sprite layer** — current state painted at `opacity: 0.90`.
- **Brushed-metal bezel** — 5-stop gold `LinearGradient` wrapping the screen.
- **Seven-segment score display** — segments A–G drawn as rounded `RRect`s; ghost segments at 7% opacity.
- **Neumorphic buttons** — dual `BoxShadow` (light top-left / dark bottom-right) with press animation (`scale: 0.95`, 80 ms). State held in `_pressed: bool` inside `_NeumorphicButtonState`.
- **Cat sprite** — appears randomly on the left or right edge (1.5% chance per tick), drawn with `CustomPaint` (no assets). Vanishes after ~8% chance per tick.

### Sound
- **Native Windows Beep** via `dart:ffi` → `kernel32.dll Beep()`, fired in an `Isolate` so the UI is never blocked.
- No audio files, no packages — 100% self-contained.
- **Platform-safe:** `audio_service.dart` guards every call with `if (!defaultTargetPlatform.isWindows) return` — the game runs silently (no crash) on Android, iOS, or Web.

| Event | Sound |
|---|---|
| Catch | Two ascending blips (880 Hz → 1175 Hz) |
| Miss | Descending buzz (300 Hz → 220 Hz) |
| Game Over | Three descending tones |
| Bonus (200/500 pts) | Four-note ascending fanfare |

### Architecture
```
ChangeNotifierProvider<GameLogic>
└── ChefGameScreen
    └── Stack
        ├── _GhostLayerPainter   (CustomPaint — opacity 0.05)
        ├── _ActiveLayerPainter  (CustomPaint — opacity 0.90)
        └── Overlay              (Menu / Game Over card)
```

---

## 🗂 Project Structure

```
lib/
├── main.dart              # App entry — ChangeNotifierProvider root
├── game_logic.dart        # GameLogic (ChangeNotifier), FoodItem, GridPos,
│                          #   arc paths, cat mechanic, Game A/B modes
├── chef_game_screen.dart  # Full UI: device shell, LCD layers, seven-segment
│                          #   score, neumorphic controls, overlays
└── audio_service.dart     # FFI wrapper for Windows Beep — no packages needed
```

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK `≥ 3.0`
- Windows 10/11 (for sound; visuals work on all platforms)

### Run

> ⚠️ **Windows path note:** Flutter's CMake build rejects paths containing `&` or other shell-special characters.
> **Recommended:** clone this repo to a plain path like `C:\chef_game_watch` to avoid the issue entirely.
> If your path already contains `&` (e.g. `Game & Watch Chef`), use the workaround below:


```powershell
# One-time setup
flutter create C:\GameWatchChef --project-name game_watch_chef --platforms=windows
Copy-Item "<repo>\lib\*" C:\GameWatchChef\lib\ -Force
Copy-Item "<repo>\pubspec.yaml" C:\GameWatchChef\pubspec.yaml -Force

cd C:\GameWatchChef
flutter pub get
flutter run -d windows
```

After that, sync changes with:
```powershell
Copy-Item "<repo>\lib\*" C:\GameWatchChef\lib\ -Force
# hot-reload or re-run
```

### Build (release)
```powershell
cd C:\GameWatchChef
flutter build windows --release
# Output: build\windows\x64\runner\Release\
```

---

## 🛠 Technical Notes

### Discrete Arc Path
Each `FoodItem` walks a **fixed 16-step `List<GridPos>`** — twice the resolution of a naive 8-step arc, so each visual jump is half the size.

```
index  0 → GridPos(col, 7)  launch (near bottom)
index  1 → GridPos(col, 6)
index  2 → GridPos(col, 5)
index  3 → GridPos(col, 4)
index  4 → GridPos(col, 3)
index  5 → GridPos(col, 2)
index  6 → GridPos(col, 1)
index  7 → GridPos(col, 0)  PEAK  ← cat holds here (catHoldRemaining = 2)
index  8 → GridPos(col, 1)
index  9 → GridPos(col, 2)
index 10 → GridPos(col, 3)
index 11 → GridPos(col, 4)
index 12 → GridPos(col, 5)
index 13 → GridPos(col, 6)
index 14 → GridPos(col, 7)
index 15 → GridPos(col, 8)  CATCH POINT (last index)
```

> **Collision is checked at index 15 only.** If `chefPosition == food.column` at that single frame → catch. Any other frame → ignored. This is intentional: it forces the player to *commit* to a position, not just hover.

The cat holds food at the peak (index 7) for `catHoldRemaining = 2` extra ticks, disrupting the player's rhythm.

### Speed Scaling
```dart
// Game A
baseMs    = 240   // was 480 before 16-step path
reduction = (score ~/ 10) * 6
minMs     = 90

// Game B
baseMs    = 175
reduction = (score ~/ 10) * 6
minMs     = 60

duration  = max(minMs, baseMs - reduction)
```
Tick speed is halved vs. the original 8-step design — real-time pace stays the same, but food moves through twice as many intermediate positions.

### Sound (FFI)
```dart
// Runs on a background Isolate — UI thread never blocked
await Isolate.run(() {
  final beep = DynamicLibrary.open('kernel32.dll')
      .lookupFunction<...>('Beep');
  beep(frequency, durationMs);
});
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
- Built as a Flutter architecture exercise in pure Dart
- Sound via Windows `kernel32.dll Beep()` — channelling the original piezo buzzer

---

## 📄 License

MIT — see [LICENSE](LICENSE) for details.
