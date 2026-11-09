"""R2 workflow tests; simulated UI acknowledgements, no live server."""
from pathlib import Path
import os
import sys
if os.environ.get("YOZAKURA_TEST_DEPS"):
    sys.path.insert(0, os.environ["YOZAKURA_TEST_DEPS"])
from lupa.lua54 import LuaRuntime
root=Path(__file__).resolve().parents[1]
lua=LuaRuntime(unpack_returned_tuples=True)
lua.globals().L=lua.execute((root/"AOTR_launch.lua").read_text(encoding="utf-8"))
lua.execute("""
function fixture(options)
    local f={time=0,screen="lobby",index=1,starts=0,creates=0,changes=0,mods={Oddball=true},selected=nil}
    options=options or {}
    f.index=options.index or 1
    local difficulties={{"easy","E-"},{"hard","D+"},{"aberrant","A-"},{"aberrant","A"}}
    local a={
        now=function()return f.time end,
        valid=function()return not f.cancelled end,
        wait=function(s)
            f.time=f.time+s
            if options.cancelAt and f.countdown and f.time-f.countdown>=options.cancelAt then f.cancelled=true end
            return not f.cancelled
        end,
        status=function(s)
            if s:match("^Starting in") and not f.countdown then f.countdown=f.time end
        end,
        stage=function()return f.screen end,
        press=function(name)
            if name=="Play" then f.screen="modes"
            elseif name=="Missions" or name=="Raids" or name=="Waves" then f.screen="setup"
            elseif name=="Next difficulty" then
                if f.index==#difficulties then return false,"No next" end
                f.index=f.index+1
            elseif name=="Previous difficulty" then
                if f.index==1 then return false,"No previous" end
                f.index=f.index-1
            elseif name=="Objectives" then f.screen="objectives"
            elseif name=="Create" then
                f.creates=f.creates+1
                if not options.createTimeout then f.screen="party" end
            elseif name=="Modifiers" then f.screen="modifiers"
            elseif name=="Close modifiers" then f.screen="party"
            elseif name=="Start" then
                f.starts=f.starts+1;f.startedAt=f.time
                if not options.startTimeout then f.teleport=true end
            else error("Unexpected press "..name) end
            return true
        end,
        selectContent=function(name)
            if options.locked then return false,"Locked" end
            f.selected=name;return true
        end,
        difficulty=function()return difficulties[f.index][1],difficulties[f.index][2]end,
        objectivesOpen=function()return f.screen=="objectives"end,
        selectObjective=function(name)f.objective=name;f.screen="setup";return true end,
        modifier=function(name)
            if options.unknownModifier and name=="Nightmare" then return nil,"unreadable" end
            return f.mods[name] or false
        end,
        toggleModifier=function(name)f.mods[name]=not f.mods[name];f.changes=f.changes+1;return true end,
        partyFingerprint=function()
            if options.changeParty and f.countdown and f.time-f.countdown>0.5 then return "changed" end
            return "same"
        end,
        mission=function()return false end,
        teleporting=function()return f.teleport==true end,
    }
    local c={mode="Missions",map="Trost",boss="Attack Titan",difficulty="Hard",grade="D+",
        objective="Protect",delay=3,modifiers={Nightmare=true},customModifier=""}
    return f,c,L.new(a)
end
assert(L.seconds("5")==5 and L.seconds(-3)==0 and L.seconds(99999)==3600)
assert(L.seconds("bad")==nil and L.seconds(0/0)==nil)
local d,g=L.readDifficulty("HARD (D+ GRADE)")
assert(d=="hard" and g=="D+")
d,g=L.readDifficulty("ABERRANT (A GRADE)")
assert(d=="aberrant" and g=="A")
local f,c,m=fixture()
assert(m:Run(c,1))
assert(f.selected=="Trost" and f.objective=="Protect")
assert(f.mods.Nightmare and not f.mods.Oddball)
assert(f.starts==1 and f.creates==1 and f.startedAt-f.countdown>=3)
assert(not m:Run(c,1) and f.starts==1)
f,c,m=fixture({cancelAt=0.5})
assert(not m:Run(c,1) and f.starts==0)
f,c,m=fixture({changeParty=true})
assert(not m:Run(c,1) and f.starts==0)
f,c,m=fixture({createTimeout=true})
assert(not m:Run(c,1) and f.creates==1 and f.starts==0)
assert(not m:Run(c,1) and f.creates==1)
f,c,m=fixture({startTimeout=true})
assert(not m:Run(c,1) and f.starts==1)
assert(not m:Run(c,1) and f.starts==1)
f,c,m=fixture({locked=true})
c.mode="Raids";c.boss="Colossal Titan"
assert(not m:Run(c,1) and f.creates==0 and f.starts==0)
f,c,m=fixture({unknownModifier=true})
assert(not m:Run(c,1) and f.starts==0)
f,c,m=fixture({index=4})
c.difficulty="Easy";c.grade="E-";c.delay=0
assert(m:Run(c,1) and f.index==1 and f.starts==1)
f,c,m=fixture()
c.difficulty="Missing";c.grade="Z"
assert(not m:Run(c,1) and f.starts==0 and f.creates==0)
for _,map in ipairs(L.maps)do
    f,c,m=fixture();c.map=map;c.objective="Default";c.delay=0
    assert(m:Run(c,1) and f.selected==map)
end
for _,boss in ipairs(L.bosses)do
    f,c,m=fixture();c.mode="Raids";c.boss=boss;c.delay=0
    assert(m:Run(c,1) and f.selected==boss)
end
f,c,m=fixture();c.mode="Waves";c.delay=0
assert(m:Run(c,1) and f.selected==nil and f.creates==1)
f,c,m=fixture();c.map="Utgard";c.objective="Protect"
assert(not m:Run(c,1) and f.creates==0)
""")
print("PASS all maps / raid bosses / Waves, objective validation, grade parsing, reverse selector, countdown, cancellation, modifiers, locked choices, create/start timeout holds")

