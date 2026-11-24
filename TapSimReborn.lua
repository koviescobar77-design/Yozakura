-- Sakura • Tap Sim Reborn • revision 6 • Pink Moonlight
-- Standalone UI. Does not change loader.lua.
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
-- Pale rose text keeps the dark surfaces readable.
local white = Color3.fromRGB(255,232,245)
local muted = Color3.fromRGB(224,174,206)
local accent = Color3.fromRGB(255,159,193)
local accentShade = Color3.fromRGB(183,84,131)
local gui = make("ScreenGui",pg,{Name="YozakuraTapReborn",ResetOnSpawn=false,
    ZIndexBehavior=Enum.ZIndexBehavior.Sibling,DisplayOrder=50})
local connections = {}
local alive = true
local function connect(signal, fn)
    local c = signal:Connect(fn)
    table.insert(connections,c)
    return c
end
-- Blank sidebar is reserved for the owner's future navigation labels.
local window=make("Frame",gui,{Size=UDim2.fromOffset(720,560),Position=UDim2.fromScale(.5,.5),
    AnchorPoint=Vector2.new(.5,.5),BackgroundColor3=Color3.fromRGB(24,12,23),BorderSizePixel=0,ClipsDescendants=true})
round(window,16)
local scale=make("UIScale",window,{Scale=1})
local border=make("UIStroke",window,{Color=accent,Transparency=.6})
local rail=make("Frame",window,{Name="ReservedSidebar",Position=UDim2.fromOffset(0,70),
    Size=UDim2.new(0,140,1,-70),BackgroundColor3=Color3.fromRGB(39,16,32),BorderSizePixel=0})
-- Intentionally no menu labels, menu icons, or placeholder actions.
local top=make("Frame",window,{Size=UDim2.new(1,0,0,70),BackgroundColor3=Color3.fromRGB(58,22,42),BorderSizePixel=0,Active=true})
local gradient=make("UIGradient",top,{Color=ColorSequence.new(accent,accentShade),Transparency=NumberSequence.new(.78)})
local function text(parent,value,x,y,w,h,size,color)
    return make("TextLabel",parent,{Text=value,Position=UDim2.fromOffset(x,y),Size=UDim2.fromOffset(w,h),
        BackgroundTransparency=1,TextColor3=color or white,Font=Enum.Font.GothamMedium,TextSize=size or 14,
        TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd})
end
-- Native fox sticker, shared by the header and restore button.
local function foxSticker(parent,x,y,size)
    local fox=make("Frame",parent,{Position=UDim2.fromOffset(x,y),Size=UDim2.fromOffset(size,size),
        BackgroundTransparency=1,ZIndex=parent.ZIndex+1})
    local rose=Color3.fromRGB(244,117,170)
    local blush=Color3.fromRGB(255,200,220)
    local plum=Color3.fromRGB(62,22,47)
    local function shape(xPos,yPos,width,height,color,rotation,radius)
        local part=make("Frame",fox,{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(xPos,yPos),
            Size=UDim2.fromScale(width,height),BackgroundColor3=color,BorderSizePixel=0,
            Rotation=rotation or 0,ZIndex=fox.ZIndex})
        round(part,radius)
    end
    shape(.25,.28,.36,.36,rose,29,3)
    shape(.75,.28,.36,.36,rose,-29,3)
    shape(.24,.26,.18,.18,blush,29,2)
    shape(.76,.26,.18,.18,blush,-29,2)
    shape(.5,.58,.91,.62,rose,0,size)
    shape(.5,.73,.61,.32,Color3.fromRGB(255,228,238),0,size)
    shape(.32,.57,.075,.115,plum,-12,size)
    shape(.68,.57,.075,.115,plum,12,size)
    shape(.5,.70,.10,.075,plum,0,size)
    return fox
end
foxSticker(top,9,19,32)
local brand=text(top,"Sakura",45,12,91,46,32,Color3.new(1,1,1))
brand.Font=Enum.Font.Antique
brand.TextXAlignment=Enum.TextXAlignment.Center
brand.TextYAlignment=Enum.TextYAlignment.Center
brand.TextTruncate=Enum.TextTruncate.None
brand.TextScaled=true
make("UITextSizeConstraint",brand,{MinTextSize=18,MaxTextSize=32})
local gold=Color3.fromRGB(255,219,177)
make("UIGradient",brand,{Rotation=85,Color=ColorSequence.new(gold,accent)})
local homeTitle=text(top,"Nezuko Moonlight",156,8,380,30,25,white)
homeTitle.Font=Enum.Font.Antique
text(top,"Tap Sim Reborn  /  Session overview",157,42,380,20,13,Color3.fromRGB(239,193,151))
local function button(parent,value,pos,size)
    local b=make("TextButton",parent,{Text=value,Position=pos,Size=size,BackgroundColor3=Color3.fromRGB(92,34,61),
        TextColor3=white,Font=Enum.Font.GothamMedium,TextSize=14,BorderSizePixel=0})
    round(b,10)
    return b
end
local minimize=button(top,"–",UDim2.new(1,-76,0,14),UDim2.fromOffset(28,28))
local close=button(top,"×",UDim2.new(1,-40,0,14),UDim2.fromOffset(28,28))
local body=make("ScrollingFrame",window,{Position=UDim2.fromOffset(156,80),Size=UDim2.new(1,-170,1,-92),
    BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=3,ScrollBarImageColor3=accent,
    CanvasSize=UDim2.new(),AutomaticCanvasSize=Enum.AutomaticSize.Y})
