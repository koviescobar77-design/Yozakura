"""Offline mission cleanup and lobby stop checks; no Roblox connection."""
import ctypes
import ctypes.util
from pathlib import Path
import sys

root = Path(sys.argv[1]) if len(sys.argv) > 1 else Path(__file__).resolve().parents[1]
def read(name):
    path = root / name
    if not path.exists():
        path = root / ('router-fix-' + name)
    return path.read_text(encoding='utf-8')

lib = ctypes.CDLL(ctypes.util.find_library('lua5.4') or 'liblua5.4.so.0')
lib.luaL_newstate.restype = ctypes.c_void_p
lib.luaL_openlibs.argtypes = [ctypes.c_void_p]
lib.luaL_loadstring.argtypes = [ctypes.c_void_p, ctypes.c_char_p]
lib.luaL_loadstring.restype = ctypes.c_int
lib.lua_pcallk.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_int, ctypes.c_int, ctypes.c_longlong, ctypes.c_void_p]
lib.lua_pcallk.restype = ctypes.c_int
lib.lua_tolstring.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_void_p]
lib.lua_tolstring.restype = ctypes.c_char_p
lib.lua_close.argtypes = [ctypes.c_void_p]

def run(code):
    state=lib.luaL_newstate()
    lib.luaL_openlibs(state)
    try:
        status=lib.luaL_loadstring(state,code.encode())
        if not status: status=lib.lua_pcallk(state,0,0,0,0,None)
        if status: raise RuntimeError(lib.lua_tolstring(state,-1,None).decode())
    finally: lib.lua_close(state)

mission=read('AOTR_mission_isolated.lua')
def section(start,end):
    i=mission.index(start)
    return mission[i:mission.index(end,i)]

setup=r'''
local mode='mission'
local lobbySession={mode=function() return mode end}
local resumes, cancelled, warnings, released = {}, {}, {}, {}
task={
    spawn=function(fn,...)
        local co=coroutine.create(fn)
        local ok,err=coroutine.resume(co,...)
        assert(ok,tostring(err))
        resumes[#resumes+1]=co
        return co
    end,
    wait=function(dt) coroutine.yield(dt); return dt end,
    cancel=function(co) cancelled[co]=true end,
}
task.defer=task.spawn
task.delay=function(_,fn,...) return task.spawn(fn,...) end
warn=function(value) warnings[#warnings+1]=value end
local input={SendKeyEvent=function(_,down,key) if not down then released[#released+1]=key end end}
game={GetService=function() return input end}
'''
checks=r'''
local actions=0
local worker=task.spawn(function()
    actions=actions+1
    task.wait(.1)
    actions=actions+1
end)
assert(actions==1)
mode='unknown'
assert(coroutine.resume(worker))
assert(actions==1 and #warnings==0,'worker must not continue after a mode change')
task.spawn(function() actions=actions+100 end)
assert(actions==1,'new mission tasks must not run outside mission')
assert(not farmActive() and not clickOnce() and not inputAllowed(),'movement and input guards must reject unknown mode')
mode='mission'
local destroyed,disconnected=0,0
life.guis[{Destroy=function() destroyed=destroyed+1 end}]=true
life.connections[1]={Disconnect=function() disconnected=disconnected+1 end}
local pending=task.spawn(function() task.wait(5); actions=actions+100 end)
missionKey(input,'R',true)
lobbySession.stopMission()
lobbySession.stopMission()
assert(destroyed==1 and disconnected==1 and cancelled[pending],'early stop must remove owned UI, subscriptions and workers once')
assert(#released==1 and released[1]=='R','held refill/skill key must be released on stop')
assert(not missionKey(input,'One',true),'inactive mission cannot press a skill key')
assert(not farmActive() and not clickOnce() and not inputAllowed(),'inactive session remains blocked even if mode says mission')
print('PASS: mission yield guards, inactive input/movement guards, partial-startup UI cleanup, connection/worker cancellation and held-key release (mocked Lua)')
'''
run(setup+section('local baseTask, baseCoroutine','-- Yozakura startup')
    +section('local function farmActive()','local function v108()')
    +section('local function clickOnce()','v4.performM1 = clickOnce')
    +section('local function inputAllowed()','local function refreshAutoSkill()')+checks)

lobby=read('AOTR_lobby.lua')
i=lobby.index('local function stop()')
stop=lobby[i:lobby.index('ctx.stopLobby=stop',i)]
run(r'''
local alive,active,epoch=true,true,0
local worker={}
local calls={disconnect=0,destroy=0,cancel=0}
local connections={{Disconnect=function() calls.disconnect=calls.disconnect+1 end}}
local gui={Destroy=function() calls.destroy=calls.destroy+1 end}
task={cancel=function(value) assert(value==worker); calls.cancel=calls.cancel+1 end}
''' + stop + r'''
stop(); stop()
assert(not alive and not active and epoch==1)
assert(calls.disconnect==1 and calls.destroy==1 and calls.cancel==1)
print('PASS: lobby stop cancels its worker, disconnects subscriptions and removes UI once (mocked Lua)')
''')
