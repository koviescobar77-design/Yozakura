# WIP targeting and travel update

The active script builds on the restored combat baseline. This update applies to the **WIP Autofarm** button, as confirmed by the user. Multi Hit still defaults ON and Auto Skill defaults OFF. OP's restored multi-hit dispatcher, attack payload, M1 input and timing are unchanged.

WIP now resolves the current boss Marker.Adornee directly and validates that it belongs to a living Titan. Regular Titans use their Nape. Missing or invalid boss markers pause targeting until a valid weakness appears; they do not fall back to an unrelated limb. A dead or removed boss no longer prevents regular Titan selection.

Movement re-evaluates WIP targeting every 50 ms and refreshes level facing toward the weakness. Travel speed remains distance * 5 within 40 studs of the existing hover destination. Farther away it increases continuously, capped at 750 instead of 500. The existing hover offsets and movement forces remain; WIP applies boss hover height only to the selected boss.

During WIP attack cooldowns, validity is polled every 20 ms so dead Titans and old boss weaknesses release promptly. Retargeting preserves the 0.4-second registration cooldown. Already pending server calls still have to return. This change does not modify attack payload values or add damage numbers.

Verified locally: full-script syntax compilation with Lua 5.4; mocked target selection, marker changes, invalid/removed targets, cooldown cancellation and preservation, travel bounds, and OP isolation; existing OP dispatch/toggle/error/timeout regression checks. Mocked tests do not establish live Roblox damage or physics behavior.

Live testing is still required: rejoin, load the new loader, enable WIP Autofarm, and compare Titan HP, hits per kill, transition time, and mission time using the same gear and mission. One-hit kills, live movement speed and server-accepted multi-hit damage are not verified. Multi Hit remains the existing OP-only feature.

Both current loader entry points load the same AOTR_maintenance.lua version. Historical pinned loaders continue loading their historical versions. The retired contact trial has not been re-enabled.
