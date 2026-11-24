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
    AnchorPoint=Vector2.new(.5,.5),BackgroundColor3=Color3.fromRGB(24,12,23),BackgroundTransparency=.15,BorderSizePixel=0,ClipsDescendants=true})
round(window,16)
local scale=make("UIScale",window,{Scale=1})
local border=make("UIStroke",window,{Color=accent,Transparency=.6})
local top=make("Frame",window,{Size=UDim2.new(1,0,0,70),BackgroundColor3=Color3.fromRGB(58,22,42),BackgroundTransparency=.18,BorderSizePixel=0,Active=true})
local gradient=make("UIGradient",top,{Color=ColorSequence.new(accent,accentShade),Rotation=18,Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,.52),NumberSequenceKeypoint.new(1,.91)})})
local function text(parent,value,x,y,w,h,size,color)
    return make("TextLabel",parent,{Text=value,Position=UDim2.fromOffset(x,y),Size=UDim2.fromOffset(w,h),
        BackgroundTransparency=1,TextColor3=color or white,Font=Enum.Font.GothamMedium,TextSize=size or 14,
        TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd})
end
local stickerImages={}
local function circuitSticker(parent,x,y,size)
    local tile=make("Frame",parent,{Position=UDim2.fromOffset(x,y),Size=UDim2.fromOffset(size,size),
        BackgroundColor3=Color3.fromRGB(27,23,40),BorderSizePixel=0,ZIndex=parent.ZIndex+1})
    local radius=size==58 and 29 or 9
    round(tile,radius)
    local fallback=text(tile,"✿",0,0,size,size,23,accent)
    fallback.TextXAlignment=Enum.TextXAlignment.Center
    fallback.ZIndex=tile.ZIndex
    local icon=make("ImageLabel",tile,{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,
        ScaleType=Enum.ScaleType.Crop,ZIndex=tile.ZIndex+1})
    round(icon,radius)
    table.insert(stickerImages,icon)
end
circuitSticker(top,9,17,36)
local brand=text(top,"Sakura",45,12,91,46,32,Color3.new(1,1,1))
brand.Font=Enum.Font.Antique
brand.TextXAlignment=Enum.TextXAlignment.Center
brand.TextYAlignment=Enum.TextYAlignment.Center
brand.TextTruncate=Enum.TextTruncate.None
brand.TextScaled=true
make("UITextSizeConstraint",brand,{MinTextSize=18,MaxTextSize=32})
local gold=Color3.fromRGB(255,219,177)
make("UIGradient",brand,{Rotation=85,Color=ColorSequence.new(gold,accent)})
local homeTitle=text(top,"",156,12,470,46,24,white)
homeTitle.Font=Enum.Font.Antique
task.spawn(function()
    local ok,info=pcall(function()
        return game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId,Enum.InfoType.Asset)
    end)
    if alive and ok and type(info.Name)=="string" then
        homeTitle.Text=info.Name
    end
end)
local function button(parent,value,pos,size)
    local b=make("TextButton",parent,{Text=value,Position=pos,Size=size,BackgroundColor3=Color3.fromRGB(92,34,61),BackgroundTransparency=.23,
        TextColor3=white,Font=Enum.Font.GothamMedium,TextSize=14,BorderSizePixel=0})
    round(b,10)
    make("UIStroke",b,{Color=accent,Transparency=.73})
    return b
end
local minimize=button(top,"–",UDim2.new(1,-76,0,14),UDim2.fromOffset(28,28))
local close=button(top,"×",UDim2.new(1,-40,0,14),UDim2.fromOffset(28,28))
local body=make("ScrollingFrame",window,{Position=UDim2.fromOffset(14,80),Size=UDim2.new(1,-28,1,-92),
    BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=3,ScrollBarImageColor3=accent,
    CanvasSize=UDim2.new(),AutomaticCanvasSize=Enum.AutomaticSize.Y})
local function card(y,h,color)
    local c=make("Frame",body,{Position=UDim2.fromOffset(0,y),Size=UDim2.new(1,-6,0,h),
        BackgroundColor3=color or Color3.fromRGB(59,30,52),BackgroundTransparency=.24,BorderSizePixel=0,ClipsDescendants=true})
    make("UIStroke",c,{Color=Color3.fromRGB(255,205,227),Transparency=.65})
    local sheen=make("Frame",c,{Position=UDim2.fromOffset(12,1),Size=UDim2.new(1,-24,0,2),
        BackgroundColor3=Color3.fromRGB(255,205,227),BorderSizePixel=0})
    make("UIGradient",sheen,{Transparency=NumberSequence.new({
        NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(.28,.35),NumberSequenceKeypoint.new(1,1)})})
    return c
