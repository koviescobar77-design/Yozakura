-- BEGIN ADDED YOZAKURA MAIN-MENU ROUTER (mission source below is unchanged)
do
    if not game:IsLoaded() then game.Loaded:Wait() end
    local players = game:GetService("Players")
    local player = players.LocalPlayer
    local pg = player and player:WaitForChild("PlayerGui", 15)
    local function visibleLabel(o)
        if not (o:IsA("TextLabel") or o:IsA("TextButton")) then return false end
        if o.AbsoluteSize.X <= 0 or o.AbsoluteSize.Y <= 0 then return false end
        local ancestor = o
        while ancestor and ancestor ~= pg do
            if ancestor:IsA("GuiObject") and not ancestor.Visible then return false end
            if ancestor:IsA("ScreenGui") and not ancestor.Enabled then return false end
            ancestor = ancestor.Parent
        end
        return true
    end
    local function mainMenuVisible()
        if not pg then return false end
        for _, o in ipairs(pg:GetDescendants()) do
            if visibleLabel(o) then
                local text = o.Text:gsub("<[^>]->", ""):gsub("^%s+", ""):gsub("%s+$", ""):upper()
                if text:match("^SLOT%s+[ABC]$") or text == "CUSTOMIZATION"
                    or text == "CUSTOMISATION" then
                    return true
                end
            end
        end
        return false
    end
    local deadline = os.clock() + 30
    local inMenu = mainMenuVisible()
    while pg and not inMenu and os.clock() < deadline do
        if workspace:FindFirstChild("Titans") then break end
        task.wait(0.25)
        inMenu = mainMenuVisible()
    end
    if inMenu then
        local function launchMainMenu()
            -- Yozakura main-menu test revision 3: slots, Play/NO, Customization/Family.
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
            panel.Size = UDim2.fromOffset(360, 600)
            panel.Position = UDim2.new(1, -380, 0.5, -300)
            panel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            panel.BackgroundTransparency = 0.25
            panel.BorderSizePixel = 0
            panel.Parent = gui
            Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 25)
            local running, generation = false, 0
            local navigating = false
            local selectedSlot = "A"
            local targets = {Helos = true, Fritz = true}
            local function widget(class, text, y, height)
                local w = Instance.new(class)
                w.Size = UDim2.new(1, -24, 0, height or 30)
                w.Position = UDim2.fromOffset(12, y)
                w.BackgroundColor3 = Color3.fromRGB(41, 41, 41)
                w.BackgroundTransparency = 0.5
                w.BorderSizePixel = 0
                w.TextColor3 = Color3.new(1, 1, 1)
                w.Font = Enum.Font.SourceSansBold
                w.TextSize = 16
                w.Text = text
                w.Parent = panel
                if class == "TextBox" then w.ClearTextOnFocus = false end
                Instance.new("UICorner", w).CornerRadius = UDim.new(0, 16)
                local stroke = Instance.new("UIStroke", w)
                stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                stroke.Color = Color3.new(1, 1, 1)
                stroke.Thickness = 1
                return w
            end
            widget("TextLabel", "Yozakura · Main Menu", 10)
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
                navigating = false
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
            local function buttonWords(o)
                local words = {o.Name}
                if o:IsA("TextButton") then table.insert(words, clean(o.Text)) end
                for _, child in ipairs(o:GetDescendants()) do
                    if child:IsA("TextLabel") and visible(child) then table.insert(words, clean(child.Text)) end
                end
                return words
            end
            local function matchingButton(allowed)
                local matches = {}
                for _, o in ipairs(pg:GetDescendants()) do
                    if o:IsA("GuiButton") and visible(o) then
                        for _, word in ipairs(buttonWords(o)) do
                            if allowed[clean(word):lower()] then table.insert(matches, o); break end
                        end
                    end
                end
                return unique(matches)
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
                        for _, word in ipairs(buttonWords(o)) do
                            local lower = clean(word):lower()
                            if kind == "custom" and (lower == "customization" or lower == "customisation") then label = lower end
                            if kind == "spin" and (lower == "spin" or lower == "spin family" or lower == "family spin") then label = lower end
                        end
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
                                or (inFamily(o) and (n == "familyname" or n == "current" or n == "name"))
                                or clean(o.Text):lower():match("^family%s*:") then
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
                -- Hide this panel briefly so it cannot cover a game button.
                panel.Visible = false
                local ok, err = pcall(function()
                    task.wait()
                    assert(visible(o), "Button disappeared before click")
                    local point = o.AbsolutePosition + o.AbsoluteSize / 2
                    local objects = pg:GetGuiObjectsAtPosition(point.X, point.Y)
                    local top
                    for _, object in ipairs(objects) do
                        if visible(object) then top = object; break end
                    end
                    assert(top and (top == o or top:IsDescendantOf(o)), "Game button is covered by another game window")
                    local vim = game:GetService("VirtualInputManager")
                    vim:SendMouseButtonEvent(point.X, point.Y, 0, true, game, 0)
                    task.wait(0.05)
                    vim:SendMouseButtonEvent(point.X, point.Y, 0, false, game, 0)
                    task.wait(0.1)
                end)
                panel.Visible = true
                if not ok then error(err, 0) end
            end
            local function waitUntil(token, getter, seconds)
                local deadline = os.clock() + seconds
                repeat
                    if generation ~= token or not gui.Parent then error("Navigation cancelled") end
                    local value = getter()
                    if value then return value end
                    task.wait(0.15)
                until os.clock() >= deadline
                error("Timed out waiting for the next screen")
            end
            local function slotTitle(o)
                if not visible(o) or not (o:IsA("TextLabel") or o:IsA("TextButton")) then return nil end
                return clean(o.Text):upper():match("^SLOT%s+([ABC])$")
            end
            local function hasWord(o, expected)
                for _, word in ipairs(buttonWords(o)) do
                    if clean(word):lower() == expected then return true end
                end
                return false
            end
            local function slotInfo(slot)
                local headers = {}
                for _, o in ipairs(pg:GetDescendants()) do
                    if slotTitle(o) == slot then table.insert(headers, o) end
                end
                local header = unique(headers)
                if not header then return nil, "Slot " .. slot .. " title not uniquely visible", #headers > 0 end
                local scope = header.Parent
                while scope and scope ~= pg do
                    local differentSlot = false
                    local selects, locked = {}, false
                    for _, o in ipairs(scope:GetDescendants()) do
                        local title = slotTitle(o)
                        if title and title ~= slot then differentSlot = true end
                        if o:IsA("GuiButton") and visible(o) then
                            if hasWord(o, "select") then table.insert(selects, o) end
                            if hasWord(o, "unlock") then locked = true end
                        end
                    end
                    -- Never cross from one slot card into the container for all three slots.
                    if differentSlot then break end
                    -- Prefer the actual SELECT button over an enclosing clickable card.
                    local deepest = {}
                    for _, candidate in ipairs(selects) do
                        local enclosing = false
                        for _, other in ipairs(selects) do
                            if candidate ~= other and other:IsDescendantOf(candidate) then enclosing = true end
                        end
                        if not enclosing then table.insert(deepest, candidate) end
                    end
                    if #deepest == 1 then return deepest[1], nil, true end
                    if #deepest > 1 then return nil, "Multiple SELECT buttons in Slot " .. slot, true end
                    if locked then return nil, "Slot " .. slot .. " is locked. UNLOCK will not be clicked.", true end
                    scope = scope.Parent
                end
                return nil, "SELECT button not found inside Slot " .. slot .. " card", true
            end
            local function slotButton(slot)
                local target = slotInfo(slot)
                return target
            end
            local function tutorialNo()
                local no = matchingButton({no = true})
                if not no then return nil end
                local p = no.Parent
                while p and p ~= pg do
                    for _, label in ipairs(p:GetDescendants()) do
                        if label:IsA("TextLabel") and visible(label) then
                            local text = clean(label.Text):lower()
                            if text:find("tutorial", 1, true) and text:find("gem", 1, true) then return no end
                        end
                    end
                    p = p.Parent
                end
                return nil
            end
            local function familyButton()
                local named = matchingButton({f = true, family = true, families = true, familybutton = true})
                if named then return named end
                -- Screenshot fallback: circular F icon at the lower left.
                -- Resolve the real GuiButton at that location; never issue a blind coordinate click.
                local camera = workspace.CurrentCamera
                if not camera then return nil end
                local size = camera.ViewportSize
                local candidates = {}
                for _, o in ipairs(pg:GetDescendants()) do
                    if o:IsA("GuiButton") and visible(o) then
                        local center = o.AbsolutePosition + o.AbsoluteSize / 2
                        local x, y = center.X / size.X, center.Y / size.Y
                        local distance = Vector2.new(x - 0.102, y - 0.77).Magnitude
                        if distance < 0.065 then table.insert(candidates, {object = o, distance = distance}) end
                    end
                end
                table.sort(candidates, function(a, b) return a.distance < b.distance end)
                if #candidates == 1 or (#candidates > 1 and candidates[2].distance - candidates[1].distance > 0.025) then
                    return candidates[1].object
                end
                return nil
            end
            local function chooseSlotIfVisible(token)
                local target, reason, shown = slotInfo(selectedSlot)
                if target then
                    setStatus("Clicking SELECT in Slot " .. selectedSlot .. "...")
                    click(target)
                    waitUntil(token, function()
                        return matchingButton({play = true}) or button("custom")
                    end, 30)
                elseif shown then
                    error(reason, 0)
                else
                    for _, slot in ipairs({"A", "B", "C"}) do
                        local _, _, anotherShown = slotInfo(slot)
                        if anotherShown then error(reason, 0) end
                    end
                end
            end
            local function openFamily(token)
                if button("spin") then return end
                chooseSlotIfVisible(token)
                local b = button("custom")
                if b then
                    setStatus("Opening Customization...")
                    click(b)
                end
                local f = waitUntil(token, function() return familyButton() end, 12)
                setStatus("Opening the circular F / Family button...")
                click(f)
                waitUntil(token, function() return button("spin") end, 12)
                setStatus("Family screen open. Ready to spin.")
            end
            local function navigate(action)
                if running or navigating then return end
                generation = generation + 1
                local token = generation
                navigating = true
                task.spawn(function()
                    local ok, err = pcall(action, token)
                    if token ~= generation then return end
                    navigating = false
                    if not ok then halt("Stopped: " .. tostring(err)) end
                end)
            end
            local slotButtons = {}
            for index, slot in ipairs({"A", "B", "C"}) do
                local b = widget("TextButton", "Slot " .. slot .. (slot == selectedSlot and " ✓" or ""), 469)
                b.Size = UDim2.fromOffset(104, 30)
                b.Position = UDim2.fromOffset(12 + (index - 1) * 116, 469)
                slotButtons[slot] = b
                b.Activated:Connect(function()
                    if running or navigating then return end
                    selectedSlot = slot
                    for key, item in pairs(slotButtons) do item.Text = "Slot " .. key .. (key == slot and " ✓" or "") end
                    navigate(function(token)
                        local target, reason = slotInfo(slot)
                        if not target then error(reason, 0) end
                        setStatus("Clicking SELECT in Slot " .. slot .. "...")
                        click(target)
                        waitUntil(token, function() return matchingButton({play = true}) or button("custom") end, 30)
                        setStatus("Slot " .. slot .. " opened.")
                    end)
                end)
            end
            local play = widget("TextButton", "PLAY · selected slot · Tutorial: NO", 510)
            play.Activated:Connect(function()
                navigate(function(token)
                    chooseSlotIfVisible(token)
                    local no = tutorialNo()
                    if no then click(no); setStatus("Tutorial: NO selected."); return end
                    local b = waitUntil(token, function() return matchingButton({play = true}) end, 12)
                    setStatus("Opening Play...")
                    click(b)
                    local deadline = os.clock() + 15
                    while token == generation and gui.Parent and os.clock() < deadline do
                        local prompt = tutorialNo()
                        if prompt then click(prompt); setStatus("Tutorial: NO selected."); return end
                        task.wait(0.15)
                    end
                    if token == generation then setStatus("Play clicked. No tutorial prompt detected.") end
                end)
            end)
            local familyOpen = widget("TextButton", "Open circular F / Family", 547)
            familyOpen.Activated:Connect(function() navigate(openFamily) end)
            custom.Text = "Customization → F / Family"
            custom.Activated:Connect(function() navigate(openFamily) end)
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
            local function startSpin()
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
            end
            start.Text = "Auto Spin · open Customization → F → Start"
            start.Activated:Connect(function()
                navigate(function(token)
                    openFamily(token)
                    if token == generation then navigating = false; startSpin() end
                end)
            end)
            
        end
        launchMainMenu()
        return
    end
