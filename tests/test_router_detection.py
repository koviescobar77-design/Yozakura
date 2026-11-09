"""Offline mission detection tests against the actual router functions."""
import ctypes
import ctypes.util
from pathlib import Path
import sys

root=Path(sys.argv[1]) if len(sys.argv)>1 else Path(__file__).resolve().parents[1]
router=(root/'loader_lobby_mission.lua').read_text()
rules=(root/'AOTR_lobby_rules.lua').read_text()
mock=(root/'tests/lobby_mock.lua').read_text()
start=router.index('local function visible(o)')
helpers=router[start:router.index('ctx={mode=mode',start)]
setup=r'''
local R=RULES()
local pg=pg
local methods=getmetatable(pg).__index
function methods:FindFirstChildOfClass(class)
    for _,child in ipairs(self:GetChildren()) do if child:IsA(class) then return child end end
end
workspace=Instance.new('Workspace')
local player=game:GetService('Players').LocalPlayer
local function make(class,name,parent)
    local item=Instance.new(class);item.Name=name;item.Parent=parent;return item
end
local function reset()
    for _,o in ipairs(pg:GetChildren()) do o:Destroy() end
    for _,o in ipairs(workspace:GetChildren()) do o:Destroy() end
    player.Character=make('Model','Player',workspace)
    make('BasePart','HumanoidRootPart',player.Character)
    task.wait(1)
end
local function scene()
    local folder=make('Folder','Titans',workspace)
    local titan=make('Model','Titan',folder)
    make('Humanoid','Humanoid',titan).Health=100
    make('BasePart','Nape',make('Folder','Hit',make('Folder','Hitboxes',titan)))
    return folder
end
local function hud()
    local main=make('Frame','Main',make('Frame','HUD',make('ScreenGui','Interface',pg)))
    local sets=make('TextLabel','Sets',make('Frame','Blade',make('Frame','Top',main)))
    sets.Text='3/3'
    return main,sets
end
local function lobby()
    local screen=make('ScreenGui','GameLobby',pg)
    for _,name in ipairs({'Gear Up','Quests','Equipment','Inventory'}) do
        make('TextButton',name,screen).Text=name
    end
end
'''
checks=r'''
reset();scene();hud()
assert(mode()=='mission','standard HUD detected')
reset();scene()
local sets=make('TextLabel','Sets',make('Frame','BladeInventory',make('ScreenGui','CombatHud',pg)))
sets.Text='2 / 3'
assert(mode()=='mission','alternative blade HUD layout detected')
reset();scene()
sets=make('TextLabel','Sets',make('Frame','Blades',make('Frame','Open',make('ScreenGui','CombatHud',pg))))
sets.Text='3/3'
assert(mode()=='mission','game frame named Open is not our Open ScreenGui')
for _,name in ipairs({'tekkit','YozakuraLoaderStatus','YozakuraLobby','Open'}) do
    reset();scene()
    sets=make('TextLabel','Sets',make('Frame','Blade',make('ScreenGui',name,pg)));sets.Text='3/3'
    assert(mode()=='unknown','own UI must not become mission evidence')
end
reset();scene()
sets=make('TextLabel','Sets',make('Frame','Collection',make('ScreenGui','Game',pg)));sets.Text='3/3'
assert(mode()=='unknown','unrelated numeric Sets label rejected')
reset();local titans=scene();local main,counter=hud();counter.Visible=false
assert(mode()=='mission','hidden counter must not suppress active battle with mission HUD')
reset();make('Folder','Titans',workspace);main,counter=hud();counter.Visible=false
assert(mode()=='unknown','Titans folder and hidden UI alone are insufficient')
reset();scene();main,counter=hud();counter.Visible=false;lobby()
assert(mode()=='lobby','positive lobby evidence defeats hidden-counter fallback')
reset();scene();hud();lobby()
assert(mode()=='transition','conflicting visible lobby and mission evidence pauses')
reset();scene();main,counter=hud();counter.Visible=false
make('TextButton','Slot',make('ScreenGui','Menu',pg)).Text='Slot A'
assert(mode()=='menu','menu defeats hidden-counter fallback')
ctx={teleporting=true}
assert(mode()=='transition','teleport blocks mode startup')
print('PASS: exact/alternate HUD paths, hidden-counter battle fallback, owned UI exclusion, lobby/menu precedence and ambiguous/teleport states (mocked UI)')
'''
lib=ctypes.CDLL(ctypes.util.find_library('lua5.4') or 'liblua5.4.so.0')
lib.luaL_newstate.restype=ctypes.c_void_p
lib.luaL_openlibs.argtypes=[ctypes.c_void_p]
lib.luaL_loadstring.argtypes=[ctypes.c_void_p,ctypes.c_char_p]
lib.luaL_loadstring.restype=ctypes.c_int
lib.lua_pcallk.argtypes=[ctypes.c_void_p,ctypes.c_int,ctypes.c_int,ctypes.c_int,ctypes.c_longlong,ctypes.c_void_p]
lib.lua_pcallk.restype=ctypes.c_int
lib.lua_tolstring.argtypes=[ctypes.c_void_p,ctypes.c_int,ctypes.c_void_p]
lib.lua_tolstring.restype=ctypes.c_char_p
lib.lua_close.argtypes=[ctypes.c_void_p]
assert ']====]' not in rules
code='local RULES=assert(load([====['+rules+']====]))\n'+mock+'\n'+setup+'\n'+helpers+'\n'+checks
def run(code):
    state=lib.luaL_newstate();lib.luaL_openlibs(state)
    try:
        status=lib.luaL_loadstring(state,code.encode())
        if not status: status=lib.lua_pcallk(state,0,0,0,0,None)
        if status: raise RuntimeError(lib.lua_tolstring(state,-1,None).decode())
    finally: lib.lua_close(state)
