-- Yozakura • Tap Sim Reborn • revision 1
-- Standalone UI. Does not change loader.lua.
-- Auto Tap calls a selected existing GUI button's connected callback.
-- Requires getconnections; compatibility with the game's current UI is unverified.
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local player = Players.LocalPlayer
assert(player, "Run this on the client")
local pg = player:WaitForChild("PlayerGui")
local old = pg:FindFirstChild("YozakuraTapReborn")
if old then old:Destroy() end

local function make(class, parent, props)
    local obj = Instance.new(class)
    for k,v in pairs(props or {}) do obj[k] = v end
    obj.Parent = parent
    return obj
end
local function round(obj, radius)
    make("UICorner", obj, {CornerRadius=UDim.new(0,radius or 12)})
end
local white = Color3.fromRGB(243,239,250)
local muted = Color3.fromRGB(182,179,205)
local themes = {
    {"Sakura", Color3.fromRGB(245,158,192), Color3.fromRGB(177,164,237)},
    {"Lavender", Color3.fromRGB(190,171,245), Color3.fromRGB(144,195,238)},
    {"Mint", Color3.fromRGB(143,218,192), Color3.fromRGB(152,194,238)},
    {"Sky", Color3.fromRGB(149,205,240), Color3.fromRGB(196,177,239)},
}
local gui = make("ScreenGui",pg,{Name="YozakuraTapReborn",ResetOnSpawn=false,
    ZIndexBehavior=Enum.ZIndexBehavior.Sibling,DisplayOrder=50})
local connections = {}
local alive, running, selected = true, false, nil
local interval, themeIndex = 0.4, 1
local function connect(signal, fn)
    local c = signal:Connect(fn)
    table.insert(connections,c)
    return c
end
local window = make("Frame",gui,{Size=UDim2.fromOffset(480,470),
    Position=UDim2.fromScale(0.5,0.5),AnchorPoint=Vector2.new(0.5,0.5),
    BackgroundColor3=Color3.fromRGB(27,27,43),BorderSizePixel=0,ClipsDescendants=true})
round(window,18)
local scale = make("UIScale",window,{Scale=1})
local border = make("UIStroke",window,{Color=themes[1][2],Transparency=0.55,Thickness=1.2})
local top = make("Frame",window,{Size=UDim2.new(1,0,0,100),BorderSizePixel=0,
    BackgroundColor3=Color3.new(1,1,1),Active=true})
local gradient = make("UIGradient",top,{Color=ColorSequence.new(themes[1][2],themes[1][3]),Rotation=18})
make("TextLabel",top,{Position=UDim2.fromOffset(22,16),Size=UDim2.fromOffset(345,31),
    BackgroundTransparency=1,Text="YOZAKURA  /  BLOOM",Font=Enum.Font.GothamBold,
    TextSize=22,TextColor3=Color3.fromRGB(35,32,53),TextXAlignment=Enum.TextXAlignment.Left})
make("TextLabel",top,{Position=UDim2.fromOffset(23,51),Size=UDim2.fromOffset(350,22),
    BackgroundTransparency=1,Text="Tap Sim Reborn   •   soft colors, cozy grinding",
    Font=Enum.Font.Gotham,TextSize=12,TextColor3=Color3.fromRGB(55,46,73),
    TextXAlignment=Enum.TextXAlignment.Left})
-- Static blossoms: no flashing or constant animation.
for i=1,9 do
    local flower = make("TextLabel",top,{Position=UDim2.fromOffset(265+i*21,64-(i%3)*24),
        Size=UDim2.fromOffset(26,26),BackgroundTransparency=1,Text="✿",
        Font=Enum.Font.Gotham,TextSize=18+(i%3)*4,TextColor3=white,TextTransparency=0.62})
end
local function button(parent,text,pos,size)
    local b=make("TextButton",parent,{Text=text,Position=pos,Size=size,
        BackgroundColor3=Color3.fromRGB(48,47,68),TextColor3=white,
        Font=Enum.Font.GothamMedium,TextSize=13,BorderSizePixel=0,AutoButtonColor=true})
    round(b,10)
    return b
