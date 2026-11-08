# Multi Hit controls and weak-point trial

Ordinary combat remains the restored uploaded attack path. Multi Hit is opt-in for OP Farm, and Auto Skill defaults to OFF.

## Controls

- **Multi Hit**: OFF on each new load; enable it manually with OP Farm.
- **Max targets**: enter a value from 5 to 10. Default 10. Invalid values retain the preceding value and values outside the interval are clamped.
- This is a maximum number of distinct Titans attempted per M1. It is not a guaranteed number of accepted hits, damage numbers, or kills. If only two eligible Titans exist, the script does not invent a third.
- Auto Config does not automatically turn Multi Hit or Auto Skill on.

## Weak points while Multi Hit is ON

Regular Titans use their actual Hitboxes/Hit/Nape part.

For Attack_Titan, the current enabled Marker must identify one of the known hitboxes: Nape, LeftLeg, RightLeg, LeftArm, RightArm, or Eyes. A marker Attachment is resolved to its owning part. Missing, disabled, outside-model, unknown, or same-name body-mesh markers do not trigger a blind nape fallback.

The weak point is refreshed before dispatch and again inside the request worker, then checked for living Humanoid and range. A phase change between selection and registration therefore does not intentionally reuse the old limb.

The character and existing gyro face the primary weak point before M1. While Multi Hit is ON, gyro facing follows the selected weak point instead of the old cached horizontal direction. Flight height, destination, speed, and ordinary-mode facing are unchanged.

This follows the known marker/hitbox structure in the user's script. No external VIP autofarm source was available to reproduce or verify its implementation.

## Range and request limits

Multi Hit selection ranges remain 300 studs for regular Titans and 350 for boss weak points. Ordinary combat retains its prior 175/250 checks.

One M1 input is followed by at most the selected number of distinct Titan requests, up to ten. Each request starts without waiting for the preceding response. There is one request per Humanoid per batch, no overlapping batches, and no automatic resend of unresolved calls.

If a batch errors or times out, Multi Hit switches OFF. Outstanding replies drain before ordinary combat resumes. Registration payload ranges remain those of the uploaded attack worker.

## Multi Hit timing

The existing 0.4-second interval now starts at M1 input, rather than after the final server response. Responses still must drain before another batch starts. No extra attacks are added, and ordinary combat timing is unchanged.

Mocked tests verify that 0.2-second replies permit the next M1 at 0.4 seconds from the first input, instead of adding a new 0.4-second wait after those replies. Replies slower than the interval are allowed to finish first; batches do not overlap. Live kill/mission speed is not established by these local tests.

## What is verified

Passed local syntax checks and mocked tests for:

- Adjustable 5–10 limits, one M1, distinct concurrent requests, and duplicate prevention.
- Current boss marker changes, attachments, disabled markers, and same-name non-hitbox rejection.
- Fresh weak-point selection immediately before registration.
- Aiming without a positional move and ordinary-mode isolation.
- Existing toggle handoff, error fallback, timeout locks, ordinary combat behavior, range boundaries, and target fallback.
- Ten requests with only one simulated HP decrease remaining one damaged target, rather than being counted as ten successful hits.

Source comparisons preserve the ordinary attack, target selector, M1/skill inputs, and full-refill code. The only movement change is facing while OP Multi Hit is ON.

These tests use fake Roblox objects. Live weak-point acceptance, 5–10 actual damage hits, and a mission speedup remain unverified. Local range does not override server validation. No cosmetic damage numbers are generated.

## In-game check

Rejoin before loading the new pinned loader. Verify ordinary combat first with Multi Hit OFF and Auto Skill OFF. Then enable OP Farm and Multi Hit, set Max targets (start at 5 if comparing), and record actual Titan HP/health bars and kills. For a boss, show the active marked weak point and phase changes.

Use the same mission, difficulty, loadout, and party conditions when comparing completed mission result times. Request counts or floating numbers alone do not establish accepted damage.
