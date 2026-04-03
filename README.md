# 👟 Sonic Soccer LCD (Flutter Recreation)

A faithful Flutter recreation of the classic **2003 Sega/McDonald's LCD Handheld games** — specifically a highly addictive custom *Sonic Soccer* edition! 

Built entirely with pure Flutter frontend architecture, this project meticulously replicates the physical aesthetic, visual constraints, synthetic audio, and responsive gameplay of early 2000s promotional fast-food handhelds.

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)
![Platform](https://img.shields.io/badge/Platform-Web%20%7C%20Windows-0078D6?logo=googlechrome)
![License](https://img.shields.io/badge/License-MIT-green)

---

## 📺 Preview

> The game renders a 3D-styled plastic console shell with a beautiful backlit glossy sticker background, matching physical hardware styles!

**True LCD Rendering** — The LCD segments behave identically to real physical hardware:
- **Active Layer:** Solid black sprites mask out the background graphics behind them completely (`BlendMode.srcIn`).
- **Ghost Layer:** All possible non-active LED positional states are drawn simultaneously at a faint 5% opacity.
- **Background Wash:** The vibrant stadium pitch underneath is washed out with a 40% white tint overlay, simulating the glossy backlight glare found on physical liquid crystal displays.

---

## 🎮 Gameplay

Defend against incoming soccer balls! Balls spawn at the top and drop vertically towards the bottom of the screen. Move Sonic horizontally to catch (save) the balls before they reach the goal line!

### ⌨️ Keyboard Controls

| Key(s) | Action |
|---|---|
| `←` &nbsp;/&nbsp; `A` | Move Sonic **left** |
| `→` &nbsp;/&nbsp; `D` | Move Sonic **right** |
| `1` | Start / restart **Game A** (Max 3 balls, normal pace) |
| `2` | Start / restart **Game B** (Max 4 balls, fast pace) |
| `Enter` &nbsp;/&nbsp; `Space` | **Confirm** — start game from menu; return to menu |
| `Esc` | **Menu** — abort current game and return to title |

### 🖱️ On-Screen Buttons

| Button | Action |
|---|---|
| `‹` `›` | Move left/right (instant `onTapDown` triggered for mobile/mouse) |
| **GAME A** | Start Game A |
| **GAME B** | Start Game B |
| **START** | Start game or return to menu |

### Rules
- Each save = **+1 point**.
- Miss a ball = **−1 life** (4 lives total, shown as MISS diamonds in the corner).
- At **200** and **500** points — all MISS markers clear (bonus lives).
- The game speeds up smoothly as your score increases (drops 12ms tick duration every 10 points).

### ⚡ Super Sonic Boost
Every 50 points, the game enters a brief **Super Sonic Boost State**:
- The screen flashes a luminous green/yellow!
- Sonic's sprite turns sky blue and gold!
- **Tick Speed Doubles** for 5 seconds — testing your reaction limits!

---

## ✨ Features

### 🎨 5 Modular Shell Themes
Inspired by the multi-colored McDonald's Happy Meal Sega line, you can dynamically hot-swap the color of your virtual device. Tap the circular swatches at the top of the interface:
1. 🔵 **Sonic Blue** (Navy casing + Red buttons)
2. 🟡 **Tails Yellow** (Bright Yellow casing + Red buttons)
3. 🔴 **Knuckles Red** (Crimson casing + Blue buttons)
4. ⚫ **Shadow Black** (Dark Slate casing + Red buttons)
5. 🟢 **Emerald Green** (Forest Green casing + Red buttons)

### 🔊 16-bit Synthesized Audio
Uses **Web Audio API** (via `dart:js_interop`) and **Windows Kernel Beep API** (`kernel32.dll`) to generate native retro frequency beeps dynamically on the device. No `.mp3` files are used in this repository!
- **Save:** Ascending ring collect (1760 Hz → 2093 Hz).
- **Miss/Goal:** Disappointing low buzz (110 Hz).
- **Movement:** Crisp zip tone (880 Hz).
- **Super Sonic Fanfare:** Arpeggiated melody sequence.

---

## 🗂 Project Structure

```text
lib/
├── main.dart                 # App entry — ChangeNotifierProvider root
├── src/
│   ├── logic/
│   │   └── game_logic.dart           # GameLogic (ChangeNotifier), spawn mechanics
│   ├── ui/
│   │   └── sonic_soccer_screen.dart  # Full UI, Shell styling, rendering stack
│   └── audio/
│       ├── audio_service.dart        # Conditional export bridge (Native vs Web)
│       ├── audio_service_stub.dart   # Web-compatible Audio Synthesizer (dart:js_interop)
│       └── audio_service_native.dart # Desktop-friendly kernel32.dll wrapper
```

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK `≥ 3.0`
- Suitable for Windows Desktop compilation or Flutter Web.

### Web Deployment (Vercel)
If you're looking to run this on **Vercel** with the `build.sh` script included in the codebase:
1. Ensure your framework preset on Vercel is set to **Other**.
2. Build command: `bash build.sh`
3. Output Directory: `build/web`
4. Install Command: Make this inherently block (e.g., `echo "skip"`).

---

## 🙏 Credits

- Inspired by the *Nintendo Game & Watch* series and the *2003 McDonald's Sega LCD toy collection*.
- Built as an architectural UI/UX exercise.

## 📄 License

MIT — see LICENSE for details.
