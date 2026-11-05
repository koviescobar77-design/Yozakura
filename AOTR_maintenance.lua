-- Yozakura startup revision 5: menu first, optional refill, bounded dependency checks.
-- Maintenance revision: static fixes only; live game compatibility unverified.
if not game:IsLoaded() then game.Loaded:Wait() end
local function waitForValue(label, getter)
    local deadline = os.clock() + 60
    repeat
        local ok, value = pcall(getter)
        if ok and value then return value end
        task.wait(0.5)
    until os.clock() >= deadline
    error("Startup timed out: " .. label .. ". This required object is unavailable in the current session.", 0)
end
local function findPath(parent, names)
    local current = parent
    for _, name in ipairs(names) do
        if not current then return nil end
        current = current:FindFirstChild(name)
    end
    return current
end
local localPlayer = game:GetService("Players").LocalPlayer
assert(localPlayer, "This script requires a local player")
local function findBladeSets()
    local sets = findPath(localPlayer, {"PlayerGui", "Interface", "HUD", "Main", "Top", "Blade", "Sets"})
    if sets and (sets:IsA("TextLabel") or sets:IsA("TextButton") or sets:IsA("TextBox")) then
        return sets
    end
    return nil
end
local function v2(v0, v1, duration) --[[ Line: 67 ]] --[[ Name: 25ms ]]
    local ok, _err = pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = tostring(v0), Text = tostring(v1), Duration = duration or 5
        })
    end)
    if not ok then warn(tostring(v0) .. ": " .. tostring(v1)) end
