-- Yozakura main-menu test revision 1.
-- Uses visible UI only. Unknown results stop the worker.
if not game:IsLoaded() then game.Loaded:Wait() end
local player = game:GetService("Players").LocalPlayer
assert(player, "LocalPlayer unavailable")
local pg = player:WaitForChild("PlayerGui", 15)
assert(pg, "PlayerGui unavailable")
local existing = pg:FindFirstChild("YozakuraFamilyMenu")
if existing then error("Yozakura Family Menu is already open. Close it before rerunning.") end
local gui = Instance.new("ScreenGui")
gui.Name = "YozakuraFamilyMenu"
gui.ResetOnSpawn = false
gui.DisplayOrder = 10000
gui.Parent = pg
local panel = Instance.new("Frame")
panel.Size = UDim2.fromOffset(360, 465)
panel.Position = UDim2.new(0, 16, 0.5, -232)
panel.BackgroundColor3 = Color3.fromRGB(24, 25, 34)
panel.Parent = gui
Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 10)
local running, generation = false, 0
local targets = {Helos = true, Fritz = true}
local function widget(class, text, y, height)
    local w = Instance.new(class)
    w.Size = UDim2.new(1, -24, 0, height or 30)
    w.Position = UDim2.fromOffset(12, y)
    w.BackgroundColor3 = Color3.fromRGB(45, 47, 64)
    w.TextColor3 = Color3.new(1, 1, 1)
    w.Font = Enum.Font.Gotham
    w.TextSize = 13
    w.Text = text
    w.Parent = panel
    if class == "TextBox" then w.ClearTextOnFocus = false end
    Instance.new("UICorner", w).CornerRadius = UDim.new(0, 5)
    return w
end
widget("TextLabel", "YOZAKURA · FAMILY SPIN · TEST v1", 10)
local status = widget("TextLabel", "Open Customization, then check family detection.", 47, 48)
status.TextWrapped = true
local custom = widget("TextButton", "Open Customization", 103)
local helos = widget("TextButton", "Helos: ON", 140)
local fritz = widget("TextButton", "Fritz: ON", 177)
local spinPath = widget("TextBox", "", 214)
spinPath.PlaceholderText = "Optional spin button path, relative to PlayerGui"
local familyPath = widget("TextBox", "", 251)
familyPath.PlaceholderText = "Optional current-family label path"
local limitBox = widget("TextBox", "10", 288)
local start = widget("TextButton", "Start · max spins in box above", 325)
local stop = widget("TextButton", "STOP", 362)
local close = widget("TextButton", "Close", 399)
widget("TextLabel", "Stops on uncertainty. Does not purchase spins.", 434, 22)
local function setStatus(s) if gui.Parent then status.Text = s end end
local function halt(s)
    running = false
    generation = generation + 1
    setStatus(s)
end
local function clean(s)
    return (s:gsub("<[^>]->", ""):gsub("^%s+", ""):gsub("%s+$", ""))
end
local function visible(o)
    if not o or not o:IsDescendantOf(pg) or o:IsDescendantOf(gui) then return false end
    local p = o
    while p and p ~= pg do
        if p:IsA("GuiObject") and not p.Visible then return false end
        if p:IsA("ScreenGui") and not p.Enabled then return false end
        p = p.Parent
    end
    return o:IsA("GuiObject") and o.AbsoluteSize.X > 0 and o.AbsoluteSize.Y > 0
end
local function fromPath(s)
    s = clean(s)
    if s == "" then return nil end
    local current = pg
    for name in s:gmatch("[^/%.]+") do
        if name ~= "PlayerGui" then
            current = current and current:FindFirstChild(name)
        end
    end
    return current
end
local function unique(list)
    if #list == 1 then return list[1] end
    return nil
end
local function inFamily(o)
    local p = o
    while p and p ~= pg do
        if p.Name:lower():find("family", 1, true) then return true end
        p = p.Parent
    end
    return false
end
local function button(kind)
    if kind == "spin" and clean(spinPath.Text) ~= "" then
        local o = fromPath(spinPath.Text)
        return o and o:IsA("GuiButton") and visible(o) and o or nil
    end
    local found = {}
    for _, o in ipairs(pg:GetDescendants()) do
        if o:IsA("GuiButton") and visible(o) then
            local label = o:IsA("TextButton") and clean(o.Text):lower() or o.Name:lower()
            if kind == "custom" and (label == "customization" or label == "customisation") then
                table.insert(found, o)
            elseif kind == "spin" and inFamily(o)
                and (label == "spin" or label == "spin family" or label == "family spin") then
                table.insert(found, o)
            end
        end
    end
    return unique(found)
