-- test.lua
-- Fichier de test complet pour kt_target
-- Couvre : TargetHeader, TargetKeybind, TargetMenu, TargetOption,
--          Checkbox (canInteract), Input (distance), Toggle (groups/items), Slider (cooldown)
-- Placez ce fichier dans un resource externe ou dans client/admin/

local api = require 'client.api'

-- ─────────────────────────────────────────────────────────────────────────────
-- Helpers notify
-- ─────────────────────────────────────────────────────────────────────────────

local function notify(title, type_, desc, duration)
    duration = duration or 4000
    if lib and lib.notify then
        lib.notify({ title = title, type = type_, description = desc, duration = duration })
    else
        print(('[TEST] %s — %s'):format(title, desc or ''))
    end
end

-- ─────────────────────────────────────────────────────────────────────────────
-- État local pour simuler Checkbox / Toggle / Slider / Input
-- ─────────────────────────────────────────────────────────────────────────────

local state = {
    debugMode    = false,   -- Checkbox
    defaultsOn   = true,    -- Toggle
    toggleHotkey = false,   -- Toggle
    maxDistance  = 7.0,     -- Slider
    cooldownMs   = 2000,    -- Slider
    playerName   = '',      -- Input (simulé via NUI callback ou commande)
}

-- ─────────────────────────────────────────────────────────────────────────────
-- TEST 1 — TargetHeader + TargetKeybind
-- Tous les peds : affiche le header avec type/nom + keybind hint
-- ─────────────────────────────────────────────────────────────────────────────

api.addGlobalPed({
    {
        name  = 'test:ped:header_demo',
        icon  = 'fa-solid fa-user',
        label = 'Infos ped (TargetHeader demo)',
        onSelect = function(data)
            local entity  = data.entity
            local model   = GetEntityArchetypeName(entity)
            local coords  = GetEntityCoords(entity)
            local netId   = NetworkGetEntityIsNetworked(entity)
                            and NetworkGetNetworkIdFromEntity(entity) or 'local'
            -- Simule ce que TargetHeader affiche en haut du menu :
            --   entityType = "Ped"
            --   entityName = model
            notify('TargetHeader — Ped', 'info',
                ('Type: Ped\nNom: %s\nNetId: %s\nCoords: %.1f, %.1f, %.1f')
                    :format(model, tostring(netId), coords.x, coords.y, coords.z),
                6000)
        end,
    },
    {
        name  = 'test:ped:keybind_demo',
        icon  = 'fa-solid fa-keyboard',
        label = 'Hint keybind (TargetKeybind demo)',
        onSelect = function(data)
            -- Simule un TargetKeybind : keyLabel="ALT" + description
            notify('TargetKeybind', 'info',
                'keyLabel: ALT\ndescription: Afficher les interactions\n\nUtilisez TargetKeybind pour guider le joueur.',
                5000)
        end,
    },
})

-- ─────────────────────────────────────────────────────────────────────────────
-- TEST 2 — TargetMenu + sous-menu (openMenu / menuName)
-- Tous les objets : menu principal → sous-menu admin
-- ─────────────────────────────────────────────────────────────────────────────