end;
local v3 = {
    ["1"] = Instance.new("ScreenGui", game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui", 15))
};
v3["1"].DisplayOrder = 999;
v3["1"].Name = "tekkit";
v3["1"].ResetOnSpawn = false;
v3["2"] = Instance.new("Frame", v3["1"]);
v3["2"].BorderSizePixel = 0;
v3["2"].BackgroundColor3 = Color3.fromRGB(0, 0, 0);
v3["2"].Size = UDim2.new(0.3, 0, 0.2955, 0);
v3["2"].Position = UDim2.new(0.62724, 0, 0.30471, 0);
v3["2"].BorderColor3 = Color3.fromRGB(255, 255, 255);
v3["2"].Name = "main";
v3["2"].LayoutOrder = 1;
v3["2"].BackgroundTransparency = 0.25;
v3["3"] = Instance.new("UICorner", v3["2"]);
v3["3"].Name = "corner";
v3["3"].CornerRadius = UDim.new(0, 25);
v3["4"] = Instance.new("Frame", v3["2"]);
v3["4"].BorderSizePixel = 0;
v3["4"].BackgroundColor3 = Color3.fromRGB(255, 255, 255);
v3["4"].Size = UDim2.new(0.73799, 0, 0.88235, 0);
v3["4"].Position = UDim2.new(0.16179, 0, 0.11746, 0);
v3["4"].BorderColor3 = Color3.fromRGB(0, 0, 0);
v3["4"].Name = "mainFrame";
v3["4"].BackgroundTransparency = 1;
v3["5"] = Instance.new("Frame", v3["4"]);
v3["5"].BorderSizePixel = 0;
v3["5"].BackgroundColor3 = Color3.fromRGB(255, 255, 255);
v3["5"].Size = UDim2.new(0.38248, 0, 0.15262, 0);
v3["5"].Position = UDim2.new(0.0459, 0, 0.072, 0);
v3["5"].BorderColor3 = Color3.fromRGB(0, 0, 0);
v3["5"].Name = "esp";
v3["5"].BackgroundTransparency = 1;
v3["6"] = Instance.new("TextLabel", v3["5"]);
v3["6"].TextWrapped = true;
v3["6"].TextStrokeTransparency = 0;
v3["6"].BorderSizePixel = 0;
v3["6"].BackgroundColor3 = Color3.fromRGB(255, 255, 255);
v3["6"].TextSize = 25;
v3["6"].TextScaled = true;
v3["6"].FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal);
v3["6"].TextColor3 = Color3.fromRGB(255, 255, 255);
v3["6"].BackgroundTransparency = 1;
v3["6"].Size = UDim2.new(0.56723, 0, 0.78967, 0);
v3["6"].BorderColor3 = Color3.fromRGB(0, 0, 0);
v3["6"].Text = "Titan ESP";
v3["6"].Name = "espLabel";
v3["6"].Position = UDim2.new(-0.00561, 0, 0.10569, 0);
v3["7"] = Instance.new("ImageButton", v3["6"]);
v3["7"].BorderSizePixel = 0;
v3["7"].ImageTransparency = 1;
v3["7"].BackgroundColor3 = Color3.fromRGB(171, 0, 0);
v3["7"].Image = "rbxasset://textures/ui/GuiImagePlaceholder.png";
v3["7"].Size = UDim2.new(0.32462, 0, 0.9967, 0);
v3["7"].Name = "espToggle";
v3["7"].BorderColor3 = Color3.fromRGB(0, 0, 0);
v3["7"].Position = UDim2.new(1.37873, 0, -0.03528, 0);
v3["8"] = Instance.new("UICorner", v3["7"]);
v3["9"] = Instance.new("UIStroke", v3["5"]);
v3["9"].Thickness = 2;
v3["9"].Color = Color3.fromRGB(255, 255, 255);
v3.a = Instance.new("UICorner", v3["5"]);
v3.b = Instance.new("Frame", v3["4"]);
v3.b.BorderSizePixel = 0;
v3.b.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
v3.b.Size = UDim2.new(0.38248, 0, 0.15262, 0);
v3.b.Position = UDim2.new(0.47236, 0, 0.06967, 0);
v3.b.BorderColor3 = Color3.fromRGB(0, 0, 0);
v3.b.Name = "escape";
v3.b.BackgroundTransparency = 1;
v3.c = Instance.new("TextLabel", v3.b);
v3.c.TextWrapped = true;
v3.c.TextStrokeTransparency = 0;
v3.c.BorderSizePixel = 0;
v3.c.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
v3.c.TextSize = 19;
v3.c.TextScaled = true;
v3.c.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal);
v3.c.TextColor3 = Color3.fromRGB(255, 255, 255);
v3.c.BackgroundTransparency = 1;
v3.c.Size = UDim2.new(0.56802, 0, 0.84626, 0);
v3.c.BorderColor3 = Color3.fromRGB(0, 0, 0);
v3.c.Text = "Auto Grab Escape";
v3.c.Name = "escapeLabel";
v3.c.Position = UDim2.new(0.05649, 0, 0.08425, 0);
v3.d = Instance.new("ImageButton", v3.c);
v3.d.BorderSizePixel = 0;
v3.d.ImageTransparency = 1;
v3.d.BackgroundColor3 = Color3.fromRGB(171, 0, 0);
v3.d.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png";
v3.d.Size = UDim2.new(0.32324, 0, 0.92631, 0);
v3.d.Name = "escapeToggle";
v3.d.BorderColor3 = Color3.fromRGB(0, 0, 0);
v3.d.Position = UDim2.new(1.22011, 0, 0.01145, 0);
v3.e = Instance.new("UICorner", v3.d);
v3.f = Instance.new("UICorner", v3.b);
v3["10"] = Instance.new("UIStroke", v3.b);
v3["10"].Thickness = 2;
v3["10"].Color = Color3.fromRGB(255, 255, 255);
v3["11"] = Instance.new("Frame", v3["4"]);
v3["11"].BorderSizePixel = 0;
v3["11"].BackgroundColor3 = Color3.fromRGB(255, 255, 255);
v3["11"].Size = UDim2.new(0.38248, 0, 0.15262, 0);
v3["11"].Position = UDim2.new(0.472, 0, 0.238, 0);
v3["11"].BorderColor3 = Color3.fromRGB(0, 0, 0);
v3["11"].Name = "refill";
v3["11"].BackgroundTransparency = 1;
v3["12"] = Instance.new("TextLabel", v3["11"]);
v3["12"].TextWrapped = true;
v3["12"].TextStrokeTransparency = 0;
v3["12"].BorderSizePixel = 0;
v3["12"].TextScaled = true;
v3["12"].BackgroundColor3 = Color3.fromRGB(255, 255, 255);
v3["12"].TextSize = 14;
v3["12"].FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal);
v3["12"].TextColor3 = Color3.fromRGB(255, 255, 255);
v3["12"].BackgroundTransparency = 1;
v3["12"].Size = UDim2.new(0.56802, 0, 0.83558, 0);
v3["12"].BorderColor3 = Color3.fromRGB(0, 0, 0);
v3["12"].Text = "Blade Refill";
v3["12"].Name = "refillLabel";
v3["12"].Position = UDim2.new(0.05149, 0, 0.07746, 0);
v3["13"] = Instance.new("ImageButton", v3["12"]);
v3["13"].BorderSizePixel = 0;
v3["13"].ImageTransparency = 1;
v3["13"].BackgroundColor3 = Color3.fromRGB(171, 0, 0);
v3["13"].Image = "rbxasset://textures/ui/GuiImagePlaceholder.png";
v3["13"].Size = UDim2.new(0.32466, 0, 0.9439, 0);
v3["13"].Name = "refillToggle";
v3["13"].BorderColor3 = Color3.fromRGB(0, 0, 0);
v3["13"].Position = UDim2.new(1.22011, 0, -0.00811, 0);
v3["14"] = Instance.new("UICorner", v3["13"]);
v3["15"] = Instance.new("UICorner", v3["11"]);
v3["16"] = Instance.new("UIStroke", v3["11"]);
v3["16"].Thickness = 2;
v3["16"].Color = Color3.fromRGB(255, 255, 255);
v3["17"] = Instance.new("Frame", v3["4"]);
v3["17"].BorderSizePixel = 0;
v3["17"].BackgroundColor3 = Color3.fromRGB(255, 255, 255);
v3["17"].Size = UDim2.new(0.38248, 0, 0.15262, 0);
v3["17"].Position = UDim2.new(0.0459, 0, 0.23556, 0);
v3["17"].BorderColor3 = Color3.fromRGB(0, 0, 0);
v3["17"].Name = "extend";
v3["17"].BackgroundTransparency = 1;
v3["18"] = Instance.new("TextLabel", v3["17"]);
v3["18"].TextWrapped = true;
v3["18"].TextStrokeTransparency = 0;
v3["18"].BorderSizePixel = 0;
v3["18"].BackgroundColor3 = Color3.fromRGB(255, 255, 255);
v3["18"].TextSize = 24;
v3["18"].TextScaled = true;
v3["18"].FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal);
v3["18"].TextColor3 = Color3.fromRGB(255, 255, 255);
v3["18"].BackgroundTransparency = 1;
v3["18"].Size = UDim2.new(0.56702, 0, 0.8005, 0);
v3["18"].BorderColor3 = Color3.fromRGB(0, 0, 0);
v3["18"].Text = "Nape extend";
v3["18"].Name = "extendLabel";
v3["18"].Position = UDim2.new(-5.8E-4, 0, 0.08696, 0);
v3["19"] = Instance.new("ImageButton", v3["18"]);
v3["19"].BorderSizePixel = 0;
v3["19"].ImageTransparency = 1;
v3["19"].BackgroundColor3 = Color3.new(1, 0, 0);
v3["19"].Image = "rbxasset://textures/ui/GuiImagePlaceholder.png";
v3["19"].Size = UDim2.new(0.32461, 0, 0.98326, 0);
v3["19"].Name = "extendToggle";
v3["19"].BorderColor3 = Color3.fromRGB(0, 0, 0);
v3["19"].Position = UDim2.new(1.37877, 0, 0, 0);
v3["1a"] = Instance.new("UICorner", v3["19"]);
v3["1b"] = Instance.new("UICorner", v3["17"]);
v3["1c"] = Instance.new("UIStroke", v3["17"]);
v3["1c"].Thickness = 2;
v3["1c"].Color = Color3.fromRGB(255, 255, 255);
v3["1d"] = Instance.new("Frame", v3["4"]);
v3["1d"].BorderSizePixel = 0;
v3["1d"].BackgroundColor3 = Color3.fromRGB(255, 255, 255);
v3["1d"].Size = UDim2.new(0.38248, 0, 0.15262, 0);
v3["1d"].Position = UDim2.new(0.0459, 0, 0.40476, 0);
v3["1d"].BorderColor3 = Color3.fromRGB(0, 0, 0);
v3["1d"].Name = "multi";
v3["1d"].BackgroundTransparency = 1;
v3["1e"] = Instance.new("TextLabel", v3["1d"]);
v3["1e"].TextWrapped = true;
v3["1e"].TextStrokeTransparency = 0;
v3["1e"].BorderSizePixel = 0;
v3["1e"].BackgroundColor3 = Color3.fromRGB(255, 255, 255);
v3["1e"].TextSize = 25;
v3["1e"].TextScaled = true;
v3["1e"].FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal);
v3["1e"].TextColor3 = Color3.fromRGB(255, 255, 255);
v3["1e"].BackgroundTransparency = 1;
v3["1e"].Size = UDim2.new(0.56702, 0, 0.8005, 0);
v3["1e"].BorderColor3 = Color3.fromRGB(0, 0, 0);
v3["1e"].Text = "Nape Multi";
v3["1e"].Name = "multiLabel";
v3["1e"].Position = UDim2.new(-5.8E-4, 0, 0.08696, 0);
v3["1f"] = Instance.new("TextBox", v3["1e"]);
v3["1f"].TextColor3 = Color3.fromRGB(0, 0, 0);
v3["1f"].BorderSizePixel = 0;
v3["1f"].TextSize = 14;
v3["1f"].Name = "multi";
v3["1f"].BackgroundColor3 = Color3.fromRGB(255, 255, 255);
v3["1f"].FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal);
v3["1f"].Size = UDim2.new(0.31745, 0, 0.97766, 0);
v3["1f"].Position = UDim2.new(1.37921, 0, -0.02716, 0);
v3["1f"].BorderColor3 = Color3.fromRGB(0, 0, 0);
v3["1f"].Text = "";
v3["20"] = Instance.new("UICorner", v3["1f"]);
v3["21"] = Instance.new("UICorner", v3["1d"]);
v3["22"] = Instance.new("UIStroke", v3["1d"]);
v3["22"].Thickness = 2;
v3["22"].Color = Color3.fromRGB(255, 255, 255);
v3["23"] = Instance.new("Frame", v3["4"]);
v3["23"].BorderSizePixel = 0;
v3["23"].BackgroundColor3 = Color3.fromRGB(255, 255, 255);
v3["23"].Size = UDim2.new(0.38248, 0, 0.15262, 0);
v3["23"].Position = UDim2.new(0.0459, 0, 0.57065, 0);
v3["23"].BorderColor3 = Color3.fromRGB(0, 0, 0);
v3["23"].Name = "visibility";
v3["23"].BackgroundTransparency = 1;
v3["24"] = Instance.new("TextLabel", v3["23"]);
v3["24"].TextWrapped = true;
v3["24"].TextStrokeTransparency = 0;
v3["24"].BorderSizePixel = 0;
v3["24"].BackgroundColor3 = Color3.fromRGB(255, 255, 255);
v3["24"].TextSize = 24;
v3["24"].TextScaled = true;
v3["24"].FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal);
v3["24"].TextColor3 = Color3.fromRGB(255, 255, 255);
v3["24"].BackgroundTransparency = 1;
v3["24"].Size = UDim2.new(0.56702, 0, 0.8005, 0);
v3["24"].BorderColor3 = Color3.fromRGB(0, 0, 0);
v3["24"].Text = "Nape Visible";
v3["24"].Name = "visLabel";
v3["24"].Position = UDim2.new(-5.8E-4, 0, 0.08696, 0);
v3["25"] = Instance.new("ImageButton", v3["24"]);
v3["25"].BorderSizePixel = 0;
v3["25"].ImageTransparency = 1;
v3["25"].BackgroundColor3 = Color3.fromRGB(171, 0, 0);
v3["25"].Image = "rbxasset://textures/ui/GuiImagePlaceholder.png";
v3["25"].Size = UDim2.new(0.32461, 0, 0.98326, 0);
v3["25"].Name = "visToggle";
v3["25"].BorderColor3 = Color3.fromRGB(0, 0, 0);
v3["25"].Position = UDim2.new(1.37877, 0, 0, 0);
v3["26"] = Instance.new("UICorner", v3["25"]);
v3["27"] = Instance.new("UICorner", v3["23"]);
v3["28"] = Instance.new("UIStroke", v3["23"]);
v3["28"].Thickness = 2;
v3["28"].Color = Color3.fromRGB(255, 255, 255);
v3["29"] = Instance.new("Frame", v3["4"]);
v3["29"].BorderSizePixel = 0;
v3["29"].BackgroundColor3 = Color3.fromRGB(255, 255, 255);
v3["29"].Size = UDim2.new(0.38248, 0, 0.15262, 0);
v3["29"].Position = UDim2.new(0.0459, 0, 0.74317, 0);
v3["29"].BorderColor3 = Color3.fromRGB(0, 0, 0);
v3["29"].Name = "ripper";
v3["29"].BackgroundTransparency = 1;
v3["2a"] = Instance.new("TextLabel", v3["29"]);
v3["2a"].TextWrapped = true;
v3["2a"].TextStrokeTransparency = 0;
v3["2a"].BorderSizePixel = 0;
v3["2a"].BackgroundColor3 = Color3.fromRGB(255, 255, 255);
v3["2a"].TextSize = 24;
v3["2a"].TextScaled = true;
v3["2a"].FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal);
v3["2a"].TextColor3 = Color3.fromRGB(255, 255, 255);
v3["2a"].BackgroundTransparency = 1;
v3["2a"].Size = UDim2.new(0.56702, 0, 0.8005, 0);
v3["2a"].BorderColor3 = Color3.fromRGB(0, 0, 0);
v3["2a"].Text = "Titan Ripper";
v3["2a"].Name = "ripperLabel";
v3["2a"].Position = UDim2.new(-5.8E-4, 0, 0.08696, 0);
v3["2b"] = Instance.new("ImageButton", v3["2a"]);
v3["2b"].BorderSizePixel = 0;
v3["2b"].ImageTransparency = 1;
v3["2b"].BackgroundColor3 = Color3.fromRGB(171, 0, 0);
v3["2b"].Image = "rbxasset://textures/ui/GuiImagePlaceholder.png";
v3["2b"].Size = UDim2.new(0.32461, 0, 0.98326, 0);
v3["2b"].Name = "ripperToggle";
v3["2b"].BorderColor3 = Color3.fromRGB(0, 0, 0);
v3["2b"].Position = UDim2.new(1.37877, 0, 0, 0);
v3["2c"] = Instance.new("UICorner", v3["2b"]);
v3["2d"] = Instance.new("UICorner", v3["29"]);
v3["2e"] = Instance.new("UIStroke", v3["29"]);
v3["2e"].Thickness = 2;
v3["2e"].Color = Color3.fromRGB(255, 255, 255);
v3["2f"] = Instance.new("ImageLabel", v3["29"]);
v3["2f"].BorderSizePixel = 0;
v3["2f"].BackgroundColor3 = Color3.fromRGB(255, 255, 255);
v3["2f"].Image = "rbxassetid://79638233305237";
v3["2f"].Size = UDim2.new(0.1617, 0, 0.70759, 0);
v3["2f"].BorderColor3 = Color3.fromRGB(0, 0, 0);
v3["2f"].BackgroundTransparency = 1;
v3["2f"].Name = "star";
v3["2f"].Position = UDim2.new(0.61946, 0, 0.11924, 0);
v3["30"] = Instance.new("Frame", v3["4"]);
v3["30"].BorderSizePixel = 0;
v3["30"].BackgroundColor3 = Color3.fromRGB(255, 255, 255);
v3["30"].Size = UDim2.new(0.38248, 0, 0.15262, 0);
v3["30"].Position = UDim2.new(0.47045, 0, 0.74649, 0);
v3["30"].BorderColor3 = Color3.fromRGB(0, 0, 0);
v3["30"].Name = "opautofarm";
v3["30"].BackgroundTransparency = 1;
v3["31"] = Instance.new("TextLabel", v3["30"]);
v3["31"].TextWrapped = true;
v3["31"].TextStrokeTransparency = 0;
v3["31"].BorderSizePixel = 0;
v3["31"].BackgroundColor3 = Color3.fromRGB(255, 255, 255);
v3["31"].TextSize = 24;
v3["31"].TextScaled = true;
v3["31"].FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal);
v3["31"].TextColor3 = Color3.fromRGB(255, 255, 255);
v3["31"].BackgroundTransparency = 1;
v3["31"].Size = UDim2.new(0.56702, 0, 0.8005, 0);
v3["31"].BorderColor3 = Color3.fromRGB(0, 0, 0);
v3["31"].Text = "OP Autofarm";
v3["31"].Name = "opautoLabel";
v3["31"].Position = UDim2.new(-5.8E-4, 0, 0.08696, 0);
v3["32"] = Instance.new("ImageButton", v3["31"]);
v3["32"].BorderSizePixel = 0;
v3["32"].ImageTransparency = 1;
v3["32"].BackgroundColor3 = Color3.fromRGB(171, 0, 0);
v3["32"].Image = "rbxasset://textures/ui/GuiImagePlaceholder.png";
v3["32"].Size = UDim2.new(0.32461, 0, 0.98326, 0);
v3["32"].Name = "opToggle";
v3["32"].BorderColor3 = Color3.fromRGB(0, 0, 0);
v3["32"].Position = UDim2.new(1.32586, 0, 0, 0);
v3["33"] = Instance.new("UICorner", v3["32"]);
v3["34"] = Instance.new("UICorner", v3["30"]);
v3["35"] = Instance.new("UIStroke", v3["30"]);
v3["35"].Thickness = 2;
v3["35"].Color = Color3.fromRGB(255, 255, 255);
v3["36"] = Instance.new("ImageLabel", v3["30"]);
v3["36"].BorderSizePixel = 0;
v3["36"].BackgroundColor3 = Color3.fromRGB(255, 255, 255);
v3["36"].Image = "rbxassetid://79638233305237";
v3["36"].Size = UDim2.new(0.1617, 0, 0.7084, 0);
v3["36"].BorderColor3 = Color3.fromRGB(0, 0, 0);
v3["36"].BackgroundTransparency = 1;
v3["36"].Name = "star";
v3["36"].Position = UDim2.new(0.58446, 0, 0.17462, 0);
v3["37"] = Instance.new("Frame", v3["4"]);
v3["37"].BorderSizePixel = 0;
v3["37"].BackgroundColor3 = Color3.fromRGB(255, 255, 255);
v3["37"].Size = UDim2.new(0.38248, 0, 0.15262, 0);
v3["37"].Position = UDim2.new(0.472, 0, 0.57641, 0);
v3["37"].BorderColor3 = Color3.fromRGB(0, 0, 0);
v3["37"].Name = "weak";
v3["37"].BackgroundTransparency = 1;
v3["38"] = Instance.new("TextLabel", v3["37"]);
v3["38"].TextWrapped = true;
v3["38"].TextStrokeTransparency = 0;
v3["38"].BorderSizePixel = 0;
v3["38"].TextScaled = true;
v3["38"].BackgroundColor3 = Color3.fromRGB(255, 255, 255);
v3["38"].TextSize = 14;
v3["38"].FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal);
v3["38"].TextColor3 = Color3.fromRGB(255, 255, 255);
v3["38"].BackgroundTransparency = 1;
v3["38"].Size = UDim2.new(0.56802, 0, 0.83558, 0);
v3["38"].BorderColor3 = Color3.fromRGB(0, 0, 0);
v3["38"].Text = "Extend Eren Weakpoint";
v3["38"].Name = "weakLabel";
v3["38"].Position = UDim2.new(0.05149, 0, 0.07746, 0);
v3["39"] = Instance.new("ImageButton", v3["38"]);
v3["39"].BorderSizePixel = 0;
v3["39"].ImageTransparency = 1;
v3["39"].BackgroundColor3 = Color3.fromRGB(171, 0, 0);
v3["39"].Image = "rbxasset://textures/ui/GuiImagePlaceholder.png";
v3["39"].Size = UDim2.new(0.32466, 0, 0.9439, 0);
v3["39"].Name = "weakToggle";
v3["39"].BorderColor3 = Color3.fromRGB(0, 0, 0);
v3["39"].Position = UDim2.new(1.22011, 0, -0.00811, 0);
v3["3a"] = Instance.new("UICorner", v3["39"]);
v3["3b"] = Instance.new("UICorner", v3["37"]);
v3["3c"] = Instance.new("UIStroke", v3["37"]);
v3["3c"].Thickness = 2;
v3["3c"].Color = Color3.fromRGB(255, 255, 255);
v3["3d"] = Instance.new("Frame", v3["4"]);
v3["3d"].BorderSizePixel = 0;
v3["3d"].BackgroundColor3 = Color3.fromRGB(255, 255, 255);
v3["3d"].Size = UDim2.new(0.38248, 0, 0.15262, 0);
v3["3d"].Position = UDim2.new(0.472, 0, 0.4072, 0);
v3["3d"].BorderColor3 = Color3.fromRGB(0, 0, 0);
v3["3d"].Name = "injury";
v3["3d"].BackgroundTransparency = 1;
v3["3e"] = Instance.new("UICorner", v3["3d"]);
v3["3f"] = Instance.new("UIStroke", v3["3d"]);
v3["3f"].Thickness = 2;
v3["3f"].Color = Color3.fromRGB(255, 255, 255);
v3["40"] = Instance.new("TextLabel", v3["3d"]);
v3["40"].TextWrapped = true;
v3["40"].TextStrokeTransparency = 0;
v3["40"].BorderSizePixel = 0;
v3["40"].BackgroundColor3 = Color3.fromRGB(255, 255, 255);
v3["40"].TextSize = 25;
v3["40"].TextScaled = true;
v3["40"].FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal);
v3["40"].TextColor3 = Color3.fromRGB(255, 255, 255);
v3["40"].BackgroundTransparency = 1;
v3["40"].Size = UDim2.new(0.56802, 0, 0.83558, 0);
v3["40"].BorderColor3 = Color3.fromRGB(0, 0, 0);
v3["40"].Text = "Anti-Injury";
v3["40"].Name = "injuryLabel";
v3["40"].Position = UDim2.new(0.05149, 0, 0.07746, 0);
v3["41"] = Instance.new("ImageButton", v3["40"]);
v3["41"].BorderSizePixel = 0;
v3["41"].ImageTransparency = 1;
v3["41"].BackgroundColor3 = Color3.fromRGB(171, 0, 0);
v3["41"].Image = "rbxasset://textures/ui/GuiImagePlaceholder.png";
v3["41"].Size = UDim2.new(0.32466, 0, 0.9439, 0);
v3["41"].Name = "injuryToggle";
v3["41"].BorderColor3 = Color3.fromRGB(0, 0, 0);
v3["41"].Position = UDim2.new(1.22011, 0, -0.00811, 0);
v3["42"] = Instance.new("UICorner", v3["41"]);
v3["43"] = Instance.new("Frame", v3["2"]);
v3["43"].Visible = false;
v3["43"].BorderSizePixel = 0;
v3["43"].BackgroundColor3 = Color3.fromRGB(255, 255, 255);
v3["43"].Size = UDim2.new(0.83799, 0, 0.88235, 0);
v3["43"].Position = UDim2.new(0.16179, 0, 0.11746, 0);
v3["43"].BorderColor3 = Color3.fromRGB(0, 0, 0);
v3["43"].Name = "testFrame";
v3["43"].BackgroundTransparency = 1;
v3["44"] = Instance.new("Frame", v3["43"]);
v3["44"].BorderSizePixel = 0;
v3["44"].BackgroundColor3 = Color3.fromRGB(255, 255, 255);
v3["44"].Size = UDim2.new(0.82222, 0, 0.35294, 0);
v3["44"].Position = UDim2.new(0.1, 0, 0.47451, 0);
v3["44"].BorderColor3 = Color3.fromRGB(0, 0, 0);
v3["44"].Name = "warningf";
v3["44"].BackgroundTransparency = 1;
v3["45"] = Instance.new("TextLabel", v3["44"]);
v3["45"].TextWrapped = true;
v3["45"].TextStrokeTransparency = 0;
v3["45"].BorderSizePixel = 0;
v3["45"].TextScaled = true;
v3["45"].BackgroundColor3 = Color3.fromRGB(255, 255, 255);
v3["45"].TextSize = 14;
v3["45"].FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal);
v3["45"].TextColor3 = Color3.fromRGB(255, 255, 255);
v3["45"].BackgroundTransparency = 1;
v3["45"].Size = UDim2.new(0.92703, 0, 0.74444, 0);
v3["45"].BorderColor3 = Color3.fromRGB(0, 0, 0);
v3["45"].Text = "These features are in testing and may ban you, use at your own risk.";
v3["45"].Name = "warning";
v3["45"].Position = UDim2.new(0.03455, 0, 0.12444, 0);
v3["46"] = Instance.new("UIStroke", v3["44"]);
v3["46"].Thickness = 2;
v3["46"].Color = Color3.fromRGB(255, 255, 255);
v3["47"] = Instance.new("UICorner", v3["44"]);
v3["48"] = Instance.new("Frame", v3["43"]);
v3["48"].BorderSizePixel = 0;
v3["48"].BackgroundColor3 = Color3.fromRGB(255, 255, 255);
v3["48"].Size = UDim2.new(0.38248, 0, 0.15262, 0);
v3["48"].Position = UDim2.new(0.05928, 0, 0.06967, 0);
v3["48"].BorderColor3 = Color3.fromRGB(0, 0, 0);
v3["48"].Name = "autofarm";
v3["48"].BackgroundTransparency = 1;
v3["49"] = Instance.new("TextLabel", v3["48"]);
v3["49"].TextWrapped = true;
v3["49"].TextStrokeTransparency = 0;
v3["49"].BorderSizePixel = 0;
v3["49"].BackgroundColor3 = Color3.fromRGB(255, 255, 255);
v3["49"].TextSize = 22;
v3["49"].TextScaled = true;
v3["49"].FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal);
v3["49"].TextColor3 = Color3.fromRGB(255, 255, 255);
v3["49"].BackgroundTransparency = 1;
v3["49"].Size = UDim2.new(0.56702, 0, 0.8005, 0);
v3["49"].BorderColor3 = Color3.fromRGB(0, 0, 0);
v3["49"].Text = "WIP Autofarm";
v3["49"].Name = "autoLabel";
v3["49"].Position = UDim2.new(-5.8E-4, 0, 0.08696, 0);
v3["4a"] = Instance.new("ImageButton", v3["49"]);
v3["4a"].BorderSizePixel = 0;
v3["4a"].ImageTransparency = 1;
v3["4a"].BackgroundColor3 = Color3.fromRGB(171, 0, 0);
v3["4a"].Image = "rbxasset://textures/ui/GuiImagePlaceholder.png";
v3["4a"].Size = UDim2.new(0.32461, 0, 0.98326, 0);
v3["4a"].Name = "autoToggle";
v3["4a"].BorderColor3 = Color3.fromRGB(0, 0, 0);
v3["4a"].Position = UDim2.new(1.32586, 0, 0, 0);
v3["4b"] = Instance.new("UICorner", v3["4a"]);
v3["4c"] = Instance.new("UICorner", v3["48"]);
v3["4d"] = Instance.new("UIStroke", v3["48"]);
v3["4d"].Thickness = 2;
v3["4d"].Color = Color3.fromRGB(255, 255, 255);
v3["4e"] = Instance.new("Frame", v3["43"]);
v3["4e"].BorderSizePixel = 0;
v3["4e"].BackgroundColor3 = Color3.fromRGB(255, 255, 255);
v3["4e"].Size = UDim2.new(0.38248, 0, 0.15262, 0);
v3["4e"].Position = UDim2.new(0.50678, 0, 0.06635, 0);
v3["4e"].BorderColor3 = Color3.fromRGB(0, 0, 0);
v3["4e"].Name = "tp";
v3["4e"].BackgroundTransparency = 1;
v3["4f"] = Instance.new("TextLabel", v3["4e"]);
v3["4f"].TextWrapped = true;
v3["4f"].TextStrokeTransparency = 0;
v3["4f"].BorderSizePixel = 0;
v3["4f"].BackgroundColor3 = Color3.fromRGB(255, 255, 255);
v3["4f"].TextSize = 22;
v3["4f"].TextScaled = true;
v3["4f"].FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal);
v3["4f"].TextColor3 = Color3.fromRGB(255, 255, 255);
v3["4f"].BackgroundTransparency = 1;
v3["4f"].Size = UDim2.new(0.56702, 0, 0.8005, 0);
v3["4f"].BorderColor3 = Color3.fromRGB(0, 0, 0);
v3["4f"].Text = "TP To Refill";
v3["4f"].Name = "tpLabel";
v3["4f"].Position = UDim2.new(-5.8E-4, 0, 0.08696, 0);
v3["50"] = Instance.new("ImageButton", v3["4f"]);
v3["50"].BorderSizePixel = 0;
v3["50"].ImageTransparency = 1;
v3["50"].BackgroundColor3 = Color3.fromRGB(171, 0, 0);
v3["50"].Image = "rbxasset://textures/ui/GuiImagePlaceholder.png";
v3["50"].Size = UDim2.new(0.32461, 0, 0.98326, 0);
v3["50"].Name = "tpButton";
v3["50"].BorderColor3 = Color3.fromRGB(0, 0, 0);
v3["50"].Position = UDim2.new(1.32586, 0, 0, 0);
v3["51"] = Instance.new("UICorner", v3["50"]);
v3["52"] = Instance.new("UICorner", v3["4e"]);
v3["53"] = Instance.new("UIStroke", v3["4e"]);
v3["53"].Thickness = 2;
v3["53"].Color = Color3.fromRGB(255, 255, 255);
v3["54"] = Instance.new("UIStroke", v3["2"]);
v3["54"].Name = "stroke";
v3["54"].Thickness = 2;
v3["54"].Color = Color3.fromRGB(255, 255, 255);
v3["55"] = Instance.new("Frame", v3["2"]);
v3["55"].BorderSizePixel = 0;
v3["55"].BackgroundColor3 = Color3.fromRGB(41, 41, 41);
v3["55"].Size = UDim2.new(0.16026, 0, 0.15223, 0);
v3["55"].Position = UDim2.new(0.0194, 0, 0.17272, 0);
v3["55"].BorderColor3 = Color3.fromRGB(0, 0, 0);
v3["55"].Name = "mainB";
v3["56"] = Instance.new("TextButton", v3["55"]);
v3["56"].TextWrapped = true;
v3["56"].BorderSizePixel = 0;
v3["56"].TextSize = 14;
v3["56"].TextColor3 = Color3.fromRGB(255, 255, 255);
v3["56"].TextScaled = true;
v3["56"].BackgroundColor3 = Color3.fromRGB(255, 255, 255);
v3["56"].FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal);
v3["56"].Size = UDim2.new(0.97418, 0, 0.54001, 0);
v3["56"].BackgroundTransparency = 1;
v3["56"].Name = "mainButton";
v3["56"].BorderColor3 = Color3.fromRGB(0, 0, 0);
v3["56"].Text = "Main";
v3["56"].Position = UDim2.new(0.00582, 0, 0.18376, 0);
v3["57"] = Instance.new("UICorner", v3["55"]);
v3["57"].CornerRadius = UDim.new(0, 16);
v3["58"] = Instance.new("UIStroke", v3["55"]);
v3["58"].Name = "stroke";
v3["58"].Color = Color3.fromRGB(255, 255, 255);
v3["59"] = Instance.new("Frame", v3["2"]);
v3["59"].BorderSizePixel = 0;
v3["59"].BackgroundColor3 = Color3.fromRGB(41, 41, 41);
v3["59"].Size = UDim2.new(0.16026, 0, 0.15223, 0);
v3["59"].Position = UDim2.new(0.0194, 0, 0.35129, 0);
v3["59"].BorderColor3 = Color3.fromRGB(0, 0, 0);
v3["59"].Name = "testB";
v3["5a"] = Instance.new("UICorner", v3["59"]);
v3["5a"].CornerRadius = UDim.new(0, 16);
v3["5b"] = Instance.new("UIStroke", v3["59"]);
v3["5b"].Name = "stroke";
v3["5b"].Color = Color3.fromRGB(100, 100, 100);
v3["5c"] = Instance.new("TextButton", v3["59"]);
v3["5c"].TextWrapped = true;
v3["5c"].BorderSizePixel = 0;
v3["5c"].TextSize = 14;
v3["5c"].TextColor3 = Color3.fromRGB(255, 255, 255);
v3["5c"].TextScaled = true;
v3["5c"].BackgroundColor3 = Color3.fromRGB(255, 255, 255);
v3["5c"].FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal);
v3["5c"].Size = UDim2.new(0.97902, 0, 0.54958, 0);
v3["5c"].BackgroundTransparency = 1;
v3["5c"].Name = "riskyButton";
v3["5c"].BorderColor3 = Color3.fromRGB(0, 0, 0);
v3["5c"].Text = "Testing";
v3["5c"].Position = UDim2.new(9.8E-4, 0, 0.22412, 0);
v3["5d"] = Instance.new("Frame", v3["2"]);
v3["5d"].BorderSizePixel = 0;
v3["5d"].BackgroundColor3 = Color3.fromRGB(41, 41, 41);
v3["5d"].Size = UDim2.new(0.16026, 0, 0.15223, 0);
v3["5d"].Position = UDim2.new(0.0194, 0, 0.62647, 0);
v3["5d"].BorderColor3 = Color3.fromRGB(0, 0, 0);
v3["5d"].Name = "banB";
v3["5e"] = Instance.new("UICorner", v3["5d"]);
v3["5e"].CornerRadius = UDim.new(0, 16);
v3["5f"] = Instance.new("UIStroke", v3["5d"]);
v3["5f"].Name = "stroke";
v3["5f"].Color = Color3.fromRGB(103, 103, 103);
v3["60"] = Instance.new("TextButton", v3["5d"]);
v3["60"].TextWrapped = true;
v3["60"].BorderSizePixel = 0;
v3["60"].TextSize = 14;
v3["60"].TextColor3 = Color3.fromRGB(255, 255, 255);
v3["60"].TextScaled = true;
v3["60"].BackgroundColor3 = Color3.fromRGB(41, 41, 41);
v3["60"].FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal);
v3["60"].Size = UDim2.new(1.00461, 0, 0.99263, 0);
v3["60"].BackgroundTransparency = 0.5;
v3["60"].Name = "banCheck";
v3["60"].BorderColor3 = Color3.fromRGB(0, 0, 0);
v3["60"].Text = "Check ShadowBan";
v3["60"].Position = UDim2.new(-0.00461, 0, 0, 0);
v3["61"] = Instance.new("UICorner", v3["60"]);
v3["61"].CornerRadius = UDim.new(0, 16);
v3["62"] = Instance.new("Frame", v3["2"]);
v3["62"].BorderSizePixel = 0;
v3["62"].BackgroundColor3 = Color3.fromRGB(41, 41, 41);
v3["62"].Size = UDim2.new(0.16026, 0, 0.15223, 0);
v3["62"].Position = UDim2.new(0.0194, 0, 0.81967, 0);
v3["62"].BorderColor3 = Color3.fromRGB(0, 0, 0);
v3["62"].Name = "closeB";
v3["63"] = Instance.new("UICorner", v3["62"]);
v3["63"].CornerRadius = UDim.new(0, 16);
v3["64"] = Instance.new("UIStroke", v3["62"]);
v3["64"].Name = "stroke";
v3["64"].Color = Color3.fromRGB(103, 103, 103);
v3["65"] = Instance.new("TextButton", v3["62"]);
v3["65"].TextWrapped = true;
v3["65"].BorderSizePixel = 0;
v3["65"].TextSize = 14;
v3["65"].TextColor3 = Color3.fromRGB(255, 255, 255);
v3["65"].TextScaled = true;
v3["65"].BackgroundColor3 = Color3.fromRGB(255, 255, 255);
v3["65"].FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal);
v3["65"].Size = UDim2.new(0.96276, 0, 0.63462, 0);
v3["65"].BackgroundTransparency = 1;
v3["65"].Name = "close";
v3["65"].BorderColor3 = Color3.fromRGB(0, 0, 0);
v3["65"].Text = "Close";
v3["65"].Position = UDim2.new(0.02725, 0, 0.13461, 0);
v3["67"] = Instance.new("Frame", v3["2"]);
v3["67"].BorderSizePixel = 0;
v3["67"].BackgroundColor3 = Color3.fromRGB(41, 41, 41);
v3["67"].Size = UDim2.new(0.26442, 0, 0.12588, 0);
v3["67"].Position = UDim2.new(0.32788, 0, 0.02342, 0);
v3["67"].BorderColor3 = Color3.fromRGB(0, 0, 0);
v3["67"].Name = "discordB";
v3["68"] = Instance.new("TextButton", v3["67"]);
v3["68"].TextWrapped = true;
v3["68"].BorderSizePixel = 0;
v3["68"].TextSize = 14;
v3["68"].TextColor3 = Color3.fromRGB(255, 255, 255);
v3["68"].TextScaled = true;
v3["68"].BackgroundColor3 = Color3.fromRGB(41, 41, 41);
v3["68"].FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal);
v3["68"].Size = UDim2.new(1, 0, 0.99786, 0);
v3["68"].BackgroundTransparency = 0.5;
v3["68"].Name = "discordButton";
v3["68"].BorderColor3 = Color3.fromRGB(0, 0, 0);
v3["68"].Text = "https://discord.gg/CXFxhXShwt";
v3["68"].Position = UDim2.new(-0.00606, 0, -0.02112, 0);
v3["69"] = Instance.new("UICorner", v3["68"]);
v3["69"].CornerRadius = UDim.new(0, 16);
v3["6a"] = Instance.new("UICorner", v3["67"]);
v3["6a"].CornerRadius = UDim.new(0, 16);
v3["6b"] = Instance.new("UIStroke", v3["67"]);
v3["6b"].Name = "stroke";
v3["6b"].Color = Color3.fromRGB(255, 255, 255);
v3["6c"] = Instance.new("Frame", v3["2"]);
v3["6c"].BorderSizePixel = 0;
v3["6c"].BackgroundColor3 = Color3.fromRGB(41, 41, 41);
v3["6c"].Size = UDim2.new(0.26442, 0, 0.12002, 0);
v3["6c"].Position = UDim2.new(0.01859, 0, 0.02076, 0);
v3["6c"].BorderColor3 = Color3.fromRGB(0, 0, 0);
v3["6c"].Name = "title";
v3["6d"] = Instance.new("UICorner", v3["6c"]);
v3["6d"].CornerRadius = UDim.new(0, 16);
v3["6e"] = Instance.new("UIStroke", v3["6c"]);
v3["6e"].Name = "stroke";
v3["6e"].Color = Color3.fromRGB(255, 255, 255);
v3["6f"] = Instance.new("TextLabel", v3["6c"]);
v3["6f"].TextWrapped = true;
v3["6f"].BorderSizePixel = 0;
v3["6f"].TextStrokeColor3 = Color3.fromRGB(167, 167, 167);
v3["6f"].TextScaled = true;
v3["6f"].BackgroundColor3 = Color3.fromRGB(255, 255, 255);
v3["6f"].TextSize = 14;
v3["6f"].FontFace = Font.new("rbxassetid://11598121416", Enum.FontWeight.Bold, Enum.FontStyle.Normal);
v3["6f"].TextColor3 = Color3.fromRGB(255, 255, 255);
v3["6f"].BackgroundTransparency = 1;
v3["6f"].Size = UDim2.new(0.95758, 0, 0.88372, 0);
v3["6f"].BorderColor3 = Color3.fromRGB(0, 0, 0);
v3["6f"].Text = "Yozakura";
v3["6f"].LayoutOrder = 2;
v3["6f"].Name = "Title";
v3["6f"].Position = UDim2.new(0.01818, 0, 0.02325, 0);
v3["70"] = Instance.new("Frame", v3["2"]);
v3["70"].BorderSizePixel = 0;
v3["70"].BackgroundColor3 = Color3.fromRGB(41, 41, 41);
v3["70"].Size = UDim2.new(0.36058, 0, 0.12295, 0);
v3["70"].Position = UDim2.new(0.61191, 0, 0.02076, 0);
v3["70"].BorderColor3 = Color3.fromRGB(0, 0, 0);
v3["70"].Name = "prem";
v3["71"] = Instance.new("UICorner", v3["70"]);
v3["71"].CornerRadius = UDim.new(0, 16);
v3["72"] = Instance.new("UIStroke", v3["70"]);
v3["72"].Name = "stroke";
v3["72"].Color = Color3.fromRGB(255, 255, 255);
v3["73"] = Instance.new("TextLabel", v3["70"]);
v3["73"].TextWrapped = true;
v3["73"].BorderSizePixel = 0;
v3["73"].TextScaled = true;
v3["73"].BackgroundColor3 = Color3.fromRGB(255, 255, 255);
v3["73"].TextSize = 14;
v3["73"].FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal);
v3["73"].TextColor3 = Color3.fromRGB(255, 255, 255);
v3["73"].BackgroundTransparency = 1;
v3["73"].Size = UDim2.new(0.96444, 0, 1, 0);
v3["73"].BorderColor3 = Color3.fromRGB(0, 0, 0);
v3["73"].Text = "     - Premium Feature";
v3["73"].Name = "premium";
v3["73"].Position = UDim2.new(0.01778, 0, -0.04706, 0);
v3["74"] = Instance.new("ImageLabel", v3["73"]);
v3["74"].BorderSizePixel = 0;
v3["74"].BackgroundColor3 = Color3.fromRGB(255, 255, 255);
v3["74"].Image = "rbxassetid://79638233305237";
v3["74"].Size = UDim2.new(0.13115, 0, 0.64865, 0);
v3["74"].BorderColor3 = Color3.fromRGB(0, 0, 0);
v3["74"].BackgroundTransparency = 1;
v3["74"].Name = "star";
v3["74"].Position = UDim2.new(-0.01639, 0, 0.18919, 0);
v3["100"] = Instance.new("ScreenGui", game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"));
v3["100"].Name = "Open";
v3["100"].ResetOnSpawn = false;
v3["100"].Enabled = false;
v3["101"] = Instance.new("Frame", v3["100"]);
v3["101"].BorderSizePixel = 0;
v3["101"].BackgroundColor3 = Color3.fromRGB(0, 0, 0);
v3["101"].Size = UDim2.new(0.068, 0, 0.05322, 0);
v3["101"].Position = UDim2.new(0.9186, 0, 0.09129, 0);
v3["101"].BorderColor3 = Color3.fromRGB(0, 0, 0);
v3["101"].BackgroundTransparency = 0.3;
v3["102"] = Instance.new("UICorner", v3["101"]);
v3["102"].CornerRadius = UDim.new(0, 12);
v3["103"] = Instance.new("TextButton", v3["101"]);
v3["103"].TextWrapped = true;
v3["103"].BorderSizePixel = 0;
v3["103"].TextSize = 14;
v3["103"].TextColor3 = Color3.fromRGB(255, 255, 255);
v3["103"].TextScaled = true;
v3["103"].BackgroundColor3 = Color3.fromRGB(255, 255, 255);
v3["103"].FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal);
v3["103"].Size = UDim2.new(0.85185, 0, 0.82143, 0);
v3["103"].BackgroundTransparency = 1;
v3["103"].BorderColor3 = Color3.fromRGB(0, 0, 0);
v3["103"].Text = "Tekkit";
v3["103"].Position = UDim2.new(0.07407, 0, 0.08591, 0);
v3["104"] = Instance.new("UIStroke", v3["101"]);
v3["104"].Thickness = 2;
v3["104"].Color = Color3.fromRGB(255, 255, 255);
v3["5c"].Activated:Connect(function() --[[ Line: 67 ]] --[[ Name: 25ms ]]
    -- upvalues: v3 (ref)
    v3["4"].Visible = false;
    v3["58"].Color = Color3.fromRGB(100, 100, 100);
    v3["43"].Visible = true;
    v3["5b"].Color = Color3.fromRGB(255, 255, 255);
end);
v3["56"].Activated:Connect(function() --[[ Line: 67 ]] --[[ Name: 25ms ]]
    -- upvalues: v3 (ref)
    v3["43"].Visible = false;
    v3["4"].Visible = true;
    v3["58"].Color = Color3.fromRGB(255, 255, 255);
    v3["5b"].Color = Color3.fromRGB(100, 100, 100);
end);
v3["65"].Activated:Connect(function() --[[ Line: 67 ]] --[[ Name: 25ms ]]
    -- upvalues: v3 (ref)
    v3["1"].Enabled = false;
    v3["100"].Enabled = true;
end);
v3["103"].Activated:Connect(function() --[[ Line: 67 ]] --[[ Name: 25ms ]]
    -- upvalues: v3 (ref)
    v3["1"].Enabled = true;
    v3["100"].Enabled = false;
end);
v3["68"].Activated:Connect(function() --[[ Line: 67 ]] --[[ Name: 25ms ]]
    -- upvalues: v2 (ref)
    print("https://discord.gg/CXFxhXShwt");
    if type(setclipboard) ~= "function" then v2("Clipboard", "Clipboard is unavailable"); return end
    setclipboard("https://discord.gg/CXFxhXShwt");
    v2("Discord", "Link copied to clipboard", 5);
end);
task.spawn(function() --[[ Line: 67 ]] --[[ Name: 25ms ]]
    -- upvalues: v3 (ref)
    return v3["1"], require;
end);
v3["6f"].Text = "Yozakura: checking dependencies"
local missionTitans = waitForValue("Titans folder", function()
    return workspace:FindFirstChild("Titans")
end)
-- Refill is optional: some maps do not expose this legacy path.
local function findMissionRefill()
    local refill = findPath(workspace, {"Unclimbable", "Reloads", "GasTanks", "Refill"})
    if refill and refill:IsA("BasePart") then return refill end
    return nil
