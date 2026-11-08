# OP multi-hit timing trial

The previous OP proximity, routing, skill, and performance changes were reverted after the user reported a regression. Movement, target switching, skills, refill, menu, and settings match the version at script commit 44bb3c1ef35f2950e22f12e43392fb01a1a75847.

## Current change

Only the OP hit-registration path uses the new timing trial. One script-generated M1 is followed by up to five distinct Titan registration requests. Each request starts without waiting for the preceding server reply. There is one request per Humanoid, no extra M1 per target, and no automatic duplicate retry.

A new batch cannot overlap an unresolved one. Requests that exceed the two-second response wait keep the batch locked until their replies return; the worker reports the timeout instead of resending. The in-flight counter includes all outstanding calls.

The WIP M1 body retains its previous behavior. A pending OP batch must finish before a mode handoff can issue another attack.

No hit range, movement offset, target-switch policy, skill input method, or refill behavior was changed by this trial.

## What passed locally

- Full-script syntax compilation.
- Cooperative coroutine tests showing five distinct requests begin before the first response, after one M1 input.
- Duplicate-target prevention, different response latencies, balanced in-flight tracking, errors, timeout locking, no repeated unresolved requests, cancellation, and mode handoff.
- HP report test: five replies with only one observed health decrease still report HP drops 1/5.
- Source comparisons confirming the pre-regression movement/targeting, skills, refill, menu, settings, and legacy WIP M1 code were restored/preserved.

These tests use fake Roblox objects. They do not establish five accepted damage hits or faster mission completion in the live game.

## In-game test

1. Rejoin to stop older scripts, then use the pinned loader supplied in chat.
2. Enable OP Farm. Compare movement and skill behavior with the version before the reverted optimization.
3. Near five living Titans, press **Test 1 M1 / 5 Titans**. Avoid manual attacks during its observation window.
4. Record the persistent result: **ONE M1 | requests .../5 | HP drops .../5**, along with each target's before/after HP and the actual fight.
5. Five replies are not five hits. HP decreases are observed replicated values and can include other players' damage. Disappearance alone is never counted as damage.
6. If requests are 5/5 but HP drops remain 1/5, this timing trial has not demonstrated working five-target damage. Server validation and live combat behavior remain unresolved.

For speed comparisons, use the same mission, difficulty, loadout, and party conditions and compare completed mission result times. No live speedup or five-target M1 success has been verified.