run(code)

def literal(value):
    assert ']====]' not in value
    return '[====['+value+']====]'

integration=r'''
reset();scene();hud()
local now,queue,byThread=0,{},{}
os.clock=function() return now end
local function resume(job)
    if job.cancelled then return end
    local ok,delay=coroutine.resume(job.co)
    assert(ok,tostring(delay))
    if coroutine.status(job.co)~='dead' then job.at=now+(delay or .01);queue[#queue+1]=job end
end
task={
    spawn=function(fn)
        local job={co=coroutine.create(fn)};byThread[job.co]=job;resume(job);return job.co
    end,
    wait=function(dt) return coroutine.yield(dt) end,
    cancel=function(co) if byThread[co] then byThread[co].cancelled=true end end,
}
local function advance(dt)
    local untilAt=now+dt
    while true do
        local index,at
        for i,job in ipairs(queue) do
            if not job.cancelled and job.at<=untilAt and (not at or job.at<at) then index,at=i,job.at end
        end
        if not index then break end
        now=at;resume(table.remove(queue,index))
    end
    now=untilAt
end
local env={}
getgenv=function() return env end
loadstring=load
function game:IsLoaded() return true end
player.OnTeleport={Connect=function() return {Disconnect=function() end} end}
function game:HttpGet(url)
    local name=url:match('([^/]+)$')
    assert(sources[name],'Unexpected download '..name)
    return sources[name]
end
local loader=assert(load(sources['loader.lua']))
loader()
advance(3)
assert(pg:FindFirstChild('tekkit'),'mission UI must be reached through the actual loader/router chain')
assert(not pg:FindFirstChild('YozakuraLoaderStatus').Enabled,'status hides when mission module becomes active')
local previous=env.YozakuraRouterR1
loader()
assert(not previous.alive,'rerun stops the previous managed router')
advance(3)
assert(pg:FindFirstChild('tekkit') and env.YozakuraRouterR1~=previous,'rerun replaces the router and starts fresh mission UI')
workspace:FindFirstChild('Titans'):Destroy()
advance(.5)
assert(not pg:FindFirstChild('tekkit'),'losing mission evidence stops mission UI')
local status=pg:FindFirstChild('YozakuraLoaderStatus')
assert(status.Enabled and status:FindFirstChild('Status').Text:find('Waiting',1,true),'waiting state is visible')
env.YozakuraRouterR1.Stop()
env.YozakuraRouterR1={alive=true}
loader()
assert(pg:FindFirstChild('YozakuraLoaderStatus'):FindFirstChild('Status').Text:find('Rejoin once',1,true),'legacy-router restart requirement is visible')
print('PASS: actual loader/router startup reaches mission module, hides status on success, replaces managed sessions and displays waiting/startup failures (mocked execution)')
'''
mission_stub="""local session=...
assert(session.mode()=='mission')
local ui=Instance.new('ScreenGui');ui.Name='tekkit';ui.Parent=game:GetService('Players').LocalPlayer:FindFirstChild('PlayerGui')
session.stopMission=function() ui:Destroy() end
"""
sources={
    'loader.lua':(root/'loader.lua').read_text(),
    'loader_lobby_mission.lua':router,
    'AOTR_router_state.lua':(root/'AOTR_router_state.lua').read_text(),
    'AOTR_lobby_rules.lua':rules,
    'AOTR_mission_isolated.lua':mission_stub,
}
source_table='local sources={'+','.join('[ '+literal(k)+' ]='+literal(v) for k,v in sources.items())+'}\n'
run('local RULES=assert(load('+literal(rules)+'))\n'+mock+'\n'+setup+'\n'+source_table+integration)