lua.execute((root/"tests/lobby_mock.lua").read_text(encoding="utf-8"))
lua.globals().R=lua.execute((root/"AOTR_lobby_rules.lua").read_text(encoding="utf-8"))
source=(root/"AOTR_lobby.lua").read_text(encoding="utf-8").replace("return {Stop=stop,Gui=gui}", """return {
    Stop=stop,Gui=gui,Press=launchPress,Stage=stage,Difficulty=readDifficulty,Modifier=modifierState,
    Begin=function()active=true;return epoch end
}""")
lua.globals().hub=lua.execute(source,lua.globals().ctx,lua.globals().R,lua.globals().L)
lua.execute("""
local function element(class,parent,name,value)
    local o=Instance.new(class);o.Parent=parent;o.Name=name
    if value then o.Text=value end
    return o
end
local background=element("TextButton",pg,"BackgroundStart","Start")
local bgHits,partyHits=0,0
background.Activated:Connect(function()bgHits=bgHits+1 end)
local party=element("Frame",pg,"PartyModal")
element("TextLabel",party,"Count","Players: 1 / 5")
element("TextLabel",party,"Map","SHIGANSHINA")
element("TextLabel",party,"Difficulty","EASY")
element("TextButton",party,"Leave","Leave")
element("TextButton",party,"Modifiers","Modifiers")
local start=element("TextButton",party,"PartyStart","Start")
start.Activated:Connect(function()partyHits=partyHits+1 end)
local token=hub.Begin()
assert(hub.Stage()=="party")
assert(hub.Press("Start",token))
assert(partyHits==1 and bgHits==0,"Never click background Start")
party.Visible=false
local setup=element("Frame",pg,"Setup")
element("TextLabel",setup,"Grade","HARD (D+ GRADE)")
element("TextButton",setup,"Back","Back")
assert(hub.Stage()=="setup")
local d,g=hub.Difficulty();assert(d=="hard" and g=="D+")
setup.Visible=false
local modifiers=element("Frame",pg,"ModifierModal")
element("TextLabel",modifiers,"Title","MODIFIERS")
element("TextButton",modifiers,"Back","Back")
local row=element("Frame",modifiers,"Nightmare")
element("TextLabel",row,"Name","Nightmare")
local checkbox=element("TextButton",row,"Checkbox","")
local tick=element("Frame",checkbox,"Checkmark");tick.Visible=false
assert(hub.Stage()=="modifiers")
assert(hub.Modifier("Nightmare")==false)
tick.Visible=true
assert(hub.Modifier("Nightmare")==true)
checkbox.Attributes={Selected=false}
assert(hub.Modifier("Nightmare")==nil,"Conflicting state must pause")
hub.Stop()
""")
print("PASS actual adapter modal scoping with duplicate Start, compound difficulty labels, modifier OFF/ON/conflicting state")
