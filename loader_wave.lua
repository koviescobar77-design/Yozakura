-- Wave loader: visible startup UI and READY run independently of the farm engine.
local env=type(getgenv)=="function" and getgenv() or _G
local players=game:GetService("Players")
local player=players.LocalPlayer
assert(player,"Wave loader requires a LocalPlayer")
local pg=player:WaitForChild("PlayerGui",30)
assert(pg,"PlayerGui unavailable")
if env.YozakuraWaveRuntime then pcall(env.YozakuraWaveRuntime.Stop) end
local gui=Instance.new("ScreenGui")
gui.Name="YozakuraWaveStartup";gui.ResetOnSpawn=false;gui.DisplayOrder=10020;gui.Parent=pg
local frame=Instance.new("Frame",gui)
frame.Size=UDim2.new(0,430,0,310);frame.Position=UDim2.new(1,-450,0.5,-155)
frame.BackgroundColor3=Color3.fromRGB(24,28,35)
Instance.new("UICorner",frame).CornerRadius=UDim.new(0,12)
local title=Instance.new("TextLabel",frame)
title.Size=UDim2.new(1,0,0,40);title.BackgroundTransparency=1;title.Text="Yozakura Wave"
title.TextColor3=Color3.new(1,1,1);title.TextSize=24;title.Font=Enum.Font.SourceSansBold
local status=title:Clone();status.Parent=frame;status.Position=UDim2.new(0,8,1,-48)
status.Size=UDim2.new(1,-16,0,44);status.TextSize=15;status.TextWrapped=true
local active,controls=true,nil
local connections,threads={},{}
local session={}
local function report(text)
    if not active then return end
    status.Text=tostring(text);print("[Yozakura Wave] "..tostring(text))
end
session.report=report
function session.mode() return active and "wave" or "stopped" end
session.isCurrent=function() return active end
function session.Stop()
    if not active then return end
    active=false
    if controls then pcall(controls.Stop) end
    if session.stopMission then pcall(session.stopMission) end
    for _,c in ipairs(connections) do c:Disconnect() end
    for _,t in ipairs(threads) do if t~=coroutine.running() then pcall(task.cancel,t) end end
    gui:Destroy()
    if env.YozakuraWaveRuntime==session then env.YozakuraWaveRuntime=nil end
end
env.YozakuraWaveRuntime=session
local function spawn(fn)
    local t=task.spawn(function()
        local ok,err=pcall(fn)
        if not ok then report("Execution error: "..tostring(err)) end
    end)
    table.insert(threads,t);return t
end
local function connect(signal,fn)
    local c=signal:Connect(fn);table.insert(connections,c);return c
end
local function waveVisible()
    for _,o in ipairs(pg:GetDescendants()) do
        if not o:IsDescendantOf(gui) and (o:IsA("TextLabel") or o:IsA("TextButton")) then
            local text=o.Text:gsub("<[^>]*>",""):lower()
            if text:match("waves%s+cleared%s*%[") then
                local visible=true
                local p=o
                while p and p~=pg do
                    if (p:IsA("GuiObject") and not p.Visible) or (p:IsA("ScreenGui") and not p.Enabled) then visible=false;break end
                    p=p.Parent
                end
                if visible then return true end
            end
        end
    end
    return false
