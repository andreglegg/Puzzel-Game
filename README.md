# Corona Puzzle & Level Editor Suite

This repository contains two Solar2D (Corona SDK) applications that ship together:

- `Puzzle/` — the player-facing puzzle game.
- `Puzzle Map Makers/` — the companion level editor for creating and exporting stages.

Both follow a mirrored layout so gameplay and tooling stay in sync during development.

## Project Layout

```text
Puzzle/
  app/
    backgrounds/      -- Shared background helpers (e.g. deep_dark)
    scenes/           -- Composer scenes (splash, menu, game, reload, thankyou)
    ui/               -- Reusable UI widgets (e.g. popout_menu)
  images/             -- Game artwork and sprites
  levels/             -- Lua level definitions (`levelN.lua`)
  libs/               -- Shared utility libraries (app5iveLib, screen, stopwatch, etc.)
  particles/          -- Particle definitions + loader
  sounds/             -- Audio assets
  main.lua            -- Entry point (bootstraps Composer)
  config.lua          -- Solar2D configuration
  build.settings      -- Build metadata

Puzzle Map Makers/
  app/
    scenes/           -- Level editor composer scene
  images/             -- Editor artwork
  levels/             -- Saved/editor reference levels
  libs/               -- Editor-specific utility libraries
  main.lua            -- Entry point for the map editor
  config.lua
  build.settings
```

## Running the Apps

1. Install the latest [Solar2D](https://solar2d.com/download.php) build.
2. Open the Solar2D Simulator and choose `File → Open...`.
3. Select `Puzzle/main.lua` to run the game, or `Puzzle Map Makers/main.lua` to launch the editor.

## Coding Guidelines

- Prefer modules under `app/` for gameplay/editor logic; reserve top-level folders for assets.
- Use Composer scene modules for screens (`app/scenes/...`). Keep shared helpers in `app/backgrounds`, `app/ui`, or `libs`.
- Require scenes via `local scenes = require("app.scene_names")` to centralize navigation targets.
- Track timers and transitions explicitly and cancel them in `scene:hide`/`scene:destroy` to avoid stray callbacks.
- Keep new assets inside the relevant `images/`, `sounds/`, or `particles/` folder to simplify packaging.

## Preparing for Version Control

A `.gitignore` is included to filter out editor caches, artifacts, and compiled Lua chunks. Before your first commit:

```bash
git init
git add .
git commit -m "Initial import"
```

## Future Improvements

- Extract common constants (colors, fonts) into a shared module beneath `app/`.
- Add automated sanity scripts (e.g., LuaCheck) once a Lua toolchain is available locally.
- Write end-to-end smoke tests for the editor to validate level exports against the game loader.

