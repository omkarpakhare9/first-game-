# Arena Clash

A simple, original mobile game inspired by the MOBA lane-pusher genre (in the spirit of games
like Mobile Legends: Bang Bang, but with its own characters, art, and code — no copyrighted
assets or IP included).

## Gameplay
- Your hero automatically pushes down the lane toward the enemy tower.
- Enemy minions spawn periodically and block your path — fight them for gold.
- Tap **Power Strike** for a burst of bonus damage (has a cooldown).
- Spend gold on **ATK+** and **HP+** upgrades between fights.
- Destroy the enemy tower to win. If your hero falls, it respawns after a few seconds — no game over.

## Project structure
```
arena_clash/
  pubspec.yaml
  lib/
    main.dart      # entire game: menu, game loop, combat logic, and UI
```

Everything is in a single `main.dart` file with no external game engine or paid packages —
just the Flutter SDK — so it's easy to read and modify.

## How to run it

1. Install the Flutter SDK if you don't have it: https://docs.flutter.dev/get-started/install
2. Unzip/copy this `arena_clash` folder to your machine.
3. From inside the folder, fetch dependencies:
   ```
   flutter pub get
   ```
4. Run on a connected device, emulator, or simulator:
   ```
   flutter run
   ```
   (Use `flutter devices` to see available targets, or `flutter run -d chrome` to try it in a browser.)

> Note: this project only contains `pubspec.yaml` and `lib/main.dart`. If your Flutter install
> needs the platform folders (`android/`, `ios/`, etc.) generated, run `flutter create .` inside
> this folder first (it will add the platform scaffolding without touching `lib/main.dart`).

## Tuning the game
All the balance numbers (hero speed, damage, minion strength, upgrade costs, spawn timing) are
defined as constants/fields near the top of `_GameScreenState` in `lib/main.dart` — tweak those
to make the game faster, harder, or easier.

## Ideas for extending it
- Add a second/third lane with more minions.
- Give the hero a choice of 2-3 original "champions" with different stats and skills.
- Add sound effects and simple sprite animations instead of icons.
- Add local high-score tracking (fastest tower kill, most gold, etc.).