api.addGlobalObject({
    -- Option principale visible de tous
    {
        name  = 'test:obj:info',
        icon  = 'fa-solid fa-cube',
        label = 'Infos objet',
        onSelect = function(data)
            local entity  = data.entity
            local model   = GetEntityArchetypeName(entity)
            local frozen  = IsEntityFrozen(entity)
            notify('TargetOption — Infos', 'info',
                ('Modèle: %s\nFrozen: %s\nDist: %.2f m')
                    :format(model, frozen and 'Oui' or 'Non', data.distance),
                5000)
        end,
    },

    -- Entrée dans le sous-menu (TargetMenu imbriqué)
    {
        name     = 'test:obj:submenu',
        icon     = 'fa-solid fa-bars',
        label    = 'Menu objet →',
        openMenu = 'test_obj_menu',
    },

        
    -- Options du sous-menu (menuName = 'test_obj_menu')
    {
        name     = 'test:obj:freeze',
        icon     = 'fa-solid fa-snowflake',
        label    = 'Geler / Dégeler',
        menuName = 'test_obj_menu',
        cooldown = 1500,
        onSelect = function(data)
            local entity    = data.entity
            local wasFrozen = IsEntityFrozen(entity)
            FreezeEntityPosition(entity, not wasFrozen)
            notify(
                not wasFrozen and 'Gelé' or 'Dégelé',
                not wasFrozen and 'warning' or 'success',
                not wasFrozen and 'L\'objet est maintenant gelé.' or 'L\'objet est libre.'
            )
        end,
    },
    {
        name     = 'test:obj:delete',
        icon     = 'fa-solid fa-trash',
        label    = 'Supprimer',
        menuName = 'test_obj_menu',
        cooldown = 500,
        onSelect = function(data)
            local entity = data.entity
            if NetworkGetEntityIsNetworked(entity) then
                local netId = NetworkGetNetworkIdFromEntity(entity)
                TriggerServerEvent('admin:object:delete', netId)
            else
                DeleteObject(entity)
            end
            notify('Supprimé', 'success', 'Objet supprimé.')
        end,
    },
    {
        name     = 'test:obj:copy_coords',
        icon     = 'fa-solid fa-location-crosshairs',
        label    = 'Copier coords',
        menuName = 'test_obj_menu',
        onSelect = function(data)
            local c = GetEntityCoords(data.entity)
            local h = GetEntityHeading(data.entity)
            local str = ('vector4(%.4f, %.4f, %.4f, %.2f)'):format(c.x, c.y, c.z, h)
            notify('Coords copiées', 'success', str, 6000)
        end,
    },
})

-- ─────────────────────────────────────────────────────────────────────────────
-- TEST 3 — TargetOption : distance, canInteract, cooldown, iconColor
-- Tous les véhicules
-- ─────────────────────────────────────────────────────────────────────────────

api.addGlobalVehicle({
    -- Cooldown long → teste la barre de cooldown React
    {
        name      = 'test:veh:repair',
        icon      = 'fa-solid fa-wrench',
        label     = 'Réparer (cooldown 5s)',
        distance  = 3.0,
        cooldown  = 5000,
        onSelect  = function(data)
            SetVehicleFixed(data.entity)
            SetVehicleDeformationFixed(data.entity)
            notify('Réparé', 'success', 'Véhicule réparé ! Cooldown 5s actif.', 3000)
        end,
    },

    -- canInteract = distance stricte (< 1.5 m)
    {
        name        = 'test:veh:plaque',
        icon        = 'fa-solid fa-id-card',
        label       = 'Lire plaque (< 1.5m)',
        distance    = 5.0,
        canInteract = function(entity, dist, coords)
            return dist < 1.5
        end,
        onSelect = function(data)
            local plate = GetVehicleNumberPlateText(data.entity)
            notify('Plaque', 'info', plate, 3000)
        end,
    },

    -- iconColor personnalisée (rouge)
    {
        name      = 'test:veh:blow',
        icon      = 'fa-solid fa-burst',
        label     = 'Exploser (iconColor)',
        iconColor = '#ff4444',
        distance  = 4.0,
        cooldown  = 8000,
        onSelect  = function(data)
            NetworkRegisterEntityAsNetworked(data.entity)
            AddExplosion(GetEntityCoords(data.entity), 7, 1.0, true, false, 1.0)
            notify('Boom', 'error', 'Explosion ! Cooldown 8s.', 3000)
        end,
    },

    -- Option sans cooldown, vérification véhicule moteur allumé
    {
        name        = 'test:veh:engine',
        icon        = 'fa-solid fa-bolt',
        label       = 'Couper / Allumer moteur',
        distance    = 2.5,
        canInteract = function(entity, dist)
            return GetPedInVehicleSeat(entity, -1) == PlayerPedId()
        end,
        onSelect = function(data)
            local veh = data.entity
            local on  = GetIsVehicleEngineRunning(veh)
            SetVehicleEngineOn(veh, not on, true, true)
            notify('Moteur', 'info', not on and 'Allumé' or 'Coupé', 2000)
        end,
    },
})