end
-- END ADDED YOZAKURA MAIN-MENU ROUTER

-- Yozakura startup revision 6: menu first, optional refill, bounded dependency checks.
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
local cachedBladeSets
local function readBladeCount(label)
    if not label then return nil end
    local current, maximum = label.Text:match("^%s*(%d+)%s*/%s*(%d+)%s*$")
    if not current then return nil end
    return tonumber(current), tonumber(maximum)
end
local function findBladeSets()
    if cachedBladeSets and cachedBladeSets:IsDescendantOf(localPlayer) then return cachedBladeSets end
    local direct = findPath(localPlayer, {"PlayerGui", "Interface", "HUD", "Main", "Top", "Blade", "Sets"})
    local function isLabel(item)
        return item and (item:IsA("TextLabel") or item:IsA("TextButton") or item:IsA("TextBox"))
    end
    if isLabel(direct) then cachedBladeSets = direct; return direct end
    local gui = localPlayer:FindFirstChildOfClass("PlayerGui")
    if not gui then return nil end
    local match
    for _, item in ipairs(gui:GetDescendants()) do
        if isLabel(item) and item.Name:lower() == "sets" and readBladeCount(item) ~= nil then
            local parent = item.Parent
            for _ = 1, 4 do
                if not parent or parent == gui then break end
                if parent.Name:lower():find("blade", 1, true) then
                    if match and match ~= item then return nil end
                    match = item
                    break
                end
                parent = parent.Parent
            end
        end
    end
    cachedBladeSets = match
    return match
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
v3["4"].Name = "missionFrame";
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
v3["12"].Text = "Auto Refill";
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
v3["48"] = Instance.new("Frame", v3["4"]);
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
v3["56"].Name = "missionButton";
v3["56"].BorderColor3 = Color3.fromRGB(0, 0, 0);
v3["56"].Text = "Mission";
v3["56"].Position = UDim2.new(0.00582, 0, 0.18376, 0);
v3["57"] = Instance.new("UICorner", v3["55"]);
v3["57"].CornerRadius = UDim.new(0, 16);
v3["58"] = Instance.new("UIStroke", v3["55"]);
v3["58"].Name = "stroke";
v3["58"].Color = Color3.fromRGB(255, 255, 255);
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
v3["68"].Text = "https://discord.gg/4dDnseEkwy";
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
-- Unified Mission page: the existing controls retain their original callbacks.
v3["4"].Visible = true
v3["4"].Size = UDim2.new(0.79, 0, 0.83, 0)
v3["4"].Position = UDim2.new(0.19, 0, 0.16, 0)
do
    local rows = {
        {v3["5"], v3.b},
        {v3["17"], v3["11"]},
        {v3["1d"], v3["3d"]},
        {v3["23"], v3["37"]},
        {v3["29"], v3["30"]},
        {v3["48"]},
    }
    for rowIndex, columns in ipairs(rows) do
        for columnIndex, control in ipairs(columns) do
            control.Size = UDim2.new(0.455, 0, 0.115, 0)
            control.Position = UDim2.new(0.015 + (columnIndex - 1) * 0.49, 0,
                0.015 + (rowIndex - 1) * 0.135, 0)
        end
    end
