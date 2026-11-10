-- Wave controls use the existing WIP combat worker; no extra attack requests.
return function(ctx)
    local pg, ui = ctx.playerGui, ctx.ui
    local alive, readyEnabled, ownedFarm = true, false, false
    local outline, held, sent, lastAttempt
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
        local found
        for _,o in ipairs(pg:GetDescendants()) do
            if (o:IsA("TextButton") or o:IsA("TextLabel")) and visible(o) and clean(o.Text)=="ready" then
                local button=o
                while button and button~=pg and not button:IsA("GuiButton") do button=button.Parent end
                if button and button:IsA("GuiButton") and button.Active then
                    local panel=button.Parent
                    for _=1,3 do
                        if not panel or panel==pg or panel:IsA("ScreenGui") then break end
                        local vote=false
                        for _,label in ipairs(panel:GetDescendants()) do
                            if (label:IsA("TextLabel") or label:IsA("TextButton")) and visible(label)
                                and clean(label.Text)=="vote start" then vote=true;break end
                        end
                        if vote then
                            if found and found~=button then return nil end
                            found=button;break
                        end
                        panel=panel.Parent
                    end
                end
            end
        end
        return found
    end
    local function clear()
        if outline then outline:Destroy();outline=nil end
    end
    local function release()
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
    local nav=button("WaveButton","Wave",ui,0)
    nav.Size=UDim2.new(0.16,0,0.10,0);nav.Position=UDim2.new(0.0194,0,0.30,0)
    local side={ctx.missionButton,nav,ui:FindFirstChild("SaveSetup"),ui:FindFirstChild("AutoConfig"),ctx.checkButton,ctx.closeButton}
    for i,o in ipairs(side) do o.Size=UDim2.new(0.16,0,0.10,0);o.Position=UDim2.new(0.0194,0,0.17+(i-1)*0.135,0) end
    local panel=Instance.new("Frame")
    panel.Name="WavePanel";panel.BackgroundTransparency=1;panel.Size=ctx.missionPage.Size
    panel.Position=ctx.missionPage.Position;panel.Visible=false;panel.Parent=ui
    local ready=button("AutoReady","Auto Ready: OFF",panel,0)
    local farm=button("WaveFarm","Wave Farm: OFF",panel,44)
    local status=Instance.new("TextLabel")
    status.BackgroundTransparency=1;status.TextColor3=Color3.new(1,1,1);status.TextWrapped=true
    status.TextSize=16;status.Size=UDim2.new(0.94,0,0,70);status.Position=UDim2.new(0.03,0,0,88);status.Parent=panel
    ctx.connect(nav.Activated,function() ctx.missionPage.Visible=false;panel.Visible=true end)
    ctx.connect(ctx.missionClick.Activated,function() panel.Visible=false end)
    ctx.connect(ready.Activated,function()
        if not isWave() then status.Text="Available only inside a Wave mission.";return end
        readyEnabled=not readyEnabled;sent=nil;lastAttempt=nil
        ready.Text="Auto Ready: "..(readyEnabled and "ON" or "OFF")
        if not readyEnabled then clear();release() end
    end)
    ctx.connect(farm.Activated,function()
        if not isWave() then status.Text="Available only inside a Wave mission.";return end
        if ownedFarm then ctx.stopFarm();ownedFarm=false
        else ownedFarm=ctx.startFarm()==true end
        farm.Text="Wave Farm: "..(ownedFarm and "ON" or "OFF")
    end)
    local function click(target)
        clear()
        outline=Instance.new("Frame");outline.Name="YozakuraReadyOutline"
        outline.BackgroundTransparency=1;outline.Active=false;outline.Selectable=false
        outline.Size=UDim2.fromScale(1,1);outline.ZIndex=target.ZIndex+1;outline.Parent=target
        local stroke=Instance.new("UIStroke",outline)
        stroke.ApplyStrokeMode=Enum.ApplyStrokeMode.Border;stroke.Thickness=3;stroke.Color=Color3.fromRGB(40,140,255)
        ctx.wait(0.15)
        if not alive or not readyEnabled or not isWave() or readyTarget()~=target or not visible(target) then clear();return end
        if game:GetService("UserInputService"):GetFocusedTextBox() then clear();return end
        local point=target.AbsolutePosition+target.AbsoluteSize*0.5
        local reachable=false
        for _,o in ipairs(pg:GetGuiObjectsAtPosition(point.X,point.Y)) do
            if o==target or o:IsDescendantOf(target) then reachable=true;break end
            if o:IsA("GuiButton") or o:IsA("TextBox") or o.Active then clear();return end
        end
        if not reachable then clear();return end
        -- Latch before dispatch: an uncertain mouse-down must never cause a duplicate click.
        sent=target;held=point
        local ok,err=pcall(function() input:SendMouseButtonEvent(point.X,point.Y,0,true,game,0) end)
        release()
        if not ok then status.Text="Ready click failed: "..tostring(err);readyEnabled=false;ready.Text="Auto Ready: OFF" end
        ctx.wait(0.4);clear()
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
                status.Text=ownedFarm and "Tracking living Titan weaknesses. Waiting between waves." or "Wave mission detected."
                local target=readyTarget()
                if not target then sent=nil end
                if readyEnabled and target and target~=sent and (not lastAttempt or os.clock()-lastAttempt>=2) then
                    lastAttempt=os.clock()
                    local ok,err=pcall(click,target)
                    if not ok then release();clear();readyEnabled=false;ready.Text="Auto Ready: OFF";status.Text="Ready stopped: "..tostring(err) end
                end
            end
            ctx.wait(0.25)
        end
    end)
    return {Stop=function()
        alive=false;readyEnabled=false;release();clear()
        if ownedFarm then ctx.stopFarm() end
        panel:Destroy();nav:Destroy()
    end}
end