end
local missionRefill = findMissionRefill()
local initialCharacter = waitForValue("player character", function()
    return localPlayer.Character
end)
local remotes = waitForValue("Assets.Remotes", function()
    return findPath(game:GetService("ReplicatedStorage"), {"Assets", "Remotes"})
end)
local remotePost = remotes:WaitForChild("POST", 15)
local remoteGet = remotes:WaitForChild("GET", 15)
assert(remotePost and remotePost:IsA("RemoteEvent"), "Missing POST RemoteEvent")
assert(remoteGet and remoteGet:IsA("RemoteFunction"), "Missing GET RemoteFunction")

local function requirePath(parent, names)
    return waitForValue(table.concat(names, "."), function()
        return findPath(parent, names)
    end)
end
local v4 = {
    player = game:GetService("Players").LocalPlayer, 
    playerName = game:GetService("Players").LocalPlayer.Name, 
    character = initialCharacter, 
    root = requirePath(initialCharacter, {"HumanoidRootPart"}), 
    humanoid = initialCharacter:FindFirstChildOfClass("Humanoid"), 
    blade = requirePath(initialCharacter, {"Rig_" .. localPlayer.Name, "LeftHand", "Blade_1"}), 
    bladebox = initialCharacter:FindFirstChild("Main"), 
    injuryFolder = requirePath(initialCharacter, {"Injuries"}), 
    buttonsFolder = requirePath(localPlayer, {"PlayerGui", "Interface", "Buttons"}), 
    hotbar = findPath(localPlayer, {"PlayerGui", "Interface", "HUD", "Main", "Top", "Hotbar"}), 
    titans = missionTitans, 
    VIM = game:GetService("VirtualInputManager"), 
    UIP = game:GetService("UserInputService"), 
    Mouse = game:GetService("Players").LocalPlayer:GetMouse(), 
    Hovered = false, 
    Holding = false, 
    MoveCon = nil, 
    InitialX = 0,
    InitialY = 0,
    UIInitialPos = v3["2"].Position,
    extendMulti = 1, 
    extendEnabled = false, 
    napeVisible = true, 
    espEnabled = false, 
    bladeEnabled = false, 
    injuryEnabled = false, 
    escapeEnabled = false, 
    firstpress = true, 
    ripperEnabled = false, 
    autofarmEnabled = false, 
    oldfarmEnabled = false, 
    GrabKeyCode = nil,
    grabtimer = nil,
    grabgui = nil,
    atmosphere = game:GetService("Lighting"):FindFirstChildOfClass("Atmosphere"), 
    attacktitan = nil,
    marker = nil,
    erenExtend = false, 
    leftleg = nil,
    rightleg = nil,
    leftarm = nil,
    rightarm = nil,
    eyes = nil,

    passed = false, 
    cooldownT = nil,
    cooldownS = nil,
    cooldownR = nil,


    remotePost = remotePost, 
    remoteGet = remoteGet, 
    nape = nil,
    hovering = false, 
    refill = missionRefill
};
v3["60"].Activated:Connect(function() --[[ Line: 67 ]] --[[ Name: 25ms ]]
    -- upvalues: v2 (ref)
    print((function() --[[ Line: 67 ]] --[[ Name: 25ms ]]
        -- upvalues: v2 (ref)
        for v5 in pairs(remoteGet:InvokeServer("Data", "Get")) do
            if v5:lower():match("blacklist") and v5 ~= "Is_Blacklisted" and v5 ~= "Is_Blacklisted_NEW" then
                return v2("Result", "You are shadow banned :(", 5);
            end;
        end;
        return v2("Result", "You are safe :)", 5);
    end)());
end);
v3["6f"].Text = "Yozakura"
v4.passed = true;
local function saveVariables(folder, values)
    if type(writefile) ~= "function" then return end
    local ok, err = pcall(function()
        if type(isfolder) == "function" and type(makefolder) == "function" and not isfolder(folder) then
            makefolder(folder)
        end
        writefile(folder .. "/savedVariables.txt", game:GetService("HttpService"):JSONEncode(values))
    end)
    if not ok then warn("Settings save failed: " .. tostring(err)) end
