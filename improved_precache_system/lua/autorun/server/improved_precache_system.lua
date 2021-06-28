--- Script By Inj3
--- Script By Inj3
--- Script By Inj3
--- https://steamcommunity.com/id/Inj3/

local Improved_Caching_Sys =  0.5 ---- Indiquer ici le délai entre chaque mise en cache (peut causer quelques freezes lors de la mise en cache). / Include here the delay between each caching (may cause some freezes during the pre-caching phase)
local Improved_Blacklist_Sys = { --- Indiquer ici les véhicules à ne pas inclure en cache. / Include here the vehicles not to be included in the cache.
     ["Yacht_2"] = true, --- Ne pas inclure dans le cache si celui-ci n'apparaît jamais sur le serveur. / Do not include in the cache if it never appears on the server.
     ["airtugtdm"] = true,
}
local Improved_Custom_Model_Sys = { --- Indiquer ici les models important à inclure dans le cache. / Models to include in the cache.
     ---"models/bkeypads/keypad_3.0.0.mdl",
     ---"models/bkeypads/keycard.mdl",
     ---"models/bkeypads/c_keycard.mdl",
}
local Improved_Custom_Sound_Sys = { --- Indiquer ici les sons important à inclure dans le cache. / Sounds to include in the cache.
     ---"bKeypads.ScanningPing",
}

--- Configuration is finished from here.
--- Do not touch anything below.
------
local Improved_Caching_Load, Impr_Count_Delay, Impr_Count_Ent = false, 0, nil
local function Improved_CountTable(tbl)
     local Impr_Number = 0
     for _ in pairs(tbl) do
          Impr_Number  = Impr_Number + 1
     end

     return Impr_Number
end

local function Improved_Precaching_S_Next()
     Impr_Count_Ent, Impr_Count_Delay = Improved_CountTable(Improved_Custom_Sound_Sys), 0
     if (Impr_Count_Ent <= 0) then
          print("Improved Caching System by Inj3 finished working !")
          return
     elseif (Impr_Count_Ent >= 16384) then
          print("We have detected a problem, you have too many sounds to include in the cache, we stop here otherwise the server will crash.")
          return
     end
     print("--------------- \nCaching of custom sounds.")

     for count, val in ipairs(Improved_Custom_Sound_Sys) do
          Impr_Count_Delay  = (Impr_Count_Delay or 0) + Improved_Caching_Sys

          timer.Simple(Impr_Count_Delay, function()
          util.PrecacheSound(val)

          print(val, "Caching : " ..count.. "/" ..Impr_Count_Ent)

          if (count >= Impr_Count_Ent) then
               print("All sounds were cached. \nImproved Caching System by Inj3 finished working !")
          end
          end)
     end

     print("Sounds detected : " ..Impr_Count_Ent.. "\nEstimated time : " ..math.Round(Impr_Count_Ent * Improved_Caching_Sys, 1).. " secs")
end

local function Improved_Precaching_C_Next()
     Impr_Count_Ent, Impr_Count_Delay = Improved_CountTable(Improved_Custom_Model_Sys), 0
     if (Impr_Count_Ent <= 0) then
          Improved_Precaching_S_Next()
          return
     end
     print("--------------- \nCaching of custom models.")

     for count, val in ipairs(Improved_Custom_Model_Sys) do
          Impr_Count_Delay  = (Impr_Count_Delay or 0) + Improved_Caching_Sys

          timer.Simple(Impr_Count_Delay, function()
          util.PrecacheModel(val)

          print(val, "Caching : " ..count.. "/" ..Impr_Count_Ent)

          if (count >= Impr_Count_Ent) then
               print("All custom models have been cached.")
               Improved_Precaching_S_Next()
          end
          end)
     end

     print("Models detected : " ..Impr_Count_Ent.. "\nEstimated time : " ..math.Round(Impr_Count_Ent * Improved_Caching_Sys, 1).. " secs")
end

local function Improved_Precaching_Func()
     if not Improved_Caching_Load then
          local Impr_List_Veh, Impr_CountPrecache = list.Get("Vehicles"), 0
          Impr_Count_Ent = Improved_CountTable(Impr_List_Veh)
          print("---------------")

          for class, tbl in pairs(Impr_List_Veh) do
               if Improved_Blacklist_Sys[class] then
                    Impr_Count_Ent = Impr_Count_Ent - 1
                    continue
               end
               Impr_Count_Delay  = (Impr_Count_Delay or 0) + Improved_Caching_Sys

               timer.Simple(Impr_Count_Delay, function()
               Impr_CountPrecache  = (Impr_CountPrecache or 0) + 1
               util.PrecacheModel(tbl.Model)

               print(tbl.Model, "Caching : " ..Impr_CountPrecache.. "/" ..Impr_Count_Ent)

               if (Impr_CountPrecache >= Impr_Count_Ent) then
                    print("All vehicles were cached.")
                    Improved_Precaching_C_Next()
               end
               end)
          end
          print("Vehicles detected : " ..Impr_Count_Ent.. "\nEstimated time : " ..math.Round(Impr_Count_Ent * Improved_Caching_Sys, 1).. " secs")

          Improved_Caching_Load = true
     end
end

hook.Add("InitPostEntity", "Impr_PreCacheModel_Init", function()
if (Improved_CountTable(list.Get("Vehicles")) + Improved_CountTable(Improved_Custom_Model_Sys) > 4096) then
     print("We have detected a problem, you have too many models to include in the cache, we stop here otherwise the server will crash.")
     Improved_Precaching_S_Next()
     return
end
Improved_Precaching_Func()
end)
