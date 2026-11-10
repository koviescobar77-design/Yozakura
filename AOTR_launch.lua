-- R3: serialized mission preparation and a cancellable countdown.
-- Adapter reads the actual game UI; this module has no game remote calls.
local L={}
local function clean(value) return tostring(value or ""):gsub("<[^>]->",""):match("^%s*(.-)%s*$"):lower() end
function L.readDifficulty(value)
    local name,grade=clean(value):match("^(.-)%s*%(([a-z][+-]?)%s+grade%)$")
    if not name then name,grade=clean(value):match("^(.-)%s*%(([a-z][+-]?)%)$") end
    if name then return name:match("^%s*(.-)%s*$"),grade:upper() end
end
L.maps={"Shiganshina","Trost","Outskirts","Forest","Utgard","Docks","Stohess","Chapel"}
L.bosses={"Attack Titan","Armored Titan","Female Titan","Colossal Titan"}
L.modes={"Missions","Raids","Waves"}
L.modifiers={"Inflation","Merchant Greed","Unworthy","Shortage","Juggernaut","Tipping Point"}
L.objectives={Trost={"Default","Skirmish","Protect","Random"},Utgard={"Default","Skirmish","Defend","Random"}}
L.presets={
    {name="Easy",grade="E-"}, {name="Hard",grade="D+"},
    {name="Aberrant",grade="A-"}, {name="Aberrant",grade="A"}
}
function L.seconds(value)
    local n=tonumber(value)
    if not n or n~=n or n==math.huge or n==-math.huge then return nil end
    return math.max(0,math.min(3600,math.floor(n)))
end
local function contains(t,value)
    for _,v in ipairs(t) do if v==value then return true end end
    return false
end
function L.validate(c)
    if not contains(L.modes,c.mode) then return false,"Choose a mode" end
    if c.mode=="Missions" and not contains(L.maps,c.map) then return false,"Choose a map" end
    if c.mode=="Raids" and not contains(L.bosses,c.boss) then return false,"Choose a raid boss" end
    if L.seconds(c.delay)==nil then return false,"Enter a valid start delay" end
    if c.mode~="Waves" and (type(c.difficulty)~="string" or c.difficulty=="") then return false,"Choose a difficulty" end
    if c.mode=="Missions" and c.objective~="Default" then
        if not contains(L.objectives[c.map] or {"Default"},c.objective) then return false,"Objective unavailable for selected map" end
    end
    return true
