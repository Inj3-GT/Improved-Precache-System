--- Script By Inj3
--- https://steamcommunity.com/id/Inj3/
--- https://github.com/Inj3-GT

local ipr_sh_config = file.Find("configuration/*", "LUA")
local ipr_sh = file.Find("ipr_caching_sh/*", "LUA")
ipr_cache = {} 

if (CLIENT) then
    for _, f in pairs(ipr_sh_config) do
        include("configuration/" ..f)
    end

    for _, f in pairs(ipr_sh) do
        include("ipr_caching_sh/" ..f)
    end
else
    for _, f in pairs(ipr_sh_config) do
        include("configuration/" ..f)
        AddCSLuaFile("configuration/" ..f)
    end

    for _, f in pairs(ipr_sh) do
        include("ipr_caching_sh/" ..f)
        AddCSLuaFile("ipr_caching_sh/" ..f)
    end
end