end
local function family()
    local label
    if clean(familyPath.Text) ~= "" then
        label = fromPath(familyPath.Text)
    else
        local found = {}
        for _, o in ipairs(pg:GetDescendants()) do
            if o:IsA("TextLabel") and visible(o) then
                local n = o.Name:lower()
                if n == "currentfamily" or n == "equippedfamily"
                    or (inFamily(o) and n == "familyname") then
                    table.insert(found, o)
                end
            end
        end
        label = unique(found)
    end
    if not label or not label:IsA("TextLabel") or not visible(label) then return nil end
    local name = clean(label.Text):gsub("^[Ff]amily%s*:%s*", "")
    if not name:match("^[%a][%a%s%-']*$") then return nil end
    local lower = name:lower()
    if lower == "rolling" or lower == "spinning" or lower == "unknown" or lower == "none" then return nil end
    return lower, label
end
local function wanted(name)
    return (targets.Helos and name == "helos") or (targets.Fritz and name == "fritz")
end
local function click(o)
    assert(o and visible(o) and o.Interactable, "Button unavailable")
    assert(not game:GetService("UserInputService"):GetFocusedTextBox(), "Finish editing the textbox first")
    local point = o.AbsolutePosition + o.AbsoluteSize / 2
    local objects = pg:GetGuiObjectsAtPosition(point.X, point.Y)
    local top
    for _, object in ipairs(objects) do
        if visible(object) or object:IsDescendantOf(gui) then top = object; break end
    end
    assert(top and (top == o or top:IsDescendantOf(o)), "Button is covered. Move/close the covering UI.")
    local vim = game:GetService("VirtualInputManager")
    vim:SendMouseButtonEvent(point.X, point.Y, 0, true, game, 0)
    vim:SendMouseButtonEvent(point.X, point.Y, 0, false, game, 0)
end
custom.Activated:Connect(function()
    if running then return end
    local ok, err = pcall(function() click(button("custom")) end)
    setStatus(ok and "Customization clicked. Select the Family screen." or tostring(err))
end)
helos.Activated:Connect(function()
    if running then return end
    targets.Helos = not targets.Helos
    helos.Text = "Helos: " .. (targets.Helos and "ON" or "OFF")
end)
fritz.Activated:Connect(function()
    if running then return end
    targets.Fritz = not targets.Fritz
    fritz.Text = "Fritz: " .. (targets.Fritz and "ON" or "OFF")
end)
stop.Activated:Connect(function() halt("Stopped. An already-submitted spin may finish.") end)
close.Activated:Connect(function() halt("Closed"); gui:Destroy() end)
start.Activated:Connect(function()
    if running then return end
    local limit = tonumber(limitBox.Text)
    if not limit or limit < 1 or limit > 1000 or limit % 1 ~= 0 then
        setStatus("Enter a whole-number spin limit: 1–1000."); return
    end
    if not targets.Helos and not targets.Fritz then setStatus("Select Helos or Fritz."); return end
    local name = family()
    if not name then setStatus("Cannot identify current family. Set its exact label path."); return end
    if wanted(name) then setStatus("Target already equipped: " .. name .. ". No spin sent."); return end
    if not button("spin") then setStatus("Cannot identify one spin button. Set its exact path."); return end
    running = true
    generation = generation + 1
    local token = generation
    task.spawn(function()
        local ok, err = pcall(function()
            for count = 1, limit do
                if not running or token ~= generation or not gui.Parent then return end
                local before = family()
                if not before then halt("Family unreadable. Stopped."); return end
                if wanted(before) then halt("Target found: " .. before); return end
                local b = button("spin")
                if not b then halt("Spin button unavailable. Stopped."); return end
                setStatus("Spin " .. count .. "/" .. limit .. " · waiting for result")
                click(b)
                local deadline = os.clock() + 15
                local candidate, stableSince
                local finished = false
                while running and token == generation and os.clock() < deadline do
                    task.wait(0.1)
                    if not running or token ~= generation then return end
                    local result = family()
                    if result and wanted(result) then halt("Target detected: " .. result .. ". STOPPED."); return end
                    -- A repeated family is deliberately ambiguous without the game's completion signal.
                    if result and result ~= before and button("spin") then
                        if result ~= candidate then candidate, stableSince = result, os.clock() end
                        if os.clock() - stableSince >= 2 then finished = true; break end
                    else candidate, stableSince = nil, nil end
                end
                if not running or token ~= generation then return end
                if not finished then halt("No confirmed new result (same family/empty spins/timeout). Stopped."); return end
            end
            halt("Spin limit reached.")
        end)
        if not ok and token == generation then halt("Stopped: " .. tostring(err)) end
    end)
end)
