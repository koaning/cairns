# Cairns

A PICO-8 stone-stacking puzzle (`pico8/cairns.p8` and `#include`d `.lua`
files), ported from snowstack in `koaning/ps-love2d`.

Notes for agents about this game (the shared toolchain notes are in `AGENTS.md`).

- Code:
  - `pico8/levels.lua` holds the 30 puzzles (7×5 boards: name, fewest moves,
    board string).
  - `pico8/rules.lua` holds the puzzle rules (pure logic, unit-tested in
    `tests/test_rules.lua`).
  - `pico8/main.lua` holds the title + level select, island and stone renderer,
    rolling/stacking animations, undo/restart, in-game menu, devkit keys,
    saves, and sfx/music.
- Levels and solver: changing a level requires its fewest-moves number to match
  the breadth-first solver (`tools/solve.lua`); `tests/test_rules.lua` checks
  and prints the solver's answer for every level. `tools/genlevels.lua`
  searches for random candidate levels (`luajit tools/genlevels.lua [tries] [seed]`)
  to pick and name by hand.
- Sound: `tools/scores.lua` (`first_sfx = 8`): sfx 0-7 are pick up, put down,
  roll, stack, flag, bump, undo, solved; one song (`high moor`) plays
  throughout via `music(0, 0, 3)` on channels 0-1 so sfx keep 2-3.
- Save data: `cartdata("koaning_cairns")` — `dget(0)` is the highest level
  solved, `dget(1..30)` your fewest moves on each level, and `dget(63)` the
  level played last.
- Screenshots: `pico8/preview/shots.lua` uses `tools/solve.lua` (bundled via
  `PREVIEW_EXTRA` in `game.mk`) to capture `pico8-cart.png`, `pico8-title.png`,
  and `pico8.png` (plus `--all` extras).
