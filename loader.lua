-- Freenium loader, copied unchanged from resellz705-cyber/Freenium.
-- Original Yozakura entry point: loader_before_freenium.lua
-- Obfuscated third-party code; runtime behavior has not been verified.
assert(type(loadstring) == "function", "This environment does not provide loadstring")
local source = game:HttpGet("https://raw.githubusercontent.com/koviescobar77-design/Yozakura/b39a00b7608b677aba716982775b27adad4647a5/FreeniumLoader.lua")
assert(type(source) == "string" and #source > 0, "Freenium download was empty")
local chunk, err = loadstring(source, "@Yozakura/FreeniumLoader.lua")
assert(chunk, err)
-- Display-name override only; the bundled third-party source remains unchanged.
do
    local env = type(getgenv) == "function" and getgenv() or _G
    local token = {}
    env.YozakuraTitleOverride = token
    local function renameTitle(object)
        if not (object:IsA("TextLabel") or object:IsA("TextButton")) then return end
        local plain = object.Text:gsub("<[^>]*>", ""):lower():match("^%s*(.-)%s*$")
        if plain == "solo hub" then
            object.Text = object.Text:gsub("[Ss][Oo][Ll][Oo]%s+[Hh][Uu][Bb]", "Yozakura")
        end
    end
    task.spawn(function()
        local deadline = os.clock() + 120
        repeat
            local roots = {}
            local player = game:GetService("Players").LocalPlayer
            local pg = player and player:FindFirstChildOfClass("PlayerGui")
            if pg then roots[pg] = true end
            pcall(function() roots[game:GetService("CoreGui")] = true end)
            if type(gethui) == "function" then
                pcall(function() local root = gethui(); if root then roots[root] = true end end)
            end
            for root in pairs(roots) do
                pcall(function()
                    for _, object in ipairs(root:GetDescendants()) do
                        pcall(renameTitle, object)
                    end
                end)
            end
            task.wait(0.5)
        until env.YozakuraTitleOverride ~= token or os.clock() >= deadline
        if env.YozakuraTitleOverride == token then env.YozakuraTitleOverride = nil end
    end)
end
return chunk()
