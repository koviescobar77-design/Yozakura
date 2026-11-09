-- Yozakura Lobby/Mission R1. Modules are pinned together at publication.
local ROOT = "https://raw.githubusercontent.com/koviescobar77-design/Yozakura/b14db68a9f5fa4562066c6aa49bf7260e7a99e04/"
local ENTRY = "https://raw.githubusercontent.com/koviescobar77-design/Yozakura/lobby-r1/loader_lobby_mission.lua"
if not game:IsLoaded() then game.Loaded:Wait() end
local env=type(getgenv)=="function" and getgenv() or _G
local previous=env.YozakuraRouterR1
if previous then
    warn("[Yozakura] Router already running. Rejoin to load another revision.")
    return
end
local pg=game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui",30)
assert(pg,"PlayerGui unavailable")
-- Old executor workers cannot be safely unloaded by merely deleting their UI.
assert(not pg:FindFirstChild("tekkit") and not pg:FindFirstChild("YozakuraFamilyMenu"),
    "Rejoin first: an older Yozakura script is already loaded")
local function fetch(name)
    local source=game:HttpGet(ROOT..name)
    local chunk,err=loadstring(source,"@Yozakura/"..name)
    assert(chunk,err)
    return chunk
end
local R=fetch("AOTR_lobby_rules.lua")()
local function visible(o)
    if not o or not o:IsA("GuiObject") or not o:IsDescendantOf(pg) then return false end
    local node=o
    while node and node~=pg do
        if node.Name=="YozakuraLobby" or node.Name=="YozakuraRouterStatus" or node.Name=="tekkit" or node.Name=="Open" then return false end
        if node:IsA("GuiObject") and not node.Visible then return false end
        if node:IsA("ScreenGui") and not node.Enabled then return false end
        node=node.Parent
    end
    return o.AbsoluteSize.X>0 and o.AbsoluteSize.Y>0
end
local cachedMode,modeAt="unknown",-math.huge
local function mode()
    if os.clock()-modeAt<0.15 then return cachedMode end
    local tabs,menu={},false
    local names={["gear up"]=true,quests=true,equipment=true,inventory=true,market=true,
        rankings=true,regiment=true,battlepass=true}
    for _,o in ipairs(pg:GetDescendants()) do
        if (o:IsA("TextLabel") or o:IsA("TextButton")) and visible(o) then
            local value=R.clean(o.Text)
            if names[value] then tabs[value]=true end
            if value:match("^slot [abc]$") or value=="customization" or value=="customisation" then menu=true end
        end
    end
    local count=0
    for _ in pairs(tabs) do count=count+1 end
    local interface=pg:FindFirstChild("Interface")
    local hud=interface and interface:FindFirstChild("HUD")
    local main=hud and hud:FindFirstChild("Main")
    local top=main and main:FindFirstChild("Top")
    local blade=top and top:FindFirstChild("Blade")
    local sets=blade and blade:FindFirstChild("Sets")
    local mission=workspace:FindFirstChild("Titans")~=nil and sets~=nil and visible(sets)
    cachedMode=R.mode({lobby=count>=4,mission=mission,menu=menu})
    modeAt=os.clock()
    return cachedMode
end
local ctx={mode=mode,visible=visible,alive=true,missionStarted=false,entry=ENTRY}
env.YozakuraRouterR1=ctx
local lobby,lastMode,stableSince,reported=nil,nil,os.clock(),nil
local function say(value)
    if value~=reported then print("[Yozakura Router] "..value); reported=value end
end
-- One teleport queue owner. The mission module's legacy queue is disabled.
local queue=queue_on_teleport or queueonteleport or (syn and syn.queue_on_teleport)
local queued=false
game:GetService("Players").LocalPlayer.OnTeleport:Connect(function(state)
    if state==Enum.TeleportState.Started and not queued and type(queue)=="function" then
        queued=pcall(queue, 'loadstring(game:HttpGet("'..ENTRY..'"))()')
    elseif state==Enum.TeleportState.Failed then queued=false end
end)
local function launchMission()
    ctx.missionStarted=true
    task.spawn(function()
        local ok,err=pcall(function()
            local chunk=fetch("AOTR_mission_isolated.lua")
            if mode()~="mission" then error("Mode changed during download; rejoin to retry") end
            chunk(ctx)
        end)
        if not ok then
            if ctx.stopMission then ctx.stopMission() end
            warn("[Yozakura] Mission initialization failed: "..tostring(err))
        end
    end)
end
task.spawn(function()
    while ctx.alive do
        local current=mode()
        if current~=lastMode then lastMode=current; stableSince=os.clock() end
        -- Immediately stop lobby input on uncertain state, then wait before launching anything.
        if current~="lobby" and lobby then lobby.Stop(); lobby=nil end
        if current=="lobby" and ctx.stopMission then ctx.stopMission() end
        if os.clock()-stableSince>=2 then
            if current=="lobby" and not lobby then
                local ok,result=pcall(function()
                    local chunk=fetch("AOTR_lobby.lua")
                    if mode()~="lobby" then error("Lobby changed during download") end
                    return chunk(ctx,R)
                end)
                if ok then lobby=result; say("Lobby loaded")
                else say("Lobby load failed: "..tostring(result)); task.wait(5) end
            elseif current=="mission" and not ctx.missionStarted then
                say("Mission confirmed · loading mission script"); launchMission()
            elseif current=="menu" then say("Slot menu detected · waiting for Gear Up lobby")
            elseif current=="unknown" or current=="transition" then
                say("Waiting for clear lobby / mission UI; neither module started")
            end
        end
        task.wait(0.5)
    end
end)
print("[Yozakura] R1 router active. Re-run the loader after teleport if your environment has no teleport queue.")