end
report("Waiting for the Wave mission screen...")
local factory=(function()
-- Wave controls use the existing WIP combat worker; no extra attack requests.
return function(ctx)
    local pg, ui = ctx.playerGui, ctx.ui
    local alive, readyEnabled, ownedFarm = true, false, false
    local outline, held, sent, lastAttempt
    local attempts, message, selectedBefore, keyHeld = 0, "Waiting for VOTE START / READY.", nil, false
    local guiService = game:GetService("GuiService")
    local input = game:GetService("VirtualInputManager")
    local function clean(text)
        return tostring(text):gsub("<[^>]*>", ""):lower():match("^%s*(.-)%s*$")
    end
    local function visible(o)
        if not o or not o:IsDescendantOf(pg) or o:IsDescendantOf(ui) then return false end
        local node=o
        while node and node~=pg do
            if node:IsA("GuiObject") and not node.Visible then return false end
            if node:IsA("ScreenGui") and not node.Enabled then return false end
            node=node.Parent
        end
        return o:IsA("GuiObject") and o.AbsoluteSize.X>0 and o.AbsoluteSize.Y>0
    end
    local function isWave()
        if not alive or not ctx.current() then return false end
        for _,o in ipairs(pg:GetDescendants()) do
            if (o:IsA("TextLabel") or o:IsA("TextButton")) and visible(o)
                and clean(o.Text):match("^waves%s+cleared%s*%[") then return true end
        end
        return false
    end
    local function readyTarget()
        local found, foundPanel
        for _,o in ipairs(pg:GetDescendants()) do
            if (o:IsA("TextButton") or o:IsA("TextLabel")) and visible(o) and clean(o.Text)=="ready" then
                local panel=o.Parent
                for _=1,6 do
                    if not panel or panel==pg or panel:IsA("ScreenGui") then break end
                    local vote=false
                    for _,label in ipairs(panel:GetDescendants()) do
                        if (label:IsA("TextLabel") or label:IsA("TextButton")) and visible(label)
                            and clean(label.Text)=="vote start" then vote=true;break end
                    end
                    if vote then
                        -- READY can be a label inside a custom clickable Frame.
                        -- Its visible center is a valid physical target even without a GuiButton ancestor.
                        if found and found~=o then return nil end
                        found,foundPanel=o,panel;break
                    end
                    panel=panel.Parent
                end
            end
        end
        return found,foundPanel
    end
    local function voteCount(panel)
        if not panel then return end
        for _,o in ipairs(panel:GetDescendants()) do
            if (o:IsA("TextLabel") or o:IsA("TextButton")) and visible(o) then
                local n,total=clean(o.Text):match("^(%d+)%s*/%s*(%d+)$")
                if n then return tonumber(n),tonumber(total) end
            end
        end
    end
    local function clear()
        if outline then outline:Destroy();outline=nil end
    end
    local function release()
        if keyHeld then
            keyHeld=false
            pcall(function() input:SendKeyEvent(false,Enum.KeyCode.Return,false,game) end)
            pcall(function() guiService.SelectedObject=selectedBefore end)
        end
        if held then
            local point=held;held=nil
            pcall(function() input:SendMouseButtonEvent(point.X,point.Y,0,false,game,0) end)
        end
    end
    local function button(name,text,parent,y)
        local b=Instance.new("TextButton")
        b.Name=name;b.Text=text;b.TextSize=17;b.TextWrapped=true
        b.Font=Enum.Font.SourceSansBold;b.TextColor3=Color3.new(1,1,1)
        b.BackgroundColor3=Color3.fromRGB(40,65,85);b.BorderSizePixel=0
        b.Size=UDim2.new(0.94,0,0,36);b.Position=UDim2.new(0.03,0,0,y);b.Parent=parent
        Instance.new("UICorner",b).CornerRadius=UDim.new(0,10)
        return b
    end
    local panel=Instance.new("Frame")
    panel.Name="WavePanel";panel.BackgroundTransparency=1
    panel.Size=UDim2.new(0.96,0,0.78,0);panel.Position=UDim2.new(0.02,0,0.19,0)
    panel.Visible=true;panel.Parent=ui
    local ready=button("AutoReady","Auto Ready: OFF",panel,0)
    local farm=button("WaveFarm","Wave Farm: OFF",panel,44)
    local status=Instance.new("TextLabel")
    status.BackgroundTransparency=1;status.TextColor3=Color3.new(1,1,1);status.TextWrapped=true
    status.TextSize=16;status.Size=UDim2.new(0.94,0,0,70);status.Position=UDim2.new(0.03,0,0,88);status.Parent=panel
    if ctx.stopRuntime then
        local stop=button("StopWave","Stop Wave Script",panel,166)
        ctx.connect(stop.Activated,ctx.stopRuntime)
    end
    ctx.connect(ready.Activated,function()
        if not isWave() then status.Text="Available only inside a Wave mission.";return end
        readyEnabled=not readyEnabled;sent=nil;lastAttempt=nil;attempts=0;message="Waiting for READY."
        ready.Text="Auto Ready: "..(readyEnabled and "ON" or "OFF")
        if not readyEnabled then clear();release() end
    end)
    ctx.connect(farm.Activated,function()
        if not isWave() then status.Text="Available only inside a Wave mission.";return end
        if ownedFarm then ctx.stopFarm();ownedFarm=false
        else ownedFarm=ctx.startFarm()==true end
        farm.Text="Wave Farm: "..(ownedFarm and "ON" or "OFF")
    end)
    local function click(target, votePanel)
        clear()
        outline=Instance.new("Frame");outline.Name="YozakuraReadyOutline"
        outline.BackgroundTransparency=1;outline.Active=false;outline.Selectable=false
        outline.Size=UDim2.fromScale(1,1);outline.ZIndex=target.ZIndex+1;outline.Parent=target
        local stroke=Instance.new("UIStroke",outline)
        stroke.ApplyStrokeMode=Enum.ApplyStrokeMode.Border;stroke.Thickness=3;stroke.Color=Color3.fromRGB(40,140,255)
        message="READY found — showing click target.";status.Text=message
        ctx.wait(0.15)
        if not alive or not readyEnabled or not isWave() or readyTarget()~=target or not visible(target) then clear();return end
        if game:GetService("UserInputService"):GetFocusedTextBox() then message="Close the text box to click READY.";clear();return end
        local point=target.AbsolutePosition+target.AbsoluteSize*0.5
        local reachable=false
        for _,o in ipairs(pg:GetGuiObjectsAtPosition(point.X,point.Y)) do
            if o==target or o:IsDescendantOf(target) or target:IsDescendantOf(o) then reachable=true;break end
            if o:IsA("GuiButton") or o:IsA("TextBox") or o.Active then message="READY is covered by another control.";clear();return end
        end
        if not reachable then message="READY center is outside the visible input area.";clear();return end
        local before,total=voteCount(votePanel)
        if before and total and total>0 and before>=total then sent=target;message="Vote count is already full.";clear();return end
        attempts=attempts+1
        local control=target
        while control and control~=votePanel and not control:IsA("GuiButton") do control=control.Parent end
        local keyboard=attempts==3 and control and control:IsA("GuiButton") and control.Selectable
        if keyboard then
            selectedBefore=guiService.SelectedObject;guiService.SelectedObject=control
            keyHeld=true;input:SendKeyEvent(true,Enum.KeyCode.Return,false,game)
        else
            if attempts==2 then local inset=guiService:GetGuiInset();point=point+inset end
            input:SendMouseMoveEvent(point.X,point.Y,game)
            held=point;input:SendMouseButtonEvent(point.X,point.Y,0,true,game,0)
        end
        ctx.wait(0.08);release()
        message="READY click "..attempts.." sent; checking game response.";status.Text=message
        for _=1,6 do
            ctx.wait(0.2)
            if not alive or not readyEnabled then clear();return end
            local after=voteCount(votePanel)
            if not visible(target) or clean(target.Text)~="ready" or (before and after and after~=before) then
                sent=target;message="Vote UI changed after READY click.";clear();return
            end
        end
        message=attempts>=3 and "No READY response after 3 attempts. Toggle Auto Ready to retry." or "No READY response yet; retrying with another input method."
        clear()
    end
    ctx.spawn(function()
        while alive and ctx.current() do
            local wave=isWave()
            if ownedFarm and (not wave or not ctx.farmActive()) then
                if ctx.farmActive() then ctx.stopFarm() end
                ownedFarm=false;farm.Text="Wave Farm: OFF"
            end
            if not wave then
                readyEnabled=false;ready.Text="Auto Ready: OFF";sent=nil;clear()
                status.Text="Available only inside a Wave mission."
            else
                status.Text=message
                local target,votePanel=readyTarget()
                if not target then sent=nil;attempts=0 end
                if readyEnabled and target and target~=sent and attempts<3 and (not lastAttempt or os.clock()-lastAttempt>=2) then
                    lastAttempt=os.clock()
                    local ok,err=pcall(click,target,votePanel)
                    if not ok then release();clear();readyEnabled=false;ready.Text="Auto Ready: OFF";message="Ready stopped: "..tostring(err);status.Text=message end
                end
            end
            ctx.wait(0.25)
        end
    end)
    return {Stop=function()
        alive=false;readyEnabled=false;release();clear()
        if ownedFarm then ctx.stopFarm() end
        panel:Destroy()
    end}
end

end)()
spawn(function()
    local deadline=os.clock()+60
    while active and not waveVisible() and os.clock()<deadline do task.wait(0.25) end
    if not active then return end
    if not waveVisible() then report("Wave screen not detected. Join a Wave mission and run this loader again.");return end
    if env.YozakuraRouterR1 then
        local ok,err=pcall(env.YozakuraRouterR1.Stop)
        if not ok then report("Could not stop old loader: "..tostring(err));return end
    end
    controls=factory({playerGui=pg,ui=frame,current=function() return active end,
        spawn=spawn,connect=connect,wait=task.wait,stopRuntime=session.Stop,
        farmActive=function() return session.farmActive and session.farmActive() or false end,
        stopFarm=function() if session.stopFarm then session.stopFarm() end end,
        startFarm=function()
            if not session.startFarm then report("Farm engine is not ready yet. See the startup status.");return false end
            return session.startFarm()
        end,
    })
    report("READY controls active. Downloading farm engine...")
    connect(player.OnTeleport,function(state)
        if state==Enum.TeleportState.Started then session.Stop() end
    end)
    spawn(function()
        local missingSince
        while active do
            if waveVisible() then missingSince=nil else missingSince=missingSince or os.clock() end
            if missingSince and os.clock()-missingSince>5 then session.Stop();return end
            task.wait(0.5)
        end
    end)
    if pg:FindFirstChild("tekkit") then report("Old farm engine still loaded. Rejoin and run only the Wave loader. READY controls remain available.");return end
    local ok,err=pcall(function()
        assert(type(loadstring)=="function","This environment does not provide loadstring")
        local source=game:HttpGet("https://raw.githubusercontent.com/koviescobar77-design/Yozakura/e6ee067d9ec6544cd02872efb707f27553a24c7c/AOTR_wave_only.lua")
        assert(active,"Wave startup cancelled")
        assert(type(source)=="string" and #source>0,"Farm download was empty")
        report("Compiling farm engine...")
        local chunk,compileError=loadstring(source,"@Yozakura/AOTR_wave_only.lua")
        assert(chunk,compileError)
        report("Starting farm engine...")
        chunk(session)
    end)
    if not ok and active then
        session.startFarm=nil;session.farmActive=nil;session.stopFarm=nil
        if session.stopMission then pcall(session.stopMission);session.stopMission=nil end
        report("Farm startup failed: "..tostring(err).." | READY controls still available.")
    end
end)