end
local function loadVariables(folder)
    if type(isfile) ~= "function" or type(readfile) ~= "function" then return {} end
    local ok, value = pcall(function()
        local path = folder .. "/savedVariables.txt"
        if not isfile(path) then return {} end
        return game:GetService("HttpService"):JSONDecode(readfile(path))
    end)
    if ok and type(value) == "table" then return value end
    warn("Settings could not be loaded; using defaults.")
    return {}
end
local v18 = "workspace"
print("Loading variables...");
local v19 = loadVariables(v18);
print("Variables loaded successfully");
if type(v19.espEnabled) == type(v4.espEnabled) then v4.espEnabled = v19.espEnabled end;
if type(v19.extendEnabled) == type(v4.extendEnabled) then v4.extendEnabled = v19.extendEnabled end;
if type(v19.escapeEnabled) == type(v4.escapeEnabled) then v4.escapeEnabled = v19.escapeEnabled end;
if type(v19.bladeEnabled) == type(v4.bladeEnabled) then v4.bladeEnabled = v19.bladeEnabled end;
if type(v19.extendMulti) == type(v4.extendMulti) then v4.extendMulti = v19.extendMulti end;
if type(v19.napeVisible) == type(v4.napeVisible) then v4.napeVisible = v19.napeVisible end;
if type(v19.erenExtend) == type(v4.erenExtend) then v4.erenExtend = v19.erenExtend end;
if type(v19.injuryEnabled) == type(v4.injuryEnabled) then v4.injuryEnabled = v19.injuryEnabled end;
if type(v19.ripperEnabled) == type(v4.ripperEnabled) then v4.ripperEnabled = v19.ripperEnabled end;
if type(v19.autofarmEnabled) == type(v4.autofarmEnabled) then v4.autofarmEnabled = v19.autofarmEnabled end;
if type(v19.oldfarmEnabled) == type(v4.oldfarmEnabled) then v4.oldfarmEnabled = v19.oldfarmEnabled end;
printLoadedVariables = function(v20) --[[ Line: 67 ]] --[[ Name: 25ms ]]
    for v21, v22 in pairs(v20) do
        print(v21 .. ": " .. tostring(v22));
    end;
