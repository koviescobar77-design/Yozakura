-- Yozakura Lobby R2: mission setup, modifiers and countdown.
-- Called by loader_lobby_mission.lua with the shared context and rules.
local ctx, R, Launch = ...
assert(Launch, "R2 requires the updated loader")
assert(ctx and R and ctx.mode() == "lobby", "Yozakura Lobby requires confirmed Gear Up lobby")
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local Http = game:GetService("HttpService")
local pg = Players.LocalPlayer:WaitForChild("PlayerGui")
local alive, active, epoch = true, false, 0
local connections, blocked, spent = {}, {}, {}
local playRequested,launchBusy,launchMachine,runButton=false,false,nil,nil
local config = {
    jobs = {}, odm = {}, perksUpgrade = {}, perksEquip = {}, boosters = {},
    branch = "Offense", plans = {
        Offense = "Drill Thrust > Offense Capstone", Defense = "", Support = ""
    },
    currencies = {Gems=true}, rarities = {Legendary=true, Mythic=true},
    budgets = {Gems=0, Pumpkins=0, Shards=0}, spins = false, resume = false,
    play={mode="Missions",map="Shiganshina",boss="Attack Titan",difficulty="Easy",
        grade="E-",objective="Default",delay=5,modifiers={},customModifier="",auto=false}
}
local file = "YozakuraLobby_R1.json"
if type(readfile) == "function" then
    local ok, saved = pcall(function() return Http:JSONDecode(readfile(file)) end)
    if ok and type(saved) == "table" and saved.version == 1 then
        for key, default in pairs(config) do
            if type(saved[key]) == type(default) then config[key] = saved[key] end
        end
    end
end
-- Merge new launch fields when loading a saved R1 / partially populated R2 config.
local playDefaults={mode="Missions",map="Shiganshina",boss="Attack Titan",difficulty="Easy",
    grade="E-",objective="Default",delay=5,modifiers={},customModifier="",auto=false}
for key,value in pairs(playDefaults) do
    if type(config.play[key])~=type(value) then config.play[key]=value end
end
-- Budgets are per session; purchasing always requires a fresh toggle after loading.
config.jobs.market = false
local function connect(signal, fn)
    local c = signal:Connect(fn); table.insert(connections, c); return c
end
local gui = Instance.new("ScreenGui")
gui.Name = "YozakuraLobby"
gui.ResetOnSpawn = false
gui.DisplayOrder = 10000
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = pg
local function make(class, parent, props)
    local o = Instance.new(class)
    for k,v in pairs(props or {}) do o[k] = v end
    o.Parent = parent
    return o
end
local function rounded(o, radius)
    make("UICorner", o, {CornerRadius=UDim.new(0, radius or 12)})
    make("UIStroke", o, {Color=Color3.fromRGB(235,235,235), Thickness=1.4,
        ApplyStrokeMode=Enum.ApplyStrokeMode.Border})
end
local panel = make("Frame", gui, {Size=UDim2.fromOffset(650,480),
    Position=UDim2.new(0.5,-325,0.5,-240), BackgroundColor3=Color3.fromRGB(18,17,19),
    BackgroundTransparency=0.1, BorderSizePixel=0})
rounded(panel, 20)
local scale = make("UIScale", panel, {})
local function resize()
    local camera = workspace.CurrentCamera
    if camera then scale.Scale = math.min(1, (camera.ViewportSize.X-24)/650, (camera.ViewportSize.Y-24)/480) end