end
v3["55"].Name = "missionB"
v3["5d"].Position = UDim2.new(0.0194, 0, 0.43, 0)
v3["62"].Position = UDim2.new(0.0194, 0, 0.70, 0)
v3["56"].Activated:Connect(function()
    v3["4"].Visible = true
end)
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
    print("https://discord.gg/4dDnseEkwy");
    if type(setclipboard) ~= "function" then v2("Clipboard", "Clipboard is unavailable"); return end
    setclipboard("https://discord.gg/4dDnseEkwy");
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
-- Custom station labels observed in the manual refill video: REFILLS: 9/10 [R].
local function refillLabelInfo(text)
    local plain = text:gsub("<[^>]->", ""):upper()
    local remaining = plain:match("REFILLS:%s*(%d+)%s*/%s*%d+")
    return tonumber(remaining), plain:find("[R]", 1, true) ~= nil
end
local function refillLabelPart(label)
    local gui = label:FindFirstAncestorWhichIsA("BillboardGui")
        or label:FindFirstAncestorWhichIsA("SurfaceGui")
    if not gui then return nil end
    local part = gui.Adornee or gui.Parent
    if part and part:IsA("Attachment") then part = part.Parent end
    if part and part:IsA("Model") then part = part.PrimaryPart end
    if part and part:IsA("BasePart") then return part end
    return nil
end
local refillRetryAfter = setmetatable({}, {__mode = "k"})
local function resolveRefill()
    local root = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    local best, bestDistance
    local function consider(part, prompt, method)
        if not part or not part:IsA("BasePart") then return end
        if (refillRetryAfter[part] or 0) > os.clock() then return end
        local distance = (root.Position - part.Position).Magnitude
        if not bestDistance or distance < bestDistance then
            bestDistance = distance
            best = {part = part, prompt = prompt, method = method}
        end
    end
    local legacy = findPath(workspace, {"Unclimbable", "Reloads", "GasTanks", "Refill"})
    consider(legacy, nil, "legacy")
    for _, item in ipairs(workspace:GetDescendants()) do
        if item:IsA("ProximityPrompt") and item.Enabled then
            local words = (item.Name .. " " .. item.ActionText .. " " .. item.ObjectText):lower()
            if words:find("refill", 1, true) or words:find("resupply", 1, true)
                or words:find("restock", 1, true) then
                local parent = item.Parent
                if parent and parent:IsA("Attachment") then parent = parent.Parent end
                if parent and parent:IsA("Model") then parent = parent.PrimaryPart end
                consider(parent, item, "prompt")
            end
        elseif item:IsA("BasePart") and item.Name == "Refill" then
            local parent = item.Parent
            for _ = 1, 5 do
                if not parent or parent == workspace then break end
                local name = parent.Name:lower()
                if name == "reload" or name == "reloads" or name == "gastanks" then
                    consider(item, nil, "legacy")
                    break
                end
                parent = parent.Parent
            end
        end
    end
    -- Custom world labels can live in either Workspace or PlayerGui.
    local function scanLabels(container)
        if not container then return end
        for _, label in ipairs(container:GetDescendants()) do
            if label:IsA("TextLabel") or label:IsA("TextButton") then
                local remaining, usesR = refillLabelInfo(label.Text)
                if remaining and remaining > 0 then
                    consider(refillLabelPart(label), nil, "keyR")
                end
            end
        end
    end
    scanLabels(workspace)
    scanLabels(localPlayer:FindFirstChildOfClass("PlayerGui"))
    return best
