-- Minimal Roblox UI model for startup and input tests; not a game/server simulator.
table.find=function(t,v) for i,x in ipairs(t) do if x==v then return i end end end
local function signal()
    local s={callbacks={}}
    function s:Connect(fn)
        table.insert(self.callbacks,fn)
        return {Disconnect=function() end}
    end
    return s
end
local function vector(x,y)
    return setmetatable({X=x or 0,Y=y or 0},{
        __add=function(a,b) return vector(a.X+b.X,a.Y+b.Y) end,
        __sub=function(a,b) return vector(a.X-b.X,a.Y-b.Y) end,
        __div=function(a,b) return vector(a.X/b,a.Y/b) end
    })
end
Color3={new=function(...) return {...} end,fromRGB=function(...) return {...} end}
UDim={new=function(...) return {...} end}
UDim2={new=function(...) return {...} end,fromOffset=function(...) return {...} end,fromScale=function(...) return {...} end}
Enum=setmetatable({}, {__index=function(t,k) local v=setmetatable({}, {__index=function(_,n)return n end}); rawset(t,k,v); return v end})
local nodes={}
local methods={}
function methods:IsA(class)
    if self.ClassName==class then return true end
    if class=="GuiButton" then return self.ClassName=="TextButton" or self.ClassName=="ImageButton" end
    if class=="GuiObject" then
        return self.ClassName=="Frame" or self.ClassName=="ScrollingFrame" or self.ClassName=="TextLabel"
            or self.ClassName=="TextBox" or self:IsA("GuiButton")
    end
    return false
end
function methods:GetChildren()
    local out={}
    for _,n in ipairs(nodes) do if n.Parent==self then out[#out+1]=n end end
    return out
end
function methods:GetDescendants()
    local out={}
    for _,n in ipairs(nodes) do if n:IsDescendantOf(self) then out[#out+1]=n end end
    return out
end
function methods:IsDescendantOf(parent)
    local p=self.Parent
    while p do if p==parent then return true end; p=p.Parent end
    return false
end
function methods:FindFirstChild(name)
    for _,n in ipairs(self:GetChildren()) do if n.Name==name then return n end end
end
methods.WaitForChild=methods.FindFirstChild
function methods:GetPropertyChangedSignal(name) return signal() end
function methods:GetAttribute(name) return (self.Attributes or {})[name] end
function methods:GetAttributes() return self.Attributes or {} end
function methods:GetFullName() return (self.Parent and self.Parent:GetFullName().."." or "")..(self.Name or self.ClassName) end
function methods:Destroy() self.Parent=nil end
function methods:GetGuiObjectsAtPosition() return {} end
Instance={new=function(class)
    local o=setmetatable({ClassName=class,Name=class,Visible=true,Active=true,Enabled=true,
        AbsoluteSize=vector(100,30),AbsolutePosition=vector(20,20),Text="",
        Activated=signal(),MouseButton1Click=signal(),InputBegan=signal(),InputEnded=signal(),
        InputChanged=signal(),FocusLost=signal()}, {__index=methods})
    nodes[#nodes+1]=o; return o
end}
pg=Instance.new("PlayerGui")
local player=Instance.new("Player")
pg.Parent=player
local input={InputBegan=signal(),InputEnded=signal(),InputChanged=signal()}
workspace={CurrentCamera={ViewportSize=vector(1280,720),GetPropertyChangedSignal=function()return signal()end}}
game={GetService=function(_,name)
    if name=="Players" then return {LocalPlayer=player} end
    if name=="UserInputService" then return input end
    if name=="HttpService" then return {JSONEncode=function()return "{}"end} end
    error("Unexpected service "..name)
end}
local clock=0
os.clock=function()return clock end
task={spawn=function(fn)return fn end, wait=function(s) clock=clock+(s or 0.1) end}
getconnections=function(signal) return signal.callbacks end
firesignal=function(signal) for _,fn in ipairs(signal.callbacks)do fn()end end
warn=print
testMode="lobby"
ctx={mode=function()return testMode end,visible=function(o)
    local p=o
    while p do
        if p.Name=="YozakuraLobby" or p.Visible==false or p.Enabled==false then return false end
        p=p.Parent
    end
    return o.Parent~=nil
end}
