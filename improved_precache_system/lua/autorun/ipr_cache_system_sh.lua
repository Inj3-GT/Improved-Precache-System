--- Script By Inj3
--- Script By Inj3
--- Script By Inj3
local ipr_cache = {} --- Do not touch !
--- https://steamcommunity.com/id/Inj3/
--- Version 2.0

----- // Configuration 
ipr_cache.delay = 0.3 --- Délai entre chaque mise en cache. / Delay between caching.
ipr_cache.enable_clientside = true --- Activer la mise en cache côté client / Enable client-side caching.

if (SERVER) then
    ipr_cache.enable_serverside = true --- Activer la mise en cache côté server / Enable server-side caching.
else
    ipr_cache.progressbar = true --- Informations visible sur le hud (barre de progression, pourcentage) / Visible information on the hud (progress bar, percentage)
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
----- //

--- Do not touch anything below.
---
local ipr_count, ipr_delay, ipr_modelmax, ipr_modelprogress, ipr_load_caching = 0, 0, 0, ""

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
     ipr_modelmax = ipr_c_custom_model + ipr_c_sound + ipr_c_vehicle

     if (ipr_modelmax == 0) then
         return
     end
     local ipr_valid = (ipr_c_custom_model > 0) and (ipr_c_sound > 0) and 3 or ((ipr_c_custom_model > 0) or (ipr_c_sound > 0)) and 2 or 1
     ipr_load_caching = true
 
     local ipr_cp = 0
     for t, m in pairs(ipr_caching) do
         if not m then
             continue
         end
 
         for n, v in ipairs(m) do
             ipr_delay = ipr_delay + ipr_cache.delay
 
             timer.Simple(ipr_delay, function()
                 ipr_modelprogress = tostring(v)
                 if (t == "sound") then util.PrecacheSound(v) else util.PrecacheModel(v) end
                 print("Model caching : " ..v)
 
                 if (n == #m) then
                     ipr_cp = ipr_cp + 1
                     print("Caching completed : " ..t.. "\n")
 
                     if not CLIENT then
                         return
                     end
                     if (ipr_valid == ipr_cp) then
 
                         timer.Simple(0.5, function()
                             ipr_load_caching = false
                         end)
 
                     end
                 end
                 ipr_count = ipr_count + 1
             end)
         end
     end
 
     print("Number of models to cache : " ..ipr_modelmax.. "\nEstimated time : " ..math.Round(ipr_modelmax * ipr_cache.delay, 1).. " secs\n----")
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
    if not ipr_cache.enable_clientside then
        return
    end

    net.Receive("ipr_net_cachesys", function()
        Ipr_CacheModel()
    end)

    local ipr_blue_box = Color(0,69,175)
    hook.Add("HUDPaint", "Ipr_CachingHud", function()
        if not ipr_load_caching or not ipr_cache.progressbar then
            return
        end
        local ipr_loading_box = ipr_count / ipr_modelmax
        local ipr_loading_box_clamp = math.Round(math.Clamp(ipr_loading_box * 100, 0, 100))
        local ipr_w, ipr_h = ScrW(), ScrH()

        draw.RoundedBox(1, ipr_w / 2 - 50, ipr_h / 2 + 13, 100, 10, color_white)
        draw.RoundedBox(1, ipr_w / 2 - 50, ipr_h / 2 + 13, ipr_loading_box_clamp, 10, ipr_blue_box)

        draw.SimpleText("Caching in progress : " ..ipr_count.. "/" ..ipr_modelmax, "DermaDefault", ipr_w / 2, ipr_h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText(ipr_loading_box_clamp.. "% - "..ipr_modelprogress, "DermaDefault", ipr_w / 2, ipr_h / 2 + 35, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end)
end 
