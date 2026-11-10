-- Main-menu-only slot selector. Game controls are resolved from the visible UI.
local ctx=...
assert(ctx and ctx.mode()=="menu","Main Menu requires the slot screen")
local pg=game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
local alive,busy=true,false
local generation=0
local env=type(getgenv)=="function" and getgenv() or _G
env.YozakuraSelectedSlot=env.YozakuraSelectedSlot or "A"
local connections={}
-- MenuNavigator approach: focus the actual game GuiButton, then send Enter.
local navigation={saved={},service=nil,original=nil,owned=nil,input=nil,enterDown=false}
local function releaseEnter()
    if navigation.enterDown and navigation.input then
        pcall(function()navigation.input:SendKeyEvent(false,Enum.KeyCode.Return,false,game)end)
        navigation.enterDown=false
    end
end
local function restoreNavigation()
    releaseEnter()
    if navigation.service and navigation.service.SelectedObject==navigation.owned then
        pcall(function()navigation.service.SelectedObject=navigation.original end)
    end
    for button,selectable in pairs(navigation.saved) do
        pcall(function()button.Selectable=selectable end)
    end
    navigation.saved={}
end
local gui=Instance.new("ScreenGui")
gui.Name="YozakuraMainMenu";gui.ResetOnSpawn=false;gui.DisplayOrder=10000;gui.Parent=pg
local function connect(signal,fn)
    local c=signal:Connect(fn);connections[#connections+1]=c;return c
end
local clickGui
local function stop()
    if not alive then return end
    alive=false;generation=generation+1
    restoreNavigation()
    for _,c in ipairs(connections) do c:Disconnect() end
    gui:Destroy()
    if clickGui then clickGui:Destroy() end
end
ctx.stopMenu=stop
local function valid()return alive and ctx.mode()=="menu"end
local function make(class,parent,properties)
    local o=Instance.new(class)
    for k,v in pairs(properties)do o[k]=v end
    o.Parent=parent;return o
end
local function round(o)
    make("UICorner",o,{CornerRadius=UDim.new(0,12)})
    make("UIStroke",o,{Color=Color3.fromRGB(235,235,235),Thickness=1.4})
end
local panel=make("Frame",gui,{Size=UDim2.fromOffset(380,348),Position=UDim2.fromOffset(16,120),
    Active=true,BackgroundColor3=Color3.fromRGB(23,22,25),BorderSizePixel=0})
round(panel)
local title=make("TextLabel",panel,{Active=true,Text="Yozakura | Menu R6",Size=UDim2.new(1,-100,0,45),
    Position=UDim2.fromOffset(15,0),BackgroundTransparency=1,TextColor3=Color3.new(1,1,1),
    Font=Enum.Font.SourceSansBold,TextSize=22,TextXAlignment=Enum.TextXAlignment.Left})
-- Mission-style grabbing: start from anywhere inside the panel.
local inputService=game:GetService("UserInputService")
local dragInput,dragStart,dragPosition
local dragMoved=false
local suppressClicksUntil=0
connect(inputService.InputBegan,function(input)
    if not alive or not gui.Enabled or not panel.Visible then return end
    if input.UserInputType~=Enum.UserInputType.MouseButton1 and input.UserInputType~=Enum.UserInputType.Touch then return end
    local point=input.Position
    local pos,size=panel.AbsolutePosition,panel.AbsoluteSize
    if point.X<pos.X or point.X>pos.X+size.X or point.Y<pos.Y or point.Y>pos.Y+size.Y then return end
    dragInput=input;dragStart=point;dragPosition=panel.Position;dragMoved=false
end)
connect(inputService.InputChanged,function(input)
    if not alive or not dragInput then return end
    local mouse=dragInput.UserInputType==Enum.UserInputType.MouseButton1
    if (mouse and input.UserInputType==Enum.UserInputType.MouseMovement) or input==dragInput then
        local delta=input.Position-dragStart
        if math.abs(delta.X)+math.abs(delta.Y)>6 then dragMoved=true end
        if not dragMoved then return end
        suppressClicksUntil=os.clock()+0.2
        local x=dragPosition.X.Offset+delta.X
        local y=dragPosition.Y.Offset+delta.Y
        local camera=workspace.CurrentCamera
        if camera then
            x=math.clamp(x,0,math.max(0,camera.ViewportSize.X-panel.AbsoluteSize.X))
            y=math.clamp(y,0,math.max(0,camera.ViewportSize.Y-panel.AbsoluteSize.Y-64))
        end
        panel.Position=UDim2.fromOffset(x,y)
    end
end)
connect(inputService.InputEnded,function(input)
    if input==dragInput then
        if dragMoved then suppressClicksUntil=os.clock()+0.2 end
        dragInput=nil
    end
end)
local status=make("TextLabel",panel,{Text="Paused — Slot "..env.YozakuraSelectedSlot..". Press Play to start.",Position=UDim2.fromOffset(15,296),
    Size=UDim2.new(1,-30,0,42),BackgroundTransparency=1,TextColor3=Color3.new(1,1,1),
    Font=Enum.Font.SourceSans,TextSize=16,TextWrapped=true})
local function report(s)if alive then status.Text=s end end
local function button(parent,label,pos,size,fn)
    local b=make("TextButton",parent,{Text=label,Position=pos,Size=size,
        BackgroundColor3=Color3.fromRGB(38,36,40),TextColor3=Color3.new(1,1,1),
        Font=Enum.Font.SourceSansBold,TextSize=19,AutoButtonColor=true,Selectable=false})
    round(b);connect(b.Activated,function()
        if os.clock()<suppressClicksUntil then return end
        fn()
    end);return b
end
local function key(value)
    return tostring(value or ""):gsub("<[^>]->",""):lower():gsub("[%s_:%-]","")
end
local function visible(o)
    return o:IsA("GuiObject") and not o:IsDescendantOf(gui)
        and not (clickGui and o:IsDescendantOf(clickGui)) and ctx.visible(o)
end
local function findControl(expected,root)
    root=root or pg
    expected=key(expected)
    local candidates={}
    for _,o in ipairs(root:GetDescendants()) do
        if visible(o) then
            local matches=key(o.Name)==expected
            if o:IsA("TextLabel") or o:IsA("TextButton") then matches=matches or key(o.Text)==expected end
            if matches then
                local p=o
                local target
                while p and p~=pg and p~=root.Parent and not p:IsA("ScreenGui") do
                    if p:IsA("GuiButton") then target=p;break end
                    p=p.Parent
                end
                candidates[target or o]=true
            end
        end
    end
    -- Prefer actual action buttons over named decorative containers.
    local hasButton=false
    for o in pairs(candidates) do if o:IsA("GuiButton") then hasButton=true end end
    if hasButton then
        for o in pairs(candidates) do if not o:IsA("GuiButton") then candidates[o]=nil end end
    end
    -- Deduplicate a named card and its title, preferring the enclosing game control.
    local remove={}
    for a in pairs(candidates)do for b in pairs(candidates)do
        if a~=b and a:IsDescendantOf(b)then remove[a]=true end
    end end
    for o in pairs(remove)do candidates[o]=nil end
    local result
    for o in pairs(candidates)do if result then return nil,"Multiple "..expected.." controls found" end;result=o end
    return result,expected.." is not visible"
end
-- Attach the outline to the game control itself: no screen/inset conversion.
local clickBox
local clickSerial=0
local function showClick(target)
    clickSerial=clickSerial+1
    local serial=clickSerial
    if clickBox then clickBox:Destroy() end
    clickBox=make("UIStroke",target,{Name="YozakuraClickIndicator",
        ApplyStrokeMode=Enum.ApplyStrokeMode.Border,
        Color=Color3.fromRGB(35,145,255),Thickness=3,Enabled=true})
    clickGui=clickBox
    local stroke=clickBox
    task.delay(0.8,function()
        if alive and serial==clickSerial then stroke.Enabled=false end
    end)
end
local function navigateActivate(target)
    if not target:IsA("GuiButton") then return false,"not a selectable game button",false end
    local token=generation
    local sent=false
    local ok,err=pcall(function()
        local gs=game:GetService("GuiService")
        local uis=game:GetService("UserInputService")
        if uis:GetFocusedTextBox() then error("Close the text box before menu navigation") end
        local input=game:GetService("VirtualInputManager")
        if not navigation.service then navigation.service=gs;navigation.original=gs.SelectedObject end
        if navigation.saved[target]==nil then navigation.saved[target]=target.Selectable end
        target.Selectable=true
        navigation.owned=target
        gs.SelectedObject=target
        task.wait(0.1)
        if not valid() or generation~=token then error("Navigation cancelled") end
        if gs.SelectedObject~=target then error("Game did not accept button selection") end
        navigation.input=input
        navigation.enterDown=true
        input:SendKeyEvent(true,Enum.KeyCode.Return,false,game)
        sent=true
        task.wait(0.05)
        releaseEnter()
    end)
    releaseEnter()
    -- If key-down was dispatched, wait for the UI result; never send a second activation.
    return ok,err,sent
end
-- Passive labels and selection artwork are returned by hit-testing too.
-- Only an interactive object in front of the target blocks a physical click.
local function clearPoint(target,p)
    local hits=pg:GetGuiObjectsAtPosition(p.X,p.Y)
    local selection
    pcall(function()selection=game:GetService("GuiService").SelectedObject.SelectionImageObject end)
    for _,hit in ipairs(hits) do
        if hit==target or hit:IsDescendantOf(target) then return true end
        local own=hit:IsDescendantOf(gui) or (clickGui and hit:IsDescendantOf(clickGui))
        local artwork=selection and (hit==selection or hit:IsDescendantOf(selection))
        if not own and not artwork and visible(hit)
            and (hit:IsA("GuiButton") or hit:IsA("TextBox") or hit.Active) then
            return false
        end
    end
    return false
end
local function click(target,method)
    local token=generation
    if not valid() or not visible(target) then return false,"Menu changed" end
    if target:GetAttribute("Locked")==true then return false,"Control is locked" end
    for _,o in ipairs(target:GetDescendants())do
        if visible(o) and (key(o.Name)=="locked" or key(o.Name)=="lock") then return false,"Control is locked" end
    end
    showClick(target)
    -- Use the actual button callback when available, rather than merely selecting it.
    if (not method or method=="auto" or method=="MouseButton1Click")
        and target:IsA("GuiButton") and type(getconnections)=="function" and type(firesignal)=="function" then
        local signals=method=="MouseButton1Click" and {target.MouseButton1Click} or {target.Activated,target.MouseButton1Click}
        for _,signal in ipairs(signals)do
            local ok,handlers=pcall(getconnections,signal)
            if ok and #handlers>0 then
                local sent=pcall(firesignal,signal)
                if sent then return true end
            end
        end
    end
    if method=="MouseButton1Click" then return false,"No usable MouseButton1Click handler" end
    local navError
    if not method or method=="auto" or method=="keyboard" then
        local focused,keySent
        focused,navError,keySent=navigateActivate(target)
        if focused or keySent then return true end
        if method=="keyboard" then return false,tostring(navError) end
    end
    if not valid() or token~=generation then return false,"Navigation cancelled" end
    gui.Enabled=false
    task.wait()
    if not valid() or token~=generation then
        if alive then gui.Enabled=true end
        return false,"Navigation cancelled"
    end
    -- Use the rendered action label when a button includes decorative space.
    local anchor=target
    for _,child in ipairs(target:GetDescendants()) do
        if (child:IsA("TextLabel") or child:IsA("TextButton")) and visible(child)
            and (key(child.Text)=="play" or key(child.Text)=="lobby" or key(child.Text)=="select") then
            anchor=child;break
        end
    end
    local point=anchor.AbsolutePosition+anchor.AbsoluteSize/2
    local points={point}
    local screen=target:FindFirstAncestorWhichIsA("ScreenGui")
    local ok,inset=pcall(function()return game:GetService("GuiService"):GetGuiInset()end)
    if ok and screen and not screen.IgnoreGuiInset then points={point+inset} end
    local found
    for _,p in ipairs(points)do
        if clearPoint(target,p) then found=p;break end
    end
    if not found then
        if alive then gui.Enabled=true end
        return false,"Button blocked by another interactive control"
    end
    showClick(target,found)
    local pressed=false
    local input
    local sent,err=pcall(function()
        input=game:GetService("VirtualInputManager")
        input:SendMouseMoveEvent(found.X,found.Y,game)
        input:SendMouseButtonEvent(found.X,found.Y,0,true,game,0)
        pressed=true
        task.wait(0.05)
        input:SendMouseButtonEvent(found.X,found.Y,0,false,game,0)
    end)
    if not sent and pressed then
        pcall(function()input:SendMouseButtonEvent(found.X,found.Y,0,false,game,0)end)

    end
    if alive then gui.Enabled=true end
    return sent or pressed,err or navError
end
local function slotName(o)
    if not visible(o) then return nil end
    local name=key(o.Name)
    local text=(o:IsA("TextLabel") or o:IsA("TextButton")) and key(o.Text) or ""
    return text:match("^slot([abc])$") or name:match("^slot([abc])$")
end
local function anySlots()
    for _,o in ipairs(pg:GetDescendants()) do if slotName(o) then return true end end
    return false
end
local function findSlot(letter)
    local matches={}
    local lockedCard
    local direct
    for _,heading in ipairs(pg:GetDescendants()) do
        if slotName(heading)==letter:lower() then
            if heading:IsA("GuiButton") then direct=heading end
            local p=heading.Parent
            while p and p~=pg and not p:IsA("ScreenGui") do
                local names={}
                local own=slotName(p)
                if own then names[own]=true end
                for _,o in ipairs(p:GetDescendants()) do
                    local name=slotName(o);if name then names[name]=true end
                end
                local count=0
                for _ in pairs(names) do count=count+1 end
                if count>1 then break end -- Never search the shared A/B/C container.
                if count==1 then
                    local selectButton=findControl("Select",p)
                    local unlockButton=findControl("Unlock",p)
                    if unlockButton or p:GetAttribute("Locked")==true then lockedCard=p;break end
                    if selectButton then matches[selectButton]=p;break end
                end
                p=p.Parent
            end
        end
    end
    local target,card
    for button,parent in pairs(matches) do
        if target then return nil,"Multiple SELECT buttons in Slot "..letter,parent end
        target,card=button,parent
    end
    if target then return target,nil,card end
    if lockedCard then return nil,"Slot "..letter.." is locked (UNLOCK will not be pressed)",lockedCard end
    -- Older layouts expose the whole slot as a button instead of a SELECT child.
    if direct then return direct,nil,direct end
    return nil,"SELECT button not found inside Slot "..letter
end
local function selectSlot(letter)
    if not valid() or busy then return end
    generation=generation+1
    local token=generation
    env.YozakuraSelectedSlot=letter
    busy=true
    local function running()return valid() and token==generation end
    local function waitFor(predicate,seconds)
        local deadline=os.clock()+seconds
        repeat
            if not running()then return false end
            if predicate()then return true end
            task.wait(0.1)
        until os.clock()>=deadline
        return false
    end
    local ok,err=pcall(function()
        -- A router restart may occur while the destination picker is already open.
        local destination=findControl("Lobby")
        if destination and not anySlots() and not findControl("Play") then
            local sent,message=click(destination)
            report(sent and "Lobby pressed; waiting for loading" or "Lobby failed: "..tostring(message))
            return
        end
        report("Auto Slot "..letter..": waiting for game controls")
        local target,play,card,reason
        if not waitFor(function()
            target,reason,card=findSlot(letter)
            play=findControl("Play")
            return target or card or (play and not anySlots())
        end,30)then
            if running()then report("Slot "..letter.." / Play not found")end
            return
        end
        if card and not target then report(reason);return end
        if target then
            report("Pressing SELECT inside Slot "..letter)
            local sent,message=click(target)
            if not sent then report("Slot "..letter..": "..tostring(message));return end
            report("Slot "..letter.." pressed; waiting 3 seconds before Play")
            local readyAt=os.clock()+3
            if not waitFor(function()return os.clock()>=readyAt end,4)then return end
            -- A visible Play/destination is also a valid next stage; some menus keep
            -- the slot cards visible and never expose Selected/ActiveSlot attributes.
            if not waitFor(function()
                return findControl("Play") or findControl("Lobby")
                    or not target.Parent or not visible(target)
                    or target:GetAttribute("Selected")==true
                    or target:GetAttribute("ActiveSlot")==true
            end,10)then
                if running()then report("Slot selection not confirmed; press SELECT manually, then Play")end
                return
            end
        end
        if not running()then return end
        report("Waiting for main-menu Play")
        if not waitFor(function()play=findControl("Play");return play~=nil end,20)then
            if running()then report("Main-menu Play not found")end
            return
        end
        local lobbyButton
        local attempts,failedMethods=0,0
        local methods={"keyboard","MouseButton1Click","mouse","auto"}
        while running() do
            lobbyButton=findControl("Lobby")
            if lobbyButton then break end
            -- Resolve again each attempt: the game may replace its Play instance.
            -- Never click the lobby's Play button after the menu/slot screen changes.
            play=findControl("Play")
            if not play then break end
            attempts=attempts+1
            local method=methods[(attempts-1)%#methods+1]
            local sent,message=click(play,method)
            if not running()then return end
            print("[Yozakura Menu] Play #"..attempts.." ["..method.."] "..(sent and "sent, not yet confirmed" or tostring(message)).." | "..play:GetFullName())
            if sent then
                failedMethods=0
                report("Play #"..attempts.." ["..method.."] sent; waiting for screen change")
            else
                failedMethods=failedMethods+1
                report("Play #"..attempts.." ["..method.."]: "..tostring(message))
                if failedMethods>=#methods then
                    report("Input unavailable: "..tostring(message)..". Check console [Yozakura Menu].")
                    return
                end
            end
            -- Poll during the one-second interval so Stop/loading cancels promptly.
            local nextClick=os.clock()+1
            waitFor(function()
                lobbyButton=findControl("Lobby")
                return lobbyButton or (not visible(play) and not findControl("Play")) or os.clock()>=nextClick
            end,2)
            if lobbyButton or not findControl("Play") then break end
        end
        -- Some menus open a destination selector after Play.
        if running() then
            waitFor(function()lobbyButton=findControl("Lobby");return lobbyButton~=nil end,15)
            if running() and lobbyButton then
                report("Pressing Lobby")
                local lobbySent,lobbyError=click(lobbyButton)
                if not lobbySent then report("Lobby failed: "..tostring(lobbyError));return end
                report("Lobby pressed; waiting for loading")
                if not waitFor(function()return not visible(lobbyButton)end,15) and running()then
                    report("Lobby sent; loading not confirmed")
                end
            end
        end
    end)
    if token==generation then busy=false end
    if not ok and running()then report("Menu automation failed: "..tostring(err))end
end
local slotButtons={}
local function paintSlots()
    for letter,b in pairs(slotButtons) do
        b.BackgroundColor3=letter==env.YozakuraSelectedSlot and Color3.fromRGB(20,115,39) or Color3.fromRGB(38,36,40)
    end
end
for i,letter in ipairs({"A","B","C"})do
    slotButtons[letter]=button(panel,"Slot "..letter,UDim2.fromOffset(15,48+(i-1)*48),UDim2.new(1,-30,0,40),function()
        if busy then report("Stop automation before changing slots");return end
        env.YozakuraSelectedSlot=letter;paintSlots()
        selectSlot(letter)
    end)
end
paintSlots()
button(panel,"Play",UDim2.fromOffset(15,198),UDim2.new(1,-30,0,40),function()
    if not busy then selectSlot(env.YozakuraSelectedSlot) end
end)
button(panel,"Stop Automation",UDim2.fromOffset(15,246),UDim2.new(1,-30,0,40),function()
    generation=generation+1;busy=false;restoreNavigation();clickSerial=clickSerial+1;if clickBox then clickBox.Enabled=false end;report("Paused — press Play to start")
end)
-- Capture before scheduling so Stop or a slot click cancels this initial dispatch.
local initialGeneration=generation
task.spawn(function()
    task.wait(0.5)
    if valid() and generation==initialGeneration then selectSlot(env.YozakuraSelectedSlot) end
end)
local reopen=button(gui,"Yozakura Menu",UDim2.fromOffset(12,80),UDim2.fromOffset(155,36),function()panel.Visible=true end)
reopen.Visible=false
button(panel,"Hide",UDim2.new(1,-95,0,10),UDim2.fromOffset(40,27),function()panel.Visible=false;reopen.Visible=true end).TextSize=14
button(panel,"X",UDim2.new(1,-45,0,10),UDim2.fromOffset(30,27),stop).TextSize=14
return {Stop=stop,Gui=gui}
