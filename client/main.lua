-- client/main.lua
if not lib.checkDependency('kt_lib', '3.30.0', true) then return end

lib.locale()

-- Shared state & utils
local state   = require 'client.state.target'
local bridge  = require 'client.nui.bridge'
local focus   = require 'client.nui.focus'
local raycast = require 'client.core.raycast'
local detect  = require 'client.core.detection'
local resolve = require 'client.core.resolver'
local exec    = require 'client.core.executor'
local api     = require 'client.api'

-- Optionnels
require 'client.debug'
require 'client.defaults'
require 'client.compat.qtarget'

-- ─── Boucle principale ────────────────────────────────────────────────────────

local _running  = false
local _disabled = false

local function shouldHide(opt, dist, endCoords, entityHit, entityType, entityModel)
    if opt.distance and dist > opt.distance then return true end

    if opt.bones then
        -- La vérification d'os est faite en amont dans le resolver
    end

    if opt.canInteract then
        local ok, result = pcall(opt.canInteract, entityHit, dist, endCoords, opt.name)
        if not ok or not result then return true end
    end

    if opt.groups then
        local utils = require 'client.utils'
        if not utils.hasPlayerGotGroup(opt.groups) then return true end
    end

    if opt.items then
        local utils = require 'client.utils'
        if not utils.hasPlayerGotItem(opt.items, opt.anyItem) then return true end
    end

    return false
end

local function buildNuiPayload(optionsGroups, nearbyZones)
    local groups = {}
    for key, opts in pairs(optionsGroups) do
        groups[#groups + 1] = { key = key, options = opts }
    end

    local zones = {}
    for i, zone in ipairs(nearbyZones) do
        zones[#zones + 1] = { zoneId = i, options = zone.options }
    end

    return groups, zones
end

CreateThread(function()
    _running = true

    while _running do
        local sleeping = true

        if not _disabled then
            local ped = cache.ped
            local hit, entityHit, endCoords = raycast.fromCamera(
                RAYCAST_FLAG_ALL, ped, Config.maxDistance
            )

            local dist = hit and #(GetEntityCoords(ped) - endCoords) or Config.maxDistance

            if hit and detect.isValid(entityHit) then
                sleeping = false

                local entityType  = detect.getType(entityHit)
                local entityModel = detect.getModel(entityHit)

                state.set(entityHit, endCoords, dist)

                -- Agrégation des options (à implémenter dans api.lua)
                local optionsGroups = api.getTargetOptions(entityHit, entityType, entityModel)
                local nearbyZones   = {}  -- lib.zones.getNearbyZones() ici

                -- Mise à jour de la visibilité
                local changed = false
                for _, opts in pairs(optionsGroups) do
                    if resolve.updateVisibility(
                        opts, dist, endCoords, shouldHide,
                        entityHit, entityType, entityModel
                    ) then
                        changed = true
                    end
                end

                if changed then
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
    -- data = [groupIndex, optionIndex, zoneId?]
    -- À router vers executor.run(option, response)
    cb('ok')
end)

-- ─── Exports publics ──────────────────────────────────────────────────────────

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