end;
local function v24() --[[ Line: 67 ]] --[[ Name: 25ms ]]
    -- upvalues: v4 (ref), v18 (ref)
    local v23 = {
        espEnabled = v4.espEnabled, 
        extendEnabled = v4.extendEnabled, 
        escapeEnabled = v4.escapeEnabled, 
        bladeEnabled = v4.bladeEnabled, 
        extendMulti = v4.extendMulti, 
        napeVisible = v4.napeVisible, 
        injuryEnabled = v4.injuryEnabled, 
        erenExtend = v4.erenExtend, 
        ripperEnabled = v4.ripperEnabled, 
        autofarmEnabled = v4.autofarmEnabled, 
        oldfarmEnabled = v4.oldfarmEnabled
    };
    saveVariables(v18, v23);
end;
game:GetService("Players").PlayerRemoving:Connect(function(v25) --[[ Line: 67 ]] --[[ Name: 25ms ]]
    -- upvalues: v24 (ref)
    if v25 == game:GetService("Players").LocalPlayer then
        v24();
    end;
end);
if v4.escapeEnabled == true then
    v3.d.BackgroundColor3 = Color3.new(0, 1, 0);
end;
if v4.bladeEnabled == true then
    v3["13"].BackgroundColor3 = Color3.new(0, 1, 0);
end;
v3["1f"].Text = tostring(v4.extendMulti);
if v4.napeVisible == true then
    v3["25"].BackgroundColor3 = Color3.new(0, 1, 0);
end;
if v4.injuryEnabled == true then
    v3["41"].BackgroundColor3 = Color3.new(0, 1, 0);
    if v4.injuryFolder then
        for _, v27 in pairs(v4.injuryFolder:GetChildren()) do
            v27:Destroy();
        end;
    end;
end;
if v4.ripperEnabled and v4.passed then
    v3["2b"].BackgroundColor3 = Color3.new(0, 1, 0);
end;
if v4.atmosphere then
    v4.atmosphere.Density = 0.22;
end;
local function v30() --[[ Line: 67 ]] --[[ Name: 25ms ]]
    -- upvalues: v4 (ref), v3 (ref)
    if v4.Holding == false then
        if v4.MoveCon then v4.MoveCon:Disconnect(); v4.MoveCon = nil end;
        return;
    else
        local v28 = v4.InitialX - v4.Mouse.X;
        local v29 = v4.InitialY - v4.Mouse.Y;
        v3["2"].Position = v4.UIInitialPos - UDim2.new(0, v28, 0, v29);
        return;
    end;
