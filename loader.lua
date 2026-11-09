-- Yozakura loader. Runtime compatibility remains unverified.
local player = game:GetService("Players").LocalPlayer
assert(player, "Yozakura requires a local player")
local playerGui = player:WaitForChild("PlayerGui", 15)
assert(playerGui, "PlayerGui did not load")
local old = playerGui:FindFirstChild("YozakuraLoaderStatus")
if old then old:Destroy() end
local statusGui = Instance.new("ScreenGui")
statusGui.Name = "YozakuraLoaderStatus"
statusGui.ResetOnSpawn = false
statusGui.DisplayOrder = 10001
statusGui.Parent = playerGui
local statusLabel = Instance.new("TextLabel")
statusLabel.Name = "Status"
statusLabel.Size = UDim2.new(0.8, 0, 0, 64)
statusLabel.Position = UDim2.new(0.1, 0, 1, -100)
statusLabel.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
statusLabel.BackgroundTransparency = 0.15
statusLabel.TextColor3 = Color3.new(1, 1, 1)
statusLabel.Font = Enum.Font.SourceSansBold
statusLabel.TextSize = 18
statusLabel.TextWrapped = true
statusLabel.Parent = statusGui
local function report(message)
    print("[Yozakura] " .. tostring(message))
    statusLabel.Text = "Yozakura · " .. tostring(message)
    statusGui.Enabled = true
end
report("Downloading script...")
local ok, err = xpcall(function()
    assert(type(loadstring) == "function", "This environment does not provide loadstring")
    local source = game:HttpGet("https://raw.githubusercontent.com/koviescobar77-design/Yozakura/75c12b82dafd1ba9cdb2f793719637d6f834ed69/loader_lobby_mission.lua")
    assert(type(source) == "string" and #source > 0, "Empty download")
    local chunk, compileError = loadstring(source, "@Yozakura/loader_lobby_mission.lua")
    assert(chunk, compileError)
    report("Starting Lobby R3 / Mission router. Waiting for a recognized game screen.")
    chunk()
    report("Waiting for lobby or mission UI...")
end, function(message)
    return tostring(message)
end)
if not ok then
    report("Startup failed:\n" .. tostring(err))
    warn("[Yozakura] " .. tostring(err))
end
