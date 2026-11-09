# Yozakura Lobby R1 — test build

This adds a separate lobby hub and a router. Use loader_lobby_mission.lua after rejoining, instead of running it alongside an older loader.

## Included

- Rounded dark Yozakura UI, green toggles, draggable header, scaled panel, Hide / Close, Save Setup, Pause, and Scan UI.
- Lobby detection requires four visible top-bar labels. Mission detection requires the existing workspace.Titans and visible Interface.HUD.Main.Top.Blade.Sets. Conflicting evidence waits; slot menus wait for Gear Up.
- Quest categories, battlepass and achievement claim workers.
- Individual gear upgrade selections and custom exact stat names.
- Offense / Defense / Support skill plans, upgraded in order. Offense starts with the two user-supplied targets: Drill Thrust and Offense Capstone.
- All 14 requested perks have separate Upgrade and Equip selectors. Select at most one perk per category for automatic equip; multi-slot replacement needs actual slot mapping.
- Gold / Luck / EXP booster selections; consumption requires readable active status. An active timer must be observed before another booster can be consumed.
- Legendary / Mythic and spin filters for Gems, Pumpkins and Shards. Each currency has its own session spending cap, initially zero. Market automation is disarmed on every script load.
- Visible stock scanning, one Swap per market pass, strict price/currency/balance checks. Random crates are not treated as guaranteed rarity purchases.
- One worker serializes UI actions. Cancellation is checked before input. Uncertain results are held instead of retried. Reset Holds is available only while paused; it retains the session spending counters.
- The mission copy uses the exact source referenced by the user's supplied loader (053433c7b022978eb3b6fbd1db487c077ec3c5b7), removes its slot-menu router, and adds lifecycle tracking and a mode check before remote dispatch. It tracks all 42 event subscriptions and task/coroutine workers. The new router owns teleport queuing.

## Setup and test

1. Rejoin to stop older executor workers. Run the new loader in Gear Up.
2. Pick one task initially, open that game page, and press Start. Status shows the exact missing button or panel when detection cannot resolve it.
3. For market purchases, select currencies and rarity/spins, set a nonzero budget, and enable Auto Buy. A dispatched purchase reserves its cost even if its result is uncertain.
4. Save Setup if desired. Automatic resume is optional. Purchases always need enabling again after a new load.
5. If an action is blocked, pause and open the relevant game panel, then press Scan UI. It writes YozakuraLobby_UI_scan.json if file APIs are available, copies the scan if clipboard is available, and prints it.
6. Start a mission using the game's normal controls. The router should show only the mission hub there. If the environment has no teleport queue API, run the loader again after the teleport.

## Known mapping limits

No live AOTR or Studio session was connected during development. UI names and descriptions supplied by the user do not establish actual instance paths, skill dependencies, image IDs, remote payloads, or purchase confirmations.

The UI adapter sends real input to uniquely identified visible buttons. These workers are implemented, but their compatibility with AOTR's current UI is **not verified**. Opaque panel names, icon-only achievements, icon-only currency prices, virtualized offscreen rows, and confirmation dialogs can require additional mapping. This build does not auto-confirm an unidentified purchase or choose an unidentified equipment slot.

The complete skill tree is not available: locked Drill Thrust will pause until the exact prerequisite names are added to the selected plan. This build does not claim to automatically discover a full path to capstone. A scan of the Skills page is needed to finish that mapping. Only displayed/unlocked nodes can be selected.

Crate rarity lists and pity numbers are descriptions of possible outcomes, not the rarity of a guaranteed direct purchase. The named Scout Fashion / Anime All-Stars / Blade Burst crate offers are excluded. The Waves shard shop must be accessible in the lobby UI; this does not launch Waves to reach it.

Mode changes within one client shut down the mission copy. Starting another mission within the same client after shutdown requires rejoining; ordinary place teleports create a fresh router. Already-dispatched server requests cannot be withdrawn.

## Verification

- All four Lua files compiled with Lua 5.4 through lupa; additionally parsed with luaparse.
- Offline tests exercised mode decisions, number parsing, ordered skill plans, rarity/currency selection, budget limits, unknown balances, Robux/crate rejection, full lobby UI construction, duplicate action holds, uncertain result holds, ambiguous buttons, mission input cancellation and Close.
- No live game upgrade, claim, potion consumption, purchase, mission transition, damage, or multi-hit result has been verified.

Run the offline checks with Python + lupa: python tests/test_lobby.py.
