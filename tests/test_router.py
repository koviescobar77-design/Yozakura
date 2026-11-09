"""Offline router lifecycle tests. Requires the Lua 5.4 shared library, not Roblox."""
import ctypes
import ctypes.util
from pathlib import Path
import sys

root = Path(__file__).resolve().parents[1]
source_path = Path(sys.argv[1]) if len(sys.argv) > 1 else root / "AOTR_router_state.lua"
if not source_path.exists():
    source_path = root / "router-fix-AOTR_router_state.lua"
source = source_path.read_text(encoding="utf-8")
router_path = source_path.with_name("loader_lobby_mission.lua")
if not router_path.exists():
    router_path = source_path.with_name("router-fix-loader_lobby_mission.lua")
router_source = router_path.read_text(encoding="utf-8")
adapter_start = router_source.index("load=function(kind,session)") + len("load=")
adapter_end = router_source.index("    end,\n})", adapter_start) + len("    end")
adapter = router_source[adapter_start:adapter_end]

lib = ctypes.CDLL(ctypes.util.find_library("lua5.4") or "liblua5.4.so.0")
lib.luaL_newstate.restype = ctypes.c_void_p
lib.luaL_openlibs.argtypes = [ctypes.c_void_p]
lib.luaL_loadstring.argtypes = [ctypes.c_void_p, ctypes.c_char_p]
lib.luaL_loadstring.restype = ctypes.c_int
lib.lua_pcallk.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_int, ctypes.c_int, ctypes.c_longlong, ctypes.c_void_p]
lib.lua_pcallk.restype = ctypes.c_int
lib.lua_tolstring.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_void_p]
lib.lua_tolstring.restype = ctypes.c_char_p
lib.lua_close.argtypes = [ctypes.c_void_p]

checks = r'''
local function fixture()
    local f = {now=0, current='unknown', jobs={}, starts={}, stops={}, live={}, reports={}, cancellations=0}
    local function resume(job)
        if job.cancelled then return end
        local ok, delay = coroutine.resume(job.thread)
        assert(ok, tostring(delay))
        if coroutine.status(job.thread) ~= 'dead' then
            job.wake = f.now + math.max(delay or 0, 0.0001)
            f.jobs[#f.jobs+1] = job
        end
    end
    function f.advance(seconds)
        local untilAt = f.now + seconds
        while true do
            local index, earliest
            for i, job in ipairs(f.jobs) do
                if not job.cancelled and job.wake <= untilAt and (not earliest or job.wake < earliest) then
                    index, earliest = i, job.wake
                end
            end
            if not index then break end
            f.now = earliest
            resume(table.remove(f.jobs,index))
        end
        f.now = untilAt
    end
    function f.attach(kind, session, index)
        for other in pairs(f.live) do error('Two active modules: '..other..' and '..kind) end
        local identity = kind..':'..index
        f.live[identity] = true
        local stopped = false
        local function stop()
            if stopped then return end
            stopped = true
            f.live[identity] = nil
            f.stops[#f.stops+1] = identity
        end
        session[kind=='mission' and 'stopMission' or 'stopLobby'] = stop
        return {Stop=stop}
    end
    local api = {
        mode=function() return f.current end,
        clock=function() return f.now end,
        report=function(message) f.reports[#f.reports+1]=message end,
        context={visible=function() return true end, entry='test-loader', teleporting=false},
        spawn=function(fn)
            local job = {thread=coroutine.create(fn)}
            f.byThread = f.byThread or {}
            f.byThread[job.thread] = job
            resume(job)
            return job.thread
        end,
        cancel=function(thread)
            f.cancellations=f.cancellations+1
            if f.ignoreCancel then return end
            local job=f.byThread and f.byThread[thread]
            if job then job.cancelled=true end
        end,
        load=function(kind,session)
            local index=#f.starts+1
            f.starts[index]={kind=kind,session=session}
            if f.behavior then return f.behavior(kind,session,index) end
            return f.attach(kind,session,index)
        end,
    }
    f.controller = makeController(api)
    function f.tick(seconds)
        f.advance(seconds or 0)
        f.controller:Tick()
    end
    function f.change(mode)
        f.current=mode
        f.controller:Tick()
    end
    function f.start(mode)
        f.change(mode)
        f.tick(2.01)
    end
    return f
end

-- Start only after stable positive evidence; unknown/menu/transition own no module.
local f=fixture()
f.tick(10)
assert(#f.starts==0)
f.change('lobby'); f.tick(1.99)
assert(#f.starts==0,'lobby started before evidence settled')
f.tick(.02)
assert(#f.starts==1 and f.starts[1].kind=='lobby')
f.tick(20)
assert(#f.starts==1,'stable lobby started twice')
local firstLobby=f.starts[1].session
f.change('unknown')
assert(#f.stops==1 and next(f.live)==nil,'unknown must stop lobby immediately')
assert(firstLobby.mode()~='lobby','stale lobby context remained valid')
f.start('mission')
assert(#f.starts==2 and f.starts[2].kind=='mission')
f.tick(10)
assert(#f.starts==2,'stable mission started twice')
local firstMission=f.starts[2].session
f.change('transition')
assert(#f.stops==2 and next(f.live)==nil,'transition must stop mission immediately')
assert(firstMission.mode()~='mission','stale mission context remained valid')
f.start('lobby')
f.start('mission')
assert(#f.starts==4 and f.starts[4].kind=='mission','second mission failed to restart')
assert(f.starts[4].session~=firstMission,'mission generations shared a session')
f.change('menu')
assert(next(f.live)==nil,'slot menu must not own mission or lobby')
f.tick(10)
assert(#f.starts==4,'menu incorrectly loaded a module')
f.controller:Stop()
f.start('lobby')
assert(#f.starts==4,'stopped router restarted')

-- In-progress mission startup is stopped on leaving mission and never adopted later.
f=fixture()
f.behavior=function(kind,session,index)
    local handle=f.attach(kind,session,index)
    coroutine.yield(10)
    return handle
end
f.start('mission')
assert(#f.starts==1)
f.change('unknown')
assert(#f.stops==1 and f.cancellations>0 and next(f.live)==nil,'loading mission not cleaned up')
f.tick(20)
assert(next(f.live)==nil,'cancelled load became live again')

-- A late old success/error cannot clean up a newer launch (even when cancellation fails).
for _,lateError in ipairs({false,true}) do
    f=fixture()
    f.ignoreCancel=true
    f.behavior=function(kind,session,index)
        local handle=f.attach(kind,session,index)
        if index==1 then
            coroutine.yield(10)
            if lateError then error('old delayed load failed') end
        end
        return handle
    end
    f.start('mission')
    local old=f.starts[1].session
    f.change('unknown')
    f.start('mission')
    local current=f.starts[2].session
    assert(current~=old and #f.stops==1)
    f.tick(11)
    assert(#f.starts==2 and #f.stops==1,'stale completion/error affected new session')
    assert(current.mode()=='mission' and next(f.live)~=nil,'new mission was invalidated by old generation')
    f.controller:Stop()
    assert(#f.stops==2 and next(f.live)==nil)
end

-- Startup failure cleans partial work, backs off, and allows a fresh same-mode retry.
f=fixture()
f.behavior=function(kind,session,index)
    local handle=f.attach(kind,session,index)
    if index==1 then error('fixture startup failure') end
    return handle
end
f.start('lobby')
assert(#f.starts==1 and #f.stops==1 and next(f.live)==nil,'failed startup leaked its module')
f.tick(4.9)
assert(#f.starts==1,'startup retry ignored backoff')
f.tick(.2)
assert(#f.starts==2 and next(f.live)~=nil,'startup failure permanently blocked same-mode retry')
f.controller:Stop(); f.controller:Stop()
assert(#f.stops==2,'Stop must be idempotent')

-- Rapidly alternating evidence cannot create an overlapping or prematurely started module.
f=fixture()
for i=1,8 do
    f.change(i%2==0 and 'mission' or 'lobby')
    f.tick(.3)
end
assert(#f.starts==0,'flapping mode evidence started a module')
f.tick(2.01)
assert(#f.starts==1 and f.starts[1].kind=='mission')
f.controller:Stop()
print('PASS: stable-mode startup, lobby/mission separation, transition cleanup, repeated missions, cancellation, stale generations, retry backoff and idempotent stop (mocked Lua)')
'''

