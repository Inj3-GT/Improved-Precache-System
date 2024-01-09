--- Script By Inj3
--- https://steamcommunity.com/id/Inj3/
--- https://github.com/Inj3-GT

local ipr_sh_config = file.Find("ipr_caching_configuration/*", "LUA")
local ipr_sh = file.Find("ipr_caching_lua/*", "LUA")
ipr_cache = {} 

if (CLIENT) then
    for _, f in pairs(ipr_sh_config) do
        include("ipr_caching_configuration/" ..f)
    end

    for _, f in pairs(ipr_sh) do
        include("ipr_caching_lua/" ..f)
    end
else
    for _, f in pairs(ipr_sh_config) do
        include("ipr_caching_configuration/" ..f)
        AddCSLuaFile("ipr_caching_configuration/" ..f)
    end

    for _, f in pairs(ipr_sh) do
        include("ipr_caching_lua/" ..f)
        AddCSLuaFile("ipr_caching_lua/" ..f)
    end
end