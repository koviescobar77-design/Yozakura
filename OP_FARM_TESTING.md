# Multi Hit and WIP validation

The current main/loader.lua loads the existing Lobby/Mission router. Its isolated mission module now routes Multi Hit through the same worker in **WIP Autofarm and OP Autofarm**. Previously three OP-only gates bypassed Multi Hit in WIP, even while the toggle was ON.

One automatic M1 can dispatch at most ten distinct Titan registrations. Regular Titans use their Nape; bosses use their current valid Marker.Adornee. Weakness, range, target health, mode, refill state and character identity are rechecked before queued requests run. Each Humanoid is requested at most once per M1. A missing or invalid boss marker does not fall back to the nape.

The cap is ten, not a guaranteed minimum: if only two valid Titans are nearby, only those two are requested. Existing range and attack payload values are preserved. No extra M1 inputs, cosmetic damage numbers or retries of unresolved requests are added. The ordinary input loop yields ownership while Multi Hit is enabled, running or pending. A shared native input cooldown prevents rapid toggle changes from creating a second click immediately.

Multi Hit defaults ON; Auto Skill defaults OFF. The earlier WIP travel and current-weakness tracking changes remain. Existing lobby modules and mission lifecycle are preserved. The historical maintenance and contact-trial loaders are separate entry points; use main/loader.lua for this release.

Verified: full isolated-script syntax compilation with Lua 5.4; mocked single-M1 dispatch to five and ten distinct targets in both modes; ten-target cap and fewer available targets; fresh boss markers; queued-task cancellation; deduplication; error and timeout recovery; shared mouse-input cooldown; WIP movement regression checks; exact GitHub readback through the published loader/router/mission chain.

Not verified: live Roblox damage acceptance, five-to-ten actual HP reductions attributable to one attack, one-hit kills, or improved mission time. Successful RPC replies and mock tests are not proof of server damage.

Live check: rejoin first, run main/loader.lua, enable WIP or OP Autofarm with Multi Hit ON, and compare actual Titan HP and kills with at least five nearby living Titans. Keep the same gear and mission when comparing completion time. If only one HP bar decreases, report that as one observed damaged Titan even if ten requests were dispatched.
