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
     ---"models/bkeypads/keypad_3.0.0.mdl", -- Exemple / Example
     ---"models/bkeypads/keycard.mdl",
     ---"models/bkeypads/c_keycard.mdl",
}
local Improved_Custom_Sound_Sys = { --- Indiquer ici les sons important à inclure dans le cache. / Sounds to include in the cache.
     ---"bKeypads.ScanningPing", -- Exemple / Example
}

--- Configuration is finished from here.
--- Do not touch anything below.
------
local Impr_Count_Ent, Impr_Count_Delay = nil, 0
local list = list

local function Improved_CountTable(tbl)
     local Impr_Count_ = 0
	 
     for _ in pairs(tbl) do
          Impr_Count_  = Impr_Count_ + 1
     end	 
     return Impr_Count_
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
          Impr_Count_Delay  = Impr_Count_Delay + Improved_Caching_Sys

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
          Impr_Count_Delay  = Impr_Count_Delay + Improved_Caching_Sys

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

local function Improved_Precaching_Func(list)
     Impr_Count_Ent = Improved_CountTable(list)
     if (Impr_Count_Ent <= 0) then
          Improved_Precaching_C_Next()
          return
     end
     print("---------------")

     local Impr_CountPrecache = 0
     for class, tbl in pairs(list) do
          if Improved_Blacklist_Sys[class] then
               Impr_Count_Ent = Impr_Count_Ent - 1
               continue
          end
          Impr_Count_Delay  = Impr_Count_Delay + Improved_Caching_Sys

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
end

local Improved_Caching_Load
hook.Add("InitPostEntity", "Impr_PreCacheModel_Init", function()
if not Improved_Caching_Load then
     local Impr_List_Veh = list.Get("Vehicles")

     if (Improved_CountTable(Impr_List_Veh) + Improved_CountTable(Improved_Custom_Model_Sys) > 4096) then
          print("We have detected a problem, you have too many models to include in the cache, we stop it now for prevent crash and move on to the next step.")
          Improved_Precaching_S_Next()
          return
     end

     Improved_Precaching_Func(Impr_List_Veh)
     Improved_Caching_Load = true
end
end)