-- ─────────────────────────────────────────────────────────────────────────────
-- TEST 4 — Checkbox (canInteract toggle simulé)
-- Zone sphérique : deux options dont une conditionnée par state.debugMode
-- Commande pour basculer l'état (simule un Checkbox NUI)
-- ─────────────────────────────────────────────────────────────────────────────

local zoneId = api.addSphereZone({
    name   = 'test:zone:checkbox',
    coords = GetEntityCoords(PlayerPedId()),  -- zone autour du spawn
    radius = 1.5,
    debug  = true,
    options = {
        {
            name  = 'test:zone:hello',
            icon  = 'fa-solid fa-hand-wave',
            label = 'Dire bonjour (toujours visible)',
            onSelect = function()
                notify('Bonjour !', 'success', 'Option toujours visible dans la zone.', 2000)
            end,
        },
        {
            name        = 'test:zone:debug_opt',
            icon        = 'fa-solid fa-bug',
            label       = 'Option debug (Checkbox)',
            canInteract = function()
                return state.debugMode  -- visible seulement si debugMode coché
            end,
            onSelect = function()
                notify('Debug', 'warning', 'Cette option n\'apparaît que si debugMode = true.', 3000)
            end,
        },
    },
})

-- /testcheckbox — bascule state.debugMode (simule un Checkbox NUI)
RegisterCommand('testcheckbox', function()
    state.debugMode = not state.debugMode
    notify(
        'Checkbox simulée',
        state.debugMode and 'success' or 'warning',
        ('debugMode = %s\nL\'option debug dans la zone est maintenant %s.')
            :format(tostring(state.debugMode), state.debugMode and 'visible' or 'cachée'),
        4000
    )
end, false)

-- ─────────────────────────────────────────────────────────────────────────────
-- TEST 5 — Input (distance dynamique)
-- Commande pour modifier la distance d'une option globale ped
-- Simule le comportement d'un champ Input NUI qui modifierait une valeur
-- ─────────────────────────────────────────────────────────────────────────────

api.addGlobalPed({
    {
        name     = 'test:ped:distance_display',
        icon     = 'fa-solid fa-ruler',
        label    = 'Distance (Input test)',
        -- distance dynamique lue depuis state
        canInteract = function(entity, dist)
            return dist <= state.maxDistance
        end,
        onSelect = function(data)
            notify('Input — Distance',  'info',
                ('Distance actuelle max : %.1f m\nDist réelle : %.2f m\nChanger avec /testinput <valeur>')
                    :format(state.maxDistance, data.distance),
                5000)
        end,
    },
})

-- /testinput <valeur> — simule la saisie dans un Input NUI
RegisterCommand('testinput', function(src, args)
    local val = tonumber(args[1])
    if not val or val <= 0 or val > 50 then
        notify('Input invalide', 'error', 'Valeur entre 0.1 et 50.', 3000)
        return
    end
    state.maxDistance = val
    notify('Input — Distance mise à jour', 'success',
        ('maxDistance = %.1f m\nL\'option "Distance (Input test)" sur les peds\nn\'apparaît plus au-delà de cette portée.')
            :format(val),
        5000)
end, false)

-- ─────────────────────────────────────────────────────────────────────────────
-- TEST 6 — Toggle (groups/items simulés)
-- Simule deux toggles :
--   toggleHotkey → change le comportement du keybind (log seulement)
--   defaultsOn   → ajoute/retire une option globale véhicule
-- ─────────────────────────────────────────────────────────────────────────────

