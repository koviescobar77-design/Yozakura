-- Yozakura loader. Runtime compatibility remains unverified.
local player = game:GetService("Players").LocalPlayer
assert(player, "Yozakura requires a local player")
local playerGui = player:WaitForChild("PlayerGui", 15)
assert(playerGui, "PlayerGui did not load")
local old = playerGui:FindFirstChild("YozakuraLoaderStatus")
if old then old:Destroy() end
local function report(message)
    print("[Yozakura] " .. tostring(message))
end
report("Downloading script...")
local ok, err = xpcall(function()
    assert(type(loadstring) == "function", "This environment does not provide loadstring")
    local source = game:HttpGet("https://raw.githubusercontent.com/koviescobar77-design/Yozakura/d56c4907c0c43d181420f67058222e582bcff5f2/loader_lobby_mission.lua")
    assert(type(source) == "string" and #source > 0, "Empty download")
    local chunk, compileError = loadstring(source, "@Yozakura/loader_lobby_mission.lua")
    assert(chunk, compileError)
    report("Starting Lobby R2 / Mission router. Waiting for a recognized game screen.")
    chunk()
    report("Router started. Live game features remain unverified.")
end, function(message)
    return tostring(message)
end)
if not ok then
    report("Startup failed:\n" .. tostring(err))
    warn("[Yozakura] " .. tostring(err))
end