end;
v3["2"].MouseEnter:Connect(function() --[[ Line: 67 ]] --[[ Name: 25ms ]]
    -- upvalues: v4 (ref)
    v4.Hovered = true;
end);
v3["2"].MouseLeave:Connect(function() --[[ Line: 67 ]] --[[ Name: 25ms ]]
    -- upvalues: v4 (ref)
    v4.Hovered = false;
end);
v4.UIP.InputBegan:Connect(function(v31) --[[ Line: 67 ]] --[[ Name: 25ms ]]
    -- upvalues: v4 (ref), v3 (ref), v30 (ref)
    if v31.UserInputType == Enum.UserInputType.MouseButton1 or v31.UserInputType == Enum.UserInputType.Touch then
        v4.Holding = v4.Hovered;
        if v4.Holding then
            local l_v4_0 = v4;
            local l_v4_1 = v4;
            local l_X_0 = v4.Mouse.X;
            l_v4_1.InitialY = v4.Mouse.Y;
            l_v4_0.InitialX = l_X_0;
            v4.UIInitialPos = v3["2"].Position;
            v4.MoveCon = v4.Mouse.Move:Connect(v30);
        end;
    end;
end);
v4.UIP.InputEnded:Connect(function(v35) --[[ Line: 67 ]] --[[ Name: 25ms ]]
    -- upvalues: v4 (ref)
    if v35.UserInputType == Enum.UserInputType.MouseButton1 or v35.UserInputType == Enum.UserInputType.Touch then
        v4.Holding = false;
    end;
end);
v4.UIP.InputEnded:Connect(function(v36) --[[ Line: 67 ]] --[[ Name: 25ms ]]
    -- upvalues: v3 (ref)
    if v36.KeyCode == Enum.KeyCode.RightShift then
        v3["1"].Enabled = not v3["1"].Enabled;
    end;
end);
local function v46() --[[ Line: 67 ]] --[[ Name: 25ms ]]
    -- upvalues: v4 (ref)
    local l_huge_0 = math.huge;
    if v4.titans then
        for _, v39 in ipairs(v4.titans:GetChildren()) do
            if v39:IsA("Model") and v39:FindFirstChildOfClass("Humanoid") and v4.titans:FindFirstChild("Attack_Titan") == nil then
                local l_Hitboxes_0 = v39:FindFirstChild("Hitboxes");
                if l_Hitboxes_0 then
                    local l_Hit_0 = l_Hitboxes_0:FindFirstChild("Hit");
                    if l_Hit_0 then
                        local l_Nape_0 = l_Hit_0:FindFirstChild("Nape");
                        if l_Nape_0 then
                            local l_Magnitude_0 = (l_Nape_0.Position - v4.root.Position).Magnitude;
                            if l_Magnitude_0 < l_huge_0 and l_Magnitude_0 <= math.huge then
                                l_huge_0 = l_Magnitude_0;
                                v4.nape = l_Nape_0;
                            end;
                        end;
                    end;
                end;
            elseif v39.Name == "Attack_Titan" and v39:FindFirstChildOfClass("Humanoid") then
                local l_Hitboxes_1 = v39:FindFirstChild("Hitboxes");
                if l_Hitboxes_1 and l_Hitboxes_1:FindFirstChild("Hit") then
                    task.wait(0.1);
                    if v4.titans:FindFirstChild("Attack_Titan") then
                        if v4.titans.Attack_Titan:FindFirstChild("Marker") and v4.titans.Attack_Titan:FindFirstChild("Marker").Adornee then
                            local l_Adornee_0 = v4.titans.Attack_Titan.Marker.Adornee;
                            if v4.oldfarmEnabled then
                                if l_Adornee_0 then
                                    if l_Adornee_0 == v4.leftleg then
                                        v4.nape = v4.leftleg;
                                    elseif l_Adornee_0 == v4.rightleg then
                                        v4.nape = v4.rightleg;
                                    elseif l_Adornee_0 == v4.leftarm then
                                        v4.nape = v4.leftarm;
                                    elseif l_Adornee_0 == v4.rightarm then
                                        v4.nape = v4.rightarm;
                                    elseif l_Adornee_0 == v4.eyes then
                                        v4.nape = v4.eyes;
                                    elseif l_Adornee_0 == v4.nape then
                                        v4.nape = v4.titans.Attack_Titan.Hitboxes.Hit.Nape;
                                    else
                                        v4.nape = v4.titans.Attack_Titan.Hitboxes.Hit.Nape;
                                    end;
                                else
                                    print("Adornee doesn't exist");
                                end;
                            end;
                        else
                            print("Attack titan doesn't exist");
                        end;
                    end;
                end;
            end;
        end;
    else
        warn("Titans folder not found in Workspace.");
    end;
end;
local function v54() --[[ Line: 67 ]] --[[ Name: 25ms ]]
    -- upvalues: v4 (ref), v3 (ref)
    if v4.espEnabled then
        v3["7"].BackgroundColor3 = Color3.new(0, 1, 0);
        local l_Highlight_0 = Instance.new("Highlight");
        l_Highlight_0.Name = "Highlight";
        l_Highlight_0.Parent = v4.titans;
        l_Highlight_0.OutlineTransparency = 0.1;
        l_Highlight_0.OutlineColor = Color3.new(1, 1, 1);
        l_Highlight_0.FillColor = Color3.new(1, 1, 1);
        l_Highlight_0.FillTransparency = 0.9;
        l_Highlight_0.Adornee = v4.titans;
        for _, v49 in pairs(v4.titans:GetChildren()) do
            if v49:IsA("Model") then
                local l_Header_0 = v49.Fake:FindFirstChild("Head"):FindFirstChild("Header");
                if l_Header_0 then
                    l_Header_0.Enabled = true;
                end;
            end;
        end;
    elseif not v4.espEnabled then
        v3["7"].BackgroundColor3 = Color3.new(1, 0, 0);
        for _, v52 in pairs(v4.titans:GetChildren()) do
            if v52:IsA("Model") then
                local l_Header_1 = v52.Fake:FindFirstChild("Head"):FindFirstChild("Header");
                if l_Header_1 then
                    l_Header_1.Enabled = false;
                end;
            elseif v52:IsA("Highlight") then
                v52:Destroy();
            end;
        end;
    end;
end;
v3["7"].Activated:Connect(function() --[[ Line: 67 ]] --[[ Name: 25ms ]]
    -- upvalues: v4 (ref), v54 (ref)
    v4.espEnabled = not v4.espEnabled;
    v54();
end);
if v4.espEnabled == true then
    v3["7"].BackgroundColor3 = Color3.new(0, 1, 0);
    v54();
end;
local function v61() --[[ Line: 67 ]] --[[ Name: 25ms ]]
    -- upvalues: v4 (ref)
    if v4.extendEnabled then
        for _, v56 in pairs(v4.titans:GetChildren()) do
            if v56:IsA("Model") and v56.Name ~= "Attack_Titan" then
                local l_Nape_1 = v56.Hitboxes.Hit.Nape;
                if l_Nape_1 and (not v4.erenExtend or v56.Name ~= "Attack_Titan") then
                    if v4.erenExtend and v56.Name ~= "Attack_Titan" then
                        l_Nape_1.Size = Vector3.new(60, 60, 60) * v4.extendMulti;
                        l_Nape_1.Color = Color3.new(1, 1, 1);
                        l_Nape_1.Material = Enum.Material.Neon;
                        l_Nape_1.Transparency = 0.96;
                    elseif not v4.erenExtend then
                        l_Nape_1.Size = Vector3.new(60, 60, 60) * v4.extendMulti;
                        l_Nape_1.Color = Color3.new(1, 1, 1);
                        l_Nape_1.Material = Enum.Material.Neon;
                        l_Nape_1.Transparency = 0.96;
                    end;
                end;
            end;
        end;
    else
        for _, v59 in pairs(v4.titans:GetChildren()) do
            if v59:IsA("Model") then
                local l_Nape_2 = v59.Hitboxes.Hit.Nape;
                if l_Nape_2 then
                    l_Nape_2.Size = Vector3.new(15, 9, 11);
                    l_Nape_2.Color = Color3.new(1, 0, 0);
                    l_Nape_2.Transparency = 1;
                end;
            end;
        end;
    end;
end;
v3["19"].Activated:Connect(function() --[[ Line: 67 ]] --[[ Name: 25ms ]]
    -- upvalues: v4 (ref), v61 (ref), v3 (ref)
    v4.extendEnabled = not v4.extendEnabled;
    coroutine.wrap(v61)();
    if v4.extendEnabled then
        v3["19"].BackgroundColor3 = Color3.new(0, 1, 0);
    else
        v3["19"].BackgroundColor3 = Color3.new(1, 0, 0);
    end;
end);
v3["1f"].FocusLost:Connect(function() --[[ Line: 67 ]] --[[ Name: 25ms ]]
    -- upvalues: v3 (ref), v4 (ref), v61 (ref)
    if tonumber(v3["1f"].Text) and tonumber(v3["1f"].Text) >= 0 and tonumber(v3["1f"].Text) <= 2 then
        v4.extendMulti = tonumber(v3["1f"].Text);
        coroutine.wrap(v61)();
    else
        print("Please put a value between 0 and 2 for extend Multiplier");
    end;
end);
v3["25"].Activated:Connect(function() --[[ Line: 67 ]] --[[ Name: 25ms ]]
    -- upvalues: v4 (ref), v3 (ref)
    v4.napeVisible = not v4.napeVisible;
    if v4.napeVisible then
        v3["25"].BackgroundColor3 = Color3.new(0, 1, 0);
        for _, v63 in pairs(v4.titans:GetChildren()) do
            local l_Nape_3 = v63.Hitboxes.Hit:FindFirstChild("Nape");
            if l_Nape_3 then
                l_Nape_3.Transparency = 0.96;
            end;
        end;
    else
        v3["25"].BackgroundColor3 = Color3.new(1, 0, 0);
        for _, v66 in pairs(v4.titans:GetChildren()) do
            local l_Nape_4 = v66.Hitboxes.Hit:FindFirstChild("Nape");
            if l_Nape_4 then
                l_Nape_4.Transparency = 1;
            end;
        end;
    end;
end);
if v4.extendEnabled == true then
    v3["19"].BackgroundColor3 = Color3.new(0, 1, 0);
    coroutine.wrap(v61)();
end;
if not v4.napeVisible then
    for _, v69 in pairs(v4.titans:GetChildren()) do
        local l_Nape_5 = v69.Hitboxes.Hit:FindFirstChild("Nape");
        if l_Nape_5 then
            l_Nape_5.Transparency = 1;
        end;
    end;