-- /testtoggle hotkey|defaults
RegisterCommand('testtoggle', function(src, args)
    local which = args[1]

    if which == 'hotkey' then
        state.toggleHotkey = not state.toggleHotkey
        notify('Toggle — Hotkey', 'info',
            ('toggleHotkey = %s\n(Simule Config.toggleHotkey dans shared/config.lua)')
                :format(tostring(state.toggleHotkey)),
            4000)

    elseif which == 'defaults' then
        state.defaultsOn = not state.defaultsOn
        if state.defaultsOn then
            api.addGlobalVehicle({
                {
                    name     = 'test:veh:toggle_added',
                    icon     = 'fa-solid fa-toggle-on',
                    label    = 'Option ajoutée par Toggle',
                    iconColor = '#75ffb7',
                    cooldown  = 1000,
                    onSelect  = function()
                        notify('Toggle ON', 'success', 'Cette option a été ajoutée dynamiquement.', 3000)
                    end,
                }
            })
            notify('Toggle — Defaults ON', 'success',
                'Option "toggle_added" ajoutée sur les véhicules.', 4000)
        else
            api.removeGlobalVehicle('test:veh:toggle_added')
            notify('Toggle — Defaults OFF', 'warning',
                'Option "toggle_added" retirée des véhicules.', 4000)
        end

    else
        notify('Usage', 'error', '/testtoggle hotkey   ou   /testtoggle defaults', 3000)
    end
end, false)

-- ─────────────────────────────────────────────────────────────────────────────
-- TEST 7 — Slider (cooldown dynamique)
-- /testslider <ms> — modifie le cooldown d'une option véhicule
-- ─────────────────────────────────────────────────────────────────────────────