end
local function findMissionRefill()
    local station = resolveRefill()
    return station and station.part or nil
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

-- One refill owner pauses movement/attacks until completion or timeout.
v4.refilling = false
v4.autoAttack = false
local lastRefillMessage
local function setRefillStatus(message)
    if lastRefillMessage == message then return end
    lastRefillMessage = message
    print("[Yozakura refill] " .. message)
end
local lastRefillAttempt = -math.huge
local function equippedBladeVisible()
    local character = localPlayer.Character
    local rig = character and character:FindFirstChild("Rig_" .. localPlayer.Name)
    if not rig then return nil end -- Unknown is not evidence that blades are gone.
    local found = false
    for _, handName in ipairs({"LeftHand", "RightHand"}) do
        local hand = rig:FindFirstChild(handName)
        local blade = hand and hand:FindFirstChild("Blade_1")
        if blade and blade:IsA("BasePart") then
            found = true
            if blade.Transparency < 1 then return true end
        end
    end
    if found then return false end
    return nil
end
local function needsStationRefill()
    return readBladeCount(findBladeSets()) == 0 and equippedBladeVisible() == false
end
local function requestRefill(manual)
    if v4.refilling then return end
    if not manual and os.clock() - lastRefillAttempt < 5 then return end
    lastRefillAttempt = os.clock()
    v4.refilling = true
    task.spawn(function()
        local suspended = {}
        local root
        local returnCFrame
        local selectedStation
        local farmingBeforeRefill = v4.oldfarmEnabled or v4.autofarmEnabled
        local ok, err = xpcall(function()
            setRefillStatus("Looking for a refill station...")
            local station = resolveRefill()
            if not station and v4.savedRefillCFrame and v4.savedRefillPlaceId == game.PlaceId
                and v4.savedRefillTitans == workspace:FindFirstChild("Titans") then
                station = {savedCFrame = v4.savedRefillCFrame, method = "keyR"}
            end
            if not station then
                error("No available loaded refill candidate. Retrying automatically; failed stations are skipped for 30 seconds.", 0)
            end
            selectedStation = station
            local character = localPlayer.Character
            root = character and character:FindFirstChild("HumanoidRootPart")
            if not root or not root:IsA("BasePart") then error("Player root is missing.", 0) end
            returnCFrame = root.CFrame
            local before = readBladeCount(findBladeSets())
            for _, mover in ipairs(root:GetChildren()) do
                if mover:IsA("BodyPosition") or mover:IsA("BodyVelocity") then
                    table.insert(suspended, {item = mover, force = mover.MaxForce})
                    mover.MaxForce = Vector3.zero
                end
            end
            local destinationCFrame = station.savedCFrame
            if not destinationCFrame then
                local destination = station.part.Position + Vector3.new(0, 3, 0)
                if station.prompt then
                    local host = station.prompt.Parent
                    if host and host:IsA("Attachment") then destination = host.WorldPosition + Vector3.new(0, 2, 0) end
                end
                destinationCFrame = CFrame.new(destination)
            end
            root.CFrame = destinationCFrame
            root.AssemblyLinearVelocity = Vector3.zero
            root.AssemblyAngularVelocity = Vector3.zero
            setRefillStatus(station.savedCFrame and "At saved refill location."
                or ("At " .. station.part:GetFullName()))
            task.wait(1)
            local completed, operationError = false, nil
            local interactionThread = task.spawn(function()
                local callOK, callError = pcall(function()
                    assert(not game:GetService("UserInputService"):GetFocusedTextBox(),
                        "Close the chat/text box before refilling.")
                    local input = game:GetService("VirtualInputManager")
                    setRefillStatus("At refill station; pressing R.")
                    input:SendKeyEvent(true, Enum.KeyCode.R, false, game)
                    task.wait(0.2)
                    input:SendKeyEvent(false, Enum.KeyCode.R, false, game)
                end)
                if not callOK then operationError = tostring(callError) end
                completed = true
            end)
            local deadline = os.clock() + math.max(10, (station.prompt and station.prompt.HoldDuration or 0) + 3)
            repeat
                task.wait(0.25)
                local count = readBladeCount(findBladeSets())
                if before ~= nil and count ~= nil and count > before then
                    if farmingBeforeRefill and (v4.oldfarmEnabled or v4.autofarmEnabled)
                        and localPlayer.Character == character and root.Parent then
                        root.CFrame = returnCFrame
                        root.AssemblyLinearVelocity = Vector3.zero
                        root.AssemblyAngularVelocity = Vector3.zero
                    end
                    setRefillStatus("Blade sets increased: " .. before .. " -> " .. count .. ". Refill confirmed.")
                    return
                end
                if completed and operationError then error(operationError, 0) end
                if not root.Parent then error("Character changed during refill.", 0) end
            until os.clock() >= deadline
            if not completed then
                if type(task.cancel) == "function" then pcall(task.cancel, interactionThread) end
                error("Refill interaction timed out; combat stays paused while supplies are empty.", 0)
            end
            if before == nil then
                error("Interaction sent; blade-count UI not found, so replenishment is unverified.", 0)
            end
            error("Interaction sent, but blade count did not increase.", 0)
        end, function(message) return tostring(message) end)
        for _, saved in ipairs(suspended) do
            if saved.item.Parent then
                if saved.item:IsA("BodyPosition") and root and root.Parent then saved.item.Position = root.Position end
                pcall(function() saved.item.MaxForce = saved.force end)
            end
        end
        v4.refilling = false
        if not ok then
            if selectedStation and selectedStation.part then
                refillRetryAfter[selectedStation.part] = os.clock() + 30
            end
            setRefillStatus(tostring(err))
        elseif selectedStation and selectedStation.part then
            refillRetryAfter[selectedStation.part] = nil
        end
    end)
