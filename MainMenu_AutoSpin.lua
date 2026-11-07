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
panel.BackgroundColor3 = Color3.fromRGB(24, 25, 34)
panel.Parent = gui
Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 10)
local running, generation = false, 0
local navigating = false
local selectedSlot = "A"
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
widget("TextLabel", "YOZAKURA · FAMILY SPIN · TEST v3", 10)
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
