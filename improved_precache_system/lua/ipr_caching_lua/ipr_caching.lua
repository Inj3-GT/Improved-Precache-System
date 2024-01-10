--- Script By Inj3
--- https://steamcommunity.com/id/Inj3/
--- https://github.com/Inj3-GT

local ipr_gcache = {}
ipr_gcache.modelmax = 0

if (CLIENT) then
    ipr_gcache.count = 0
    ipr_gcache.modelprogress = ""
    ipr_gcache.loadcaching = false
end

local function Ipr_CacheModel()
    ipr_gcache.list = {}
    ipr_gcache.list.vehicle = {}

    for c, d in pairs(list.Get("Vehicles")) do
        if ipr_cache.blacklist[c] then
           continue
        end
        
        ipr_gcache.list.vehicle[#ipr_gcache.list.vehicle + 1] = d.Model
    end

    ipr_gcache.list.custom_model = ipr_cache.modelsys
    ipr_gcache.list.sound = ipr_cache.customsound

    for _, v in pairs(ipr_gcache.list) do
        if not v then
           continue
        end
        local ipr_c = #v
        if (ipr_c <= 0) then
           continue
        end
        
        ipr_gcache.cx = (ipr_gcache.cx or 0) + 1
        ipr_gcache.modelmax = ipr_c + ipr_gcache.modelmax
    end
    if (ipr_gcache.cx == 0) then
        return
    end

    if (CLIENT) then
        ipr_gcache.ct = 0
        ipr_gcache.loadcaching = true
    end
    
    for t, m in pairs(ipr_gcache.list) do
        if not m then
           continue
        end

        for n, v in ipairs(m) do
            ipr_gcache.delay = (ipr_gcache.delay or 0) + ipr_cache.delay

            timer.Simple(ipr_gcache.delay, function()
                print(((SERVER) and "Server" or "Client") .." Model caching : " ..v)

                if (t ~= "sound") then util.PrecacheModel(v) else util.PrecacheSound(v) end

                if (n == #m) then
                    print("Caching completed : " ..t.. "\n")

                    if (SERVER) then
                        return
                    end
                    ipr_gcache.ct = ipr_gcache.ct + 1

                    if (ipr_gcache.cx == ipr_gcache.ct) then
                        timer.Simple(0.5, function()
                            ipr_gcache.loadcaching = false
                        end)
                    end
                end

                if (SERVER) then
                    return
                end
                ipr_gcache.count, ipr_gcache.modelprogress = ipr_gcache.count + 1, tostring(v)
            end)
        end
    end

    print("Number of models to cache : " ..ipr_gcache.modelmax.. "\nEstimated time : " ..math.Round(ipr_gcache.modelmax * ipr_cache.delay, 1).. " secs\n----")
end

if (SERVER) then
    util.AddNetworkString("ipr_net_cachesys")

    hook.Add("InitPostEntity", "Ipr_CachingInit", function()
        if not ipr_cache.enable_serverside then
            return
        end

        Ipr_CacheModel()
    end)

    hook.Add("PlayerInitialSpawn", "Ipr_CachingSpawn", function(ply)
        if not ipr_cache.enable_clientside then
            return
        end

        timer.Simple(10, function()
            if not IsValid(ply) then
                return
            end

            net.Start("ipr_net_cachesys")
            net.Send(ply)
        end)
    end)

    print("Improved Caching System by Inj3")
else
    net.Receive("ipr_net_cachesys", function()
        Ipr_CacheModel()
    end)

    local function Ipr_Pos(t, w, h)
        return (t == "w") and ((ipr_cache.progressbar_w == "centre") and w / 2 or (ipr_cache.progressbar_w == "gauche") and 115 or (ipr_cache.progressbar_w == "droite") and w - 100) or (ipr_cache.progressbar_h == "centre") and h / 2 or (ipr_cache.progressbar_h == "haut") and 25 or (ipr_cache.progressbar_h == "bas") and h - 50
    end

    local ipr_w, ipr_h = ScrW(), ScrH()
    hook.Add("OnScreenSizeChanged", "ipr_CachingChangeResolution", function()
        ipr_w, ipr_h = ScrW(), ScrH()
    end)

    local ipr_bluebox = Color(77, 97, 185)
    hook.Add("HUDPaint", "Ipr_CachingHud", function()
        if not ipr_gcache.loadcaching or not ipr_cache.progressbar then
            return
        end
        local ipr_loading_box = ipr_gcache.count / ipr_gcache.modelmax
        local ipr_loading_box_clamp = math.Round(math.Clamp(ipr_loading_box * 100, 0, 100))

        draw.RoundedBox(1, Ipr_Pos("w", ipr_w) - 50, Ipr_Pos("h", nil, ipr_h) + 13, 100, 10, color_white)
        draw.RoundedBox(1, Ipr_Pos("w", ipr_w) - 50, Ipr_Pos("h", nil, ipr_h) + 13, ipr_loading_box_clamp, 10, ipr_bluebox)

        draw.SimpleText("Caching in progress : " ..ipr_gcache.count.. "/" ..ipr_gcache.modelmax, "DermaDefault", Ipr_Pos("w", ipr_w), Ipr_Pos("h", nil, ipr_h), color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText(ipr_loading_box_clamp.. "% - "..ipr_gcache.modelprogress, "DermaDefault", Ipr_Pos("w", ipr_w), Ipr_Pos("h", nil, ipr_h) + 35, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end)
end