end
local function guiIsShown(object)
    if not object then return false end
    local node = object
    while node and node ~= localPlayer do
        if node:IsA("GuiObject") and not node.Visible then return false end
        if node:IsA("LayerCollector") and not node.Enabled then return false end
        node = node.Parent
    end
    return node == localPlayer
end
local function missionResults()
    local rewards = findPath(localPlayer, {"PlayerGui", "Interface", "Rewards"})
    local main = rewards and rewards:FindFirstChild("Main")
    if not main or not guiIsShown(main) then return false, nil end
    local retry = findPath(main, {"Info", "Main", "Buttons", "Retry"})
    local title = retry and retry:FindFirstChild("Title")
    if title and (title:IsA("TextLabel") or title:IsA("TextButton")) and guiIsShown(title) then
        return true, title.Text
    end
    return true, nil
end
local function refillBlocksCombat()
    if missionResults() then return true end
    if v4.refilling then return true end
    if v4.bladeEnabled and needsStationRefill() then
        requestRefill(false)
        return true
    end
    return false
end
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
    v4.nape = nil
    local l_huge_0 = math.huge;
    if v4.titans then
        for _, v39 in ipairs(v4.titans:GetChildren()) do
            if v39:IsA("Model") and v39:FindFirstChildOfClass("Humanoid") and v39:FindFirstChildOfClass("Humanoid").Health > 0 and v4.titans:FindFirstChild("Attack_Titan") == nil then
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
            elseif v39.Name == "Attack_Titan" and v39:FindFirstChildOfClass("Humanoid") and v39:FindFirstChildOfClass("Humanoid").Health > 0 then
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
local function hasLivingTitans()
    if not v4.titans or not v4.titans.Parent then return true end
    for _, titan in ipairs(v4.titans:GetChildren()) do
        if titan:IsA("Model") then
            local humanoid = titan:FindFirstChildOfClass("Humanoid")
            if not humanoid or humanoid.Health > 0 then return true end
        end
    end
    return false
end
local function stopAutoFarm(message)
    v4.oldfarmEnabled = false
    v4.autofarmEnabled = false
    v4.autoAttack = false
    v4.nape = nil
    v4.attackTarget = nil
    v4.steadyFacingTarget = nil
    v4.steadyFacing = nil
    v4.noTitanSince = nil
    v4.farmDeadline = nil
    v3["4a"].BackgroundColor3 = Color3.new(1, 0, 0)
    v3["32"].BackgroundColor3 = Color3.new(1, 0, 0)
    if v4.farmHover and v4.farmHover.Parent then
        if v4.ownsFarmHover then
            v4.farmHover:Destroy()
        elseif v4.savedFarmHover then
            v4.farmHover.MaxForce = v4.savedFarmHover.force
            v4.farmHover.D = v4.savedFarmHover.d
            v4.farmHover.P = v4.savedFarmHover.p
        end
    end
    v4.farmHover = nil
    if v4.root and v4.root.Parent then
        local velocity = v4.root:FindFirstChild("BV")
        if velocity and velocity:IsA("BodyVelocity") then
            velocity.Velocity = Vector3.zero
            if v4.savedFarmForce then velocity.MaxForce = v4.savedFarmForce end
        end
        v4.root.AssemblyLinearVelocity = Vector3.zero
    end
    for part, original in pairs(v4.farmCollisions or {}) do
        if part.Parent then part.CanCollide = original end
    end
    v4.farmCollisions = {}
    if message then v2("Autofarm stopped", message, 6) end
end
-- Saved refill control below the six Mission rows.
local saveRefillButton = Instance.new("TextButton")
saveRefillButton.Name = "SaveRefillLocation"
saveRefillButton.Size = UDim2.new(0.945, 0, 0.12, 0)
saveRefillButton.Position = UDim2.new(0.015, 0, 0.84, 0)
saveRefillButton.BackgroundColor3 = Color3.fromRGB(40, 65, 85)
saveRefillButton.TextColor3 = Color3.new(1, 1, 1)
saveRefillButton.Font = Enum.Font.SourceSansBold
saveRefillButton.TextScaled = true
saveRefillButton.Text = "Save refill location"
saveRefillButton.Parent = v3["4"]
local saveCorner = Instance.new("UICorner")
saveCorner.CornerRadius = UDim.new(0, 8)
saveCorner.Parent = saveRefillButton
local function clearSavedRefill()
    v4.savedRefillCFrame = nil
    v4.savedRefillPlaceId = nil
    v4.savedRefillTitans = nil
    saveRefillButton.Text = "Save refill location"
end
saveRefillButton.Activated:Connect(function()
    if v4.refilling or missionResults() then
        v2("Cannot save now", "Wait until the refill or mission results have finished.", 5)
        return
    end
    if v4.oldfarmEnabled or v4.autofarmEnabled then
        v2("Pause autofarm first", "Turn autofarm off and stand where R refills your blades, then save.", 7)
        return
    end
    local character = localPlayer.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local titans = workspace:FindFirstChild("Titans")
    if not root or not titans then
        v2("Location not saved", "Join a mission and wait for your character to load.", 5)
        return
    end
    v4.savedRefillCFrame = root.CFrame
    v4.savedRefillPlaceId = game.PlaceId
    v4.savedRefillTitans = titans
    lastRefillAttempt = -math.huge
    saveRefillButton.Text = "Refill saved — save again"
    v2("Refill location saved", "This position will be used for R refills in this mission. Enable Auto Refill and autofarm.", 7)
end)
local function requestMissionRetry(reason)
    v2("Mission retry", reason or "Sending mission retry request.", 8)
    task.spawn(function()
        local finished = false
        task.delay(10, function()
            if not finished then
                v2("Mission retry pending", "No server response yet. Farming remains stopped.", 8)
            end
        end)
        local ok, err = pcall(function()
            v4.remoteGet:InvokeServer("Functions", "Retry", "Add")
        end)
        finished = true
        if not ok then
            v2("Mission retry failed", tostring(err), 8)
        else
            v2("Mission retry requested", "Request returned; restart is unconfirmed. The game may require the mission results screen.", 10)
        end
    end)
