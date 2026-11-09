# Restored combat release

The active script is the accepted combat baseline from e6cc271976580f6878dc848a4443d0ff8ab6cc3a, with only the Multi Hit default changed to ON at the user's explicit request. Auto Skill remains OFF.

The original movement, target selector, ordinary attack payload/pacing, M1 input implementation, skill implementation, and full-refill check are preserved. Later contact-trial, aiming, expanded-range, adjustable target-count, and faster-cadence changes are not part of the active script.

Both current loader.lua and loader_m1_contact_trial.lua point to the same restored AOTR_maintenance.lua commit. The former trial entry point is now a compatibility alias. Historical pinned URLs still load their historical versions.

Rejoin before using the newly supplied loader to stop old workers. Multi Hit starts ON and its existing Mission toggle can turn it OFF. Auto Skill starts OFF.

Verified: exact source comparison against the accepted baseline, allowing only the Multi Hit default/comment changes, complete-script syntax compilation, and GitHub readback. No new live-game multi-hit success or speedup is claimed.
