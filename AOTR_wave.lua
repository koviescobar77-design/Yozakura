-- Wave R18: mission-scoped UI and READY input; uses the existing farm workers.
local api=...
local v4,v3=api.state,api.ui
local pg=api.player:WaitForChild("PlayerGui")
local alive=true
local connections={}
local outline,pressedPoint
local input=game:GetService("VirtualInputManager")
local function connect(signal,fn)
    local c=signal:Connect(fn);connections[#connections+1]=c
end
local function release()
    if pressedPoint then
        local p=pressedPoint;pressedPoint=nil
        pcall(function()input:SendMouseButtonEvent(p.X,p.Y,0,false,game,0)end)
    end
    if outline then outline:Destroy();outline=nil end
end
local function make(class,parent,props)
    local o=Instance.new(class)
    for k,v in pairs(props) do o[k]=v end
    o.Parent=parent
    return o
end
local page=make("Frame",v3["2"],{Name="WaveFrame",Position=v3["4"].Position,
    Size=v3["4"].Size,BackgroundTransparency=1,Visible=false})
local function button(parent,text,y)
    local b=make("TextButton",parent,{Text=text,Size=UDim2.new(0.94,0,0.18,0),
        Position=UDim2.new(0.03,0,y,0),BackgroundColor3=Color3.fromRGB(35,34,38),
        TextColor3=Color3.new(1,1,1),Font=Enum.Font.SourceSansBold,
        TextScaled=true,TextWrapped=true,BorderSizePixel=0})
    make("UICorner",b,{CornerRadius=UDim.new(0,12)})
    make("UIStroke",b,{Color=Color3.new(1,1,1),ApplyStrokeMode=Enum.ApplyStrokeMode.Border})
    return b
end
local ready=button(page,"Auto Ready: ON",0.04)
local farm=button(page,"Wave Autofarm: OFF",0.27)
local status=make("TextLabel",page,{Text="Wave R18 • Waves missions only",Position=UDim2.new(0.03,0,0.52,0),
    Size=UDim2.new(0.94,0,0.4,0),BackgroundTransparency=1,TextWrapped=true,TextScaled=true,
    Font=Enum.Font.SourceSans,TextColor3=Color3.new(1,1,1)})
local tab=button(v3["2"],"Wave",0.30)
tab.Name="WaveTab";tab.Position=UDim2.new(0.0194,0,0.30,0);tab.Size=UDim2.new(0.16,0,0.10,0)
for _,entry in ipairs({{v3["55"],0.18},{v3["2"]:FindFirstChild("SaveSetup"),0.43},
    {v3["2"]:FindFirstChild("AutoConfig"),0.56},{v3["5d"],0.69},{v3["62"],0.82}}) do
    if entry[1] then entry[1].Position=UDim2.new(0.0194,0,entry[2],0);entry[1].Size=UDim2.new(0.16,0,0.10,0) end
end
local function paint()
    ready.Text="Auto Ready: "..(v4.waveReadyEnabled and "ON" or "OFF")
    farm.Text="Wave Autofarm: "..(v4.waveRequested and "ON" or "OFF")
    ready.BackgroundColor3=v4.waveReadyEnabled and Color3.fromRGB(20,115,39) or Color3.fromRGB(35,34,38)
    farm.BackgroundColor3=v4.waveRequested and Color3.fromRGB(20,115,39) or Color3.fromRGB(35,34,38)
end
connect(tab.Activated,function()v3["4"].Visible=false;page.Visible=true;paint()end)
connect(v3["56"].Activated,function()page.Visible=false;v3["4"].Visible=true end)
connect(ready.Activated,function()v4.waveReadyEnabled=not v4.waveReadyEnabled;release();paint()end)
connect(farm.Activated,function()
    if not v4.isWaveMission() then status.Text="Wave farm is available only with Waves Cleared objectives.";return end
    if v4.waveRequested then
        v4.waveRequested=false;api.stopFarm()
    else
        api.stopFarm()
        v4.waveRequested=true
    end
    paint()
end)
local function clean(text)return text:gsub("<[^>]->",""):lower():match("^%s*(.-)%s*$")end
local function readyTarget()
    local result
    for _,label in ipairs(pg:GetDescendants()) do
        if (label:IsA("TextButton") or label:IsA("TextLabel")) and api.visible(label)
            and clean(label.Text)=="ready" then
            local p=label.Parent
            while p and p~=pg and not p:IsA("ScreenGui") do
                local vote,complete=false,false
                for _,o in ipairs(p:GetDescendants()) do
                    if (o:IsA("TextLabel") or o:IsA("TextButton")) and api.visible(o) then
                        local t=clean(o.Text)
                        if t=="vote start" then vote=true end
                        local n,total=t:match("^(%d+)%s*/%s*(%d+)$")
                        if n and tonumber(total)>0 and tonumber(n)>=tonumber(total) then complete=true end
                    end
                end
                if vote then
                    if complete then return nil end
                    local b=label
                    while b.Parent~=p and not b:IsA("GuiButton") do b=b.Parent end
                    if not b:IsA("GuiButton") then b=label end
                    if result and result~=b then return nil end
                    result=b;break
                end
                p=p.Parent
            end
        end
    end
    return result
end
local function readyClick(target)
    release()
    outline=make("UIStroke",target,{Color=Color3.fromRGB(35,145,255),Thickness=3,
        ApplyStrokeMode=Enum.ApplyStrokeMode.Border})
    local pos,size=target.AbsolutePosition,target.AbsoluteSize
    task.wait(0.3)
    if not alive or not api.valid() or not v4.waveReadyEnabled or not v4.isWaveMission()
        or readyTarget()~=target or not api.visible(target) then release();return end
    if (target.AbsolutePosition-pos).Magnitude>1 or (target.AbsoluteSize-size).Magnitude>1 then release();return end
    local center=pos+size/2
    local accepted=false
    for _,hit in ipairs(pg:GetGuiObjectsAtPosition(center.X,center.Y)) do
        if hit==target or hit:IsDescendantOf(target) then accepted=true;break end
        if (hit:IsA("GuiButton") or hit:IsA("TextBox") or hit.Active) and not target:IsDescendantOf(hit) then break end
    end
    if not accepted then status.Text="READY blocked: move the Yozakura panel away from the blue box.";release();return end
    local point=center+game:GetService("GuiService"):GetGuiInset()
    input:SendMouseMoveEvent(point.X,point.Y,game)
    pressedPoint=point
    input:SendMouseButtonEvent(point.X,point.Y,0,true,game,0)
    task.wait(0.05)
    release()
    status.Text="READY click sent; waiting for vote / wave."
end
local function startFarm()
    local character=api.player.Character
    local root=character and character:FindFirstChild("HumanoidRootPart")
    local hum=character and character:FindFirstChildOfClass("Humanoid")
    if not root or not hum or hum.Health<=0 then return end
    v4.character,v4.root,v4.humanoid=character,root,hum
    v4.autofarmEnabled=false;v4.oldfarmEnabled=true;v4.waveFarmEnabled=true
    v4.autoAttack=true;v4.centerClickFailed=false;v4.skillInputFailed=false
    v4.pendingFarmMode=nil;v4.farmDeadline=nil
    v3["32"].BackgroundColor3=Color3.new(1,0,0)
    v3["4a"].BackgroundColor3=Color3.new(1,0,0)
    api.startFarm()
end
paint()
local thread=task.spawn(function()
    while alive and api.valid() do
        local ok,err=pcall(function()
            if not v4.isWaveMission() then
                if v4.waveFarmEnabled then api.stopFarm() end
                status.Text="Wave R18 • inactive outside Waves missions"
                return
            end
            if api.results() then return end
            local target=readyTarget()
            if target then
                if v4.waveFarmEnabled then api.stopFarm(nil,true) end
                if v4.waveReadyEnabled then readyClick(target) end
            elseif v4.waveRequested then
                if not v4.waveFarmEnabled then startFarm()
                elseif not v4.movementWorkerRunning and not v4.combatWorkerRunning then api.startFarm() end
                status.Text="Wave farm running • travel up to 900 • attack interval 0.3s"
            else
                status.Text="Waves detected • enable Wave Autofarm to start"
            end
            paint()
        end)
        if not ok then release();status.Text="Wave input error: "..tostring(err) end
        task.wait(1)
    end
    release()
end)
return function()
    alive=false;release()
    for _,c in ipairs(connections) do c:Disconnect() end
    pcall(task.cancel,thread)
    page:Destroy();tab:Destroy()
end