end
local banner=card(0,181,Color3.fromRGB(65,24,55))
local bannerImage=make("ImageLabel",banner,{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,
    ScaleType=Enum.ScaleType.Crop,Image="",ZIndex=2})
local bannerNotice=text(banner,"Loading Sakura artwork…",14,77,480,26,12,Color3.fromRGB(255,222,242))
local profile=card(191,84)
local avatar=make("ImageLabel",profile,{Position=UDim2.fromOffset(14,12),Size=UDim2.fromOffset(60,60),
    BackgroundColor3=Color3.fromRGB(78,31,66),Image=""})
round(avatar,30)
make("UIStroke",avatar,{Color=accent,Thickness=2})
text(profile,player.DisplayName,90,12,300,25,18,white)
text(profile,"@"..player.Name,90,39,300,18,13,muted)
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
    "nezuko-action-crimson.jpg",
    "nezuko-scene-rose-moon.jpg",
    "nezuko-action-indigo.jpg",
}
local bannerRoot="https://raw.githubusercontent.com/koviescobar77-design/Yozakura/main/assets/"

local env=type(getgenv)=="function" and getgenv() or _G
local lite=env.SakuraLite==true
local function getArtwork(name)
    local register=getcustomasset or getsynasset
    assert(type(register)=="function","Custom images unavailable")
    local path="Sakura-"..name
    if type(isfile)=="function" and type(readfile)=="function" then
        local ok,uri=pcall(function()
            if not isfile(path) then return end
            local bytes=readfile(path)
            if bytes:sub(1,2)==string.char(255,216) and bytes:sub(-2)==string.char(255,217) then
                return register(path)
            end
        end)
        if ok and type(uri)=="string" and uri~="" then return uri end
    end
    local bytes=game:HttpGet(bannerRoot..name)
    assert(bytes:sub(1,2)==string.char(255,216) and bytes:sub(-2)==string.char(255,217),"Invalid JPEG")
    writefile(path,bytes)
    local uri=register(path)
    assert(type(uri)=="string" and uri~="","Empty asset URI")
    return uri
end
task.spawn(function()
    local ready={}
    for _,name in ipairs(bannerFiles) do
        if not alive then return end
        local ok,asset=pcall(getArtwork,name)
        if not alive then return end
        if ok then
            table.insert(ready,asset)
            if #ready==1 then
                bannerImage.Image=asset
                bannerNotice.Visible=false
                if lite then return end
            end
        end
    end
    if #ready==0 then
        local fallback=env.YozakuraSakuraBannerAsset
        if type(fallback)=="string" and fallback~="" then
            bannerImage.Image=fallback
            bannerNotice.Visible=false
        else
            bannerNotice.Text="Nezuko artwork could not load."
        end
        return
    end
    if #ready<2 then return end
    local index=1
    while alive do
        task.wait(5)
        if alive and window.Visible and body.Visible then
            index=index%#ready+1
            bannerImage.Image=ready[index]
        end
    end
end)
-- Kept outside the window so hiding the panel leaves a restore button.
local restore=make("TextButton",gui,{Name="SakuraRestore",Visible=false,Text="",
    Position=UDim2.new(0,20,.5,-29),Size=UDim2.fromOffset(58,58),
    BackgroundColor3=Color3.fromRGB(89,31,74),BorderSizePixel=0,
    AutoButtonColor=true,ZIndex=20})
round(restore,29)
make("UIStroke",restore,{Color=accent,Thickness=2,Transparency=.15})
circuitSticker(restore,0,0,58)
task.spawn(function()
    local ok,asset=pcall(getArtwork,"sakura-circuit-sticker.jpg")
    if alive and ok then
        for _,icon in ipairs(stickerImages) do icon.Image=asset end
    end
end)
local function showWindow(show)
    window.Visible=show
    restore.Visible=not show
end
connect(restore.Activated,function() showWindow(true) end)
local mini=false
connect(minimize.Activated,function()
    mini=not mini
    body.Visible=not mini
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
local viewportConnection
local function watchCamera()
    if viewportConnection then viewportConnection:Disconnect() end
    local camera=workspace.CurrentCamera
    viewportConnection=camera and camera:GetPropertyChangedSignal("ViewportSize"):Connect(resize)
    resize()
end
connect(workspace:GetPropertyChangedSignal("CurrentCamera"),watchCamera)
watchCamera()
connect(gui.Destroying,function()
    alive=false
    if viewportConnection then viewportConnection:Disconnect() end
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
        if window.Visible and body.Visible then refreshSession() end
        task.wait(1)
    end
end)
