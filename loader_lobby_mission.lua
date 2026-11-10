-- Yozakura Lobby/Mission router. Each mode owns a separate disposable session.
local ROOT = "https://raw.githubusercontent.com/koviescobar77-design/Yozakura/6b9210c48566d6d206663203e8171508d9b3c02c/"
local ENTRY = "https://raw.githubusercontent.com/koviescobar77-design/Yozakura/main/loader.lua"
if not game:IsLoaded() then game.Loaded:Wait() end
local env=type(getgenv)=="function" and getgenv() or _G
local previous=env.YozakuraRouterR1
if previous then
    if type(previous.Stop)=="function" then
        previous.Stop()
    else
        error("Rejoin once to replace the older router, then run the loader again.")
    end
end
local pg=game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui",30)
assert(pg,"PlayerGui unavailable")
-- Old executor workers cannot be safely unloaded by merely deleting their UI.
assert(not pg:FindFirstChild("tekkit") and not pg:FindFirstChild("YozakuraFamilyMenu"),
    "Rejoin first: an older Yozakura script is already loaded")
local function fetch(name)
    local url=name=="AOTR_main_menu.lua" and "https://raw.githubusercontent.com/koviescobar77-design/Yozakura/a1741ecc89377ffd48c453e3241e1bb0a5823e0a/AOTR_main_menu.lua" or ROOT..name
    if name=="AOTR_lobby.lua" then
        url="https://raw.githubusercontent.com/koviescobar77-design/Yozakura/58a11818b67553f70efdcb2551902eabacdedacb/AOTR_lobby.lua"
    end
    if name=="AOTR_launch.lua" then
        url="https://raw.githubusercontent.com/koviescobar77-design/Yozakura/ba1ce308476d6792cd3da8ba128f3257818d000f/AOTR_launch.lua"
    end
    if name=="AOTR_wave.lua" or name=="AOTR_mission_isolated.lua" then
        url="https://raw.githubusercontent.com/koviescobar77-design/Yozakura/e947e7e5bfac34253e73356228a6c44eb3d203e9/"..name
    end
    local source=game:HttpGet(url)
    local chunk,err=loadstring(source,"@Yozakura/"..name)
    assert(chunk,err)
    return chunk
end
local R=fetch("AOTR_lobby_rules.lua")()
local function visible(o)
    if not o or not o:IsA("GuiObject") or not o:IsDescendantOf(pg) then return false end
    local node=o
    while node and node~=pg do
        if node:IsA("ScreenGui") and (node.Name=="YozakuraLobby" or node.Name=="YozakuraRouterStatus"
            or node.Name=="YozakuraClickIndicator" or node.Name=="YozakuraMainMenu" or node.Name=="YozakuraLoaderStatus" or node.Name=="tekkit" or node.Name=="Open") then return false end
        if node:IsA("GuiObject") and not node.Visible then return false end
        if node:IsA("ScreenGui") and not node.Enabled then return false end
        node=node.Parent
    end
    return o.AbsoluteSize.X>0 and o.AbsoluteSize.Y>0
end
local ctx
local modeDetail="Waiting for game UI"
local cachedMode,modeAt="unknown",-math.huge
local menuRecognized=false
local function bladeCounter(o)
    if not o or not (o:IsA("TextLabel") or o:IsA("TextButton") or o:IsA("TextBox"))
        or o.Name:lower()~="sets" then return false end
    local count,maximum=o.Text:match("^%s*(%d+)%s*/%s*(%d+)%s*$")
    if not count or tonumber(maximum)<1 or tonumber(count)>tonumber(maximum) then return false end
    local parent=o.Parent
    for _=1,4 do
        if not parent or parent==pg then break end
        if parent.Name:lower():find("blade",1,true) then return true end
        parent=parent.Parent
    end
    return false
end
local function combatScene(titans)
    local character=game:GetService("Players").LocalPlayer.Character
    local root=character and character:FindFirstChild("HumanoidRootPart")
    if not root or not root:IsA("BasePart") then return false end
    for _,titan in ipairs(titans:GetChildren()) do
        local humanoid=titan:IsA("Model") and titan:FindFirstChildOfClass("Humanoid")
        if humanoid and humanoid.Health>0 then
            local boxes=titan:FindFirstChild("Hitboxes")
            local hit=boxes and boxes:FindFirstChild("Hit")
            local nape=hit and hit:FindFirstChild("Nape")
            if nape and nape:IsA("BasePart") then return true end
        end
    end
    return false
