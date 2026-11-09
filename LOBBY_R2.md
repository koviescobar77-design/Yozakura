# Yozakura Lobby R2 — Play and Auto Start

R2 adds a Play tab to the R1 lobby hub. The mission combat file is unchanged.

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
