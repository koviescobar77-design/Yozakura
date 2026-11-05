-- Yozakura loader. Runtime compatibility remains unverified.
local player = game:GetService("Players").LocalPlayer
assert(player, "Yozakura requires a local player")
local playerGui = player:WaitForChild("PlayerGui", 15)
assert(playerGui, "PlayerGui did not load")
local old = playerGui:FindFirstChild("YozakuraLoaderStatus")
if old then old:Destroy() end
local gui = Instance.new("ScreenGui")
gui.Name = "YozakuraLoaderStatus"
gui.ResetOnSpawn = false
gui.DisplayOrder = 1000
gui.Parent = playerGui
local status = Instance.new("TextLabel")
status.Size = UDim2.new(0.85, 0, 0, 140)
status.Position = UDim2.new(0.075, 0, 0.05, 0)
status.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
status.TextColor3 = Color3.new(1, 1, 1)
status.TextSize = 16
status.TextWrapped = true
status.Parent = gui
local function report(message)
    status.Text = "Yozakura — diagnostic revision 9\n" .. tostring(message)
    print("[Yozakura] " .. tostring(message))
end
report("Downloading script...")
local ok, err = xpcall(function()
    assert(type(loadstring) == "function", "This environment does not provide loadstring")
    local source = game:HttpGet("https://raw.githubusercontent.com/koviescobar77-design/Yozakura/3ba135aab478050ed2709886324c5ddcc14313d6/AOTR_maintenance.lua")
    assert(type(source) == "string" and #source > 0, "Empty download")
    local chunk, compileError = loadstring(source, "@Yozakura/AOTR_maintenance.lua")
    assert(chunk, compileError)
    report("Starting script. Mission objects must be available; startup can take several minutes.")
    chunk()
    report("Initialization finished. Game features are not verified.")
    task.delay(5, function() gui:Destroy() end)
end, function(message)
    return tostring(message)
end)
if not ok then
    report("Startup failed:\n" .. tostring(err))
    warn("[Yozakura] " .. tostring(err))
end