end
local function mode()
    if ctx and ctx.teleporting then modeDetail="Teleporting"; return "transition" end
    if os.clock()-modeAt<0.15 then return cachedMode end
    local tabs,menu,bladeVisible={},false,false
    local pickerLobby,pickerTrade=false,false
    local names={["gear up"]=true,quests=true,equipment=true,inventory=true,market=true,
        rankings=true,regiment=true,battlepass=true}
    for _,o in ipairs(pg:GetDescendants()) do
        if bladeCounter(o) and visible(o) then bladeVisible=true end
        if visible(o) then
            local name=R.clean(o.Name)
            if name=="lobby" then pickerLobby=true end
            if name=="trade" then pickerTrade=true end
        end
        if (o:IsA("TextLabel") or o:IsA("TextButton")) and visible(o) then
            local value=R.clean(o.Text)
            if value=="lobby" then pickerLobby=true end
            if value=="trade" then pickerTrade=true end
            if names[value] then tabs[value]=true end
            if value:find("tutorial",1,true) and value:find("gems",1,true) then menu=true end
            -- The destination picker after Play still belongs to the main menu.
            if value=="lobby" then
                local p=o
                while p and p~=pg and not p:IsA("ScreenGui") do
                    if p:IsA("GuiButton") then menu=true;break end
                    p=p.Parent
                end
            end
            if value:gsub("[%s_:%-]",""):match("^slot[abc]$") or value=="customization" or value=="customisation" then menu=true end
        end
    end
    -- Destination cards may use a Frame with sibling input objects, not a GuiButton ancestor.
    if pickerLobby and pickerTrade then menu=true end
    local count=0
    for _ in pairs(tabs) do count=count+1 end
    local interface=pg:FindFirstChild("Interface")
    local hud=interface and interface:FindFirstChild("HUD")
    local main=hud and hud:FindFirstChild("Main")
    local titans=workspace:FindFirstChild("Titans")
    local lobby=count>=4
    -- A hidden counter is not sufficient evidence that an active Titan battle ended.
    -- This fallback requires the mission HUD, a player root and a living Titan weakness.
    local battle=not bladeVisible and not lobby and not menu and titans and main and combatScene(titans)
    local mission=titans~=nil and (bladeVisible or battle==true)
    cachedMode=R.mode({lobby=count>=4,mission=mission,menu=menu})
    if cachedMode=="menu" then
        menuRecognized=true
    elseif cachedMode=="lobby" or cachedMode=="mission" then
        menuRecognized=false
    elseif cachedMode=="unknown" and menuRecognized then
        -- Preserve the existing menu session during the Play/popup/picker animation.
        -- Click workers still require visible targets and cannot click an absent control.
        cachedMode="menu"
    end
    if cachedMode=="mission" then modeDetail="Mission detected"
    elseif cachedMode=="lobby" then modeDetail="Lobby detected"
    elseif cachedMode=="menu" then modeDetail=(pickerLobby and pickerTrade) and "Lobby / Trade picker detected" or "Main menu active; waiting for next control"
    elseif cachedMode=="transition" then modeDetail="Waiting for the lobby/mission screen to settle"
    elseif titans then modeDetail="Titans found; waiting for mission HUD or active battle"
    else modeDetail="Waiting for lobby or mission UI" end
    modeAt=os.clock()
    return cachedMode
end
ctx={mode=mode,visible=visible,alive=true,entry=ENTRY,teleporting=false}
local reported
local function say(value)
    if value~=reported then print("[Yozakura Router] "..value); reported=value end
    local statusGui=pg:FindFirstChild("YozakuraLoaderStatus")
    local label=statusGui and statusGui:FindFirstChild("Status")
    if label then
        label.Text="Yozakura · "..value
        statusGui.Enabled=value~="Main Menu script active" and value~="Mission script active" and value~="Lobby script active"
    end
end
local newController=fetch("AOTR_router_state.lua")()
local controller=newController({
    mode=mode, clock=os.clock, spawn=task.spawn, cancel=task.cancel,
    currentThread=coroutine.running, context=ctx, report=say,
    load=function(kind,session)
        say(kind=="menu" and "Loading slot menu..." or (kind=="mission" and "Loading mission UI..." or "Loading lobby UI..."))
        local function module(name)
            assert(session.isCurrent(), "Mode changed before download")
            local chunk=fetch(name)
            assert(session.isCurrent(), "Mode changed during download")
            return chunk
        end
        if kind=="menu" then return module("AOTR_main_menu.lua")(session) end
        if kind=="lobby" then
            local lobbyModule=module("AOTR_lobby.lua")
            local launchModule=module("AOTR_launch.lua")
            local launch=launchModule()
            assert(session.isCurrent(), "Mode changed during lobby setup")
            return lobbyModule(session,R,launch)
        end
        session.waveFactory=module("AOTR_wave.lua")()
        return module("AOTR_mission_isolated.lua")(session)
    end,
})
env.YozakuraRouterR1=ctx
-- One teleport queue owner. The mission module's legacy queue is disabled.
local queue=queue_on_teleport or queueonteleport or (syn and syn.queue_on_teleport)
local queued=false
local teleportConnection=game:GetService("Players").LocalPlayer.OnTeleport:Connect(function(state)
    if state==Enum.TeleportState.Started then ctx.teleporting=true end
    if state==Enum.TeleportState.Failed then ctx.teleporting=false end
    modeAt=-math.huge
    controller:Tick()
    if state==Enum.TeleportState.Started and not queued and type(queue)=="function" then
        queued=pcall(queue, 'loadstring(game:HttpGet("'..ENTRY..'"))()')
    elseif state==Enum.TeleportState.Failed then queued=false end
end)
function ctx.Stop()
    if not ctx.alive then return end
    ctx.alive=false
    controller:Stop()
    teleportConnection:Disconnect()
    if env.YozakuraRouterR1==ctx then env.YozakuraRouterR1=nil end
end
task.spawn(function()
    while ctx.alive do
        local ok,err=pcall(function() controller:Tick() end)
        if not ok then
            say("Router error: "..tostring(err))
            ctx.Stop()
            return
        end
        if not controller.slot and (controller.observed=="unknown" or controller.observed=="menu"
            or controller.observed=="transition") then say(modeDetail) end
        task.wait(0.15)
    end
    controller:Stop()
    teleportConnection:Disconnect()
end)
print("[Yozakura] Lobby/Mission router active. Re-run the loader after teleport if your environment has no teleport queue.")
