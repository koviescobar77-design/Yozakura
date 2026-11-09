# Yozakura Lobby R2 — Play and Auto Start

R2 adds a Play tab to the R1 lobby hub. The current main/loader.lua uses separate lobby and mission sessions.

## Lobby / mission switching

Only the lobby module runs with confirmed lobby UI. Only the isolated Titan mission module runs with confirmed mission UI. Unknown, conflicting, menu and teleport states stop the active session before another module is started. The new mode must stay confirmed for two seconds before startup.

Each launch owns its own cleanup hooks and workers. Mode changes during downloads discard the stale launch; an old completion or error cannot stop a newer session. Returning to the lobby and entering another mission can start fresh modules again. Failed initialization cleans up and retries after five seconds while the same mode remains confirmed.

Lobby cleanup removes its UI and subscriptions and cancels its worker. Mission cleanup also handles partial initialization, removes its UI, cancels workers, blocks movement/native input outside mission, and releases held refill or skill keys. The existing Multi Hit logic and lobby features remain.

Rejoin before using the updated loader to stop previously loaded revisions. The router queues itself across teleport when the executor supports it. Otherwise run main/loader.lua again after teleport.

Offline checks pass for repeated lobby/mission transitions, unknown mode, stale downloads, startup failure/retry, cleanup, input cancellation, existing lobby/launch assertions and Multi Hit regression cases. Live Roblox mode detection and teleport behavior still require testing.

Run the lifecycle checks with Python and the Lua 5.4 shared library:

    python tests/test_router.py
    python tests/test_mission_lifecycle.py

## Controls

- PLAY SELECTED SETUP and Cancel launch / countdown.
- Delay from 0 to 3,600 seconds, counted after the party and modifiers are prepared.
- Missions, Raids and Waves mode buttons.
- Eight mission map buttons: Shiganshina, Trost, Outskirts, Forest, Utgard, Docks, Stohess and Chapel.
- Four raid boss buttons: Attack Titan, Armored Titan, Female Titan and Colossal Titan. The script stops if the game shows a locked choice.
- Difficulty presets from the supplied reference: Easy (E-), Hard (D+), Aberrant (A-) and Aberrant (A). Exact difficulty and grade fields accept other options that the game actually offers. A blank grade accepts the selected difficulty's grade.
- Trost: Default, Skirmish, Protect, Random. Utgard: Default, Skirmish, Defend, Random. Other maps use Default until their objective choices are verified.
- Fourteen modifier toggles, including No Skills, identified in the supplied video as the +3% per-skill modifier. An additional exact-label field supports another modifier.
- Auto Play on lobby load. Select the setup before enabling, then Save Setup to restore it on a later load. Turning it on starts preparation immediately. Cancel stops the current run; turn Auto Play off and save to disable future automatic starts.

## Sequence and verification

The workflow reads Gear Up / Play, selects the mode and content, reads the compound difficulty label, walks the right/left selector, chooses the objective, creates a party, sets modifiers, verifies the party window, counts down, and sends Start once.

The supplied video shows two Start buttons simultaneously: the party modal and its background. R2 scopes Start to the modal containing Players, Leave and Modifiers. It also handles the Waves setup / Create screen shown in the video.

Changing options, Pause, Cancel, a party change or leaving the lobby cancels the countdown. Unknown Create / Start outcomes are held and require inspection before Reset Holds. A dispatched request cannot be withdrawn.

Modifier state must be readable from a boolean selection attribute/value or a named checkmark / ON-OFF indicator. Conflicting or unknown state stops the launch. The video does not expose Roblox instance names, so a live UI scan may still be needed. The unidentified green reward toggle is left for manual selection.

## Testing

- All five Lua files compile with Lua 5.4.
- R1 regression checks pass.
- R2 mocked workflow tests cover all map/boss choices, Waves, objective validation, compound grade labels, selecting a lower difficulty, countdown duration, cancellation, changed party settings, applying and clearing modifiers, locked content, unavailable grades, Create timeout, Start timeout and duplicate suppression.
- Actual UI-adapter tests with a mocked object hierarchy check duplicate Start scoping, difficulty parsing, and OFF / ON / conflicting modifier signals.
- Video frames were inspected for the setup sequence, Waves Create, objective panels, grade format, No Skills label and party-modal Start.
- Live AOTR execution, server acceptance, private UI paths and checkbox mapping remain unverified.

Run tests with Python and lupa:

    python tests/test_lobby.py
    python tests/test_launch.py

Rejoin before loading R2. Select the setup, then press PLAY SELECTED SETUP. If the hub reports an unreadable control, open the relevant game panel and press Scan UI to capture its instance paths and attributes.

## Mission UI startup update

Mission detection now supports visible Blade/Sets counters outside the original exact HUD path. A hidden counter can still identify a mission when the mission HUD, player root and a living Titan's nape are present; lobby or slot-menu evidence blocks this fallback. A Titans folder alone is insufficient.

The loader displays download progress, waiting state and startup errors on screen. The status hides after the selected module initializes. New managed routers can be replaced by running the loader again. Rejoin once when upgrading from the older router, which has no managed Stop method.

The current main and lobby-r1 loader.lua entry points use the same router. The gameplay modules, including Multi Hit, remain unchanged in this startup repair.

Run `python tests/test_router_detection.py` for alternate HUD layouts, hidden-counter detection, mode conflicts, full loader-to-mission startup using a mocked mission module, visible status and managed rerun checks. These tests pass offline; the user's live HUD and executor still require verification.
