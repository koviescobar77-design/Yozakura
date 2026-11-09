"""Run with Python and lupa installed. These tests do not connect to Roblox."""
from pathlib import Path
import os
import sys

if os.environ.get("YOZAKURA_TEST_DEPS"):
    sys.path.insert(0, os.environ["YOZAKURA_TEST_DEPS"])
from lupa.lua54 import LuaRuntime

root = Path(__file__).resolve().parents[1]
lua = LuaRuntime(unpack_returned_tuples=True)
for path in root.glob("*.lua"):
    result = lua.eval("function(s) local f,e=load(s); return f~=nil,e end")(path.read_text(encoding="utf-8"))
    assert result[0], f"{path.name}: {result[1]}"
    print("COMPILE", path.name)

lua.globals().R = lua.execute((root / "AOTR_lobby_rules.lua").read_text(encoding="utf-8"))
lua.execute("""
assert(R.mode({})=="unknown")
assert(R.mode({lobby=true})=="lobby")
assert(R.mode({mission=true})=="mission")
assert(R.mode({menu=true})=="menu")
assert(R.mode({lobby=true,mission=true})=="transition")
assert(R.number("7,744")==7744)
assert(R.number("10.5k")==10500)
assert(R.number("149 Robux")==nil)
assert(R.number("10 / 100")==nil)
assert(R.number("-1")==nil)
assert(R.clean("  <b>FOUNDER’S BLESSING</b> ")=="founder's blessing")
local plan=R.plan(" First > Drill Thrust > Offense Capstone ")
assert(#plan==3 and plan[1]=="First" and plan[3]=="Offense Capstone")
local config={currencies={Gems=true},rarities={Legendary=true,Mythic=true},budgets={Gems=1000}}
local card={currency="Gems",rarity="Legendary",price=799,balance=7744}
assert(R.market(card,config,{}))
assert(not R.market(card,config,{Gems=202}))
card.balance=10;assert(not R.market(card,config,{}));card.balance=7744
card.balance=nil;assert(not R.market(card,config,{}));card.balance=7744
card.price=nil;assert(not R.market(card,config,{}));card.price=799
card.price=0;assert(not R.market(card,config,{}));card.price=799
card.robux=true;assert(not R.market(card,config,{}));card.robux=false
card.crate=true;assert(not R.market(card,config,{}));card.crate=false
card.soldOut=true;assert(not R.market(card,config,{}));card.soldOut=false
card.currency="Pumpkins";assert(not R.market(card,config,{}));card.currency="Gems"
card.rarity="Epic";assert(not R.market(card,config,{}));card.rarity="Mythic"
assert(R.market(card,config,{}))
card.spin=true;assert(not R.market(card,config,{}))
config.spins=true;assert(R.market(card,config,{}))
config.budgets.Gems=0;assert(not R.market(card,config,{}))
""")
print("PASS mode decisions, currency parsing, skill ordering, purchase filtering and budget cases")

lua.execute((root / "tests/lobby_mock.lua").read_text(encoding="utf-8"))
source = (root / "AOTR_lobby.lua").read_text(encoding="utf-8")
# Expose the actual local functions only in this test copy.
source = source.replace("return {Stop=stop,Gui=gui}", """return {
    Stop=stop,Gui=gui,Transaction=transaction,Unique=uniqueButton,
    Begin=function() active=true; return epoch end
}""")
lua.globals().Launch = lua.execute((root / "AOTR_launch.lua").read_text(encoding="utf-8"))
lua.globals().hub = lua.execute(source, lua.globals().ctx, lua.globals().R, lua.globals().Launch)
lua.execute("""
assert(hub.Gui.Name=="YozakuraLobby")
local panel=hub.Gui:GetChildren()[1]
local count=0
for _,o in ipairs(hub.Gui:GetDescendants())do if o:IsA("TextButton")then count=count+1 end end
assert(count>=60, "Expected actual controls for all feature groups")
local card=Instance.new("Frame");card.Name="Offer";card.Parent=pg
local buy=Instance.new("TextButton");buy.Text="Buy";buy.Parent=card
local count=0
buy.Activated:Connect(function() count=count+1;buy.Text="Sold out" end)
local token=hub.Begin()
assert(hub.Transaction(card,buy,"one",token))
assert(count==1)
assert(not hub.Transaction(card,buy,"one",token))
assert(count==1,"Duplicate transaction must not dispatch")
local timeout=Instance.new("TextButton");timeout.Text="Claim";timeout.Parent=card
timeout.Activated:Connect(function()count=count+1 end)
assert(not hub.Transaction(card,timeout,"timeout",token))
assert(not hub.Transaction(card,timeout,"timeout",token))
assert(count==2,"Unknown outcome must be held")
local another=Instance.new("TextButton");another.Text="Claim";another.Parent=card
assert(hub.Unique(card,{"Claim"})==nil,"Ambiguous button must not be picked")
testMode="mission"
assert(not hub.Transaction(card,timeout,"wrongmode",token))
assert(count==2,"Lobby actions must stop in a mission")
testMode="lobby"
hub.Stop()
assert(hub.Gui.Parent==nil)
assert(not hub.Transaction(card,timeout,"closed",token))
""")
print("PASS full lobby UI construction, duplicate holds, unknown outcomes, ambiguity, mode gate and close")