local function card(y,h,color)
    local c=make("Frame",body,{Position=UDim2.fromOffset(0,y),Size=UDim2.new(1,-6,0,h),
        BackgroundColor3=color or Color3.fromRGB(53,22,41),BorderSizePixel=0,ClipsDescendants=true})
    round(c,12)
    make("UIStroke",c,{Color=accent,Transparency=.8})
    return c
end
local banner=card(0,181,Color3.fromRGB(65,24,55))
local bannerImage=make("ImageLabel",banner,{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,
    ScaleType=Enum.ScaleType.Fit,Image="",ZIndex=2})
round(bannerImage,12)
local bannerNotice=text(banner,"Loading Sakura artwork…",14,77,480,26,12,Color3.fromRGB(255,222,242))
local profile=card(191,84)
local avatar=make("ImageLabel",profile,{Position=UDim2.fromOffset(14,12),Size=UDim2.fromOffset(60,60),
    BackgroundColor3=Color3.fromRGB(78,31,66),Image=""})
round(avatar,30)
make("UIStroke",avatar,{Color=accent,Thickness=2})
text(profile,player.DisplayName,90,12,300,25,18,white)
text(profile,"@"..player.Name,90,39,300,18,13,muted)
text(profile,"TAP SIM REBORN",90,60,300,17,12,accent)
local session=card(285,76)
text(session,"✿  SESSION",14,7,450,22,14,accent)
local stats=text(session,"Session: 0s",14,37,490,25,14,white)
task.spawn(function()
    local ok,result=pcall(function()
        return Players:GetUserThumbnailAsync(player.UserId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size150x150)
    end)
    if alive and ok then avatar.Image=result end
end)
local bannerFiles={
    "nezuko-scene-flames.jpg",
    "nezuko-scene-rain.jpg",
    "nezuko-scene-rose-moon.jpg",
}
local bannerRoot="https://raw.githubusercontent.com/koviescobar77-design/Yozakura/main/assets/"

task.spawn(function()
    local ready={}
    local register=getcustomasset or getsynasset
    local provider=game:GetService("ContentProvider")
    local preloadTargets={}
    if type(register)=="function" and type(writefile)=="function" then
        for _,name in ipairs(bannerFiles) do
            if not alive then return end
            local ok,asset=pcall(function()
                local bytes=game:HttpGet(bannerRoot..name)
                assert(bytes:sub(1,2)==string.char(255,216),"Invalid JPEG")
                local path="Sakura-"..name
                writefile(path,bytes)
                local uri=register(path)
                assert(type(uri)=="string" and uri~="","Empty asset URI")
                return uri
            end)
            if not alive then return end
            if ok then
                table.insert(ready,asset)
                local preloadImage=Instance.new("ImageLabel")
                preloadImage.Image=asset
                table.insert(preloadTargets,preloadImage)
                if #ready==1 then
                    bannerImage.Image=asset
                    bannerNotice.Visible=false
                end
            else
                warn("[Sakura banner] "..name..": "..tostring(asset))
            end
        end
    end
    if not alive then return end
    if #ready==0 then
        local env=type(getgenv)=="function" and getgenv() or _G
        local fallback=env.YozakuraSakuraBannerAsset
        if type(fallback)=="string" and fallback~="" then
            bannerImage.Image=fallback
            bannerNotice.Visible=false
        else
            bannerNotice.Text="Nezuko artwork could not load."
        end
        return
    end
    pcall(function() provider:PreloadAsync(preloadTargets) end)
    for _,target in ipairs(preloadTargets) do target:Destroy() end
    if not alive or #ready<2 then return end
    local index=1
    while alive do
        task.wait(5)
        if not alive then break end
        index=index%#ready+1
        bannerImage.Image=ready[index]
    end
end)
-- Kept outside the window so hiding the panel leaves a restore button.
local restore=make("TextButton",gui,{Name="SakuraRestore",Visible=false,Text="",
    Position=UDim2.new(0,20,.5,-29),Size=UDim2.fromOffset(58,58),
    BackgroundColor3=Color3.fromRGB(89,31,74),BorderSizePixel=0,
    AutoButtonColor=true,ZIndex=20})
round(restore,29)
make("UIStroke",restore,{Color=accent,Thickness=2,Transparency=.15})
foxSticker(restore,10,10,38)
local function showWindow(show)
    window.Visible=show
    restore.Visible=not show
end
connect(restore.Activated,function() showWindow(true) end)
local mini=false
connect(minimize.Activated,function()
    mini=not mini
    body.Visible=not mini
    rail.Visible=not mini
    window.Size=UDim2.fromOffset(720,mini and 70 or 560)
    minimize.Text=mini and "+" or "–"
end)
connect(UIS.InputBegan,function(input,processed)
    if not processed and input.KeyCode==Enum.KeyCode.RightShift then showWindow(not window.Visible) end
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
    alive=false
    for _,c in ipairs(connections) do c:Disconnect() end
end)
connect(close.Activated,function() showWindow(false) end)
local started=os.clock()
local function refreshSession()
    stats.Text=string.format("Session: %ds",math.floor(os.clock()-started))
end
local reset=button(body,"Reset session counter",UDim2.fromOffset(0,371),UDim2.new(1,-6,0,38))
connect(reset.Activated,function()
    started=os.clock()
    refreshSession()
end)
task.spawn(function()
    while alive do
        refreshSession()
        task.wait(1)
    end
end)
