--- Script By Inj3
--- https://steamcommunity.com/id/Inj3/
--- https://github.com/Inj3-GT
--- Version 2.2
local ipr_cache = {} --- Do not touch !

---------------------------------- // Configuration 
ipr_cache.delay = 0.3 --- Délai entre chaque mise en cache. / Delay between caching.

if (SERVER) then
    ipr_cache.enable_serverside = true --- Activer la mise en cache côté server / Enable server-side caching.
    ipr_cache.enable_clientside = true --- Activer la mise en cache côté client / Enable client-side caching.
else
    ipr_cache.progressbar = true --- Informations visible sur le hud (barre de progression, pourcentage) / Visible information on the hud (progress bar, percentage)
    ipr_cache.progressbar_w = "centre" --- Largeur (gauche, droite, centre) / Width (gauche = left, droite = right, centre = center)
    ipr_cache.progressbar_h = "bas" --- Hauteur (haut, bas, centre) / Height (haut = top, bas = bottom, centre = center)
end

ipr_cache.blacklist = { --- Indiquer ici les véhicules à ne pas inclure en cache. / Include here the vehicles not to be included in the cache.
    ["Yacht_2"] = true, --- Exemple / Example - Ne pas inclure dans le cache si celui-ci n'apparaît jamais sur le serveur. / Do not include in the cache if it never appears on the server.
    ["airtugtdm"] = true,
}
ipr_cache.modelsys = { --- Indiquer ici vos models customs à ajouter dans le cache. / Enter your custom models to be added to the cache here.
    --"models/bkeypads/keypad_3.0.0.mdl", --- Exemple / Example
    --"models/bkeypads/keycard.mdl",
}
ipr_cache.customsound = { --- Indiquer ici vos sons customs à ajouter dans le cache. / Enter your custom sounds to be added to the cache here.
    --"bKeypads.ScanningPing", --- Exemple / Example
}
---------------------------------- //

--- Do not touch anything below.
local ipr_gcache = {}
ipr_gcache.delay, ipr_gcache.modelmax = 0, 0

if (CLIENT) then
    ipr_gcache.count, ipr_gcache.modelprogress, ipr_gcache.loadcaching = 0, "", false
end

local function Ipr_CacheModel()
    local ipr_caching = {}
    ipr_caching.vehicle = {}

    for c, d in pairs(list.Get("Vehicles")) do
        if ipr_cache.blacklist[c] then
            continue
        end
        ipr_caching.vehicle[#ipr_caching.vehicle + 1] = d.Model
    end
    ipr_caching.custom_model = ipr_cache.modelsys
    ipr_caching.sound = ipr_cache.customsound

    local ipr_c_custom_model, ipr_c_sound, ipr_c_vehicle = #ipr_caching.custom_model, #ipr_caching.sound, #ipr_caching.vehicle
    ipr_gcache.modelmax = ipr_c_custom_model + ipr_c_sound + ipr_c_vehicle
    if (ipr_gcache.modelmax == 0) then
        return
    end

    if (CLIENT) then
        ipr_gcache.cx, ipr_gcache.ct, ipr_gcache.loadcaching = (ipr_c_custom_model > 0) and (ipr_c_sound > 0) and 3 or ((ipr_c_custom_model > 0) or (ipr_c_sound > 0)) and 2 or 1, 0, true
    end

    for t, m in pairs(ipr_caching) do
        if not m then
            continue
        end

        for n, v in ipairs(m) do
            ipr_gcache.delay = ipr_gcache.delay + ipr_cache.delay

            timer.Simple(ipr_gcache.delay, function()
                print("Model caching : " ..v)

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
    local ipr_cacheprevent = false

    hook.Add("InitPostEntity", "Ipr_CachingInit", function()
        if not ipr_cache.enable_serverside then
            return
        end

        if not ipr_cacheprevent then
            Ipr_CacheModel()
            ipr_cacheprevent = true
        end
    end)

    hook.Add("PlayerInitialSpawn", "Ipr_CachingSpawn", function(ply)
        if not ipr_cache.enable_clientside then
            return
        end

        timer.Simple(5, function()
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