-- Option dont le cooldown est lu depuis state.cooldownMs au moment du select
-- (En pratique le cooldown est fixé à l'enregistrement, on re-enregistre ici)
local function reregisterSliderOption()
    api.removeGlobalVehicle('test:veh:slider_cooldown')
    api.addGlobalVehicle({
        {
            name     = 'test:veh:slider_cooldown',
            icon     = 'fa-solid fa-hourglass-half',
            label    = ('Cooldown Slider (%d ms)'):format(state.cooldownMs),
            cooldown = state.cooldownMs,
            onSelect = function(data)
                notify('Slider — Cooldown', 'info',
                    ('Cooldown actuel : %d ms\nChanger avec /testslider <ms>')
                        :format(state.cooldownMs),
                    3000)
            end,
        }
    })
end

reregisterSliderOption()

-- /testslider <ms> — simule le drag du Slider NUI
RegisterCommand('testslider', function(src, args)
    local val = tonumber(args[1])
    if not val or val < 0 or val > 30000 then
        notify('Slider invalide', 'error', 'Valeur entre 0 et 30000 ms.', 3000)
        return
    end
    state.cooldownMs = math.floor(val)
    reregisterSliderOption()
    notify('Slider — Cooldown mis à jour', 'success',
        ('cooldownMs = %d ms\nL\'option "Cooldown Slider" sur les véhicules\nutilise maintenant ce cooldown.')
            :format(state.cooldownMs),
        5000)
end, false)

-- ─────────────────────────────────────────────────────────────────────────────
-- TEST 8 — TargetOption : groups (filtre job)
-- Visible uniquement si le joueur a le job 'police' (adaptateur ESX/Union)
-- ─────────────────────────────────────────────────────────────────────────────

api.addGlobalPed({
    {
        name   = 'test:ped:groups',
        icon   = 'fa-solid fa-shield-halved',
        label  = 'Fouiller (police only)',
        groups = { police = 0, sheriff = 0 },
        onSelect = function(data)
            notify('Fouille', 'success',
                ('Ped #%d fouillé. Groupe vérifié via utils.hasPlayerGotGroup.')
                    :format(data.entity),
                4000)
        end,
    },
    {
        name  = 'test:ped:items',
        icon  = 'fa-solid fa-syringe',
        label = 'Soigner (item: medikit)',
        items = 'medikit',
        onSelect = function(data)
            notify('Soin', 'success',
                'Item "medikit" détecté via utils.hasPlayerGotItem.',
                4000)
        end,
    },
})

-- ─────────────────────────────────────────────────────────────────────────────
-- TEST 9 — NoOptions : zone sans interaction valide
-- Zone volontairement vide pour tester le message "Aucune interaction"
-- ─────────────────────────────────────────────────────────────────────────────

api.addBoxZone({
    name     = 'test:zone:nooptions',
    coords   = GetEntityCoords(PlayerPedId()) + vector3(10.0, 0.0, 0.0),
    size     = vector3(3.0, 3.0, 2.0),
    rotation = 0,
    debug    = true,
    options  = {
        {
            name        = 'test:zone:invisible',
            icon        = 'fa-solid fa-eye-slash',
            label       = 'Option toujours cachée',
            canInteract = function() return false end,
            onSelect    = function() end,  -- ne sera jamais appelé
        },
    },
})

-- ─────────────────────────────────────────────────────────────────────────────
-- TEST 10 — addLocalEntity
-- Spawn un objet local et lui attache des options
-- ─────────────────────────────────────────────────────────────────────────────

RegisterCommand('testlocalentity', function()
    local ped    = PlayerPedId()
    local coords = GetEntityCoords(ped) + vector3(1.5, 0.0, 0.0)
    local hash   = joaat('prop_barrel_01a')

    RequestModel(hash)
    local t = GetGameTimer()
    while not HasModelLoaded(hash) and GetGameTimer() - t < 5000 do Wait(10) end
    if not HasModelLoaded(hash) then
        notify('Erreur', 'error', 'Modèle non chargé.', 3000)
        return
    end

    local obj = CreateObject(hash, coords.x, coords.y, coords.z, false, false, false)
    PlaceObjectOnGroundProperly(obj)

    api.addLocalEntity(obj, {
        {
            name     = 'test:local:info',
            icon     = 'fa-solid fa-cube',
            label    = 'Infos (entité locale)',
            onSelect = function(data)
                local c = GetEntityCoords(data.entity)
                notify('Entité locale', 'info',
                    ('Handle: %d\nModèle: prop_barrel_01a\nCoords: %.1f, %.1f, %.1f\nNon-networked.')
                        :format(data.entity, c.x, c.y, c.z),
                    5000)
            end,
        },
        {
            name     = 'test:local:delete',
            icon     = 'fa-solid fa-trash',
            label    = 'Supprimer (local)',
            cooldown = 0,
            onSelect = function(data)
                api.removeLocalEntity(data.entity)
                DeleteObject(data.entity)
                notify('Supprimé', 'success', 'Entité locale supprimée.', 2000)
            end,
        },
    })

    SetModelAsNoLongerNeeded(hash)
    notify('testlocalentity', 'success',
        ('Barrel spawné. Handle: %d\nOptions locales attachées.'):format(obj), 4000)
end, false)

-- ─────────────────────────────────────────────────────────────────────────────
-- RÉCAP DES COMMANDES
-- ─────────────────────────────────────────────────────────────────────────────

-- CreateThread(function()
--     Wait(2000)
--     notify('kt_target — test.lua chargé', 'info',
-- [[Commandes disponibles :
--   /testcheckbox      → toggle debugMode (zone option cachée)
--   /testinput <m>     → modifier distance max ped
--   /testtoggle hotkey → toggle hotkey mode
--   /testtoggle defaults → ajouter/retirer option véhicule
--   /testslider <ms>   → modifier cooldown option véhicule
--   /testlocalentity   → spawn barrel + options locales]],
--         12000)
-- end)

print('')