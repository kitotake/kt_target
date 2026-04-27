-- client/admin/object_target.lua
-- Options d'administration pour les objets du monde.

local api = require 'client.api'

local isMovingObject = false
local frozenObjects  = {}

-- ─── Guard admin ─────────────────────────────────────────────────────────────

local function isAdmin()
    local ok, player

    ok, player = pcall(function() return exports['union']:GetCurrentPlayer() end)
    if not ok or not player then
        ok, player = pcall(function() return exports['union']:getPlayer() end)
    end
    if not ok or not player then return false end

    local group = player.group or 'user'
    return group == 'admin' or group == 'founder' or group == 'moderator'
end

-- ─── Notify ──────────────────────────────────────────────────────────────────

local function notify(title, type_, duration, description)
    duration = duration or 3000
    if lib and lib.notify then
        lib.notify({
            title       = title,
            description = description,
            type        = type_,
            duration    = duration,
        })
    else
        print(('[kt_target:admin] %s — %s'):format(title, description or ''))
    end
end

-- ─── Actions admin ───────────────────────────────────────────────────────────

local function showObjectInfos(data)
    local entity = data.entity
    if not DoesEntityExist(entity) then return end

    local coords  = GetEntityCoords(entity)
    local heading = GetEntityHeading(entity)
    local model   = GetEntityModel(entity)
    local frozen  = IsEntityFrozen(entity)
    local netId   = NetworkGetEntityIsNetworked(entity)
                    and NetworkGetNetworkIdFromEntity(entity)
                    or 'local'

    local msg = ('Model: %s (%d)\nNetId: %s\nCoords: %.2f, %.2f, %.2f\nHeading: %.1f°\nFrozen: %s'):format(
        GetEntityArchetypeName(entity), model,
        tostring(netId),
        coords.x, coords.y, coords.z,
        heading,
        frozen and 'Oui' or 'Non'
    )

    notify('Infos Objet', 'info', 8000, msg)
end

local function toggleFreeze(data)
    local entity = data.entity
    if not DoesEntityExist(entity) then return end

    local wasFrozen = frozenObjects[entity]
    FreezeEntityPosition(entity, not wasFrozen)
    frozenObjects[entity] = not wasFrozen or nil

    notify(
        not wasFrozen and 'Objet Gelé' or 'Objet Dégelé',
        not wasFrozen and 'warning' or 'success',
        3000
    )
end

local function moveObject(data)
    local entity = data.entity
    if not DoesEntityExist(entity) or isMovingObject then return end

    isMovingObject = true
    exports.kt_target:disableTargeting(true)

    DetachEntity(entity, false, false)
    FreezeEntityPosition(entity, true)
    SetEntityCollision(entity, false, false)

    notify('Déplacement', 'info', 5000, 'Clic gauche = poser | Clic droit = annuler')

    CreateThread(function()
        while isMovingObject do
            local coords, dir = GetWorldCoordFromScreenCoord(0.5, 0.5)
            local dest = coords + dir * 10.0
            local handle = StartShapeTestLosProbe(
                coords.x, coords.y, coords.z,
                dest.x, dest.y, dest.z,
                1 | 16, entity, 4
            )

            local retval, hit, endCoords
            repeat
                Wait(0)
                retval, hit, endCoords, _, _ = GetShapeTestResult(handle)
            until retval ~= 1

            if hit == 1 and endCoords then
                SetEntityCoords(entity,
                    endCoords.x, endCoords.y, endCoords.z,
                    false, false, false, false)
            end

            if IsControlPressed(0, 44) then
                SetEntityHeading(entity, GetEntityHeading(entity) + 2.0)
            elseif IsControlPressed(0, 38) then
                SetEntityHeading(entity, GetEntityHeading(entity) - 2.0)
            end

            if IsDisabledControlJustPressed(0, 24) then
                FreezeEntityPosition(entity, false)
                SetEntityCollision(entity, true, true)
                isMovingObject = false
                exports.kt_target:disableTargeting(false)
                notify('Objet posé', 'success', 2000)
            end

            if IsDisabledControlJustPressed(0, 25) then
                FreezeEntityPosition(entity, false)
                SetEntityCollision(entity, true, true)
                isMovingObject = false
                exports.kt_target:disableTargeting(false)
                notify('Déplacement annulé', 'error', 2000)
            end

            Wait(0)
        end
    end)
end

local function deleteObject(data)
    local entity = data.entity
    if not DoesEntityExist(entity) then return end

    if NetworkGetEntityIsNetworked(entity) then
        local netId = NetworkGetNetworkIdFromEntity(entity)
        api.removeEntity(netId)
        TriggerServerEvent('admin:object:delete', netId)
    else
        api.removeLocalEntity(entity)
        DeleteObject(entity)
    end

    notify('Objet supprimé', 'success', 2000)
end

-- ─── Targets de test ─────────────────────────────────────────────────────────

-- Test 1 : Tous les peds
api.addGlobalPed({
    {
        name     = 'test:ped:wave',
        icon     = 'fa-solid fa-hand-wave',
        label    = 'Dire bonjour',
        onSelect = function(data)
            notify('Ped', 'success', 2000, 'Tu as salué le ped #' .. tostring(data.entity))
        end,
    },
    {
        name     = 'test:ped:info',
        icon     = 'fa-solid fa-circle-info',
        label    = 'Infos ped',
        onSelect = function(data)
            local entity  = data.entity
            local coords  = GetEntityCoords(entity)
            local model   = GetEntityArchetypeName(entity)
            notify('Ped Info', 'info', 5000,
                ('Model: %s\nCoords: %.1f, %.1f, %.1f'):format(
                    model, coords.x, coords.y, coords.z))
        end,
    },
})