end
local resultsHandled = false
local resultsRetryPending = false
task.spawn(function()
    while v3["1"].Parent do
        task.wait(0.1)
        local shown, retryText = missionResults()
        if shown then
            if v4.savedRefillCFrame then clearSavedRefill() end
            if v4.oldfarmEnabled or v4.autofarmEnabled then
                resultsRetryPending = not resultsHandled
                stopAutoFarm("Mission results opened.")
            end
            if resultsRetryPending and retryText then
                local text = retryText:upper()
                if text:find("STARTING", 1, true) then
                    resultsHandled = true
                    resultsRetryPending = false
                elseif text:find("RETRY", 1, true) and not text:find("(0/0)", 1, true) then
                    resultsHandled = true
                    resultsRetryPending = false
                    requestMissionRetry("Mission results opened. Submitting Retry once.")
                end
            end
        else
            resultsHandled = false
            resultsRetryPending = false
        end
        if not shown and (v4.oldfarmEnabled or v4.autofarmEnabled) then
            v4.farmDeadline = v4.farmDeadline or (os.clock() + 300)
            if os.clock() >= v4.farmDeadline then
                stopAutoFarm("Five-minute session finished.")
                requestMissionRetry("Five minutes elapsed. Sending mission retry request.")
            elseif hasLivingTitans() then
                v4.noTitanSince = nil
            elseif not v4.noTitanSince then
                v4.noTitanSince = os.clock()
                v2("Waiting for targets", "No living titans found. The five-minute timer continues.", 5)
            end
        else
            v4.farmDeadline = nil
            v4.noTitanSince = nil
        end
    end
end)
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
-- Blade Refill is polled below; HUD text is never modified locally.
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
                        l_Nape_6.Size = Vector3.new(300, 300, 300);
                        l_Nape_6.Transparency = 1;
                        l_Nape_6.Position = v88.Position;
                    else
                        return;
                    end;
                end;
            end;
            v88.Size = Vector3.new(250, 250, 250);
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
    if not v4.autofarmEnabled or refillBlocksCombat() then return end
    v2("Autofarm", "Clearing Mission...");
    local _ = v4.character.Humanoid:GetPlayingAnimationTracks();
    local v107 = tick();
    while tick() - v107 < 3.5 do
        if not v4.autofarmEnabled or refillBlocksCombat() then return end
        if not v4.autofarmEnabled or refillBlocksCombat() then return end
        v4.remoteGet:InvokeServer("S_Skills", "Usage", "108");
        task.wait(0.1);
        if not v4.autofarmEnabled or refillBlocksCombat() then return end
        v4.remoteGet:InvokeServer("S_Skills", "Usage", "14");
        task.wait(2.5);
        if not v4.autofarmEnabled or refillBlocksCombat() then return end
        v4.remoteGet:InvokeServer("S_Skills", "Usage", "23");
        task.wait(0.1);
        if not v4.autofarmEnabled or refillBlocksCombat() then return end
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
-- Estimate visible body height without enlarged hitboxes or accessories.
local titanHeightCache = setmetatable({}, {__mode = "k"})
local function regularHoverHeight(nape)
    if not nape or not nape.Parent then return 75 end
    local model = nape.Parent
    while model and model ~= v4.titans do
        if model:IsA("Model") and model:FindFirstChildOfClass("Humanoid") then break end
        model = model.Parent
    end
    if not model or model == v4.titans then return 75 end
    -- Only apply smaller-target height when the torso is clearly upright.
    -- Unknown posture keeps the original height instead of assuming standing.
    if model.Name:lower():find("crawl", 1, true) then return 75 end
    local torso = model:FindFirstChild("UpperTorso", true) or model:FindFirstChild("Torso", true)
    if not torso or not torso:IsA("BasePart") or torso.CFrame.UpVector.Y < 0.7 then
        return 75
    end
    local cached = titanHeightCache[model]
    if cached and os.clock() - cached.time < 1 then return cached.height end
    local low, high = math.huge, -math.huge
    local count = 0
    for _, part in ipairs(model:GetDescendants()) do
        if part:IsA("BasePart") and part.Transparency < 1 then
            local excluded = false
            local parent = part
            while parent and parent ~= model do
                if parent.Name:lower():find("hitbox", 1, true) or parent:IsA("Accessory") then
                    excluded = true
                    break
                end
                parent = parent.Parent
            end
            if not excluded then
                local cf, size = part.CFrame, part.Size
                local halfY = (math.abs(cf.RightVector.Y) * size.X
                    + math.abs(cf.UpVector.Y) * size.Y
                    + math.abs(cf.LookVector.Y) * size.Z) * 0.5
                low = math.min(low, part.Position.Y - halfY)
                high = math.max(high, part.Position.Y + halfY)
                count = count + 1
            end
        end
    end
    local height = count >= 3 and math.clamp((high - low) * 0.75, 40, 75) or 75
    titanHeightCache[model] = {height = height, time = os.clock()}
    return height
end
local function titanRearOffset(nape)
    local ancestor = nape.Parent
    local facing = nape.CFrame.LookVector
    while ancestor and ancestor ~= v4.titans do
        if ancestor:IsA("Model") and ancestor:FindFirstChildOfClass("Humanoid") then
            local root = ancestor:FindFirstChild("HumanoidRootPart") or ancestor.PrimaryPart
            if root and root:IsA("BasePart") then facing = root.CFrame.LookVector end
            break
        end
        ancestor = ancestor.Parent
    end
    local horizontal = Vector3.new(facing.X, 0, facing.Z)
    if horizontal.Magnitude < 0.01 then return Vector3.zero end
    return -horizontal.Unit * 12
