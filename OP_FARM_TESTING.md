# Combat restore and optional Multi Hit

The user's original uploaded attack worker, movement, target selection, skill-input implementation, and independent M1 input loop have been restored. The later full-refill check is retained.

## Defaults on every new load

- **Multi Hit: OFF.** Ordinary combat uses the original single-target registration burst and independent M1 loop.
- **Auto Skill: OFF.** Skill inputs are not sent unless the user explicitly enables Auto Skill again.
- Multi Hit and Auto Skill are not restored to ON by Auto Config.

The Mission panel has a separate **Multi Hit** toggle. Enabling it selects the experimental path only while OP Farm is enabled. Disabling it returns to the original combat path once any outstanding multi-hit replies have returned.

## Optional Multi Hit behavior

One M1 input is followed by up to five distinct Titan registration requests. Requests start without waiting for each previous reply. The payload ranges match the original uploaded attack worker. There are no cosmetic floating damage numbers.

One request is allowed per Humanoid in the batch. Batches do not overlap. Unresolved calls are not automatically repeated.

If the experimental path errors or its replies time out, Multi Hit turns OFF automatically. Ordinary combat resumes after outstanding replies return. No other farm mode is switched to Multi Hit.

The previous standalone five-target test overlays/buttons were removed; this control is integrated into the Mission panel.

## Verification and limits

Passed locally: complete-script syntax compilation, restored-code comparisons, ordinary OFF behavior, opt-in OP dispatch, changing modes during an attack, fallback after errors, timeout draining without duplicate calls, and WIP isolation.

These are mocked tests with fake Roblox objects. Actual five-target damage is still unverified. Enabling the toggle enables the experimental code path; it is not a guarantee that the game's server accepts five damage hits.

Rejoin before using the updated loader so older script workers stop. First verify ordinary combat with Multi Hit OFF and Auto Skill OFF. Then enable only Multi Hit and compare actual Titan HP loss and kills. Request counts or floating numbers alone do not establish damage.