-- Test 2 : Tous les véhicules
api.addGlobalVehicle({
    {
        name     = 'test:vehicle:info',
        icon     = 'fa-solid fa-car',
        label    = 'Infos véhicule',
        onSelect = function(data)
            local entity = data.entity
            local model  = GetEntityArchetypeName(entity)
            local plate  = GetVehicleNumberPlateText(entity)
            local speed  = math.floor(GetEntitySpeed(entity) * 3.6)
            notify('Véhicule', 'info', 5000,
                ('Model: %s\nPlaque: %s\nVitesse: %d km/h'):format(model, plate, speed))
        end,
    },
    {
        name     = 'test:vehicle:repair',
        icon     = 'fa-solid fa-wrench',
        label    = 'Réparer',
        onSelect = function(data)
            SetVehicleFixed(data.entity)
            SetVehicleDeformationFixed(data.entity)
            notify('Véhicule', 'success', 2000, 'Véhicule réparé !')
        end,
    },
    {
        name     = 'test:vehicle:flip',
        icon     = 'fa-solid fa-rotate',
        label    = 'Remettre à l\'endroit',
        onSelect = function(data)
            local entity  = data.entity
            local coords  = GetEntityCoords(entity)
            local heading = GetEntityHeading(entity)
            SetEntityCoords(entity, coords.x, coords.y, coords.z + 1.0, false, false, false, false)
            SetEntityHeading(entity, heading)
            SetEntityRotation(entity, 0.0, 0.0, heading, 2, true)
            notify('Véhicule', 'success', 2000, 'Véhicule remis à l\'endroit !')
        end,
    },
})

-- Test 3 : Tous les objets (+ admin si admin)
api.addGlobalObject({
    -- Options visibles par tous
    {
        name     = 'test:object:info',
        icon     = 'fa-solid fa-cube',
        label    = 'Infos objet',
        onSelect = function(data)
            showObjectInfos(data)
        end,
    },
    -- Options admin uniquement
    {
        name        = 'admin:object:menu',
        icon        = 'fa-solid fa-screwdriver-wrench',
        label       = 'Admin — Menu objet',
        openMenu    = 'admin_object_menu',
        canInteract = isAdmin,
    },
    {
        name        = 'admin:object:infos',
        icon        = 'fa-solid fa-circle-info',
        label       = 'Informations (admin)',
        menuName    = 'admin_object_menu',
        onSelect    = showObjectInfos,
        canInteract = isAdmin,
    },
    {
        name        = 'admin:object:freeze',
        icon        = 'fa-solid fa-snowflake',
        label       = 'Geler / Dégeler',
        menuName    = 'admin_object_menu',
        onSelect    = toggleFreeze,
        canInteract = isAdmin,
    },
    {
        name        = 'admin:object:move',
        icon        = 'fa-solid fa-up-down-left-right',
        label       = 'Déplacer',
        menuName    = 'admin_object_menu',
        onSelect    = moveObject,
        canInteract = isAdmin,
    },
    {
        name        = 'admin:object:delete',
        icon        = 'fa-solid fa-trash',
        label       = 'Supprimer',
        menuName    = 'admin_object_menu',
        onSelect    = deleteObject,
        canInteract = isAdmin,
    },
})

-- Test 4 : Tous les joueurs
api.addGlobalPlayer({
    {
        name     = 'test:player:info',
        icon     = 'fa-solid fa-user',
        label    = 'Infos joueur',
        onSelect = function(data)
            local entity = data.entity
            local netId  = NetworkGetNetworkIdFromEntity(entity)
            local coords = GetEntityCoords(entity)
            notify('Joueur', 'info', 5000,
                ('NetId: %d\nCoords: %.1f, %.1f, %.1f'):format(
                    netId, coords.x, coords.y, coords.z))
        end,
    },
    {
        name        = 'admin:player:kick',
        icon        = 'fa-solid fa-ban',
        label       = 'Kick (admin)',
        canInteract = isAdmin,
        onSelect    = function(data)
            local entity = data.entity
            local netId  = NetworkGetNetworkIdFromEntity(entity)
            TriggerServerEvent('admin:player:kick', netId)
            notify('Admin', 'warning', 3000, 'Kick envoyé pour netId ' .. tostring(netId))
        end,
    },
})

-- Test 5 : Zone de test (BoxZone autour des coordonnées 0,0,0 — à adapter)
-- Décommente et adapte les coords à ton serveur
--[[
api.addBoxZone({
    name    = 'test:zone:spawn',
    coords  = vector3(0.0, 0.0, 70.0),
    size    = vector3(5.0, 5.0, 3.0),
    options = {
        {
            name     = 'test:zone:heal',
            icon     = 'fa-solid fa-heart-pulse',
            label    = 'Se soigner',
            onSelect = function()
                local ped = cache.ped
                SetEntityHealth(ped, 200)
                notify('Zone', 'success', 2000, 'Vous avez été soigné !')
            end,
        },
        {
            name     = 'test:zone:weather',
            icon     = 'fa-solid fa-cloud-sun',
            label    = 'Changer météo',
            onSelect = function()
                SetWeatherTypePersist('EXTRASUNNY')
                SetWeatherTypeNow('EXTRASUNNY')
                notify('Zone', 'success', 2000, 'Météo ensoleillée !')
            end,
        },
    },
})
]]

print('[kt_target] client/admin/object_target.lua chargé')