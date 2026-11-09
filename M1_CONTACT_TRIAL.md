# Contact trial with the user-supplied replacement module

The supplied pasted text replaced only the native-M1 contact trial module inside AOTR_m1_contact_trial.lua. Its incomplete trailing dispatcher comment was excluded; the existing full dispatcher and the rest of the trial script were preserved. The trial loader is pinned to the updated script commit.

## Supplied behavior

- Primary contact stays at nine studs, with height two and rear offset four.
- Secondary selection expands from 14 to 175 studs.
- After a native M1, the primary target is explicitly registered even with Multi Hit OFF.
- With Multi Hit ON, up to ten distinct eligible Titans are registered from the first contact input; the previous observed-HP gate is removed.
- The dispatcher window starts after the native input helper returns.
- Errors are reported as warnings without automatically turning Multi Hit OFF. Existing pending-batch locks still prevent repeated unresolved requests.
- Auto Skill still defaults to OFF.
- The normal rollback script and loader remain separate.

## Limits

The panel wording "175 stud splash" comes from the supplied module. It describes a local target-selection radius, not a verified server-side splash mechanic. Native M1 may already register a hit, so an additional primary registration is not proof of an additional accepted damage hit.

Observed HP loss and zero-HP events are distinct from input and request counts. Multiplayer damage or the existing automatic escape behavior can affect observed HP.

Despite the heading "fixed for Multi-Hit & Multi-Instance", the supplied block does not add a global singleton guard against multiple copies running in the same client. Its busy flags coordinate workers within one script instance.

## Local verification

The combined script compiles. Mocked tests passed for close primary contact, primary registration while OFF, first-input Multi Hit, inclusive 175-stud selection, exclusion beyond 175, ten distinct concurrent targets after one native input, HP accounting without fabricated damage, blocked input, fresh dispatch timing, warning-only errors, pending-response locks, death release, and WIP guards. The actual virtual-input helper's press/release and cleanup checks also passed.

These tests do not establish live hit acceptance, 175-stud splash damage, a speedup, or same-client multi-instance safety.

Rejoin before running the updated trial loader. Show the distance/HP panel and actual Titan health when testing. The normal loader still uses the rollback script.