end
local function v134() --[[ Line: 67 ]] --[[ Name: 25ms ]]
    -- upvalues: v4 (ref), v46 (ref)
    local existingHover = v4.root:FindFirstChild("BodyPosition")
    local v122 = existingHover or Instance.new("BodyPosition", v4.root)
    v4.farmHover = v122
    v4.ownsFarmHover = existingHover == nil
    v4.savedFarmHover = {force = v122.MaxForce, d = v122.D, p = v122.P}
    v4.farmCollisions = v4.farmCollisions or {}
    local existingVelocity = v4.root:FindFirstChild("BV")
    if existingVelocity and existingVelocity:IsA("BodyVelocity") then v4.savedFarmForce = existingVelocity.MaxForce end
    v122.MaxForce = Vector3.new(0, 1000, 0);
    v122.D = 1000;
    v122.P = 1000;
    while v4.oldfarmEnabled and task.wait(0.05) do
        if not v4.oldfarmEnabled then break end
        if not refillBlocksCombat() then
        if not v4.attackTarget or not v4.attackTarget.Parent then v46() end
        if v4.attackTarget and v4.attackTarget.Parent then v4.nape = v4.attackTarget end
        if not v4.oldfarmEnabled then break end
        if not refillBlocksCombat() then
        local v123 = regularHoverHeight(v4.nape);
        if v4.titans:FindFirstChild("Attack_Titan") then
            v123 = 195;
        end;
        if v4.nape ~= nil then
            local l_BV_0 = v4.root:FindFirstChild("BV");
            if l_BV_0 then
                l_BV_0.MaxForce = Vector3.new(5500, 5500, 5500);
            end;
            local l_BG_0 = v4.root:FindFirstChild("BG");
            local v126 = v4.nape.Position + Vector3.new(0, v123, 0) + titanRearOffset(v4.nape);
            local delta = v126 - v4.root.Position
            local l_Unit_0 = delta.Magnitude > 0.01 and delta.Unit or v4.root.CFrame.LookVector;
            local l_Magnitude_2 = (v126 - v4.root.Position).Magnitude;
            local v129 = math.min(l_Magnitude_2 * 5, 500);
            if l_BV_0 then
                l_BV_0.MaxForce = Vector3.new(5500, 5500, 5500);
                l_BV_0.Velocity = l_Unit_0 * v129;
            end;
            v122.Position = Vector3.new(v122.Position.X, v126.Y, v122.Position.Z);
            if l_BG_0 then
                -- Hold a level facing direction for this target; do not face the flight velocity.
                if v4.steadyFacingTarget ~= v4.nape or not v4.steadyFacing then
                    local toward = v4.nape.Position - v4.root.Position
                    local flat = Vector3.new(toward.X, 0, toward.Z)
                    if flat.Magnitude < 0.01 then
                        local look = v4.root.CFrame.LookVector
                        flat = Vector3.new(look.X, 0, look.Z)
                    end
                    v4.steadyFacing = flat.Magnitude > 0.01 and flat.Unit or Vector3.new(0, 0, -1)
                    v4.steadyFacingTarget = v4.nape
                end
                l_BG_0.CFrame = CFrame.lookAt(v4.root.Position, v4.root.Position + v4.steadyFacing)
            end;
            for _, v133 in pairs(v4.character:GetDescendants()) do
                if v133:IsA("BasePart") and v133.CanCollide == true then
                    if v4.farmCollisions[v133] == nil then v4.farmCollisions[v133] = v133.CanCollide end
                    v133.CanCollide = false;
                end;
            end;
        else
            local velocity = v4.root:FindFirstChild("BV")
            if velocity and velocity:IsA("BodyVelocity") then velocity.Velocity = Vector3.zero end
        end;
        end -- post-selection refill check
        end -- refill pause
    end;
end;
-- Local diagnostics only: no external reporting.
local diagCount = 0
local diagDetail = ""
local function diagShow(stage)
    -- Screen diagnostics removed; gameplay does not depend on this display.
end
local function diagHit(...)
    diagCount = diagCount + 1
    diagShow("Waiting for attack call to return")
    local result = v4.remoteGet:InvokeServer(...)
    local kind = type(result)
    local summary = kind
    if kind == "string" or kind == "number" or kind == "boolean" or kind == "nil" then
        summary = tostring(result):sub(1, 180)
    end
    diagDetail = "Call returned: " .. summary .. " (not proof of damage)"
    diagShow("Attack call returned")
    return result
end

-- Local scheduling and validation only; these are not server damage/crit stats.
local CombatConfig = {
    AttackInterval = 0.4,
    AttemptsPerBurst = 10,
    RegularRange = 175,
    BossRange = 250,
}
local CombatManager = {}
function CombatManager.CanAttack(target, maxDistance)
    local character = localPlayer.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root or not root:IsA("BasePart") then return false end
    if not target or not target:IsA("BasePart") or not target.Parent then return false end
    if not v4.titans or not target:IsDescendantOf(v4.titans) then return false end
    local ancestor = target.Parent
    local humanoid
    while ancestor and ancestor ~= v4.titans do
        humanoid = ancestor:FindFirstChildOfClass("Humanoid")
        if humanoid then break end
        ancestor = ancestor.Parent
    end
    if not humanoid or humanoid.Health <= 0 then return false end
    if (root.Position - target.Position).Magnitude > maxDistance then return false end
    v4.root = root
    return true
end
local nextHitAt = 0
local function hitBurst(target, maxDistance)
    v4.attackTarget = target
    local sent = 0
    for hit = 1, CombatConfig.AttemptsPerBurst do
        local delay = nextHitAt - os.clock()
        if delay > 0 then task.wait(delay) end
        if not v4.oldfarmEnabled or refillBlocksCombat() then break end
        if not CombatManager.CanAttack(target, maxDistance) then break end
        nextHitAt = os.clock() + CombatConfig.AttackInterval
        diagHit("Hitboxes", "Register", target, math.random(215, 230), math.random(10, 100))
        sent = sent + 1
    end
    v4.attackTarget = nil
    diagDetail = "Burst attempts sent: " .. sent .. "/" .. CombatConfig.AttemptsPerBurst
        .. " (accepted hits are unverified)"
    diagShow(refillBlocksCombat() and "Paused for refill" or "Burst finished")
