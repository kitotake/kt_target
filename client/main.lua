-- client/main.lua
-- Point d'entrée client. Charge les modules dans le bon ordre
-- et démarre la boucle principale de ciblage.

if not lib.checkDependency('kt_lib', '3.30.0', true) then return end

lib.locale()

-- ─── Chargement des modules (ordre important — pas de circular dep) ───────────

local utils   = require 'client.utils'       -- utils/init.lua (pas de dep sur api)
local state   = require 'client.state.target'
local bridge  = require 'client.nui.bridge'
local focus   = require 'client.nui.focus'
local raycast = require 'client.core.raycast'
local detect  = require 'client.core.detection'
local resolve = require 'client.core.resolver'
local exec    = require 'client.core.executor'

-- L'API charge le registre — doit venir APRÈS utils et state
local api     = require 'client.api'

-- Modules optionnels (chargés après l'API pour qu'ils puissent l'utiliser)
require 'client.debug'
require 'client.defaults'
require 'client.compat.qtarget'

-- ─── État interne de la boucle ────────────────────────────────────────────────

local _running  = false
local _disabled = false

-- ─── Filtre de visibilité ─────────────────────────────────────────────────────

---Détermine si une option doit être masquée pour l'entité ciblée.
---@param opt          KtTargetOption
---@param dist         number
---@param endCoords    vector3
---@param entityHit    number
---@param entityType   number
---@param entityModel  number|false
---@return boolean  true = masquer
local function shouldHide(opt, dist, endCoords, entityHit, entityType, entityModel)
    -- Distance
    if opt.distance and dist > opt.distance then return true end

    -- canInteract personnalisé
    if opt.canInteract then
        local ok, result = pcall(opt.canInteract, entityHit, dist, endCoords, opt.name)
        if not ok or not result then return true end
    end

    -- Filtre par groupe / job
    if opt.groups then
        if not utils.hasPlayerGotGroup(opt.groups) then return true end
    end

    -- Filtre par item
    if opt.items then
        if not utils.hasPlayerGotItem(opt.items, opt.anyItem) then return true end
    end

    return false
end

-- ─── Sérialisation NUI ───────────────────────────────────────────────────────

---Convertit optionsGroups en payload NUI.
---Filtre les options masquées, ne transmet que les champs nécessaires au React.
---@param optionsGroups table<string, KtTargetOption[]>
---@param nearbyZones   table
---@return table groups, table zones
local function buildNuiPayload(optionsGroups, nearbyZones)
    local groups = {}

    for key, opts in pairs(optionsGroups) do
        local serialized = {}
        for _, opt in ipairs(opts) do
            serialized[#serialized + 1] = {
                label     = opt.label,
                icon      = opt.icon or 'fa-solid fa-hand-pointer',
                iconColor = opt.iconColor,
                hide      = opt.hide,
                cooldown  = opt.cooldown,
                name      = opt.name,
                openMenu  = opt.openMenu,
                menuName  = opt.menuName,
            }
        end
        if #serialized > 0 then
            groups[#groups + 1] = { key = key, options = serialized }
        end
    end

    local zones = {}
    if nearbyZones then
        for i, zone in ipairs(nearbyZones) do
            local serialized = {}
            for _, opt in ipairs(zone.options or {}) do
                serialized[#serialized + 1] = {
                    label     = opt.label,
                    icon      = opt.icon or 'fa-solid fa-map-pin',
                    iconColor = opt.iconColor,
                    hide      = opt.hide,
                    cooldown  = opt.cooldown,
                    name      = opt.name,
                }
            end
            if #serialized > 0 then
                zones[#zones + 1] = { zoneId = i, options = serialized }
            end
        end
    end

    return groups, zones
end

-- ─── Boucle principale ────────────────────────────────────────────────────────

CreateThread(function()
    _running = true

    while _running do
        local sleeping = true

        if not _disabled then
            local ped    = cache.ped
            local coords = GetEntityCoords(ped)

            -- 1. Raycast depuis la caméra
            local hit, entityHit, endCoords = raycast.fromCamera(
                RAYCAST_FLAG_ALL, ped, Config.maxDistance
            )

            local dist = hit and #(coords - endCoords) or Config.maxDistance

            -- 2. Détection zones (kt_lib)
            local nearbyZones = {}
            if lib.zones then
                for _, zone in ipairs(lib.zones.getNearby and lib.zones.getNearby(coords, Config.zoneDistance) or {}) do
                    if zone.options then
                        nearbyZones[#nearbyZones + 1] = zone
                    end
                end
            end

            local hasEntity = hit and detect.isValid(entityHit)
            local hasZones  = #nearbyZones > 0

            if hasEntity or hasZones then
                sleeping = false

                local entityType  = hasEntity and detect.getType(entityHit) or 0
                local entityModel = hasEntity and detect.getModel(entityHit) or false

                if hasEntity then
                    state.set(entityHit, endCoords, dist)
                end

                -- 3. Agrégation des options
                local optionsGroups = hasEntity
                    and api.getTargetOptions(entityHit, entityType, entityModel)
                    or {}

                -- 4. Mise à jour de la visibilité
                local changed = false
                for _, opts in pairs(optionsGroups) do
                    if resolve.updateVisibility(
                        opts, dist, endCoords, shouldHide,
                        entityHit, entityType, entityModel
                    ) then
                        changed = true
                    end
                end

                -- Visibilité des zones
                for _, zone in ipairs(nearbyZones) do
                    if resolve.updateVisibility(
                        zone.options, dist, endCoords, shouldHide,
                        0, 0, false
                    ) then
                        changed = true
                    end
                end

                -- 5. Envoi NUI si changement
                if changed or not focus.isFocused() then
                    local groups, zones = buildNuiPayload(optionsGroups, nearbyZones)
                    bridge.setTarget(groups, zones)
                end

                if not focus.isFocused() then
                    focus.set(true, true)
                end
            else
                if focus.isFocused() then
                    focus.set(false)
                    bridge.leftTarget()
                    state.reset()
                end
            end
        end

        Wait(sleeping and 100 or 0)
    end
end)

-- ─── NUI Callbacks ────────────────────────────────────────────────────────────

RegisterNuiCallback('select', function(data, cb)
    -- data = [groupIndex, optionIndex, zoneId?] (1-based, depuis React)
    local groupIndex  = data[1]
    local optionIndex = data[2]
    local zoneId      = data[3]

    local currentState = state.get()
    local option

    if zoneId then
        -- Option de zone
        local nearbyZones = {}
        if lib.zones and lib.zones.getNearby then
            local coords = GetEntityCoords(cache.ped)
            nearbyZones = lib.zones.getNearby(coords, Config.zoneDistance) or {}
        end
        local zone = nearbyZones[zoneId]
        if zone and zone.options then
            option = zone.options[optionIndex]
        end
        state.setZone(zoneId)
    else
        -- Option d'entité : reconstruit les groupes pour retrouver l'option
        local etype  = detect.getType(currentState.entity)
        local emodel = detect.getModel(currentState.entity)
        local groups = api.getTargetOptions(currentState.entity, etype, emodel)

        -- Convertit la table pairs() en tableau ordonné
        local groupList = {}
        for key, opts in pairs(groups) do
            groupList[#groupList + 1] = { key = key, options = opts }
        end

        local group = groupList[groupIndex]
        if group then
            option = group.options[optionIndex]
        end
    end

    if not option then
        warn('[kt_target] select : option introuvable (groupIndex=' ..
            tostring(groupIndex) .. ', optionIndex=' .. tostring(optionIndex) .. ')')
        cb('error')
        return
    end

    -- Exécution de l'action
    exec.run(option, currentState)
    cb('ok')
end)

-- ─── Exports de contrôle ─────────────────────────────────────────────────────

exports('disableTargeting', function(value)
    _disabled = value
    if value then
        focus.set(false)
        bridge.leftTarget()
    end
end)

exports('isActive', function()
    return _running and not _disabled
end)