end
function L.new(a)
    local machine={held=false}
    local function waitFor(predicate,seconds,token)
        local untilTime=a.now()+seconds
        repeat
            if not a.valid(token) then return false,"Cancelled" end
            if predicate() then return true end
            if not a.wait(0.1,token) then return false,"Cancelled" end
        until a.now()>=untilTime
        return false,"UI response timed out"
    end
    local function press(name,token)
        if not a.valid(token) then return false,"Cancelled" end
        return a.press(name,token)
    end
    function machine:OpenMode(mode,token)
        if not contains(L.modes,mode) then return false,"Choose a mode" end
        if self.held then return false,"Previous launch outcome is unknown. Inspect the lobby, then Reset Holds." end
        local ok,err
        if not a.valid(token) then return false,"Cancelled" end
        a.status("Opening Gear Up / Play")
        local stage=a.stage()
        for _=1,4 do
            if stage=="setup" or stage=="objectives" or stage=="modifiers" or stage=="party" then
                local before=stage
                ok,err=press(stage=="party" and "Leave" or "Back",token)
                if not ok then return false,err end
                ok,err=waitFor(function()return a.stage()~=before end,5,token)
                if not ok then return false,err end
                stage=a.stage()
            else break end
        end
        if stage=="other" then
            ok,err=press("Gear Up",token); if not ok then return false,err end
            ok,err=waitFor(function()return a.stage()~="other"end,5,token); if not ok then return false,err end
            stage=a.stage()
        end
        if stage=="lobby" then
            ok,err=press("Play",token); if not ok then return false,err end
            ok,err=waitFor(function()return a.stage()=="modes"end,5,token); if not ok then return false,err end
            stage="modes"
        end
        if stage~="modes" then
            return false,"Open the mode selector first (leave an existing party manually)"
        end
        ok,err=press(mode,token); if not ok then return false,err end
        ok,err=waitFor(function()
            local s=a.stage();return s=="setup" or (mode=="Waves" and s=="party")
        end,5,token)
        if not ok then return false,err end
        self.openedMode=mode
        return true,"Opened "..mode
    end
    function machine:Run(c,token)
        if self.held then return false,"Previous launch outcome is unknown. Inspect the lobby, then Reset Holds." end
        local ok,err=L.validate(c); if not ok then return false,err end
        if not a.valid(token) then return false,"Cancelled" end
        local current=a.stage()
        if current=="party" and a.partyMatches and a.partyMatches(c) then
            self.openedMode=c.mode
            a.status("Using current "..c.mode.." party; applying selected modifiers")
        end
        if self.openedMode~=c.mode or (current~="setup" and current~="party") then
            ok,err=self:OpenMode(c.mode,token); if not ok then return false,err end
        end
        if c.mode~="Waves" then
            local selection=c.mode=="Missions" and c.map or c.boss
            a.status("Selecting "..selection)
            ok,err=a.selectContent(selection,token)
            if not ok then return false,err end
        end
        if c.mode~="Waves" then
        a.status("Selecting "..c.difficulty..(c.grade~="" and " ("..c.grade..")" or ""))
        -- Enumerate the game's selector without assuming its order or grade mapping.
        local seen,direction={}, "Next difficulty"
        local matched=false
        for attempt=1,32 do
            if not a.valid(token) then return false,"Cancelled" end
            local difficulty,grade=a.difficulty()
            if not difficulty then return false,"Difficulty label unreadable · Scan UI" end
            if clean(difficulty)==clean(c.difficulty) and (c.grade=="" or grade==c.grade) then matched=true;break end
            local key=difficulty.."|"..tostring(grade)
            if seen[direction..key] then
                if direction=="Next difficulty" then direction="Previous difficulty"
                else return false,"Selected difficulty / grade is not offered in this mode" end
            end
            seen[direction..key]=true
            ok,err=press(direction,token)
            if ok then
                ok,err=waitFor(function()
                    local d,g=a.difficulty(); return d and (d.."|"..tostring(g))~=key
                end,3,token)
            end
            if not ok then
                if not a.valid(token) then return false,"Cancelled" end
                if direction=="Next difficulty" then direction="Previous difficulty"
                else return false,"Selected difficulty / grade unavailable or selector unreadable" end
            end
        end
        if not matched then return false,"Difficulty scan limit reached" end
        end
        if c.mode=="Missions" and c.objective~="Default" then
            ok,err=press("Objectives",token); if not ok then return false,err end
            ok,err=waitFor(function()return a.objectivesOpen()end,3,token); if not ok then return false,err end
            ok,err=a.selectObjective(c.objective,token); if not ok then return false,err end
        end
        if a.stage()=="setup" then
            a.status("Creating "..c.mode.." lobby")
            -- Held before dispatch: a timeout must never produce a second party.
            self.held=true
            ok,err=press("Create",token)
            if not ok then return false,err end
            ok,err=waitFor(function()return a.stage()=="party"end,8,token)
            if not ok then return false,"Create result not confirmed · inspect the game lobby" end
            self.held=false
        end
        if a.stage()~="party" then return false,"Party lobby / Start button missing" end
        -- A fresh party needs the modifier panel only when at least one option was selected.
        local wantsModifiers=false
        for _,name in ipairs(L.modifiers) do if c.modifiers[name]==true then wantsModifiers=true end end
        if wantsModifiers then
        a.status("Opening Modifiers for selected setup")
        ok,err=press("Modifiers",token); if not ok then return false,err end
        ok,err=waitFor(function()return a.stage()=="modifiers"end,5,token); if not ok then return false,err end
        local names={}
        for _,name in ipairs(L.modifiers) do names[#names+1]=name end
        for _,name in ipairs(names) do
            if not a.valid(token) then return false,"Cancelled" end
            local desired=c.modifiers[name]==true
            local state,reason=a.modifier(name)
            if state==nil then
                -- Missing unchecked modifiers may not exist in a particular game mode.
                if reason~="missing" or desired then return false,"Cannot verify modifier: "..name end
            elseif state~=desired then
                a.status("Modifier "..name..": "..(desired and "ON" or "OFF"))
                ok,err=a.toggleModifier(name,token); if not ok then return false,err end
                ok,err=waitFor(function()return a.modifier(name)==desired end,3,token)
                if not ok then return false,"Modifier change not confirmed: "..name end
            end
        end
        -- Recheck every requested modifier before leaving the panel and starting.
        for _,name in ipairs(L.modifiers) do
            if c.modifiers[name]==true and a.modifier(name)~=true then
                return false,"Required modifier not confirmed: "..name
            end
        end
        a.status("Selected modifiers confirmed; returning to Start")
        ok,err=press("Close modifiers",token); if not ok then return false,err end
        ok,err=waitFor(function()return a.stage()=="party"end,5,token); if not ok then return false,err end
        end
        -- Snapshot party identity and settings. Countdown cancels if another player changes them.
        local fingerprint=a.partyFingerprint()
        if not fingerprint then return false,"Party settings unreadable · Scan UI before starting" end
        local deadline=a.now()+L.seconds(c.delay)
        while a.now()<deadline do
            if not a.valid(token) then return false,"Countdown cancelled" end
            if a.stage()~="party" or a.partyFingerprint()~=fingerprint then return false,"Party settings changed; countdown cancelled" end
            a.status("Starting in "..math.ceil(deadline-a.now()).."s · "..c.mode..(c.mode=="Waves" and "" or " / "..c.difficulty))
            if not a.wait(0.1,token) then return false,"Countdown cancelled" end
        end
        if not a.valid(token) or a.stage()~="party" or a.partyFingerprint()~=fingerprint then return false,"Launch cancelled" end
        self.held=true
        a.status("Sending Start once")
        ok,err=press("Start",token); if not ok then return false,err end
        -- A successful input is not evidence that the mission loaded.
        local untilTime=a.now()+15
        repeat
            if a.mission() then return true,"Mission detected" end
            if a.teleporting() then return true,"Teleport started" end
            if not a.valid(token) then return false,"Start sent; check mission / teleport result" end
            if not a.wait(0.2,token) then return false,"Start sent; check mission / teleport result" end
        until a.now()>=untilTime
        return false,"Start sent once; mission not confirmed · held to avoid duplicate starts"
    end
    return machine
end
return L