end
local minimize=button(top,"–",UDim2.new(1,-76,0,14),UDim2.fromOffset(28,28))
local close=button(top,"×",UDim2.new(1,-40,0,14),UDim2.fromOffset(28,28))
local body=make("Frame",window,{Position=UDim2.fromOffset(20,115),
    Size=UDim2.new(1,-40,1,-130),BackgroundTransparency=1})
local function label(text,y,height)
    return make("TextLabel",body,{Position=UDim2.fromOffset(0,y),
        Size=UDim2.new(1,0,0,height or 22),BackgroundTransparency=1,
        Text=text,Font=Enum.Font.Gotham,TextSize=12,TextColor3=muted,
        TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true})
end
label("FARMING",0)
local picker=button(body,"Select game tap button  ›",UDim2.fromOffset(0,28),UDim2.new(1,0,0,42))
local toggle=button(body,"Auto Tap   •   OFF",UDim2.fromOffset(0,80),UDim2.new(0.65,-5,0,42))
local speed=button(body,"0.4s / tap",UDim2.new(0.65,5,0,80),UDim2.new(0.35,-5,0,42))
label("APPEARANCE",140)
local themeButtons={}
for i,t in ipairs(themes) do
    local b=button(body,t[1],UDim2.new((i-1)*0.25,0,0,168),UDim2.new(0.25,-6,0,35))
    b.TextColor3=t[2]
    themeButtons[i]=b
    connect(b.Activated,function()
        themeIndex=i
        gradient.Color=ColorSequence.new(t[2],t[3])
        border.Color=t[2]
        toggle.TextColor3=running and t[2] or white
    end)
end
local status=label("Ready • select the game's tap button first.",221,44)
local stats=label("Session: 0s  •  Tap attempts: 0",275,24)
label("Right Shift: hide/show   •   drag the banner to move",310,22)
local menu=make("ScrollingFrame",window,{Visible=false,Position=UDim2.fromOffset(20,140),
    Size=UDim2.new(1,-40,0,240),BackgroundColor3=Color3.fromRGB(36,35,54),
    BorderSizePixel=0,ScrollBarThickness=4,AutomaticCanvasSize=Enum.AutomaticSize.Y,
    CanvasSize=UDim2.new(),ZIndex=5})
round(menu)
make("UIListLayout",menu,{Padding=UDim.new(0,4),SortOrder=Enum.SortOrder.LayoutOrder})
local function stopped(message)
    running=false
    toggle.Text="Auto Tap   •   OFF"
    toggle.TextColor3=white
    if message then status.Text=message end
end
local function candidates()
    local result={}
    for _,o in ipairs(pg:GetDescendants()) do
        if o:IsA("GuiButton") and not o:IsDescendantOf(gui) then
            local text=o:IsA("TextButton") and o.Text or ""
            local key=(o.Name.." "..text):lower()
            if key:find("tap",1,true) or key:find("click",1,true) then
                table.insert(result,o)
            end
        end
    end
    table.sort(result,function(a,b) return a:GetFullName()<b:GetFullName() end)
    return result
