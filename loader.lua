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
    local source = game:HttpGet("https://raw.githubusercontent.com/koviescobar77-design/Yozakura/c6dc0f76fbd1127667ddc34c536050107e4e609f/AOTR_maintenance.lua")
    assert(type(source) == "string" and #source > 0, "Empty download")
    local chunk, compileError = loadstring(source, "@Yozakura/AOTR_maintenance.lua")
    assert(chunk, compileError)
    report("Starting script. Mission objects must be available; startup can take several minutes.")
    chunk()
    report("Initialization finished. Game features are not verified.")
end, function(message)
    return tostring(message)
end)
if not ok then
    report("Startup failed:\n" .. tostring(err))
    warn("[Yozakura] " .. tostring(err))
end
