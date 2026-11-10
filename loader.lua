-- Freenium loader, copied unchanged from resellz705-cyber/Freenium.
-- Original Yozakura entry point: loader_before_freenium.lua
-- Obfuscated third-party code; runtime behavior has not been verified.
assert(type(loadstring) == "function", "This environment does not provide loadstring")
local source = game:HttpGet("https://raw.githubusercontent.com/koviescobar77-design/Yozakura/b39a00b7608b677aba716982775b27adad4647a5/FreeniumLoader.lua")
assert(type(source) == "string" and #source > 0, "Freenium download was empty")
local chunk, err = loadstring(source, "@Yozakura/FreeniumLoader.lua")
assert(chunk, err)
return chunk()