end
connect(picker.Activated,function()
    if menu.Visible then menu.Visible=false return end
    stopped()
    for _,o in ipairs(menu:GetChildren()) do if o:IsA("GuiButton") then o:Destroy() end end
    local found=candidates()
    if #found==0 then
        status.Text="No tap button found. Open the game's tapping screen, then try again."
        return
    end
    for i,o in ipairs(found) do
        local b=button(menu,o.Name.."  •  "..o.Parent.Name,UDim2.new(),UDim2.new(1,-8,0,36))
        b.ZIndex=6 b.LayoutOrder=i b.TextTruncate=Enum.TextTruncate.AtEnd
        connect(b.Activated,function()
            selected=o
            picker.Text="Tap button: "..o.Name
            menu.Visible=false
            status.Text="Selected. Auto Tap is ready to try."
        end)
    end
    menu.Visible=true
end)
local delays={0.2,0.4,0.6,1}
local delayIndex=2
connect(speed.Activated,function()
    delayIndex=delayIndex%#delays+1
    interval=delays[delayIndex]
    speed.Text=tostring(interval).."s / tap"
end)
local function tap()
    if not selected or not selected:IsDescendantOf(pg) then
        return false,"Tap button changed. Select it again."
    end
    if type(getconnections)~="function" then
        return false,"Executor has no getconnections support."
    end
    -- Prefer one signal to avoid firing the same tap twice.
    for _,signal in ipairs({selected.Activated,selected.MouseButton1Click}) do
        local ok,list=pcall(getconnections,signal)
        if ok and type(list)=="table" then
            local callbacks={}
            for _,c in ipairs(list) do
                local readable,fn=pcall(function() return c.Function end)
                if readable and type(fn)=="function" and c.Enabled~=false then
                    table.insert(callbacks,fn)
                end
            end
            if #callbacks>0 then
                for _,fn in ipairs(callbacks) do
                    local success=pcall(fn)
                    if not success then return false,"Button callback failed; Auto Tap stopped." end
                end
                return true
            end
        end
    end
    return false,"No callable tap handler. This game needs a specific adapter."
end
connect(toggle.Activated,function()
    if running then stopped("Paused.") return end
    if not selected then status.Text="Select a tap button first." return end
    running=true
    toggle.Text="Auto Tap   •   ON"
    toggle.TextColor3=themes[themeIndex][2]
    status.Text="Running • attempts are counted, rewards are not verified."
end)
local mini=false
connect(minimize.Activated,function()
    mini=not mini
    body.Visible=not mini
    menu.Visible=false
    window.Size=UDim2.fromOffset(480,mini and 100 or 470)
    minimize.Text=mini and "+" or "–"
end)
connect(UIS.InputBegan,function(input,processed)
    if not processed and input.KeyCode==Enum.KeyCode.RightShift then window.Visible=not window.Visible end
end)
local dragging,dragStart,original
connect(top.InputBegan,function(input)
    if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
        dragging=input dragStart=input.Position original=window.Position
    end
end)
connect(UIS.InputChanged,function(input)
    if dragging and (input.UserInputType==Enum.UserInputType.MouseMovement or input==dragging) then
        local delta=input.Position-dragStart
        window.Position=UDim2.new(original.X.Scale,original.X.Offset+delta.X,
            original.Y.Scale,original.Y.Offset+delta.Y)
    end
end)
connect(UIS.InputEnded,function(input)
    if input==dragging or input.UserInputType==Enum.UserInputType.MouseButton1 then dragging=nil end
end)
local function resize()
    local camera=workspace.CurrentCamera
    if camera then
        local v=camera.ViewportSize
        scale.Scale=math.clamp(math.min((v.X-24)/480,(v.Y-40)/470),0.35,1)
    end
end
local lastCamera
local viewportConnection
connect(game:GetService("RunService").Heartbeat,function()
    if workspace.CurrentCamera~=lastCamera then
        if viewportConnection then viewportConnection:Disconnect() end
        lastCamera=workspace.CurrentCamera
        if lastCamera then viewportConnection=connect(lastCamera:GetPropertyChangedSignal("ViewportSize"),resize) end
        resize()
    end
end)
connect(gui.Destroying,function()
    alive=false running=false
    for _,c in ipairs(connections) do c:Disconnect() end
end)
connect(close.Activated,function() gui:Destroy() end)
local started,attempts=os.clock(),0
task.spawn(function()
    while alive do
        if running then
            local ok,err=tap()
            if ok then attempts=attempts+1 else stopped(err) end
        end
        if alive then
            stats.Text=string.format("Session: %ds  •  Tap attempts: %d",os.clock()-started,attempts)
        end
        task.wait(interval)
    end
end)
