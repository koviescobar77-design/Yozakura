-- Freenium loader, copied unchanged from resellz705-cyber/Freenium.
-- Original Yozakura entry point: loader_before_freenium.lua
-- Obfuscated third-party code; runtime behavior has not been verified.
assert(type(loadstring) == "function", "This environment does not provide loadstring")
local source = game:HttpGet("https://raw.githubusercontent.com/koviescobar77-design/Yozakura/b39a00b7608b677aba716982775b27adad4647a5/FreeniumLoader.lua")
assert(type(source) == "string" and #source > 0, "Freenium download was empty")
local chunk, err = loadstring(source, "@Yozakura/FreeniumLoader.lua")
assert(chunk, err)

-- Yozakura Sakura Edition: cosmetic adapter for the protected third-party UI.
-- Runtime compatibility is unverified. Only a window containing the hub title is styled.
-- Optional: getgenv().YozakuraBannerAsset = "rbxassetid://YOUR_UPLOADED_IMAGE_ID"
local env = type(getgenv) == "function" and getgenv() or _G
-- PNG hosted with the loader. Custom assets require executor image-file support.
local bannerAsset = env.YozakuraBannerAsset
if type(bannerAsset) ~= "string" or bannerAsset == "" then
    local register = getcustomasset or getsynasset
    if type(register) == "function" and type(writefile) == "function" then
        local ok, result = pcall(function()
            local file = "YozakuraWide-7210bb10.png"
            if type(isfile) ~= "function" or not isfile(file) then
                local bytes = game:HttpGet("https://raw.githubusercontent.com/koviescobar77-design/Yozakura/7210bb1097e4546917519e1f7390c103038060c8/assets/yozakura-wide.png")
                assert(bytes:sub(1, 8) == string.char(137, 80, 78, 71, 13, 10, 26, 10), "Invalid banner PNG")
                writefile(file, bytes)
            end
            return register(file)
        end)
        if ok then bannerAsset = result
        else warn("[Yozakura] Banner image could not load: " .. tostring(result)) end
    else
        warn("[Yozakura] Generated banner needs getcustomasset/writefile or YozakuraBannerAsset.")
    end
end
local token = {}
env.YozakuraTitleOverride = token
local pink = Color3.fromRGB(255, 115, 180)
local function plain(s)
    return s:gsub("<[^>]*>", ""):lower():match("^%s*(.-)%s*$")
end
local function isTitle(o)
    if not (o:IsA("TextLabel") or o:IsA("TextButton")) then return false end
    local t = plain(o.Text)
    return t == "solo hub" or t == "yozakura"
end
local function hasCJK(s)
    local ok, found = pcall(function()
        for _, cp in utf8.codes(s) do
            if cp >= 0x3400 and cp <= 0x9FFF then return true end
        end
        return false
    end)
    return ok and found
end
local function tint(c)
    local _, s, v = c:ToHSV()
    if s > 0.12 then return Color3.fromHSV(0.92, math.min(s, 0.65), v) end
    if v < 0.45 then return Color3.fromHSV(0.92, 0.3, v) end
    return c
end
local function make(class, parent, props)
    local o = Instance.new(class)
    for k, v in pairs(props) do o[k] = v end
    o.Parent = parent
    return o
end
-- Native UI illustration needs no external image download or executor filesystem.
local function sakura(image)
    if image:FindFirstChild("YozakuraArtwork") then return end
    local art = make("Frame", image, {
        Name = "YozakuraArtwork", Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Color3.fromRGB(31, 12, 30), BorderSizePixel = 0,
        ClipsDescendants = true, ZIndex = image.ZIndex + 1, Active = false,
    })
    if type(bannerAsset) == "string" and bannerAsset ~= "" then
        make("ImageLabel", art, {
            Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1,
            Image = bannerAsset, ScaleType = Enum.ScaleType.Crop,
            ZIndex = art.ZIndex + 1,
        })
        return
    end
    make("UIGradient", art, {
        Color = ColorSequence.new(Color3.fromRGB(29, 12, 33), Color3.fromRGB(105, 31, 65)),
        Rotation = 70,
    })
    local function dot(x, y, w, color)
        local d = make("Frame", art, {
            AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(x, y),
            Size = UDim2.fromScale(w, w * 3), BackgroundColor3 = color,
            BorderSizePixel = 0, ZIndex = art.ZIndex + 1,
        })
        make("UICorner", d, {CornerRadius = UDim.new(1, 0)})
    end
    dot(0.14, 0.28, 0.105, Color3.fromRGB(255, 211, 229))
    local function branch(x, y, length, angle, width, depth)
        local dx, dy = math.cos(angle) * length, math.sin(angle) * length
        make("Frame", art, {
            AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.fromScale(x, y),
            Size = UDim2.fromScale(length, width), Rotation = math.deg(angle),
            BackgroundColor3 = Color3.fromRGB(67, 26, 47), BorderSizePixel = 0,
            ZIndex = art.ZIndex + 2,
        })
        if depth > 0 then
            branch(x + dx, y + dy, length * 0.66, angle - 0.55, width * 0.6, depth - 1)
            branch(x + dx, y + dy, length * 0.7, angle + 0.6, width * 0.6, depth - 1)
        else
            for i = 1, 7 do
                local a = i * math.pi * 2 / 7
                dot(x + dx + math.cos(a) * 0.035, y + dy + math.sin(a) * 0.09,
                    0.018, i % 2 == 0 and pink or Color3.fromRGB(255, 183, 214))
            end
        end
    end
    branch(0.90, 1.0, 0.28, -1.9, 0.055, 3)
    branch(0.99, 0.15, 0.23, -2.9, 0.025, 3)
    make("TextLabel", art, {
        Position = UDim2.fromScale(0.06, 0.4), Size = UDim2.fromScale(0.66, 0.27),
        BackgroundTransparency = 1, Text = "YOZAKURA", TextScaled = true,
        Font = Enum.Font.GothamBold, TextColor3 = Color3.fromRGB(255, 227, 240),
        ZIndex = art.ZIndex + 4,
    })
    make("TextLabel", art, {
        Position = UDim2.fromScale(0.08, 0.7), Size = UDim2.fromScale(0.6, 0.1),
        BackgroundTransparency = 1, Text = "S A K U R A   E D I T I O N",
        TextScaled = true, Font = Enum.Font.Gotham, TextColor3 = pink,
        ZIndex = art.ZIndex + 4,
    })
end

-- Keep navigation accents pink when the protected UI updates hover/selection colors.
if type(env.YozakuraNavCleanup) == "function" then pcall(env.YozakuraNavCleanup) end
local navConnections = {}
local navSeen = setmetatable({}, {__mode = "k"})
local navRows = setmetatable({}, {__mode = "k"})
local navActive = true
env.YozakuraNavCleanup = function()
    navActive = false
    for _, connection in ipairs(navConnections) do connection:Disconnect() end
    table.clear(navConnections)
end
local navNames = {
    home = true, kaitun = true, autofarm = true, missions = true,
    raids = true, pacing = true, safety = true, combat = true,
    visuals = true, settings = true, premium = true, configs = true,
}
local function navColor(color)
    local h, s, v = color:ToHSV()
    -- Warm gold colors are supplied by the original theme on every interaction.
    if h >= 0.065 and h <= 0.20 and s > 0.08 then
        return Color3.fromHSV(0.93, math.max(s, 0.45), math.min(v, 0.68))
    end
    return color
end
local function watchNavObject(object)
    if navSeen[object] then return end
    navSeen[object] = true
    local properties = {}
    if object:IsA("GuiObject") then
        table.insert(properties, "BackgroundColor3")
        table.insert(properties, "BorderColor3")
    end
    if object:IsA("TextLabel") or object:IsA("TextButton") then
        table.insert(properties, "TextColor3")
    end
    if object:IsA("ImageLabel") or object:IsA("ImageButton") then
        table.insert(properties, "ImageColor3")
    end
    if object:IsA("UIStroke") then table.insert(properties, "Color") end
    if object:IsA("UIGradient") then table.insert(properties, "Color") end
    for _, property in ipairs(properties) do
        local busy = false
        local function refresh()
            if busy or not navActive then return end
            busy = true
            pcall(function()
                local old = object[property]
                if object:IsA("UIGradient") then
                    local points, changed = {}, false
                    for _, point in ipairs(old.Keypoints) do
                        local color = navColor(point.Value)
                        if color ~= point.Value then changed = true end
                        table.insert(points, ColorSequenceKeypoint.new(point.Time, color))
                    end
                    if changed then object[property] = ColorSequence.new(points) end
                else
                    local color = navColor(old)
                    if color ~= old then object[property] = color end
                end
            end)
            busy = false
        end
        table.insert(navConnections, object:GetPropertyChangedSignal(property):Connect(refresh))
        refresh()
    end
end
local function bindNavigation(window, title)
    for _, label in ipairs(window:GetDescendants()) do
        if (label:IsA("TextLabel") or label:IsA("TextButton"))
            and navNames[plain(label.Text)]
            and label.AbsolutePosition.X < title.AbsolutePosition.X + 110 then
            local row = label:IsA("TextButton") and label or label.Parent
            while row and row ~= window do
                if row:IsA("GuiObject") and row.AbsoluteSize.X >= 100
                    and row.AbsoluteSize.X <= 250 and row.AbsoluteSize.Y <= 48 then
                    if not navRows[row] then
                        navRows[row] = true
                        watchNavObject(row)
                        for _, child in ipairs(row:GetDescendants()) do watchNavObject(child) end
                        table.insert(navConnections, row.DescendantAdded:Connect(watchNavObject))
                    end
                    break
                end
                row = row.Parent
            end
        end
    end
end

local windows = setmetatable({}, {__mode = "k"})
local function style(window, title)
    bindNavigation(window, title)
    -- Locate the home hero by its actual labels, rather than guessing the image size.
    for _, label in ipairs(window:GetDescendants()) do
        if label:IsA("TextLabel") and not label:FindFirstAncestor("YozakuraArtwork") then
            local t = plain(label.Text)
            if t == "attack titan" or t == "attack on titan"
                or label.Text:find("進撃の巨人", 1, true) then
                local hero = label.Parent
                while hero and hero ~= window do
                    if hero:IsA("GuiObject") and hero.AbsoluteSize.X >= 220
                        and hero.AbsoluteSize.Y >= 65 and hero.AbsoluteSize.Y <= 200
                        and hero.AbsoluteSize.X / hero.AbsoluteSize.Y >= 2 then
                        if not hero:FindFirstChild("YozakuraArtwork") then
                            for _, child in ipairs(hero:GetDescendants()) do
                                if child:IsA("GuiObject") then child.Visible = false end
                            end
                            sakura(hero)
                        end
                        break
                    end
                    hero = hero.Parent
                end
            end
        end
    end
    for _, o in ipairs(window:GetDescendants()) do
        if o.Name ~= "YozakuraArtwork" and not o:FindFirstAncestor("YozakuraArtwork") then
            pcall(function()
                if o:IsA("GuiObject") then o.BackgroundColor3 = tint(o.BackgroundColor3) end
                if o:IsA("UIStroke") then o.Color = tint(o.Color) end
                if o:IsA("TextLabel") or o:IsA("TextButton") or o:IsA("TextBox") then
                    o.TextColor3 = tint(o.TextColor3)
                    -- Remove only the small FREE / AOTR subtitle beneath the brand.
                    local text = plain(o.Text)
                    local dy = o.AbsolutePosition.Y - title.AbsolutePosition.Y
                    local dx = o.AbsolutePosition.X - title.AbsolutePosition.X
                    if o:IsA("TextLabel") and dy > 0 and dy <= 55
                        and dx >= -10 and dx <= 150
                        and (text == "free" or text == "aotr"
                            or (text:find("free", 1, true) and text:find("aotr", 1, true))) then
                        o.Visible = false
                    end
                    if isTitle(o) then o.Text = "Yozakura"; o.TextColor3 = pink end
                    -- Limit Chinese-text removal to noninteractive labels beside the title.
                    if o:IsA("TextLabel") and hasCJK(o.Text)
                        and math.abs(o.AbsolutePosition.Y - title.AbsolutePosition.Y) <= 40 then
                        o.Text = ""
                    end
                end
                -- The S emblem sits immediately left of the Yozakura heading.
                if (o:IsA("ImageLabel") or o:IsA("ImageButton"))
                    and o.AbsoluteSize.X <= 64 and o.AbsoluteSize.Y <= 64
                    and o.AbsolutePosition.X < title.AbsolutePosition.X
                    and title.AbsolutePosition.X - o.AbsolutePosition.X <= 70
                    and math.abs(o.AbsolutePosition.Y - title.AbsolutePosition.Y) <= 32 then
                    o.Visible = false
                end
                if o:IsA("ScrollingFrame") then o.ScrollBarImageColor3 = pink end
                if o:IsA("UIGradient") then
                    local points = {}
                    for _, p in ipairs(o.Color.Keypoints) do
                        table.insert(points, ColorSequenceKeypoint.new(p.Time, tint(p.Value)))
                    end
                    o.Color = ColorSequence.new(points)
                end
                -- Best-effort banner detection; small icons and image buttons are excluded.
                if o:IsA("ImageLabel") and o.Image ~= "" and o.Visible
                    and o.AbsoluteSize.X >= 220 and o.AbsoluteSize.Y >= 90
                    and o.AbsoluteSize.X / o.AbsoluteSize.Y >= 1.7
                    and o.AbsolutePosition.Y >= title.AbsolutePosition.Y - 40
                    and o.AbsolutePosition.Y <= title.AbsolutePosition.Y + 220 then
                    sakura(o)
                end
            end)
        end
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
            pcall(function() local r = gethui(); if r then roots[r] = true end end)
        end
        for root in pairs(roots) do
            pcall(function()
                for _, o in ipairs(root:GetDescendants()) do
                    if isTitle(o) then
                        local window = o
                        while window.Parent and window.Parent ~= root
                            and not window.Parent:IsA("ScreenGui") do
                            window = window.Parent
                        end
                        if window:IsA("GuiObject") and window ~= o then windows[window] = o end
                    end
                end
            end)
        end
        for window, title in pairs(windows) do
            if window.Parent and title.Parent then pcall(style, window, title)
            else windows[window] = nil end
        end
        task.wait(1)
    until env.YozakuraTitleOverride ~= token or os.clock() >= deadline
    if env.YozakuraTitleOverride == token then env.YozakuraTitleOverride = nil end
end)
return chunk()