end;
v4.blade:GetPropertyChangedSignal("Transparency"):Connect(function() --[[ Line: 67 ]] --[[ Name: 25ms ]]
    -- upvalues: v4 (ref)
    task.wait(0.15);
    if v4.blade.Transparency == 1 and v4.bladeEnabled and v4.character:GetAttribute("IFrames") == nil then
        local l_Sets_0 = findBladeSets();
        if not l_Sets_0 then warn("Blade Sets UI is unavailable"); return end
        print("Reloaded");
        if l_Sets_0.Text == "3 / 3" then
            l_Sets_0.Text = "2 / 3";
        elseif l_Sets_0.Text == "2 / 3" then
            l_Sets_0.Text = "1 / 3";
        elseif l_Sets_0.Text == "1 / 3" then
            l_Sets_0.Text = "0 / 3";
        end;
        local v72 = tick();
        while tick() - v72 < 30 and v4.blade.Transparency == 1 do
            task.wait(0.5);
            v4.remoteGet:InvokeServer("Blades", "Reload");
        end;
    end;
end);
v3["13"].Activated:Connect(function() --[[ Line: 67 ]] --[[ Name: 25ms ]]
    -- upvalues: v4 (ref), v3 (ref)
    v4.bladeEnabled = not v4.bladeEnabled;
    if v4.bladeEnabled then
        v3["13"].BackgroundColor3 = Color3.new(0, 1, 0);
    else
        v3["13"].BackgroundColor3 = Color3.new(1, 0, 0);
    end;
end);
v4.injuryFolder.ChildAdded:Connect(function() --[[ Line: 67 ]] --[[ Name: 25ms ]]
    -- upvalues: v4 (ref)
    task.wait(0.2);
    for _, v74 in pairs(v4.injuryFolder:GetChildren()) do
        v74:Destroy();
    end;
end);
v3["41"].Activated:Connect(function() --[[ Line: 67 ]] --[[ Name: 25ms ]]
    -- upvalues: v4 (ref), v3 (ref)
    v4.injuryEnabled = not v4.injuryEnabled;
    if v4.injuryEnabled then
        v3["41"].BackgroundColor3 = Color3.new(0, 1, 0);
    else
        v3["41"].BackgroundColor3 = Color3.new(1, 0, 0);
    end;
end);
v4.buttonsFolder.ChildAdded:Connect(function(v75) --[[ Line: 67 ]] --[[ Name: 25ms ]]
    -- upvalues: v4 (ref), v46 (ref)
    if v4.escapeEnabled then
        task.wait(0.15);
        v4.remotePost:FireServer("Attacks", "Slash_Escape");
        v75:Destroy();
        task.wait(0.3);
        coroutine.wrap(v46)();
        if v4.nape ~= nil then
            local l_Magnitude_1 = v4.root.BV.Velocity.Magnitude;
            v4.remotePost:FireServer("Attacks", "Slash", true);
            v4.remoteGet:InvokeServer("Hitboxes", "Register", v4.nape, l_Magnitude_1, 0);
        end;
    end;
end);
v3.d.Activated:Connect(function() --[[ Line: 67 ]] --[[ Name: 25ms ]]
    -- upvalues: v4 (ref), v3 (ref)
    v4.escapeEnabled = not v4.escapeEnabled;
    if v4.escapeEnabled then
        v3.d.BackgroundColor3 = Color3.new(0, 1, 0);
    else
        v3.d.BackgroundColor3 = Color3.new(1, 0, 0);
    end;
end);
local function v80() --[[ Line: 67 ]] --[[ Name: 25ms ]]
    -- upvalues: v4 (ref)
    local v77 = {
        v4.leftleg, 
        v4.rightleg, 
        v4.leftarm, 
        v4.rightarm, 
        v4.eyes, 
        v4.nape
    };
    for _, v79 in pairs(v77) do
        if v79 then
            v79.Size = Vector3.new(10, 20, 10);
            v79.Color = Color3.new(1, 1, 1);
            v79.Transparency = 1;
        end;
    end;
end;
local function v82(v81) --[[ Line: 67 ]] --[[ Name: 25ms ]]
    if v81 then
        v81.Size = Vector3.new(95, 95, 95);
        v81.Color = Color3.new(1, 1, 1);
        v81.Material = Enum.Material.Neon;
        v81.Transparency = 0.94;
    end;
end;
local function v84() --[[ Line: 67 ]] --[[ Name: 25ms ]]
    -- upvalues: v4 (ref), v80 (ref), v82 (ref)
    task.wait(0.1);
    if v4.titans:FindFirstChild("Attack_Titan") then
        local l_Adornee_1 = v4.titans.Attack_Titan.Marker.Adornee;
        if v4.erenExtend then
            if l_Adornee_1 then
                if l_Adornee_1 == v4.leftleg then
                    v80();
                    task.wait(0.1);
                    v82(v4.leftleg);
                elseif l_Adornee_1 == v4.rightleg then
                    v80();
                    task.wait(0.1);
                    v82(v4.rightleg);
                elseif l_Adornee_1 == v4.leftarm then
                    v80();
                    task.wait(0.1);
                    v82(v4.leftarm);
                elseif l_Adornee_1 == v4.rightarm then
                    v80();
                    task.wait(0.1);
                    v82(v4.rightarm);
                elseif l_Adornee_1 == v4.eyes then
                    v80();
                    task.wait(0.1);
                    v82(v4.eyes);
                elseif l_Adornee_1 == v4.nape then
                    v80();
                    task.wait(0.1);
                    v82(v4.nape);
                else
                    v80();
                end;
            else
                v80();
            end;
        else
            v80();
        end;
    else
        print("Attack titan doesn't exist");
    end;
end;
local function v86() --[[ Line: 67 ]] --[[ Name: 25ms ]]
    -- upvalues: v4 (ref), v84 (ref)
    task.wait(0.1);
    v4.attacktitan = missionTitans:FindFirstChild("Attack_Titan");
    if v4.attacktitan ~= nil then
        v4.marker = v4.attacktitan:FindFirstChild("Marker");
        if not v4.marker then return end
        local l_Hitboxes_2 = v4.attacktitan:FindFirstChild("Hitboxes");
        if l_Hitboxes_2 and l_Hitboxes_2:FindFirstChild("Hit") then
            v4.leftleg = l_Hitboxes_2.Hit:FindFirstChild("LeftLeg");
            v4.rightleg = l_Hitboxes_2.Hit:FindFirstChild("RightLeg");
            v4.leftarm = l_Hitboxes_2.Hit:FindFirstChild("LeftArm");
            v4.rightarm = l_Hitboxes_2.Hit:FindFirstChild("RightArm");
            v4.eyes = l_Hitboxes_2.Hit:FindFirstChild("Eyes");
            v4.nape = l_Hitboxes_2.Hit:FindFirstChild("Nape");
        end;
        coroutine.wrap(v84)();
        v4.marker:GetPropertyChangedSignal("Adornee"):Connect(v84);
    end;
end;
if v4.erenExtend == true then
    v3["39"].BackgroundColor3 = Color3.new(0, 1, 0);
    coroutine.wrap(v86)();
end;
v4.titans.ChildAdded:Connect(function(v87) --[[ Line: 67 ]] --[[ Name: 25ms ]]
    -- upvalues: v86 (ref), v61 (ref)
    if v87.Name == "Attack_Titan" then
        task.wait(0.2);
        coroutine.wrap(v86)();
    elseif v87:IsA("Model") then
        task.wait(0.1);
        coroutine.wrap(v61)();
    end;
end);
v3["39"].Activated:Connect(function() --[[ Line: 67 ]] --[[ Name: 25ms ]]
    -- upvalues: v4 (ref), v3 (ref), v84 (ref), v80 (ref)
    v4.erenExtend = not v4.erenExtend;
    task.wait(0.1);
    if v4.erenExtend then
        v3["39"].BackgroundColor3 = Color3.new(0, 1, 0);
        if v4.titans:FindFirstChild("Attack_Titan") then
            coroutine.wrap(v84)();
        end;
    else
        v3["39"].BackgroundColor3 = Color3.new(1, 0, 0);
        coroutine.wrap(v80)();
    end;
end);
game:GetService("Workspace").ChildAdded:Connect(function(v88) --[[ Line: 67 ]] --[[ Name: 25ms ]]
    -- upvalues: v4 (ref)
    if (v4.ripperEnabled and v4.passed or v4.autofarmEnabled and v4.passed) and v88:IsA("Part") then
        local v89 = v4.player.Character:FindFirstChildOfClass("Humanoid") or v4.player.Character:FindFirstChildOfClass("AnimationController");
        if v88.Name == v4.playerName .. "_Steel" or v88.Name == v4.playerName .. "_Thrust" or v88.Name == v4.playerName .. "_RIP" then
            for _, v91 in pairs(v4.titans:GetChildren()) do
                if v91:IsA("Model") and v91.Name ~= "Attack_Titan" then
                    local l_Nape_6 = v91:FindFirstChild("Hitboxes"):FindFirstChild("Hit"):FindFirstChild("Nape");
                    if l_Nape_6 and l_Nape_6:IsA("BasePart") then
                        l_Nape_6.Size = Vector3.new(150, 150, 150);
                        l_Nape_6.Transparency = 1;
                        l_Nape_6.Position = v88.Position;
                    else
                        return;
                    end;
                end;
            end;
            v88.Size = Vector3.new(125, 125, 125);
            local pausedTracks = {};
            local v93 = tick();
            while true do
                if tick() - v93 < 2 then
                    for _, v95 in pairs(v4.titans:GetChildren()) do
                        if v95:IsA("Model") and v95.Name ~= "Attack_Titan" then
                            local l_Nape_7 = v95:FindFirstChild("Hitboxes"):FindFirstChild("Hit"):FindFirstChild("Nape");
                            if l_Nape_7 and l_Nape_7:IsA("BasePart") then
                                local l_v89_PlayingAnimationTracks_0 = v89:GetPlayingAnimationTracks();
                                if l_v89_PlayingAnimationTracks_0 then
                                    for _, v99 in pairs(l_v89_PlayingAnimationTracks_0) do
                                        if pausedTracks[v99] == nil then pausedTracks[v99] = v99.Speed end
                                        v99:AdjustSpeed(0);
                                    end;
                                end;
                                l_Nape_7.Position = v88.Position;
                                l_Nape_7.Transparency = 1;
                                task.wait(0.01);
                            else
                                return;
                            end;
                        end;
                    end;
                else
                    for track, originalSpeed in pairs(pausedTracks) do
                        pcall(function() track:AdjustSpeed(originalSpeed) end)
                    end;
                    task.wait(0.5);
                    for _, v103 in pairs(v4.titans:GetChildren()) do
                        if v103:IsA("Model") and v103.Name ~= "Attack_Titan" then
                            local l_Nape_8 = v103:FindFirstChild("Hitboxes"):FindFirstChild("Hit"):FindFirstChild("Nape");
                            local l_Head_0 = v103:FindFirstChild("Fake"):FindFirstChild("Head");
                            if l_Nape_8 and l_Nape_8:IsA("BasePart") then
                                l_Nape_8.Position = l_Head_0.Position - Vector3.new(2, 5, 0);
                                if v4.napeVisible then
                                    l_Nape_8.Transparency = 0.96;
                                else
                                    l_Nape_8.Transparency = 1;
                                end;
                                task.wait(0.01);
                            else
                                return;
                            end;
                        end;
                    end;
                    break;
                end;
            end;
        end;
    end;
end);
v3["2b"].Activated:Connect(function() --[[ Line: 67 ]] --[[ Name: 25ms ]]
    -- upvalues: v4 (ref), v2 (ref), v3 (ref)
    if v4.passed then
        v4.ripperEnabled = not v4.ripperEnabled;
    else
        v2("Premium", "Feature locked, check discord.");
    end;
    if v4.ripperEnabled then
        v3["2b"].BackgroundColor3 = Color3.new(0, 1, 0);
    else
        v3["2b"].BackgroundColor3 = Color3.new(1, 0, 0);
    end;
end);
local function v108() --[[ Line: 67 ]] --[[ Name: 25ms ]]
    -- upvalues: v2 (ref), v4 (ref)
    v2("Autofarm", "Clearing Mission...");
    local _ = v4.character.Humanoid:GetPlayingAnimationTracks();
    local v107 = tick();
    while tick() - v107 < 3.5 do
        v4.remoteGet:InvokeServer("S_Skills", "Usage", "108");
        task.wait(0.1);
        v4.remoteGet:InvokeServer("S_Skills", "Usage", "14");
        task.wait(2.5);
        v4.remoteGet:InvokeServer("S_Skills", "Usage", "23");
        task.wait(0.1);
        v4.remoteGet:InvokeServer("S_Skills", "Usage", "14");
        task.wait(0.5);
    end;
end;
if v4.autofarmEnabled and v4.passed then
    v3["32"].BackgroundColor3 = Color3.new(0, 1, 0);
    task.wait(1.5);
    coroutine.wrap(v108)();