end
local function v136() -- One attack worker, independent of frame rate.
    if v4.combatWorkerRunning then return end
    v4.combatWorkerRunning = true
    -- upvalues: v4 (ref), v46 (ref)
    local function iteration()
        if refillBlocksCombat() then
            diagDetail = "Refill/results pause. Zero spare sets alone does not stop combat."
            diagShow("Paused for refill")
            return
        end

        diagShow("Finding target")
        v46();
        diagShow("Checking target distance")
        local target = v4.nape
        local range = missionTitans:FindFirstChild("Attack_Titan")
            and CombatConfig.BossRange or CombatConfig.RegularRange
        if v4.oldfarmEnabled and not refillBlocksCombat() and CombatManager.CanAttack(target, range) then
            hitBurst(target, range)
        end
    end
    while v4.oldfarmEnabled do
        local iterationStarted = os.clock()
        local ok, err = xpcall(iteration, function(message)
            return tostring(message)
        end)
        if not ok then
            v4.combatWorkerRunning = false
            v4.attackTarget = nil
            v4.oldfarmEnabled = false
            v3["4a"].BackgroundColor3 = Color3.new(1, 0, 0)
            diagDetail = "ERROR: " .. tostring(err)
            diagShow("Stopped after error")
            return
        end
        local targetInterval = CombatConfig.AttackInterval
        task.wait(math.max(0.01, targetInterval - (os.clock() - iterationStarted)))
    end
    v4.combatWorkerRunning = false
    diagShow("Stopped")
end
if v4.oldfarmEnabled then
    v4.autoAttack = true
    v3["4a"].BackgroundColor3 = Color3.new(0, 1, 0);
    coroutine.wrap(v134)();
    coroutine.wrap(v136)();
end;
v3["4a"].Activated:Connect(function() --[[ Line: 67 ]] --[[ Name: 25ms ]]
    -- upvalues: v4 (ref), v134 (ref), v136 (ref), v3 (ref)
    v4.oldfarmEnabled = not v4.oldfarmEnabled;
    v4.centerClickFailed = false
    v4.autoAttack = v4.oldfarmEnabled
    if v4.oldfarmEnabled then
        coroutine.wrap(v134)();
        coroutine.wrap(v136)();
        v3["4a"].BackgroundColor3 = Color3.new(0, 1, 0);
    else
        stopAutoFarm()
    end;
end);
local function clickOnce()
    local input = game:GetService("UserInputService")
    if input:GetFocusedTextBox() then return false end
    local camera = workspace.CurrentCamera
    if not camera then return false end
    local position = camera.ViewportSize * 0.5
    local gui = localPlayer:FindFirstChildOfClass("PlayerGui")
    if gui then
        for _, object in ipairs(gui:GetGuiObjectsAtPosition(position.X, position.Y)) do
            if object:IsA("GuiButton") or object:IsA("TextBox") then return false end
        end
    end
    local vim = game:GetService("VirtualInputManager")
    vim:SendMouseButtonEvent(position.X, position.Y, 0, true, game, 0)
    vim:SendMouseButtonEvent(position.X, position.Y, 0, false, game, 0)
    return true
end
task.spawn(function()
    while v3["1"].Parent do
        local started = os.clock()
        v4.autoAttack = v4.oldfarmEnabled and not v4.centerClickFailed
        if v4.autoAttack and not refillBlocksCombat() then
            local ok, clicked = pcall(clickOnce)
            if not ok then
                v4.centerClickFailed = true
                v4.autoAttack = false
                v2("Center input unavailable", tostring(clicked), 8)
            end
        end
        task.wait(math.max(0.01, CombatConfig.AttackInterval - (os.clock() - started)))
    end
    v4.autoAttack = false
end)
-- Event observation triggers at zero; polling reconnects if the HUD changes.
v4.bladeEnabled = true
v3["13"].BackgroundColor3 = Color3.new(0, 1, 0)
local bladeCountConnection
local observedBladeLabel
local function checkEmptyBlades()
    if v4.bladeEnabled and not v4.refilling and needsStationRefill() then
        requestRefill(false)
    end
end
task.spawn(function()
    local lastBladeReload = -math.huge
    local reloadInFlight = false
    while v3["1"].Parent do
        local label = findBladeSets()
        if label ~= observedBladeLabel then
            if bladeCountConnection then bladeCountConnection:Disconnect() end
            bladeCountConnection = nil
            observedBladeLabel = label
            if label then bladeCountConnection = label:GetPropertyChangedSignal("Text"):Connect(checkEmptyBlades) end
        end
        if v4.bladeEnabled and not v4.refilling then
            local count, maximum = readBladeCount(label)
            if count == 0 and equippedBladeVisible() == false then
                requestRefill(false)
            elseif count == 0 then
                setRefillStatus("0 spare sets; equipped blade still visible or unverified. Combat remains enabled.")
            elseif count and count > 0 and v4.blade.Transparency == 1 and not reloadInFlight and os.clock() - lastBladeReload > 1 then
                lastBladeReload = os.clock()
                reloadInFlight = true
                local reloadThread = task.spawn(function()
                    local ok, err = pcall(function()
                        if not refillBlocksCombat() then v4.remoteGet:InvokeServer("Blades", "Reload") end
                    end)
                    reloadInFlight = false
                    if not ok then setRefillStatus("Blade reload error: " .. tostring(err)) end
                end)
                task.delay(5, function()
                    if reloadInFlight and os.clock() - lastBladeReload >= 5 then
                        if type(task.cancel) == "function" then
                            pcall(task.cancel, reloadThread)
                            reloadInFlight = false
                        end
                        setRefillStatus("Blade reload response timed out; supply monitoring remains active.")
                    end
                end)
            elseif count == nil then
                setRefillStatus("Blade-count UI unavailable; automatic empty detection cannot run.")
            elseif os.clock() - lastRefillAttempt > 12 then
                setRefillStatus("Watching " .. count .. "/" .. maximum .. "; station trip when spare sets are 0 and equipped blades are hidden.")
            end
        end
        task.wait(0.5)
    end
    if bladeCountConnection then bladeCountConnection:Disconnect() end
end)
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