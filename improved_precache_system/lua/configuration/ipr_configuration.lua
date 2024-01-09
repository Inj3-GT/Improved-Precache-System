--- Script By Inj3
--- https://steamcommunity.com/id/Inj3/
--- https://github.com/Inj3-GT

ipr_cache.delay = 0.3 --- Délai entre chaque mise en cache. / Delay between caching.

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

if (SERVER) then
    ipr_cache.enable_serverside = true --- Activer la mise en cache côté server / Enable server-side caching.
    
    ipr_cache.enable_clientside = true --- Activer la mise en cache côté client / Enable client-side caching.
else
    ipr_cache.progressbar = true --- Informations visible sur le hud (barre de progression, pourcentage) / Visible information on the hud (progress bar, percentage)
    
    ipr_cache.progressbar_w = "centre" --- Largeur (gauche, droite, centre) / Width (gauche = left, droite = right, centre = center)
    
    ipr_cache.progressbar_h = "bas" --- Hauteur (haut, bas, centre) / Height (haut = top, bas = bottom, centre = center)
end