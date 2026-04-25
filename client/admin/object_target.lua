-- client/admin/object_target.lua
-- Système d'interaction admin sur les objets au sol via kt_target + Union

local kt_target = exports.kt_target
local isMovingObject = false
local frozenObjects = {}

-- ─────────────────────────────────────────────────────────────
-- Vérifie si le joueur local est admin/founder via Union
-- ─────────────────────────────────────────────────────────────
local function isAdmin()
    local ok, player = pcall(function()
        return exports['union']:GetCurrentPlayer()
    end)

    if not ok or not player then return false end

    local group = player.group or 'user'
    return group == 'admin' or group == 'founder' or group == 'moderator'
end

-- ─────────────────────────────────────────────────────────────
-- Infos de l'objet
-- ─────────────────────────────────────────────────────────────
local function showObjectInfos(data)
    local entity = data.entity
    if not DoesEntityExist(entity) then return end

    local coords   = GetEntityCoords(entity)
    local heading  = GetEntityHeading(entity)
    local model    = GetEntityModel(entity)
    local frozen   = IsEntityFrozen(entity)
    local netId    = NetworkGetEntityIsNetworked(entity) and NetworkGetNetworkIdFromEntity(entity) or 'local'

    local msg = string.format(
        "^3[Object Infos]^0\n" ..
        "Model  : ^5%s^0 (%d)\n" ..
        "NetId  : ^5%s^0\n" ..
        "Coords : ^5%.2f, %.2f, %.2f^0\n" ..
        "Heading: ^5%.1f°^0\n" ..
        "Frozen : ^5%s^0",
        GetEntityArchetypeName(entity), model,
        tostring(netId),
        coords.x, coords.y, coords.z,
        heading,
        frozen and 'Oui' or 'Non'
    )

    -- Affiche via lib.notify si disponible, sinon print
    if lib and lib.notify then
        lib.notify({ title = 'Infos Objet', description = msg, type = 'info', duration = 8000 })
    else
        print(msg)
    end
end

-- ─────────────────────────────────────────────────────────────
-- Geler / Dégeler
-- ─────────────────────────────────────────────────────────────
local function toggleFreeze(data)
    local entity = data.entity
    if not DoesEntityExist(entity) then return end

    local frozen = frozenObjects[entity]

    FreezeEntityPosition(entity, not frozen)
    frozenObjects[entity] = not frozen or nil

    local state = not frozen and '^1Gelé' or '^2Dégelé'
    if lib and lib.notify then
        lib.notify({ title = 'Objet ' .. state .. '^0', type = frozen and 'success' or 'warning', duration = 3000 })
    end
end

-- ─────────────────────────────────────────────────────────────
-- Déplacer (placement libre avec le curseur)
-- ─────────────────────────────────────────────────────────────
local function moveObject(data)
    local entity = data.entity
    if not DoesEntityExist(entity) or isMovingObject then return end

    isMovingObject = true
    exports.kt_target:disableTargeting(true)

    -- Détache l'objet et le rend manipulable
    DetachEntity(entity, false, false)
    FreezeEntityPosition(entity, true)
    SetEntityCollision(entity, false, false)

    if lib and lib.notify then
        lib.notify({ title = 'Déplacement', description = 'Clic gauche pour poser, Clic droit pour annuler', type = 'info', duration = 5000 })
    end

    CreateThread(function()
        while isMovingObject do
            local hit, _, endCoords = lib.raycast.fromCamera(511 | 16, 4, 10)

            if hit and endCoords then
                SetEntityCoords(entity, endCoords.x, endCoords.y, endCoords.z, false, false, false, false)
            end

            -- Rotation avec molette (Q/E)
            if IsControlPressed(0, 44) then -- Q
                local heading = GetEntityHeading(entity)
                SetEntityHeading(entity, heading + 2.0)
            elseif IsControlPressed(0, 38) then -- E
                local heading = GetEntityHeading(entity)
                SetEntityHeading(entity, heading - 2.0)
            end

            -- Clic gauche = poser
            if IsDisabledControlJustPressed(0, 24) then
                FreezeEntityPosition(entity, false)
                SetEntityCollision(entity, true, true)
                isMovingObject = false
                exports.kt_target:disableTargeting(false)

                if lib and lib.notify then
                    lib.notify({ title = 'Objet posé', type = 'success', duration = 2000 })
                end
            end

            -- Clic droit = annuler (remet à la position d'origine)
            if IsDisabledControlJustPressed(0, 25) then
                FreezeEntityPosition(entity, false)
                SetEntityCollision(entity, true, true)
                isMovingObject = false
                exports.kt_target:disableTargeting(false)

                if lib and lib.notify then
                    lib.notify({ title = 'Déplacement annulé', type = 'error', duration = 2000 })
                end
            end

            Wait(0)
        end
    end)
end

-- ─────────────────────────────────────────────────────────────
-- Supprimer
-- ─────────────────────────────────────────────────────────────
local function deleteObject(data)
    local entity = data.entity
    if not DoesEntityExist(entity) then return end

    -- Retire les options kt_target liées à cet objet
    if NetworkGetEntityIsNetworked(entity) then
        local netId = NetworkGetNetworkIdFromEntity(entity)
        exports.kt_target:removeEntity(netId)
        TriggerServerEvent('admin:object:delete', netId)
    else
        exports.kt_target:removeLocalEntity(entity)
        DeleteObject(entity)
    end

    if lib and lib.notify then
        lib.notify({ title = 'Objet supprimé', type = 'success', duration = 2000 })
    end
end

-- ─────────────────────────────────────────────────────────────
-- Enregistrement des interactions globales sur les objets
-- ─────────────────────────────────────────────────────────────
kt_target:addGlobalObject({
    -- Entrée du menu admin (visible seulement pour les admins)
    {
        name = 'admin:object:menu',
        icon = 'fa-solid fa-screwdriver-wrench',
        label = 'Admin — Objet',
        openMenu = 'admin_object_menu',
        canInteract = function()
            return isAdmin()
        end,
    },

    -- ── Sous-menu : Infos ────────────────────────────────────
    {
        name = 'admin:object:infos',
        icon = 'fa-solid fa-circle-info',
        label = 'Informations',
        menuName = 'admin_object_menu',
        onSelect = showObjectInfos,
        canInteract = function()
            return isAdmin()
        end,
    },

    -- ── Sous-menu : Geler ────────────────────────────────────
    {
        name = 'admin:object:freeze',
        icon = 'fa-solid fa-snowflake',
        label = 'Geler / Dégeler',
        menuName = 'admin_object_menu',
        onSelect = toggleFreeze,
        canInteract = function()
            return isAdmin()
        end,
    },

    -- ── Sous-menu : Déplacer ─────────────────────────────────
    {
        name = 'admin:object:move',
        icon = 'fa-solid fa-up-down-left-right',
        label = 'Déplacer',
        menuName = 'admin_object_menu',
        onSelect = moveObject,
        canInteract = function()
            return isAdmin()
        end,
    },

    -- ── Sous-menu : Supprimer ────────────────────────────────
    {
        name = 'admin:object:delete',
        icon = 'fa-solid fa-trash',
        label = 'Supprimer',
        menuName = 'admin_object_menu',
        onSelect = deleteObject,
        canInteract = function()
            return isAdmin()
        end,
    },
})