end
resize()
if workspace.CurrentCamera then connect(workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"), resize) end
local function text(parent, label, pos, size)
    return make("TextLabel", parent, {Text=label, Position=pos or UDim2.new(),
        Size=size or UDim2.new(1,0,0,28), BackgroundTransparency=1,
        TextColor3=Color3.new(1,1,1), Font=Enum.Font.SourceSansBold, TextSize=17,
        TextXAlignment=Enum.TextXAlignment.Left})
end
local header = text(panel, "Yozakura  |  Lobby", UDim2.fromOffset(14,6), UDim2.fromOffset(380,36))
header.TextSize = 27
local status = text(panel, "Paused · select options, then Start", UDim2.fromOffset(146,430), UDim2.fromOffset(490,40))
status.TextWrapped = true; status.TextSize = 15
local function report(s)
    if alive then status.Text = s end
    print("[Yozakura Lobby] " .. s)
end
local function button(parent, label, pos, size, fn)
    local b = make("TextButton", parent, {Text=label, Position=pos or UDim2.new(),
        Size=size or UDim2.new(1,0,0,32), BackgroundColor3=Color3.fromRGB(35,34,36),
        BorderSizePixel=0, TextColor3=Color3.new(1,1,1), Font=Enum.Font.SourceSansBold,
        TextSize=16, AutoButtonColor=true})
    rounded(b)
    connect(b.Activated, fn)
    return b
end
local body = make("Frame", panel, {Position=UDim2.fromOffset(146,50), Size=UDim2.fromOffset(490,374), BackgroundTransparency=1})
local pages = {}
local function page(name)
    local p = make("ScrollingFrame", body, {Name=name, Size=UDim2.fromScale(1,1), BackgroundTransparency=1,
        BorderSizePixel=0, ScrollBarThickness=5, CanvasSize=UDim2.new(), AutomaticCanvasSize=Enum.AutomaticSize.Y, Visible=false})
    make("UIListLayout", p, {Padding=UDim.new(0,7), SortOrder=Enum.SortOrder.LayoutOrder})
    make("UIPadding", p, {PaddingLeft=UDim.new(0,3), PaddingRight=UDim.new(0,9), PaddingBottom=UDim.new(0,5)})
    pages[name] = p
    return p
end
local function note(p, value, height)
    local l = text(p, value, nil, UDim2.new(1,0,0,height or 36))
    l.TextWrapped=true; l.TextSize=15
    return l
end
local function toggle(p, label, map, key, changed)
    local b
    local function paint()
        b.Text = label .. (map[key] and "    ON" or "    OFF")
        b.BackgroundColor3 = map[key] and Color3.fromRGB(20,115,39) or Color3.fromRGB(37,35,38)
    end
    b = button(p, "", nil, nil, function()
        map[key] = not map[key]; epoch=epoch+1; paint()
        if changed then changed(map[key]) end
    end)
    paint(); return b
end
local function entry(p, label, initial, callback)
    note(p,label,22)
    local e=make("TextBox",p,{Text=tostring(initial), Size=UDim2.new(1,0,0,34),
        ClearTextOnFocus=false, BackgroundColor3=Color3.fromRGB(31,31,34),
        TextColor3=Color3.new(1,1,1), Font=Enum.Font.SourceSans, TextSize=16})
    rounded(e,8)
    connect(e.FocusLost,function() callback(e.Text); epoch=epoch+1 end)
    return e
end
local play=page("Play")
local choiceRefresh={}
local function refreshChoices()
    for _,fn in ipairs(choiceRefresh) do fn() end
end
local function choices(p,label,values,key,onChange)
    local heading=note(p,label,23)
    local rows,buttons={},{}
    for i,name in ipairs(values) do
        local col=(i-1)%3
        if col==0 then
            rows[#rows+1]=make("Frame",p,{Size=UDim2.new(1,0,0,33),BackgroundTransparency=1})
        end
        local b=button(rows[#rows],name,UDim2.new(col/3,3,0,0),UDim2.new(1/3,-6,0,31),function()
            config.play[key]=name; epoch=epoch+1
            if onChange then onChange(name) end
            refreshChoices()
        end)
        b.TextSize=15;buttons[name]=b
    end
    local function paint()
        for name,b in pairs(buttons) do
            b.BackgroundColor3=config.play[key]==name and Color3.fromRGB(20,115,39) or Color3.fromRGB(37,35,38)
        end
    end
    choiceRefresh[#choiceRefresh+1]=paint;paint()
    return {heading=heading,rows=rows,buttons=buttons}
end
local playAction=button(play,"PLAY SELECTED SETUP",nil,UDim2.new(1,0,0,40),function()
    if launchBusy then report("Launch in progress · Cancel first"); return end
    playRequested=true;active=true;epoch=epoch+1
    if runButton then runButton.Text="Pause" end
    report("Preparing selected mission setup")
end)
playAction.BackgroundColor3=Color3.fromRGB(25,105,47)
button(play,"Cancel launch / countdown",nil,nil,function()
    active=false;playRequested=false;epoch=epoch+1
    if runButton then runButton.Text="Run tasks" end
    report("Launch / countdown cancelled")
end)
toggle(play,"Auto Play on lobby load",config.play,"auto",function(enabled)
    active=enabled
    if runButton then runButton.Text=enabled and "Pause" or "Run tasks" end
    report(enabled and "Auto Play enabled · Save Setup to resume on lobby load" or "Auto Play stopped")
end)
entry(play,"Seconds before Start (0–3600)",config.play.delay,function(value)
    local delay=Launch.seconds(value)
    if delay then config.play.delay=delay else report("Invalid delay; previous value retained") end
end)
choices(play,"Mode",Launch.modes,"mode",function() config.play.objective="Default" end)
local mapChoices=choices(play,"Mission map",Launch.maps,"map",function()config.play.objective="Default"end)
local bossChoices=choices(play,"Raid boss",Launch.bosses,"boss")
local objectiveChoices=choices(play,"Objective",{"Default","Skirmish","Protect","Defend","Random"},"objective")
choiceRefresh[#choiceRefresh+1]=function()
    local isMission=config.play.mode=="Missions"
    mapChoices.heading.Visible=isMission
    for _,row in ipairs(mapChoices.rows)do row.Visible=isMission end
    bossChoices.heading.Visible=config.play.mode=="Raids"
    for _,row in ipairs(bossChoices.rows)do row.Visible=config.play.mode=="Raids" end
    objectiveChoices.heading.Visible=isMission
    for _,row in ipairs(objectiveChoices.rows)do row.Visible=isMission end
    local available=Launch.objectives[config.play.map] or {"Default"}
    for name,b in pairs(objectiveChoices.buttons)do b.Visible=table.find(available,name)~=nil end
end
note(play,"Difficulty / grade presets",24)
local difficultyBox,gradeBox
for _,preset in ipairs(Launch.presets) do
    button(play,preset.name.." ("..preset.grade..")",nil,nil,function()
        config.play.difficulty=preset.name;config.play.grade=preset.grade;epoch=epoch+1
        difficultyBox.Text=preset.name;gradeBox.Text=preset.grade
    end)
end
difficultyBox=entry(play,"Difficulty name (or enter another offered difficulty)",config.play.difficulty,function(value)
    config.play.difficulty=value:match("^%s*(.-)%s*$")
end)
gradeBox=entry(play,"Grade (blank = accept the grade for that difficulty)",config.play.grade,function(value)
    config.play.grade=value:match("^%s*(.-)%s*$"):upper()
end)
note(play,"The game's < > selector is read until both selected labels match. Locked / unavailable choices stop setup.",50)
note(play,"Additional modifiers",24)
for _,name in ipairs(Launch.modifiers)do toggle(play,name,config.play.modifiers,name)end
entry(play,"Additional modifier (exact game label, optional)",config.play.customModifier,function(value)
    value=value:match("^%s*(.-)%s*$")
    if config.play.customModifier~="" then config.play.modifiers[config.play.customModifier]=nil end
    config.play.customModifier=value
    if value~="" then config.play.modifiers[value]=true end
end)
note(play,"No Skills is the +3% modifier in the video. Default objective keeps the game's default. Select the unidentified reward boost toggle manually.",65)
refreshChoices()
local claims=page("Claims")
toggle(claims,"Auto Claim Quests",config.jobs,"quests")
toggle(claims,"Auto Claim Battlepass",config.jobs,"battlepass")
toggle(claims,"Auto Claim Achievements",config.jobs,"achievements")
note(claims,"Visits quest categories and claims available rewards. Locked / premium rewards are skipped.",52)
local odm=page("ODM")
toggle(odm,"Auto Upgrade selected gear",config.jobs,"odm")
local gearNames={"Blade Durability","Critical Chance","ODM Damage","Critical Damage","ODM Speed","ODM Control","Gas","ODM Range"}
for _,name in ipairs(gearNames) do toggle(odm,name,config.odm,name) end
note(odm,"Names are matched to visible game labels. An unmatched stat waits for a UI scan.",44)
entry(odm,"Additional exact stat names (separate with >)","",function(value)
    for _,name in ipairs(R.plan(value)) do config.odm[name]=true end
end)
local skills=page("Skills")
toggle(skills,"Auto Upgrade selected skill path",config.jobs,"skills")
local planBox
local branchButton
local branches={"Offense","Defense","Support"}
branchButton=button(skills,"Path: "..config.branch,nil,nil,function()
    local index=table.find(branches,config.branch) or 1
    config.branch=branches[index%3+1]; branchButton.Text="Path: "..config.branch
    planBox.Text=config.plans[config.branch] or ""; epoch=epoch+1
end)
note(skills,"Ordered node names: first prerequisite > next node > Drill Thrust > Offense Capstone",48)
planBox=entry(skills,"Selected branch plan",config.plans[config.branch] or "",function(value) config.plans[config.branch]=value end)
note(skills,"The full prerequisite tree is not in the supplied source. Add its exact node names or export a scan. Locked nodes stop this path; points are never assigned by screen position.",72)
local perks=page("Perks")
toggle(perks,"Auto Upgrade selected perks",config.jobs,"perksUpgrade")
toggle(perks,"Auto Equip selected perks",config.jobs,"perksEquip")
local groups={
    {"Core","Founder's Blessing","Heavenly Restriction","Maximum Firepower"},
    {"Offense","Art of War","Black Flash","Everlasting Flame","Kengo"},
    {"Defense","Adaptation","Immortal"},
    {"Support","Explosive Fortune","Font of Inspiration","Soulfeed","Tatsujin","Unwavering Belief"}
}
for _,group in ipairs(groups) do
    note(perks,group[1],25)
    for i=2,#group do
        local name=group[i]
        toggle(perks,"Upgrade · "..name,config.perksUpgrade,name)
        toggle(perks,"Equip · "..name,config.perksEquip,name)
    end
end
note(perks,"Equip skips a perk already equipped. Stop if the game needs a slot choice. Heavenly Restriction disables skills, according to your supplied description.",65)
local inventory=page("Boosters")
toggle(inventory,"Auto Use selected boosters",config.jobs,"boosters")
for _,name in ipairs({"2x Gold","2x Luck","2x EXP"}) do toggle(inventory,name,config.boosters,name) end
note(inventory,"Uses one booster and waits for its active timer to end. If an active/inactive state cannot be read, consumption pauses.",60)
local market=page("Market")
toggle(market,"Auto Buy selected market items",config.jobs,"market")
toggle(market,"Legendary",config.rarities,"Legendary")
toggle(market,"Mythic",config.rarities,"Mythic")
toggle(market,"Spins",config,"spins")
for _,currency in ipairs({"Gems","Pumpkins","Shards"}) do
    toggle(market,"Use "..currency,config.currencies,currency)
    entry(market,currency.." budget this session (0 = no spend)",config.budgets[currency] or 0,function(value)
        config.budgets[currency]=math.max(0,math.floor(tonumber(value) or 0))
    end)
end
note(market,"Reads item rarity, currency, price and balance. Random crates and Robux offers are excluded. Shard purchases need their shop to be available in this lobby.",75)
local settings=page("Setup")
toggle(settings,"Resume saved lobby tasks on load",config,"resume")
local function save()
    if type(writefile)~="function" then report("Save unavailable in this environment"); return end
    config.version=1
    local ok,err=pcall(function() writefile(file,Http:JSONEncode(config)) end)
    report(ok and "Setup saved · market still requires manual enabling on each load" or tostring(err))
end
button(settings,"Save Setup",nil,nil,save)
note(settings,"UI adapter R2 · live AOTR compatibility still needs testing. Use Scan UI while the relevant game panel is open.",56)
local order={"Play","Claims","ODM","Skills","Perks","Boosters","Market","Setup"}
for i,name in ipairs(order) do
    button(panel,name,UDim2.fromOffset(12,50+(i-1)*34),UDim2.fromOffset(120,29),function()
        for key,p in pairs(pages) do p.Visible=key==name end
    end)
end
play.Visible=true
runButton=button(panel,"Run tasks",UDim2.fromOffset(12,335),UDim2.fromOffset(120,34),function()
    active=not active; epoch=epoch+1
    runButton.Text=active and "Pause" or "Run tasks"
    report(active and "Running selected lobby tasks" or "Paused")
end)
button(panel,"Save Setup",UDim2.fromOffset(12,378),UDim2.fromOffset(120,34),save)
local reopen=button(gui,"Yozakura Lobby",UDim2.fromOffset(12,80),UDim2.fromOffset(145,35),function() panel.Visible=true end)
reopen.Visible=false
button(panel,"Hide",UDim2.fromOffset(458,9),UDim2.fromOffset(76,30),function() panel.Visible=false; reopen.Visible=true end)
local function stop()
    if not alive then return end
    active=false; alive=false; epoch=epoch+1
    for _,c in ipairs(connections) do c:Disconnect() end
    gui:Destroy()
end
button(panel,"Close",UDim2.fromOffset(544,9),UDim2.fromOffset(90,30),stop)
-- Dragging the title does not consume clicks on the controls.
local dragging, origin, position
connect(header.InputBegan,function(input)
    if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
        dragging=input; origin=input.Position; position=panel.Position
    end
end)
connect(UIS.InputChanged,function(input)
    if dragging and (input.UserInputType==Enum.UserInputType.MouseMovement or input==dragging) then
        local delta=input.Position-origin
        panel.Position=position+UDim2.fromOffset(delta.X,delta.Y)
    end
end)
connect(UIS.InputEnded,function(input)
    if input==dragging or input.UserInputType==Enum.UserInputType.MouseButton1 then dragging=nil end
end)
local function visible(o)
    return ctx.visible(o) and not o:IsDescendantOf(gui)
end
local function labels(root)
    local out={}
    local function add(o)
        if (o:IsA("TextLabel") or o:IsA("TextButton") or o:IsA("TextBox")) and visible(o) then
            out[#out+1]={object=o,value=R.clean(o.Text)}
        end
    end
    add(root)
    for _,o in ipairs(root:GetDescendants()) do add(o) end
    return out
end
local function words(root)
    local out={}
    for _,item in ipairs(labels(root)) do out[#out+1]=item.value end
    table.sort(out)
    return table.concat(out," | ")
end
local function exact(root, names)
    local result={}
    for _,item in ipairs(labels(root)) do
        for _,name in ipairs(names) do
            if item.value==R.clean(name) then result[#result+1]=item.object; break end
        end
    end
    return result
end
local function target(o)
    while o and o~=pg do
        if o:IsA("GuiButton") then return o end
        o=o.Parent
    end
end
local function uniqueButton(root,names)
    local found={}
    for _,o in ipairs(exact(root,names)) do
        local b=target(o)
        if b and visible(b) and b.Active then found[b]=true end
    end
    local result
    for b in pairs(found) do if result then return nil,"Ambiguous button: "..names[1] end; result=b end
    return result, "Button unavailable: "..names[1]
end
local function valid(token)
    return alive and active and token==epoch and ctx.mode()=="lobby"
end
local function pause(seconds,token)
    local deadline=os.clock()+seconds
    repeat
        if not valid(token) then return false end
        task.wait(0.1)
    until os.clock()>=deadline
    return true
end
local function click(b,token)
    if not valid(token) or not b or not visible(b) or not b.Active then return false end
    -- Fire one connected signal only: firing both Activated and MouseButton1Click duplicates purchases.
    if type(getconnections)=="function" and type(firesignal)=="function" then
        for _,signal in ipairs({b.Activated,b.MouseButton1Click}) do
            local ok,list=pcall(getconnections,signal)
            if ok and #list>0 then
                local fired=pcall(firesignal,signal)
                if fired then return true end
            end
        end
    end
    -- Physical input is only allowed if the button is actually the top hit at its center.
    local center=b.AbsolutePosition+b.AbsoluteSize/2
    local hits=pg:GetGuiObjectsAtPosition(center.X,center.Y)
    if #hits==0 or not (hits[1]==b or hits[1]:IsDescendantOf(b)) then
        report("Button covered or offscreen · move the hub / scroll the game panel")
        return false
    end
    local ok=pcall(function()
        local input=game:GetService("VirtualInputManager")
        input:SendMouseButtonEvent(center.X,center.Y,0,true,game,0)
        input:SendMouseButtonEvent(center.X,center.Y,0,false,game,0)
    end)
    return ok
end
local scope
local function navigate(names,token)
    if scope(names[#names]) then return true end
    for _,name in ipairs(names) do
        local b,err=uniqueButton(pg,{name})
        if not b then return false,err end
        if not click(b,token) or not pause(0.7,token) then return false,"Navigation paused: "..name end
    end
    return true
end
-- The closest named panel containing the control scopes generic actions like Claim / Upgrade.
scope=function(name)
    local matches={}
    for _,o in ipairs(pg:GetDescendants()) do
        if o:IsA("GuiObject") and visible(o) and R.clean(o.Name)==R.clean(name) then
            -- Exclude tab buttons; only accept a real content container.
            if not o:IsA("GuiButton") and #o:GetDescendants()>2 then matches[#matches+1]=o end
        end
    end
    if #matches==1 then return matches[1] end
    -- An exact heading can identify a panel when its object name is opaque.
    local headings=exact(pg,{name})
    for _,heading in ipairs(headings) do
        if not target(heading) then
            local parent=heading.Parent
            if parent and parent:IsA("GuiObject") and #parent:GetDescendants()>2 then matches[#matches+1]=parent end
        end
    end
    if #matches==1 then return matches[1] end
end
local function signature(root)
    if not root.Parent then return "<removed>" end
    local data={words(root)}
    for _,o in ipairs(root:GetDescendants()) do
        if o:IsA("ValueBase") then data[#data+1]=o.Name.."="..tostring(o.Value) end
    end
    for k,v in pairs(root:GetAttributes()) do data[#data+1]=k.."="..tostring(v) end
    table.sort(data)
    return table.concat(data,"\n")
end
local function transaction(root,b,key,token)
    if blocked[key] then return false,"Held: "..key.." · inspect the result, then Reset Holds" end
    if not b then return false,"Action unavailable: "..key end
    local before=signature(root)
    -- Reserve before input. No automatic retry if the game times out or shows an unknown dialog.
    blocked[key]=true
    if not click(b,token) then return false,"Input unavailable: "..key end
    local deadline=os.clock()+4
    repeat
        if not pause(0.2,token) then return false,"Stopped" end
        if not root.Parent or not b.Parent or not visible(b) or not b.Active or signature(root)~=before then
            return true,"UI changed after "..key.." (server result not independently verified)"
        end
    until os.clock()>=deadline
    return false,"No visible confirmation: "..key.." · held to avoid duplicates"
end
local function namedCard(root,name)
    local headings=exact(root,{name})
    if #headings~=1 then return nil,"Item missing / ambiguous: "..name end
    local p=headings[1].Parent
    while p and p~=root do
        if uniqueButton(p,{"Upgrade","Equip","Use","Buy","Purchase","Unlock","Learn"}) then return p end
        p=p.Parent
    end
end
local function selectItem(root,name,token)
    local card=namedCard(root,name)
    if card then return card end
    local b,err=uniqueButton(root,{name})
    if not b then return nil,err end
    if not click(b,token) or not pause(0.6,token) then return nil,"Selection paused" end
    -- Re-read after selection; a detail panel must still explicitly name this item.
    return namedCard(root,name)
end
local function actionItem(root,name,actions,key,token)
    local card,err=selectItem(root,name,token)
    if not card then return false,err or "Need item details: "..name end
    local content=words(card)
    if content:find("max level",1,true) or content:find("maxed",1,true) or #exact(card,{"Locked"})>0
        or content:find("insufficient",1,true) or content:find("not enough",1,true) then return false,"Locked / max / insufficient: "..name end
    local b=uniqueButton(card,actions)
    return transaction(card,b,key,token)
end
local function selected(map)
    local out={}
    for name,on in pairs(map) do if on==true then out[#out+1]=name end end
    table.sort(out); return out
end
local function claimPanel(root,key,token)
    if not root then return false,"Panel not detected: "..key end
    local all=uniqueButton(root,{"Claim All"})
    if all then return transaction(root,all,key..":all",token) end
    for _,label in ipairs(exact(root,{"Claim"})) do
        local b=target(label)
        if b and b.Active and visible(b) then
            local card=b.Parent
            local content=words(card)
            if not content:find("premium",1,true) and not content:find("locked",1,true) then
                local id=key..":"..b:GetFullName()..":"..content
                if not blocked[id] then return transaction(card,b,id,token) end
            end
        end
    end
    return false,"No available claim: "..key
end
local questCategories={"Main Quests","Side Quests","Thunder Spears","Daily Quests","Weekly Quests"}
for i=1,10 do questCategories[#questCategories+1]="Week "..i.." Quests" end
local questIndex=1
local jobs={}
jobs.quests=function(token)
    local ok,err=navigate({"Quests"},token); if not ok then return false,err end
    local name=questCategories[questIndex]; questIndex=questIndex%#questCategories+1
    local b=uniqueButton(pg,{name})
    if b then click(b,token); if not pause(0.5,token) then return false,"Paused" end end
    return claimPanel(scope("Quests"),"quests:"..name,token)
end
jobs.battlepass=function(token)
    local ok,err=navigate({"Battlepass"},token); if not ok then return false,err end
    return claimPanel(scope("Battlepass"),"battlepass",token)
end
jobs.achievements=function(token)
    local ok,err=navigate({"Achievements"},token); if not ok then return false,err.." · icon-only button needs mapping" end
    return claimPanel(scope("Achievements"),"achievements",token)
end
jobs.odm=function(token)
    local ok,err=navigate({"Equipment","Upgrades"},token); if not ok then return false,err end
    local root=scope("Upgrades"); if not root then return false,"Upgrades panel needs UI scan" end
    for _,name in ipairs(selected(config.odm)) do
        local card=namedCard(root,name)
        local key="odm:"..name..":"..(card and signature(card) or "")
        if not blocked[key] then
            local done,msg=actionItem(root,name,{"Upgrade"},key,token)
            if done then return done,msg end
        end
    end
    return false,"Selected gear missing, held, maxed, or unaffordable"
end
jobs.skills=function(token)
    local ok,err=navigate({"Equipment","Skills"},token); if not ok then return false,err end
    local root=scope("Skills"); if not root then return false,"Skills panel needs UI scan" end
    local plan=R.plan(config.plans[config.branch])
    if #plan==0 then return false,"Enter exact prerequisite order for "..config.branch end
    for _,name in ipairs(plan) do
        local card=selectItem(root,name,token)
        if not card then return false,"Missing skill: "..name.." · scan tree / add prerequisites" end
        local w=words(card)
        if not (w:find("learned",1,true) or w:find("owned",1,true) or w:find("maxed",1,true)) then
            return actionItem(root,name,{"Learn","Unlock","Upgrade"},"skill:"..name..":"..signature(card),token)
        end
    end
    return false,"Selected skill path completed"
end
local function perkJob(token,equip)
    if equip then
        for _,group in ipairs(groups) do
            local count=0
            for i=2,#group do if config.perksEquip[group[i]] then count=count+1 end end
            if count>1 then return false,"Choose one "..group[1].." perk for Auto Equip to prevent replacements cycling" end
        end
    end
    local ok,err=navigate({"Equipment","Perks"},token); if not ok then return false,err end
    local root=scope("Perks"); if not root then return false,"Perks panel needs UI scan" end
    local list=equip and config.perksEquip or config.perksUpgrade
    for _,name in ipairs(selected(list)) do
        local card=selectItem(root,name,token)
        if card and not (equip and uniqueButton(card,{"Unequip"})) then
            local key=(equip and "equip:" or "perk:")..name..":"..signature(card)
            if not blocked[key] then return actionItem(root,name,{equip and "Equip" or "Upgrade"},key,token) end
        end
    end
    return false,"Selected perks unavailable / already equipped / held"
end
jobs.perksUpgrade=function(token) return perkJob(token,false) end
jobs.perksEquip=function(token) return perkJob(token,true) end
local function boosterState(name)
    -- Requires explicit status, not the existence of a Use button or a description.
    for _,o in ipairs(pg:GetDescendants()) do
        if visible(o) and R.clean(o.Name)==R.clean(name) then
            local state=o:GetAttribute("Active")
            if type(state)=="boolean" then return state end
            if o:IsA("GuiObject") then
                for _,label in ipairs(labels(o)) do
                    if label.value=="inactive" or label.value=="00:00" then return false end
                    if label.value=="active" or label.value:match("^%d+:%d%d$") then return true end
                end
            end
        end
    end
    return nil
end
jobs.boosters=function(token)
    local ok,err=navigate({"Inventory"},token); if not ok then return false,err end
    local root=scope("Inventory"); if not root then return false,"Inventory panel needs UI scan" end
    for _,name in ipairs(selected(config.boosters)) do
        local state=boosterState(name)
        if state==false and not blocked["booster:"..name] then
            return actionItem(root,name,{"Use"},"booster:"..name,token)
        elseif state==true then
            -- Keep the hold until a timer has first been observed active and later inactive.
            blocked["boosterSeen:"..name]=true
        elseif state==false and blocked["boosterSeen:"..name] then
            blocked["booster:"..name]=nil; blocked["boosterSeen:"..name]=nil
        end
    end
    return false,"Boosters active / held / state unreadable"
end
local currencies={"Gems","Pumpkins","Shards"}
local function balance(currency)
    local found={}
    for _,o in ipairs(pg:GetDescendants()) do
        if visible(o) and R.clean(o.Name)==R.clean(currency) and not o:IsDescendantOf(gui) then
            if o:IsA("TextLabel") or o:IsA("TextButton") then
                local n=R.number(o.Text); if n then found[n]=true end
            end
            for _,l in ipairs(labels(o)) do
                local n=R.number(l.value); if n then found[n]=true end
            end
        end
    end
    local result
    for value in pairs(found) do if result~=nil then return nil end; result=value end
    return result
end
local function marketCard(root,b)
    local p=b.Parent
    while p and p~=root do
        local data={object=p,button=b}
        local ls=labels(p)
        local names={}
        for _,l in ipairs(ls) do
            local value=l.value
            if value=="legendary" then
                if data.rarity and data.rarity~="Legendary" then data.crate=true end
                data.rarity="Legendary"
            end
            if value=="mythic" then
                if data.rarity and data.rarity~="Mythic" then data.crate=true end
                data.rarity="Mythic"
            end
            if value:find("spin",1,true) then data.spin=true end
            if value:find("crate",1,true) or value:find("pity",1,true) or value:find("drop chance",1,true) then data.crate=true end
            if value:find("scout fashion",1,true) or value:find("anime all-stars",1,true) or value:find("blade burst",1,true) then data.crate=true end
            if value:find("robux",1,true) or value:find("r$",1,true) then data.robux=true end
            if value:find("sold out",1,true) then data.soldOut=true end
            for _,currency in ipairs(currencies) do
                local clean=R.clean(currency)
                local raw=value:match("^([%d,%.kmb]+)%s+"..clean.."$")
                    or value:match("^"..clean.."%s*:%s*([%d,%.kmb]+)$")
                if raw then
                    if data.currency and data.currency~=currency then data.robux=true end
                    data.currency=currency; data.price=R.number(raw)
                end
            end
            names[#names+1]=value
        end
        if data.currency and (data.rarity or data.spin) then
            -- Require exactly one purchase control in this card, never infer a whole grid as one item.
            local unique=uniqueButton(p,{"Buy","Purchase"})
            if unique~=b then return nil end
            table.sort(names); data.key=table.concat(names,"|")
            data.balance=balance(data.currency)
            return data
        end
        p=p.Parent
    end
end
local marketSwaps=0
jobs.market=function(token)
    local ok,err=navigate({"Market"},token); if not ok then return false,err end
    local root=scope("Market"); if not root then return false,"Market panel needs UI scan" end
    for _,label in ipairs(exact(root,{"Buy","Purchase"})) do
        local b=target(label)
        if b then
            local card=marketCard(root,b)
            if card then
                local eligible,reason=R.market(card,config,spent)
                local key="market:"..card.key
                if eligible and not blocked[key] then
                    -- Charge the budget before dispatch, including unknown outcomes.
                    spent[card.currency]=(spent[card.currency] or 0)+card.price
                    local done,msg=transaction(card.object,b,key,token)
                    local after=balance(card.currency)
                    if done and card.spin and after and card.balance-after>=card.price then
                        blocked[key]=nil -- Repeat spins only after an observed currency debit.
                    end
                    return done,msg.." · reserved "..spent[card.currency].." "..card.currency
                end
            end
        end
    end
    -- Swap is clicked once per pass, never a guessed currency button or a confirmation.
    local swap=uniqueButton(root,{"Swap"})
    if swap then
        marketSwaps=marketSwaps+1
        if click(swap,token) then pause(1,token) end
    end
    return false,"No eligible readable offer · budgets / stock / currency checked"
end
-- R2 launch adapter. Scope actions to their current modal, not the background Play/Start.
local function enclosing(object,predicate)
    local p=object and object.Parent
    for _=1,10 do
        if not p or p==pg or p:IsA("ScreenGui") then return nil end
        if p:IsA("GuiObject") and predicate(p) then return p end
        p=p.Parent
    end
end
local function partyPanel()
    for _,item in ipairs(labels(pg))do
        if item.value:match("^players%s*:") then
            local p=enclosing(item.object,function(node)
                return uniqueButton(node,{"Leave"}) and uniqueButton(node,{"Modifiers"}) and uniqueButton(node,{"Start"})
            end)
            if p then return p end
        end
    end
end
local function modifierPanel()
    for _,heading in ipairs(exact(pg,{"Modifiers"}))do
        if not target(heading) then
            local p=enclosing(heading,function(node)
                return uniqueButton(node,{"Back"}) and #exact(node,{"No Skills","No Memories","Nightmare","Oddball"})>0
            end)
            if p then return p end
        end
    end
end
local function setupPanel()
    for _,item in ipairs(labels(pg))do
        if Launch.readDifficulty(item.object.Text) then
            local p=enclosing(item.object,function(node)
                return uniqueButton(node,{"Back"})~=nil
            end)
            if p then return p end
        end
    end
end
local function objectivePanel()
    for _,item in ipairs(exact(pg,{"Skirmish","Protect","Defend","Random"}))do
        local p=enclosing(item,function(node)
            return uniqueButton(node,{"Back"}) and #exact(node,{"Skirmish"})>0 and #exact(node,{"Random"})>0
        end)
        if p then return p end
    end
end
local function stage()
    if modifierPanel() then return "modifiers" end
    if objectivePanel() then return "objectives" end
    if partyPanel() then return "party" end
    if setupPanel() then return "setup" end
    if uniqueButton(pg,{"Missions"}) and uniqueButton(pg,{"Raids"}) and uniqueButton(pg,{"Waves"}) then return "modes" end
    if uniqueButton(pg,{"Play"}) then return "lobby" end
    return "other"
end
local function waitUI(predicate,token,seconds)
    local deadline=os.clock()+(seconds or 4)
    repeat
        if not valid(token) then return false,"Cancelled" end
        if predicate() then return true end
        if not pause(0.1,token) then return false,"Cancelled" end
    until os.clock()>=deadline
    return false,"Selection not confirmed"
end
local function chooseNamed(name,token,root)
    root=root or pg
    local b,err=uniqueButton(root,{name})
    if not b then return false,err end
    local card=b
    if #exact(card,{"Locked"})>0 or b:GetAttribute("Locked")==true then return false,"Locked: "..name end
    for _,o in ipairs(card:GetDescendants()) do
        if (R.clean(o.Name)=="lock" or R.clean(o.Name)=="locked") and o:IsA("GuiObject") and visible(o) then return false,"Locked: "..name end
    end
    if not click(b,token) then return false,"Cannot click "..name end
    return true
end
local function selectedContent(name)
    local p=setupPanel()
    if not p then return false end
    -- In the video the selected map / raid is the modal's title, separate from its clickable tile.
    for _,o in ipairs(exact(p,{name}))do if not target(o) then return true end end
    return false
end
local function readDifficulty()
    local p=setupPanel()
    if not p then return nil end
    local resultName,resultGrade
    for _,item in ipairs(labels(p))do
        local name,grade=Launch.readDifficulty(item.object.Text)
        if name then
            if resultName and (name~=resultName or grade~=resultGrade) then return nil end
            resultName,resultGrade=name,grade
        end
    end
    return resultName,resultGrade
end
local function modifierRow(name)
    local root=modifierPanel()
    if not root then return nil,nil,"missing" end
    local matches=exact(root,{name})
    if #matches==0 then return nil,nil,"missing" end
    if #matches~=1 then return nil,nil,"ambiguous" end
    local p=matches[1].Parent
    for _=1,6 do
        if not p or p==root then break end
        local other=0
        for _,known in ipairs(Launch.modifiers) do if #exact(p,{known})>0 then other=other+1 end end
        if other>1 then break end
        local buttons={}
        if p:IsA("GuiButton") then buttons[#buttons+1]=p end
        for _,o in ipairs(p:GetDescendants())do if o:IsA("GuiButton") and visible(o) then buttons[#buttons+1]=o end end
        if #buttons==1 then return p,buttons[1] end
        p=p.Parent
    end
    return nil,nil,"unreadable"
end
local function modifierState(name)
    local row,b,reason=modifierRow(name)
    if not row then return nil,reason end
    local values={}
    local function take(value) if type(value)=="boolean" then values[value]=true end end
    for _,object in ipairs({row,b})do
        for _,key in ipairs({"Selected","Checked","Toggled"})do take(object:GetAttribute(key)) end
    end
    for _,o in ipairs(row:GetDescendants())do
        local n=R.clean(o.Name)
        if (n=="selected" or n=="checked" or n=="enabled") and o:IsA("BoolValue") then take(o.Value) end
        if (n=="checkmark" or n=="tick" or n=="check") and o:IsA("GuiObject") then
            local shown=o.Visible
            if o:IsA("ImageLabel") or o:IsA("ImageButton") then shown=shown and o.Image~="" and o.ImageTransparency<1 end
            take(shown)
        end
    end
    for _,item in ipairs(labels(row))do
        if item.value=="on" or item.value=="selected" then take(true) end
        if item.value=="off" or item.value=="unselected" then take(false) end
    end
    if values[true] and values[false] then return nil,"conflicting" end
    if values[true] then return true end
    if values[false] then return false end
    return nil,"unreadable"
end
local function launchPress(name,token)
    local root,names=pg,{name}
    if name=="Next difficulty" then root=setupPanel();names={">","›","→"}
    elseif name=="Previous difficulty" then root=setupPanel();names={"<","‹","←"}
    elseif name=="Close modifiers" then root=modifierPanel();names={"Back"}
    elseif name=="Create" or name=="Objectives" then root=setupPanel()
    elseif name=="Start" or name=="Modifiers" then root=partyPanel() end
    if not root then return false,"Panel missing for "..name end
    local b,err=uniqueButton(root,names)
    if not b then return false,err end
    return click(b,token), "Input unavailable: "..name
end
launchMachine=Launch.new({
    now=os.clock,valid=valid,wait=pause,status=report,stage=stage,
    press=launchPress,difficulty=readDifficulty,
    selectContent=function(name,token)
        if selectedContent(name) then return true end
        local ok,err=chooseNamed(name,token)
        if not ok then return false,err end
        return waitUI(function()return selectedContent(name)end,token)
    end,
    objectivesOpen=function()return objectivePanel()~=nil end,
    selectObjective=function(name,token)
        local root=objectivePanel()
        if not root then return false,"Objectives panel missing" end
        local ok,err=chooseNamed(name,token,root)
        if not ok then return false,err end
        return waitUI(function()return setupPanel()~=nil end,token)
    end,
    modifier=modifierState,
    toggleModifier=function(name,token)
        local _,b=modifierRow(name)
        if not b then return false,"Modifier button unreadable: "..name end
        return click(b,token),"Modifier input unavailable: "..name
    end,
    partyFingerprint=function()
        local p=partyPanel()
        if not p then return nil end
        return p:GetFullName().."|"..words(p)
    end,
    mission=function()return ctx.mode()=="mission"end,
    teleporting=function()return ctx.teleporting==true end
})
local function scan()
    active=false;playRequested=false; epoch=epoch+1; runButton.Text="Run tasks"
    local data={version=1,placeId=game.PlaceId,mode=ctx.mode(),objects={}}
    for _,o in ipairs(pg:GetDescendants()) do
        if visible(o) then
            local record={path=o:GetFullName(),class=o.ClassName}
            if o:IsA("TextLabel") or o:IsA("TextButton") or o:IsA("TextBox") then record.text=o.Text end
            if o:IsA("GuiButton") then record.active=o.Active end
            record.attributes={}
            for key,value in pairs(o:GetAttributes())do
                local kind=type(value)
                record.attributes[key]=(kind=="boolean" or kind=="number" or kind=="string") and value or tostring(value)
            end
            record.name=o.Name
            if record.text or o:IsA("GuiButton") then data.objects[#data.objects+1]=record end
        end
    end
    local json=Http:JSONEncode(data)
    local saved=false
    if type(writefile)=="function" then saved=pcall(writefile,"YozakuraLobby_UI_scan.json",json) end
    if type(setclipboard)=="function" then pcall(setclipboard,json) end
    print(json)
    report(saved and "Scan saved: YozakuraLobby_UI_scan.json · also copied if clipboard is available" or "Scan printed / copied if available")
end
button(settings,"Scan current game UI",nil,nil,scan)
button(settings,"Reset Holds (after checking game result)",nil,nil,function()
    if active then report("Pause before resetting holds"); return end
    blocked={};launchMachine.held=false; report("Holds cleared · spending counters retained")
end)
button(panel,"Scan UI",UDim2.fromOffset(12,427),UDim2.fromOffset(120,32),scan)
local jobOrder={"quests","battlepass","achievements","odm","skills","perksUpgrade","perksEquip","boosters","market"}
if config.resume or config.play.auto then active=true; runButton.Text="Pause" end
local worker=task.spawn(function()
    while alive do
        if active and (playRequested or config.play.auto) then
            launchBusy=true
            local token=epoch
            local ok,done,message=pcall(function()return launchMachine:Run(config.play,token)end)
            launchBusy=false;playRequested=false
            active=false;epoch=epoch+1;runButton.Text="Run tasks"
            report(ok and (message or "Launch finished") or ("Launch paused: "..tostring(done)))
        else
          for _,name in ipairs(jobOrder) do
            if not alive then return end
            if ctx.mode()~="lobby" then active=false; epoch=epoch+1; runButton.Text="Start" end
            if active and config.jobs[name] then
                local token=epoch
                local ok,done,message=pcall(jobs[name],token)
                if not ok then
                    active=false; epoch=epoch+1; runButton.Text="Start"; report("Paused: "..tostring(done))
                else report(message or name) end
                if not pause(name=="market" and 5 or 1,token) then break end
            end
          end
        end
        task.wait(0.5)
    end
end)
return {Stop=stop,Gui=gui}
