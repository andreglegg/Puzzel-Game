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

## Developer Tooling

Install the Lua toolchain once (macOS/Linux example):

```bash
brew install lua luarocks          # or use your package manager
luarocks install luacheck --local
luarocks install busted --local
```

Add your local LuaRocks bin directory to the `PATH` (once per shell profile, e.g. `~/.zshrc`):

```bash
export PATH="$HOME/.luarocks/bin:$PATH"
```

Useful helper scripts live under `tools/`:

```bash
./tools/lint.sh           # runs luacheck with repo-wide configuration
./tools/test.sh           # runs busted specs under tests/
./tools/check_assets.sh   # verifies 1x/2x/4x PNG sets (defaults to both projects)
```

Tests currently exercise level metadata to ensure stage definitions load cleanly in both the game and the editor.

## Continuous Integration

A GitHub Actions workflow (`.github/workflows/ci.yml`) runs on every push / pull request. It installs Lua 5.3, Luacheck, and Busted, then executes:

1. `./tools/lint.sh`
2. `./tools/test.sh`
3. `./tools/check_assets.sh`

Keep these scripts green before opening a PR to guarantee basic regressions are caught early.

## Coding Guidelines

- Prefer modules under `app/` for gameplay/editor logic; reserve top-level folders for assets.
- Use Composer scene modules for screens (`app/scenes/...`). Keep shared helpers in `app/backgrounds`, `app/ui`, or `libs`.
- Require scenes via `local scenes = require("app.scene_names")` to centralize navigation targets.
- Track timers and transitions explicitly and cancel them in `scene:hide`/`scene:destroy` to avoid stray callbacks.
- Keep new assets inside the relevant `images/`, `sounds/`, or `particles/` folder to simplify packaging.

## Next Steps

- Extract common constants (colors, fonts) into shared modules under `app/`.
- Expand the Busted suite with behavioural tests (e.g., verifying level progression rules, editor export output).
- Integrate lint/test scripts into pre-commit hooks for faster feedback.
- Explore automated texture packing or compression in the asset check script if the art pipeline grows.
