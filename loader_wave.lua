-- Separate Wave entry point. Does not download or start the Mission module.
if not game:IsLoaded() then game.Loaded:Wait() end
local env=type(getgenv)=="function" and getgenv() or _G
local player=game:GetService("Players").LocalPlayer
local pg=player:WaitForChild("PlayerGui",30)
assert(pg,"PlayerGui unavailable")
local function waveVisible()
    for _,o in ipairs(pg:GetDescendants()) do
        if o:IsA("TextLabel") or o:IsA("TextButton") then
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
assert(waveVisible(),"Join a Wave mission first, then run loader_wave.lua")
if env.YozakuraWaveRuntime then env.YozakuraWaveRuntime.Stop() end
if env.YozakuraRouterR1 then env.YozakuraRouterR1.Stop() end
assert(not pg:FindFirstChild("tekkit"),"Rejoin once to clear the older script, then run only the Wave loader")
local active=true
local session={}
function session.mode() return active and "wave" or "stopped" end
function session.Stop()
    if not active then return end
    active=false
    if session.stopMission then pcall(session.stopMission) end
    if env.YozakuraWaveRuntime==session then env.YozakuraWaveRuntime=nil end
end
session.isCurrent=function() return active end
env.YozakuraWaveRuntime=session
local ok,message=pcall(function()
    local source=game:HttpGet("https://raw.githubusercontent.com/koviescobar77-design/Yozakura/4e9ab0ecef710e3fc78446c570c62b06b8d35a24/AOTR_wave_only.lua")
    local chunk,err=loadstring(source,"@Yozakura/AOTR_wave_only.lua")
    assert(chunk,err)
    chunk(session)
end)
if not ok then session.Stop();error(message) end
local teleport=player.OnTeleport:Connect(function(state)
    if state==Enum.TeleportState.Started then session.Stop() end
end)
task.spawn(function()
    local missingSince
    while active do
        if waveVisible() then missingSince=nil else missingSince=missingSince or os.clock() end
        if missingSince and os.clock()-missingSince>3 then session.Stop();break end
        task.wait(0.5)
    end
    teleport:Disconnect()
end)
