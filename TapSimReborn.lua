-- Sakura • Tap Sim Reborn • revision 4
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
-- Deep plum text keeps the pastel surfaces readable.
local white = Color3.fromRGB(81,48,70)
local muted = Color3.fromRGB(119,82,106)
local themes = {
    {"Sakura", Color3.fromRGB(166,56,105), Color3.fromRGB(172,139,204)},
    {"Lavender", Color3.fromRGB(120,75,161), Color3.fromRGB(192,156,218)},
    {"Mint", Color3.fromRGB(48,118,103), Color3.fromRGB(164,213,197)},
    {"Sky", Color3.fromRGB(66,107,151), Color3.fromRGB(177,199,230)},
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
-- Blank sidebar is reserved for the owner's future navigation labels.
local window=make("Frame",gui,{Size=UDim2.fromOffset(720,560),Position=UDim2.fromScale(.5,.5),
    AnchorPoint=Vector2.new(.5,.5),BackgroundColor3=Color3.fromRGB(255,243,248),BorderSizePixel=0,ClipsDescendants=true})
round(window,16)
local scale=make("UIScale",window,{Scale=1})
local border=make("UIStroke",window,{Color=themes[1][2],Transparency=.6})
local rail=make("Frame",window,{Name="ReservedSidebar",Position=UDim2.fromOffset(0,56),
    Size=UDim2.new(0,140,1,-56),BackgroundColor3=Color3.fromRGB(249,226,238),BorderSizePixel=0})
-- Intentionally no menu labels, menu icons, or placeholder actions.
local top=make("Frame",window,{Size=UDim2.new(1,0,0,56),BackgroundColor3=Color3.fromRGB(255,247,251),BorderSizePixel=0,Active=true})
local gradient=make("UIGradient",top,{Color=ColorSequence.new(themes[1][2],themes[1][3]),Transparency=NumberSequence.new(.78)})
local function text(parent,value,x,y,w,h,size,color)
    return make("TextLabel",parent,{Text=value,Position=UDim2.fromOffset(x,y),Size=UDim2.fromOffset(w,h),
        BackgroundTransparency=1,TextColor3=color or white,Font=Enum.Font.Gotham,TextSize=size or 13,
        TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd})
end
local brand=text(top,"Sakura",12,8,116,40,26,themes[1][2])
brand.Font=Enum.Font.Antique
brand.TextXAlignment=Enum.TextXAlignment.Center
brand.TextYAlignment=Enum.TextYAlignment.Center
brand.TextTruncate=Enum.TextTruncate.None
brand.TextScaled=true
make("UITextSizeConstraint",brand,{MinTextSize=18,MaxTextSize=26})
local homeTitle=text(top,"Home",156,6,380,28,24,white)
homeTitle.Font=Enum.Font.Antique
text(top,"Tap Sim Reborn  /  Session overview",157,34,380,16,10,muted)
local function button(parent,value,pos,size)
    local b=make("TextButton",parent,{Text=value,Position=pos,Size=size,BackgroundColor3=Color3.fromRGB(246,218,233),
        TextColor3=white,Font=Enum.Font.GothamMedium,TextSize=13,BorderSizePixel=0})
    round(b,10)
    return b
end
local minimize=button(top,"–",UDim2.new(1,-76,0,14),UDim2.fromOffset(28,28))
local close=button(top,"×",UDim2.new(1,-40,0,14),UDim2.fromOffset(28,28))
local body=make("ScrollingFrame",window,{Position=UDim2.fromOffset(156,66),Size=UDim2.new(1,-170,1,-78),
    BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=3,ScrollBarImageColor3=themes[1][2],
    CanvasSize=UDim2.fromOffset(0,626)})
local function card(y,h,color)
    local c=make("Frame",body,{Position=UDim2.fromOffset(0,y),Size=UDim2.new(1,-6,0,h),
        BackgroundColor3=color or Color3.fromRGB(255,250,253),BorderSizePixel=0,ClipsDescendants=true})
    round(c,12)
    make("UIStroke",c,{Color=themes[1][2],Transparency=.8})
    return c
end
local banner=card(0,112,Color3.fromRGB(221,199,220))
local bannerImage=make("ImageLabel",banner,{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,
    ScaleType=Enum.ScaleType.Crop,Image=""})
local bannerNotice=text(banner,"Loading Sakura artwork…",14,42,480,26,12,Color3.fromRGB(77,57,83))
local profile=card(122,84)
local avatar=make("ImageLabel",profile,{Position=UDim2.fromOffset(14,12),Size=UDim2.fromOffset(60,60),
    BackgroundColor3=Color3.fromRGB(243,218,236),Image=""})
round(avatar,30)
make("UIStroke",avatar,{Color=themes[1][2],Thickness=2})
text(profile,player.DisplayName,90,12,300,25,18,white)
text(profile,"@"..player.Name,90,39,300,18,11,muted)
text(profile,"TAP SIM REBORN",90,60,300,15,10,themes[1][2])
local session=card(216,76)
text(session,"✿  SESSION",14,7,450,22,14,themes[1][2])
local stats=text(session,"Session: 0s  •  Tap attempts: 0",14,37,490,25,14,white)
local function label(value,y,h)
    local l=text(body,value,2,y,526,h or 22,12,muted)
    l.TextWrapped=true
    l.TextTruncate=Enum.TextTruncate.None
    return l
end
label("FARMING",306)
local picker=button(body,"Select game tap button  ›",UDim2.fromOffset(0,334),UDim2.new(1,-6,0,38))
local toggle=button(body,"Auto Tap   •   OFF",UDim2.fromOffset(0,382),UDim2.new(.65,-6,0,38))
local speed=button(body,"0.4s / tap",UDim2.new(.65,4,0,382),UDim2.new(.35,-10,0,38))
label("APPEARANCE",436)
for i,t in ipairs(themes) do
    local b=button(body,t[1],UDim2.new((i-1)*.25,0,0,464),UDim2.new(.25,-6,0,34))
    b.TextColor3=t[2]
    connect(b.Activated,function()
        themeIndex=i
        gradient.Color=ColorSequence.new(t[2],t[3])
        border.Color=t[2]
        brand.TextColor3=t[2]
        body.ScrollBarImageColor3=t[2]
        toggle.TextColor3=running and t[2] or white
    end)
end
local status=label("Ready • select the game's tap button first.",512,48)
label("Right Shift: hide/show  •  drag the top bar to move",580,24)
local menu=make("ScrollingFrame",window,{Visible=false,Position=UDim2.fromOffset(156,136),
    Size=UDim2.new(1,-176,0,240),BackgroundColor3=Color3.fromRGB(255,240,248),BorderSizePixel=0,
    ScrollBarThickness=4,AutomaticCanvasSize=Enum.AutomaticSize.Y,CanvasSize=UDim2.new(),ZIndex=5})
round(menu)
make("UIListLayout",menu,{Padding=UDim.new(0,4),SortOrder=Enum.SortOrder.LayoutOrder})
task.spawn(function()
    local ok,result=pcall(function()
        return Players:GetUserThumbnailAsync(player.UserId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size150x150)
    end)
    if alive and ok then avatar.Image=result end
end)
task.spawn(function()
    local env=type(getgenv)=="function" and getgenv() or _G
    local override=env.YozakuraSakuraBannerAsset
    local ok,result=pcall(function()
        if type(override)=="string" and override~="" then return override end
        local register=getcustomasset or getsynasset
        assert(type(register)=="function" and type(writefile)=="function","Custom image support unavailable")
        local path="Yozakura-SakuraLight-r2.jpg"
        local bytes=game:HttpGet("https://raw.githubusercontent.com/koviescobar77-design/Yozakura/main/assets/sakura-light-banner.jpg")
        assert(bytes:sub(1,2)==string.char(255,216),"Invalid banner download")
        writefile(path,bytes)
        return register(path)
    end)
    if not alive then return end
    if ok then bannerImage.Image=result bannerNotice.Visible=false
    else bannerNotice.Text="Sakura image unavailable on this executor."
        warn("[Sakura banner] "..tostring(result)) end
end)
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
    rail.Visible=not mini
    menu.Visible=false
    window.Size=UDim2.fromOffset(720,mini and 56 or 560)
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
        window.Position=UDim2.new(original.X.Scale,original.X.Offset+delta.X/scale.Scale,
            original.Y.Scale,original.Y.Offset+delta.Y/scale.Scale)
    end
end)
connect(UIS.InputEnded,function(input)
    if input==dragging or input.UserInputType==Enum.UserInputType.MouseButton1 then dragging=nil end
end)
local function resize()
    local camera=workspace.CurrentCamera
    if camera then
        local v=camera.ViewportSize
        scale.Scale=math.max(0.1, math.min((v.X-24)/720,(v.Y-40)/560,1))
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
