# Current rollback: restore the previously accepted combat version

The current AOTR_maintenance.lua is restored byte-for-byte to the script from commit e6cc271976580f6878dc848a4443d0ff8ab6cc3a (blob 05c5f38d0bd734aeaa61afcfcfb49802f603507e).

This rollback follows the user's report that the later changes made combat worse. The supplied 22-second clip shows repeated swing effects while the objective remains at 6/41 Titans.

Removed by restoring that version:
- The later expanded Multi Hit range and primary-gate changes.
- Forced weak-point root/gyro aiming and the revised weakness resolver.
- The adjustable 3–10 / 5–10 target-count field.
- The later input-start cadence change.

Restored defaults:
- Multi Hit OFF.
- Auto Skill OFF.
- Original uploaded ordinary attack/M1 behavior, movement, and target selection.
- The full-refill check remains present in this accepted version.

The existing optional Multi Hit toggle remains the older experimental implementation, capped at five attempted distinct targets. Leave it OFF while confirming ordinary combat. Its presence does not establish valid five-target damage.

Rejoin before running the rollback loader. Old workers in an already-running game session are not stopped by changing GitHub files.

Verified: GitHub returned the exact expected restored content blob SHA. No live-game speedup, damage increase, or multi-target success is claimed for this rollback.