adapter_checks = r'''
local current, downloaded, invoked, behavior
local session={isCurrent=function() return current end}
local function resetAdapter()
    current,downloaded,invoked=true,{},{}
    behavior=nil
end
fetch=function(name)
    downloaded[#downloaded+1]=name
    if behavior then behavior('download',name) end
    return function(...)
        invoked[#invoked+1]=name
        if behavior then behavior('invoke',name) end
        if name=='AOTR_launch.lua' then return {} end
        assert(current,'module body invoked after mode changed')
        assert((...)==session,'module must receive its own launch session')
        return {Stop=function() end}
    end
end
for _,kind in ipairs({'lobby','mission'}) do
    resetAdapter()
    current=false
    assert(not pcall(adapter,kind,session) and #downloaded==0,'inactive launch downloaded a module')
    resetAdapter()
    behavior=function(stage)
        if stage=='download' then current=false end
    end
    assert(not pcall(adapter,kind,session) and #invoked==0,'mode change during first fetch invoked stale module')
end
resetAdapter()
behavior=function(stage,name)
    if stage=='download' and name=='AOTR_launch.lua' then current=false end
end
assert(not pcall(adapter,'lobby',session) and #downloaded==2 and #invoked==0,'mode change during second lobby fetch invoked modules')
resetAdapter()
behavior=function(stage,name)
    if stage=='invoke' and name=='AOTR_launch.lua' then current=false end
end
assert(not pcall(adapter,'lobby',session) and #invoked==1,'mode change during setup still opened lobby')
resetAdapter()
assert(pcall(adapter,'lobby',session))
assert(#downloaded==2 and #invoked==2 and invoked[2]=='AOTR_lobby.lua')
resetAdapter()
assert(pcall(adapter,'mission',session))
assert(#downloaded==1 and invoked[1]=='AOTR_mission_isolated.lua')
print('PASS: actual router adapter rejects stale sessions before/after each module download and before opening the lobby (mocked downloads)')
'''

assert "]====]" not in source
code = "local makeController = assert(load([====[" + source + "]====]))()\n" + checks
code += "\nlocal fetch\nlocal R={}\nlocal adapter=" + adapter + "\n" + adapter_checks
state=lib.luaL_newstate()
lib.luaL_openlibs(state)
try:
    status=lib.luaL_loadstring(state,code.encode())
    if status==0:
        status=lib.lua_pcallk(state,0,0,0,0,None)
    if status:
        raise RuntimeError(lib.lua_tolstring(state,-1,None).decode())
finally:
    lib.lua_close(state)
