-- Sakura | Tap Simulator Reborn | visible HUD controls
local player = game:GetService("Players").LocalPlayer
local pg = player:WaitForChild("PlayerGui")
local input = game:GetService("UserInputService")
local guiService = game:GetService("GuiService")
local previous = pg:FindFirstChild("YozakuraTapReborn")
if previous then previous:Destroy() end
local gui = Instance.new("ScreenGui")
gui.Name = "YozakuraTapReborn"
gui.ResetOnSpawn = false
gui.DisplayOrder = 50
gui.Parent = pg
local panel = Instance.new("ScrollingFrame")
panel.BackgroundColor3 = Color3.fromRGB(255,237,245)
panel.Position = UDim2.new(0,12,0.09,0)
panel.Size = UDim2.new(0,245,0.42,0)
panel.AutomaticCanvasSize = Enum.AutomaticSize.Y
panel.CanvasSize = UDim2.new()
panel.ScrollBarThickness = 4
panel.Parent = gui
local layout = Instance.new("UIListLayout",panel)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0,4)
local order = 0
local function row(label, action)
    order += 1
    local item = Instance.new(action and "TextButton" or "TextLabel")
    item.LayoutOrder = order
    item.Text = label
    item.Size = UDim2.new(1,-6,0,36)
    item.TextWrapped = true
    item.BackgroundColor3 = Color3.fromRGB(248,211,230)
    item.TextColor3 = Color3.fromRGB(73,32,55)
    item.Font = Enum.Font.GothamMedium
    item.TextSize = 14
    item.Parent = panel
    Instance.new("UICorner",item)
    if action then item.Activated:Connect(action) end
    return item
end
local function visible(item)
    if not item or not item:IsDescendantOf(pg) or item:IsDescendantOf(gui) then return false end
    local node = item
    while node ~= pg do
        if node:IsA("GuiObject") and not node.Visible then return false end
        if node:IsA("ScreenGui") and not node.Enabled then return false end
        node = node.Parent
    end
    return true
end
local function targetAt(point)
    local top = pg:GetGuiObjectsAtPosition(point.X,point.Y)[1]
    if not visible(top) then return nil end
    while top and top ~= pg do
        if top:IsA("GuiButton") and top.Interactable then return top end
        top = top.Parent
    end
end
local function click(button,point)
    assert(not input:GetFocusedTextBox(),"Finish typing first")
    assert(visible(button) and targetAt(point)==button,"Button is covered or unavailable")
    local vim = game:GetService("VirtualInputManager")
    vim:SendMouseButtonEvent(point.X,point.Y,0,true,game,0)
    vim:SendMouseButtonEvent(point.X,point.Y,0,false,game,0)
end
local status
row("Sakura · Tap Simulator Reborn")
row("Toggle game Auto Clicker",function()
    local size = workspace.CurrentCamera.ViewportSize
    local point = Vector2.new(math.round(size.X * 0.586), math.round(size.Y * 0.93))
    local button = targetAt(point)
    local node = button
    while node and node ~= pg do
        local name = node.Name:lower():gsub("[^a-z]","")
        if name == "autoclicker" or name == "autotap" or name == "autoclick" then break end
        node = node.Parent
    end
    if not node or node == pg then
        status.Text = "Tap the game's Auto Clicker control beside the blue tap button."
        return
    end
    local ok, err = pcall(click,button,point)
    status.Text = ok and "Check the game HUD for Auto Clicker status." or tostring(err)
end)
local destinations = {}
local function caption(button)
    local function read(o)
        if o:IsA("TextLabel") or o:IsA("TextButton") then
            return o.ContentText:match("^%s*(.-)%s*$")
        end
    end
    local name = read(button)
    if name and name ~= "" then return name end
    for _,o in ipairs(button:GetDescendants()) do
        if visible(o) then
            name = read(o)
            if name and name ~= "" then return name end
        end
    end
end
local function mapMenu(button)
    local node = button.Parent
    while node and node ~= pg do
        local name = node.Name:lower()
        if name:find("teleport",1,true) or name=="maps" or name=="worlds" then return true end
        node = node.Parent
    end
    return false
end
row("Maps · refresh destinations",function()
    for _,r in ipairs(destinations) do r:Destroy() end
    table.clear(destinations)
    local choices = {}
    for _,b in ipairs(pg:GetDescendants()) do
        if b:IsA("GuiButton") and b.Interactable and visible(b) and mapMenu(b) then
            local name = caption(b)
            if name and not name:lower():match("unlock") and not name:lower():match("purchase")
                and not name:lower():match("buy") and not name:lower():match("locked")
                and not ({close=true,back=true,x=true,yes=true,no=true})[name:lower()] then
                table.insert(choices,{name=name,button=b})
            end
        end
    end
    table.sort(choices,function(a,b) return a.name<b.name end)
    for _,entry in ipairs(choices) do
        local b,name = entry.button,entry.name
        table.insert(destinations,row(name,function()
            if not visible(b) or caption(b)~=name then status.Text="Refresh Maps first."; return end
            local center = b.AbsolutePosition + b.AbsoluteSize/2
            local ok,err = pcall(function()
                if targetAt(center)~=b then center += guiService:GetGuiInset() end
                click(b,center)
            end)
            status.Text = ok and ("Selected "..name) or tostring(err)
        end))
    end
    status.Text = #choices>0 and "Choose a visible destination." or "Open the game's teleport menu, then refresh Maps."
end)
local picking, hatchButton = false, nil
local hatchToggle
hatchToggle = row("Auto Hatch · OFF",function()
    if picking or hatchButton then
        picking, hatchButton = false, nil
        hatchToggle.Text = "Auto Hatch · OFF"
    else
        picking = true
        hatchToggle.Text = "Auto Hatch · Pick hatch button"
        status.Text = "Open an egg menu first, then click its hatch button."
    end
end)
local pickConnection = input.InputBegan:Connect(function(event)
    if not picking then return end
    if event.UserInputType ~= Enum.UserInputType.MouseButton1 and event.UserInputType ~= Enum.UserInputType.Touch then return end
    local point = Vector2.new(event.Position.X,event.Position.Y)
    local button = targetAt(point)
    if not button then return end
    picking, hatchButton = false, button
    hatchToggle.Text = "Auto Hatch · ON"
    status.Text = "Repeating the selected hatch button."
end)
gui.Destroying:Connect(function() pickConnection:Disconnect() end)
task.spawn(function()
    while gui.Parent do
        task.wait(1)
        local button = hatchButton
        if button and not button.Parent then
            hatchButton = nil
            hatchToggle.Text = "Auto Hatch · OFF"
            status.Text = "Egg menu changed. Select the hatch button again."
        elseif button and visible(button) and not input:GetFocusedTextBox() then
            local center = button.AbsolutePosition + button.AbsoluteSize/2
            if targetAt(center) ~= button then center += guiService:GetGuiInset() end
            if targetAt(center) == button then
                local ok,err = pcall(click,button,center)
                if not ok then
                    hatchButton = nil
                    hatchToggle.Text = "Auto Hatch · OFF"
                    status.Text = tostring(err)
                end
            end
        end
    end
end)
status = row("Use the game auto clicker to keep your mouse free.")
