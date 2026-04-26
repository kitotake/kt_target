-- client/admin/object_target.lua
local kt_target      = exports.kt_target
local isMovingObject = false
local frozenObjects  = {}

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

local function notify(title, type_, duration, description)
    duration = duration or 3000
    if lib and lib.notify then
        lib.notify({ title = title, description = description, type = type_, duration = duration })
    else
        print(('[kt_target:admin] %s — %s'):format(title, description or ''))
    end
end

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

    notify(not wasFrozen and 'Objet Gelé' or 'Objet Dégelé',
           not wasFrozen and 'warning' or 'success', 3000)
end

local function moveObject(data)
    local entity = data.entity
    if not DoesEntityExist(entity) or isMovingObject then return end

    isMovingObject = true
    kt_target:disableTargeting(true)
    DetachEntity(entity, false, false)
    FreezeEntityPosition(entity, true)
    SetEntityCollision(entity, false, false)

    notify('Déplacement', 'info', 5000, 'Clic gauche = poser | Clic droit = annuler')

    CreateThread(function()
        while isMovingObject do
            -- Utilise le raycast interne de kt_target si lib n'est pas dispo
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
                SetEntityCoords(entity, endCoords.x, endCoords.y, endCoords.z, false, false, false, false)
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
                kt_target:disableTargeting(false)
                notify('Objet posé', 'success', 2000)
            end

            if IsDisabledControlJustPressed(0, 25) then
                FreezeEntityPosition(entity, false)
                SetEntityCollision(entity, true, true)
                isMovingObject = false
                kt_target:disableTargeting(false)
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
        -- ✅ removeEntity attend un netId, pas l'entity handle
        kt_target:removeEntity(netId)
        TriggerServerEvent('admin:object:delete', netId)
    else
        kt_target:removeLocalEntity(entity)
        DeleteObject(entity)
    end

    notify('Objet supprimé', 'success', 2000)
end

kt_target:addGlobalObject({
    {
        name        = 'admin:object:menu',
        icon        = 'fa-solid fa-screwdriver-wrench',
        label       = 'Admin — Objet',
        openMenu    = 'admin_object_menu',
        canInteract = function() return isAdmin() end,
    },
    {
        name        = 'admin:object:infos',
        icon        = 'fa-solid fa-circle-info',
        label       = 'Informations',
        menuName    = 'admin_object_menu',
        onSelect    = showObjectInfos,
        canInteract = function() return isAdmin() end,
    },
    {
        name        = 'admin:object:freeze',
        icon        = 'fa-solid fa-snowflake',
        label       = 'Geler / Dégeler',
        menuName    = 'admin_object_menu',
        onSelect    = toggleFreeze,
        canInteract = function() return isAdmin() end,
    },
    {
        name        = 'admin:object:move',
        icon        = 'fa-solid fa-up-down-left-right',
        label       = 'Déplacer',
        menuName    = 'admin_object_menu',
        onSelect    = moveObject,
        canInteract = function() return isAdmin() end,
    },
    {
        name        = 'admin:object:delete',
        icon        = 'fa-solid fa-trash',
        label       = 'Supprimer',
        menuName    = 'admin_object_menu',
        onSelect    = deleteObject,
        canInteract = function() return isAdmin() end,
    },
})