end;
v3["32"].Activated:Connect(function() --[[ Line: 67 ]] --[[ Name: 25ms ]]
    -- upvalues: v4 (ref), v3 (ref), v108 (ref), v2 (ref)
    if v4.passed then
        v4.autofarmEnabled = not v4.autofarmEnabled;
        if v4.autofarmEnabled then
            v3["32"].BackgroundColor3 = Color3.new(0, 1, 0);
            task.wait(0.2);
            coroutine.wrap(v108)();
        else
            v3["32"].BackgroundColor3 = Color3.new(1, 0, 0);
        end;
    else
        v2("Premium", "Feature locked, check discord.");
    end;
end);
local function v121()
    while v3["1"].Parent do
        task.wait(1)
        if v4.autofarmEnabled or v4.oldfarmEnabled then
            local title = findPath(v4.player, {"PlayerGui", "Interface", "Rewards", "Main", "Info", "Main", "Buttons", "Retry", "Title"})
            if title and (title:IsA("TextLabel") or title:IsA("TextButton")) then
                if string.find(title.Text, "STARTING", 1, true) then return end
                if not string.find(title.Text, "(0/0)", 1, true) then
                    v4.remoteGet:InvokeServer("Functions", "Retry", "Add")
                end
            end
        end
    end
end
task.spawn(v121)
local function v134() --[[ Line: 67 ]] --[[ Name: 25ms ]]
    -- upvalues: v4 (ref), v46 (ref)
    local v122 = v4.root:FindFirstChild("BodyPosition") or Instance.new("BodyPosition", v4.root);
    v122.MaxForce = Vector3.new(0, 1000, 0);
    v122.D = 1000;
    v122.P = 1000;
    while v4.oldfarmEnabled and task.wait(0.15) do
        coroutine.wrap(v46)();
        local v123 = 75;
        if v4.titans:FindFirstChild("Attack_Titan") then
            v123 = 195;
        end;
        if v4.nape ~= nil then
            local l_BV_0 = v4.root:FindFirstChild("BV");
            if l_BV_0 then
                l_BV_0.MaxForce = Vector3.new(5500, 5500, 5500);
            end;
            local l_BG_0 = v4.root:FindFirstChild("BG");
            local v126 = v4.nape.Position + Vector3.new(0, v123, 0);
            local l_Unit_0 = (v126 - v4.root.Position).Unit;
            local l_Magnitude_2 = (v126 - v4.root.Position).Magnitude;
            local v129 = math.min(l_Magnitude_2, 150);
            if l_BV_0 then
                l_BV_0.MaxForce = Vector3.new(5500, 5500, 5500);
                l_BV_0.Velocity = l_Unit_0 * v129;
            end;
            v122.Position = Vector3.new(v122.Position.X, v126.Y, v122.Position.Z);
            if l_BG_0 then
                l_BG_0.CFrame = CFrame.new(v4.root.Position, v4.root.Position + l_Unit_0);
            end;
            if game:GetService("Workspace"):FindFirstChild("Climbable") then
                task.wait(3);
                local climbable = workspace:FindFirstChild("Climbable")
                if climbable then climbable:Destroy() end
                local unclimbable = workspace:FindFirstChild("Unclimbable")
                local mapChildren = unclimbable and unclimbable:GetChildren() or {}
                for _, v131 in pairs(mapChildren) do
                    if v131.Name ~= "Reloads" and v131.Name ~= "Cutscene" and v131.Name ~= "Objective" and v131.Name ~= "Reload" then
                        v131:Destroy();
                    end;
                end;
            end;
            for _, v133 in pairs(v4.character:GetDescendants()) do
                if v133:IsA("BasePart") and v133.CanCollide == true then
                    v133.CanCollide = false;
                end;
            end;
        end;
    end;
end;
local function v136() --[[ Line: 67 ]] --[[ Name: 25ms ]]
    -- upvalues: v4 (ref), v46 (ref)
    while v4.oldfarmEnabled and task.wait(1) do
        local l_Sets_1 = findBladeSets();
        if not l_Sets_1 then warn("Blade Sets UI is unavailable"); return end
        coroutine.wrap(v46)();
        task.wait(0.05);
        if v4.nape ~= nil then
            if missionTitans:FindFirstChild("Attack_Titan") then
                if (v4.root.Position - v4.nape.Position).Magnitude <= 250 then
                    v4.remotePost:FireServer("Attacks", "Slash", true);
                    v4.remoteGet:InvokeServer("Hitboxes", "Register", v4.nape, math.random(215, 230), math.random(10, 100));
                end;
            elseif (v4.root.Position - v4.nape.Position).Magnitude <= 175 then
                v4.remotePost:FireServer("Attacks", "Slash", true);
                v4.remoteGet:InvokeServer("Hitboxes", "Register", v4.nape, math.random(215, 230), math.random(10, 100));
            end;
        end;
        task.wait(0.05);
        if string.find(l_Sets_1.Text, "0") and v4.blade.Transparency == 1 then
            v4.refill = findMissionRefill()
            if not v4.refill then
                warn("[Yozakura] Refill unavailable at the configured path; reload skipped.")
                return
            end
            v4.remoteGet:InvokeServer("Blades", "Full_Reload", "Left", v4.refill);
            v4.remoteGet:InvokeServer("Blades", "Full_Reload", "Right", v4.refill);
            l_Sets_1.Text = "3 / 3";
        end;
    end;
end;
if v4.oldfarmEnabled then
    v3["4a"].BackgroundColor3 = Color3.new(0, 1, 0);
    coroutine.wrap(v134)();
    coroutine.wrap(v136)();
end;
v3["4a"].Activated:Connect(function() --[[ Line: 67 ]] --[[ Name: 25ms ]]
    -- upvalues: v4 (ref), v134 (ref), v136 (ref), v3 (ref)
    v4.oldfarmEnabled = not v4.oldfarmEnabled;
    if v4.oldfarmEnabled then
        coroutine.wrap(v134)();
        coroutine.wrap(v136)();
        v3["4a"].BackgroundColor3 = Color3.new(0, 1, 0);
    else
        v3["4a"].BackgroundColor3 = Color3.new(1, 0, 0);
        if v4.root:FindFirstChild("BodyPosition") then
            v4.root:FindFirstChild("BodyPosition"):Destroy();
        end;
    end;
end);
v3["50"].Activated:Connect(function() --[[ Line: 67 ]] --[[ Name: 25ms ]]
    -- upvalues: v4 (ref)
    v4.refill = findMissionRefill()
    if not v4.refill then
        v2("Refill unavailable", "This map does not expose the configured refill station.")
        return
    end
    local v137 = v4.refill.Position + Vector3.new(0, 2, 0);
    local v138 = (v137 - v4.root.Position).magnitude / 225;
    local v139 = TweenInfo.new(v138, Enum.EasingStyle.Linear, Enum.EasingDirection.In);
    local v140 = {
        CFrame = CFrame.new(v137)
    };
    local v141 = game:GetService("TweenService"):Create(v4.root, v139, v140);
    v4.hovering = true;
    v141.Completed:Connect(function() --[[ Line: 67 ]] --[[ Name: 25ms ]]
        -- upvalues: v4 (ref)
        v4.hovering = false;
    end);
    v141:Play();
end);
task.spawn(function() --[[ Line: 67 ]] --[[ Name: 25ms ]]
    -- upvalues: v4 (ref)
    local v142 = getconnections or get_signal_cons;
    if v142 then
        for _, v144 in pairs(v142(v4.player.Idled)) do
            if v144.Disable then
                v144:Disable();
            elseif v144.Disconnect then
                v144:Disconnect();
            end;
        end;
    else
        local v145 = game:GetService("VirtualUser");
        if type(cloneref) == "function" then v145 = cloneref(v145) end
        do
            local l_v145_0 = v145;
            v4.player.Idled:Connect(function() --[[ Line: 67 ]] --[[ Name: 25ms ]]
                -- upvalues: l_v145_0 (ref)
                l_v145_0:CaptureController();
                l_v145_0:ClickButton2(Vector2.new());
            end);
        end;
    end;
end);
task.wait(15);
local function v151() --[[ Line: 67 ]] --[[ Name: 25ms ]]
    -- upvalues: v4 (ref)
    v4.hotbar = findPath(localPlayer, {"PlayerGui", "Interface", "HUD", "Main", "Top", "Hotbar"})
    if not v4.hotbar then
        v2("Cooldown monitoring unavailable", "The configured hotbar path is missing. Other initialization can continue.", 8)
        return
    end
    for _, v148 in pairs(v4.hotbar:GetChildren()) do
        if v148.Name:find("Skill") then
            local l_Icon_0 = v148.Inner.Icon;
            local l_Cooldown_0 = v148.Cooldown;
            if l_Icon_0.Image == "rbxassetid://15215081865" then
                if v148.Name:find("1") then
                    v4.cooldownS = l_Cooldown_0;
                elseif v148.Name:find("2") then
                    v4.cooldownS = l_Cooldown_0;
                elseif v148.Name:find("3") then
                    v4.cooldownS = l_Cooldown_0;
                elseif v148.Name:find("4") then
                    v4.cooldownS = l_Cooldown_0;
                elseif v148.Name:find("5") then
                    v4.cooldownS = l_Cooldown_0;
                end;
            elseif l_Icon_0.Image == "rbxassetid://15215073606" then
                if v148.Name:find("1") then
                    v4.cooldownT = l_Cooldown_0;
                elseif v148.Name:find("2") then
                    v4.cooldownT = l_Cooldown_0;
                elseif v148.Name:find("3") then
                    v4.cooldownT = l_Cooldown_0;
                elseif v148.Name:find("4") then
                    v4.cooldownT = l_Cooldown_0;
                elseif v148.Name:find("5") then
                    v4.cooldownT = l_Cooldown_0;
                end;
            elseif l_Icon_0.Image == "rbxassetid://15216496277" then
                if v148.Name:find("1") then
                    v4.cooldownR = l_Cooldown_0;
                elseif v148.Name:find("2") then
                    v4.cooldownR = l_Cooldown_0;
                elseif v148.Name:find("3") then
                    v4.cooldownR = l_Cooldown_0;
                elseif v148.Name:find("4") then
                    v4.cooldownR = l_Cooldown_0;
                elseif v148.Name:find("5") then
                    v4.cooldownR = l_Cooldown_0;
                end;
            else
                if l_Icon_0.Image ~= "rbxassetid://15215073606" or not "rbxassetid://15215081865" then

                end;
                print("Skill is being passed.");
            end;
        else
            print("Child is not a skill");
        end;
    end;
end;
if v4.passed then
    coroutine.wrap(v151)();
end;
print("defined");
if v4.cooldownT ~= nil then
    v4.cooldownT:GetPropertyChangedSignal("Visible"):Connect(function() --[[ Line: 67 ]] --[[ Name: 25ms ]]
        -- upvalues: v4 (ref), v108 (ref)
        if v4.passed and v4.autofarmEnabled and v4.cooldownT.Visible == false then
            coroutine.wrap(v108)();
        end;
    end);
else
    print("Thrust not equipped");
end;
if v4.cooldownS ~= nil then
    v4.cooldownS:GetPropertyChangedSignal("Visible"):Connect(function() --[[ Line: 67 ]] --[[ Name: 25ms ]]
        -- upvalues: v4 (ref), v108 (ref)
        if v4.passed and v4.autofarmEnabled and v4.cooldownS.Visible == false then
            coroutine.wrap(v108)();
        end;
    end);
else
    print("Steel not equipped");
end;
if v4.cooldownR ~= nil then
    v4.cooldownR:GetPropertyChangedSignal("Visible"):Connect(function() --[[ Line: 67 ]] --[[ Name: 25ms ]]
        -- upvalues: v4 (ref), v108 (ref)
        if v4.passed and v4.autofarmEnabled and v4.cooldownR.Visible == false then
            coroutine.wrap(v108)();
        end;
    end);
else
    print("Let it RIP not equipped");
end;