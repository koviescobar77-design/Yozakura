-- Yozakura Lobby/Mission router. Each mode owns a separate disposable session.
local ROOT = "https://raw.githubusercontent.com/koviescobar77-design/Yozakura/93c0df684cea260b971f28eb5030ae11cc55de3c/"
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
local ctx
local cachedMode,modeAt="unknown",-math.huge
local function mode()
    if ctx and ctx.teleporting then return "transition" end
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
ctx={mode=mode,visible=visible,alive=true,entry=ENTRY,teleporting=false}
local reported
local function say(value)
    if value~=reported then print("[Yozakura Router] "..value); reported=value end
end
local newController=fetch("AOTR_router_state.lua")()
local controller=newController({
    mode=mode, clock=os.clock, spawn=task.spawn, cancel=task.cancel,
    currentThread=coroutine.running, context=ctx, report=say,
    load=function(kind,session)
        local function module(name)
            assert(session.isCurrent(), "Mode changed before download")
            local chunk=fetch(name)
            assert(session.isCurrent(), "Mode changed during download")
            return chunk
        end
        if kind=="lobby" then
            local lobbyModule=module("AOTR_lobby.lua")
            local launchModule=module("AOTR_launch.lua")
            local launch=launchModule()
            assert(session.isCurrent(), "Mode changed during lobby setup")
            return lobbyModule(session,R,launch)
        end
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
task.spawn(function()
    while ctx.alive do
        controller:Tick()
        task.wait(0.15)
    end
    controller:Stop()
    teleportConnection:Disconnect()
end)
print("[Yozakura] Lobby/Mission router active. Re-run the loader after teleport if your environment has no teleport queue.")
