# Isolated native M1 contact trial

This trial is in AOTR_m1_contact_trial.lua and loader_m1_contact_trial.lua. The normal AOTR_maintenance.lua and loader.lua remain the rollback version. It is a test of actual contact and native M1 input, not a verified copy of a VIP autofarm.

## OP behavior in this trial

- Approach the current known weak point before attacking. The OP destination is two studs above and four studs behind it, rather than the rollback's much larger hover offset.
- Limit approach speed to 180 locally. Use the original proportional velocity control and nocollision behavior.
- Keep gyro facing level. Do not force root CFrame rotation or invent an animation.
- Require the player to be within a local nine-stud contact gate before M1 input.
- One OP worker owns M1. It presses the game's normal mouse input for 50 milliseconds, releases it, and enforces the existing 0.4-second interval. The independent OP autoclick and original ten-request burst are bypassed in this trial.
- Use an enabled, known boss marker hitbox, refreshing it when choosing a target. Regular Titans use their Nape hitbox. Missing active boss markers are not replaced by a guessed nape.
- Release the target after observed zero HP, or try another living target after two seconds of contact attempts without observed HP progress.

Flight height/contact positioning is intentionally different in this test. It still needs live collision, grab, boss-phase, animation, and hit verification.

## Multi Hit and HP feedback

Start with Multi Hit OFF and Auto Skill OFF. The initial OP path sends native M1 input only, without direct scripted Hitboxes/Register calls.

The panel shows distance, native M1 inputs, observed HP loss, and observed zero-HP events. HP changes after an attempted input are observations; in multiplayer, other players or existing automatic escape behavior can contribute. They are not conclusive attribution to our M1.

If Multi Hit is enabled, extra registration requests remain blocked until an HP decrease has been observed after a contact input. Then at most ten distinct nearby weak points within a local 14-stud proximity check are attempted after the same M1. There is no guarantee that enough targets are close together or that the server accepts these extra requests.

No floating damage numbers are created. Target disappearance alone is not counted as a death.

## What passed locally

Full-script syntax checks and mocked tests passed for a reachable contact destination, no far-away native input, one M1 worker and interval, actual input press/release and failure release, focused/covered UI guards, observed HP feedback, gated nearby extra requests, stalled-target selection, death release, and WIP guards.

Roblox was not run here. Live accepted damage, parity with the VIP reference, simultaneous damage to 5–10 Titans, and improved mission times remain unverified.

## Run and record

Rejoin first, then use the pinned trial loader from chat. Enable OP Farm. Leave Auto Skill OFF. First leave Multi Hit OFF and record the panel plus the target's health while approaching and attacking.

Once actual HP decreases are visible, try Multi Hit ON near a group and compare actual health changes. Do not infer success from input counters, registration replies, or floating effects.

Auto Config's queued loader uses the separate contact-trial loader in this file. The normal loader still loads the rollback version.
