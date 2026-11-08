# OP Farm: observed-performance test

This revision changes the OP Farm branch. Existing WIP target selection, M1 input, skill input, refill, menu, and settings remain on their existing paths.

## What changed

- OP approaches the selected weak point at 6 studs above its position, with the existing rear offset, instead of hovering 40–75 studs above it (195 for the previous boss offset). In-game collision and boss positioning still need testing.
- OP registers only living targets within a local 35-stud proximity gate, up to five distinct targets after one M1 input. This gate does not override or establish the server's accepted hit range.
- The next M1 is scheduled from the start of the preceding attack at the existing 0.4-second interval. Network response time is not followed by another full 0.4-second pause.
- A health-confirmed death immediately releases the selected target. OP tries another target after 2.5 seconds without health progress, or four seconds without approach progress, when an alternative exists.
- Secondary targets with three request windows without observed HP loss receive a two-second request backoff. A returned request is never counted as damage.
- OP skills prefer key input on desktop and an unobstructed icon click on touch. There is one fallback method. A cooldown transition is reported separately from an unconfirmed input. Failed attempts retry after 1, 2, 4, then 8 seconds while M1 continues.
- Ready skills get the next input opportunity after an in-flight registration returns. M1 and skill input do not run together.

## What is verified

The complete script compiles under a Lua 5.4 syntax check. Mocked behavior tests passed for proximity, distinct targets, attack cadence, replicated-health accounting, death and stalled-target switching, secondary backoff, skill priority, desktop/touch fallback, cooldown feedback, bounded retry, cleanup, result retention, and WIP guards. Source comparisons verified the legacy target/M1/skill bodies and refill/menu/settings code were preserved.

These are local tests with fake Roblox objects. They do not verify server acceptance, more damage, faster kills, faster missions, actual skill activation, or correct live boss positioning.

The supplied 28-second reference clip shows multiple floating numbers. It does not expose per-target HP or a completed mission comparison, so it cannot establish independent accepted damage hits or a mission speedup.

## Read the panel accurately

- **Observed HP loss**: decreases observed on engaged Titans' Humanoids. This can include damage from other players.
- **HP-confirmed deaths**: engaged Humanoids observed reaching zero HP. Disappearance alone is not counted.
- **Mean engagement**: time from our first input/request attempt involving that Titan until its observed zero HP. This is not a controlled, attributed time-to-kill measurement.
- **Last window**: distinct candidate targets with an observed HP decrease during the attack observation window. This can overlap a skill or another player's damage; it is not proof that one M1 caused every decrease.
- **Skill cooldowns**: cooldown transitions observed after input, not confirmed skill damage.
- **OP elapsed**: local OP-session time, not the game's mission timer.
- **Result time**: copied only if the visible Rewards UI has one unique HH:MM:SS value. Otherwise use the game's result screen.

No cosmetic floating damage numbers are created.

## Compare before and after in game

1. Rejoin before each run so only one script version is active.
2. Baseline loader: https://raw.githubusercontent.com/koviescobar77-design/Yozakura/7902bad0ab114a953a10d76c313a2eb934d716c5/loader.lua
3. For the new version, use the pinned loader supplied in chat. Enable OP Farm with the same Auto Skill setting used in the baseline.
4. Keep mission, difficulty, modifiers, loadout, and party conditions the same. Prefer solo runs to reduce damage attribution uncertainty.
5. Alternate baseline/new for three runs each if practical. Record the game's mission time, completion, kills, deaths, refills, and the OP panel. Do not compare different mission sizes or incomplete runs.
6. For attack behavior, record several seconds with the Titans and OP panel visible. Actual HP drops and observed deaths matter; request counts and floating numbers do not establish damage.
7. Report any skill input without cooldown feedback, approach/collision problem, repeated stalled-target switch, or refill pause. Include the final result screen.

Only call the new version faster if comparable completed missions and engagement observations improve. Valid five-target M1 damage remains unverified until demonstrated in game.
