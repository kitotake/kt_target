-- client/main.lua
if not lib.checkDependency('kt_lib', '3.30.0', true) then return end

lib.locale()

-- ─── Modules ────────────────────────────────────────────────────────────────
local utils   = require 'client.utils'
local state   = require 'client.state.target'
local bridge  = require 'client.nui.bridge'
local focus   = require 'client.nui.focus'
local raycast = require 'client.core.raycast'
local detect  = require 'client.core.detection'
local resolve = require 'client.core.resolver'
local exec    = require 'client.core.executor'
local api     = require 'client.api'

require 'client.debug'
require 'client.defaults'
require 'client.compat.qtarget'

-- ─── État ───────────────────────────────────────────────────────────────────
local _running  = false
local _disabled = false

local combatBlocked  = false
local _lastGroupList = {}
local _lastEntityHit = 0
local _lastVisible   = false

-- ─── Constantes ─────────────────────────────────────────────────────────────
local HOTKEY        = 19
local DOT_THRESHOLD = Config.dotThreshold or 0.92

-- Controls à bloquer pendant le targeting (DisableControlAction, frame-by-frame)
local BLOCKED_CONTROLS = {
    24,   -- Attack
    25,   -- Aim
    140,  -- Melee attack light
    141,  -- Melee attack heavy
    142,  -- Melee attack alternate
    257,  -- Attack 2
    263,  -- Melee attack 1
    264,  -- Melee attack 2
    37,   -- Select weapon
    73,   -- Attack (gamepad)
}

Config.maxDistance  = tonumber(Config.maxDistance)  or 5.0
Config.zoneDistance = tonumber(Config.zoneDistance) or 10.0

-- ─── Helpers ────────────────────────────────────────────────────────────────
local function toNumber(value)
    if type(value) == 'number' then return value end
    if type(value) == 'string' then return tonumber(value) end
    return nil
end

---Bloque ou débloque les inputs de combat.
---DisableControlAction ne persiste pas : doit être rappelé chaque frame.
---@param active boolean
local function setCombatBlock(active)
    for _, control in ipairs(BLOCKED_CONTROLS) do
        DisableControlAction(0, control, active)
    end
end

---Restaure immédiatement tous les inputs de combat.
---À appeler UNE SEULE FOIS lors de la désactivation, pas en boucle.
local function restoreCombatControls()
    local ped = cache.ped
    -- DisableControlAction(false) n'est pas nécessaire car l'effet
    -- est automatiquement annulé dès qu'on arrête de l'appeler chaque frame.
    -- On remet quand même les flags ped explicitement.
    SetPedCanSwitchWeapon(ped, true)
    SetPedConfigFlag(ped, 122, false)
end

local function isLookingAt(entityCoords)
    local camCoords = GetGameplayCamCoords()
    local camRot    = GetGameplayCamRot(2)

    local x = math.rad(camRot.x)
    local z = math.rad(camRot.z)

    local dir = vector3(
        -math.sin(z) * math.abs(math.cos(x)),
         math.cos(z) * math.abs(math.cos(x)),
         math.sin(x)
    )

    local toEntity = entityCoords - camCoords
    local len      = #toEntity
    if len < 0.001 then return false end

    local normalized = toEntity / len
    local dot = normalized.x * dir.x + normalized.y * dir.y + normalized.z * dir.z

    return dot == dot and dot >= DOT_THRESHOLD
end

local function closeTarget()
    if focus.isFocused() then focus.set(false) end
    bridge.send({ event = 'leftTarget' })
    bridge.setVisible(false)
    state.reset()

    _lastGroupList = {}
    _lastEntityHit = 0
    _lastVisible   = false
end

-- ─── FILTER ─────────────────────────────────────────────────────────────────
local function shouldHide(opt, dist, endCoords, entityHit, entityType, entityModel)
    local maxDist = toNumber(opt.distance)
    if maxDist and dist > maxDist then return true end

    if opt.canInteract then
        local ok, result = pcall(opt.canInteract, entityHit, dist, endCoords, opt.name)
        if not ok or not result then return true end
    end

    if opt.groups and not utils.hasPlayerGotGroup(opt.groups) then return true end
    if opt.items  and not utils.hasPlayerGotItem(opt.items, opt.anyItem) then return true end

    return false
end

local function sanitizeOptions(optionsGroups)
    for _, opts in pairs(optionsGroups or {}) do
        for _, opt in ipairs(opts) do
            opt.distance = toNumber(opt.distance)
        end
    end
end

-- ─── NUI ────────────────────────────────────────────────────────────────────
local function buildNuiPayload(optionsGroups, nearbyZones)
    local groups = {}
    _lastGroupList = {}

    for key, opts in pairs(optionsGroups) do
        _lastGroupList[#_lastGroupList + 1] = { key = key, options = opts }
    end

    for _, grp in ipairs(_lastGroupList) do
        local serialized = {}
        for _, opt in ipairs(grp.options) do
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
            groups[#groups + 1] = { key = grp.key, options = serialized }
        end
    end

    local zones = {}
    for i, zone in ipairs(nearbyZones or {}) do
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

    return groups, zones
end

-- ─── INPUT LOOP ─────────────────────────────────────────────────────────────
-- Séparé de la target loop pour garantir que le bloc combat tourne
-- à CHAQUE frame, indépendamment du Wait(0)/Wait(100) de la target loop.
CreateThread(function()
    while true do
        Wait(0)

        if _disabled then
            -- Targeting désactivé en cours d'utilisation → nettoyage immédiat
            if combatBlocked then
                combatBlocked = false
                restoreCombatControls()
                closeTarget()
            end

        elseif IsControlPressed(0, HOTKEY) then
            -- ── ALT pressé ──────────────────────────────────────────────────
            if not combatBlocked then
                combatBlocked = true
                bridge.setVisible(true)
            end

            -- Maintenu chaque frame tant que ALT est enfoncé
            local ped = cache.ped
            setCombatBlock(true)
            SetPedCanSwitchWeapon(ped, false)
            SetCurrentPedWeapon(ped, `WEAPON_UNARMED`, true)
            SetPedConfigFlag(ped, 122, true)

            if IsPedInMeleeCombat(ped) then
                ClearPedTasksImmediately(ped)
            end

        else
            -- ── ALT relâché ─────────────────────────────────────────────────
            if combatBlocked then
                combatBlocked = false
                -- Les DisableControlAction s'annulent automatiquement
                -- dès qu'ils ne sont plus appelés chaque frame,
                -- mais on remet les flags ped explicitement.
                restoreCombatControls()
                closeTarget()
            end
        end
    end
end)

-- ─── MAIN TARGET LOOP ───────────────────────────────────────────────────────
CreateThread(function()
    _running = true

    while _running do

        if not _disabled and combatBlocked then

            local ped    = cache.ped
            local coords = GetEntityCoords(ped)

            local hit, entityHit, endCoords = raycast.fromCamera(
                RAYCAST_FLAG_ALL, ped, Config.maxDistance
            )

            local dist = hit and #(coords - endCoords) or Config.maxDistance
            dist = toNumber(dist) or Config.maxDistance

            -- Valide l'entité AVANT tout appel réseau
            local entityValid = false
            if hit and entityHit ~= 0 and DoesEntityExist(entityHit) then
                local ec = GetEntityCoords(entityHit)
                entityValid = isLookingAt(ec) and detect.isValid(entityHit)
            end

            local nearbyZones = {}
            if lib.zones and lib.zones.getNearby then
                for _, zone in ipairs(lib.zones.getNearby(coords, Config.zoneDistance) or {}) do
                    if zone.options then
                        nearbyZones[#nearbyZones + 1] = zone
                    end
                end
            end

            local hasEntity = entityValid
            local hasZones  = #nearbyZones > 0

            if hasEntity or hasZones then

                local entityType  = hasEntity and detect.getType(entityHit)  or 0
                local entityModel = hasEntity and detect.getModel(entityHit) or false

                if hasEntity then
                    state.set(entityHit, endCoords, dist)
                end

                local optionsGroups = hasEntity
                    and api.getTargetOptions(entityHit, entityType, entityModel)
                    or  {}

                sanitizeOptions(optionsGroups)

                local changed      = false
                local totalVisible = 0

                for _, opts in pairs(optionsGroups) do
                    if resolve.updateVisibility(opts, dist, endCoords, shouldHide,
                            entityHit, entityType, entityModel) then
                        changed = true
                    end
                    for _, opt in ipairs(opts) do
                        if not opt.hide then totalVisible = totalVisible + 1 end
                    end
                end

                for _, zone in ipairs(nearbyZones) do
                    if resolve.updateVisibility(zone.options, dist, endCoords,
                            shouldHide, 0, 0, false) then
                        changed = true
                    end
                end

                local entityChanged = entityHit ~= _lastEntityHit

                if changed or entityChanged or not _lastVisible then
                    local groups, zones = buildNuiPayload(optionsGroups, nearbyZones)

                    bridge.send({
                        event          = 'setTarget',
                        groups         = groups,
                        zones          = zones,
                        noOptionsLabel = (totalVisible == 0) and locale('no_options') or nil,
                    })

                    _lastVisible = true
                end

                _lastEntityHit = entityHit

                if not focus.isFocused() then
                    focus.set(true, true)
                end

            else
                if _lastVisible then
                    closeTarget()
                end
            end

            Wait(0)

        else
            Wait(100)
        end
    end
end)

-- ─── CALLBACK NUI ───────────────────────────────────────────────────────────
RegisterNUICallback('select', function(data, cb)
    local groupIndex  = data[1]
    local optionIndex = data[2]
    local zoneId      = data[3]

    local currentState = state.get()
    local option

    if zoneId and zoneId ~= 0 then
        local zones = lib.zones.getNearby(GetEntityCoords(cache.ped), Config.zoneDistance) or {}
        local zone  = zones[zoneId]
        if zone then option = zone.options[optionIndex] end
    else
        local group = _lastGroupList[groupIndex]
        if group then option = group.options[optionIndex] end
    end

    if not option then cb('error') return end

    exec.run(option, currentState)
    cb('ok')
end)

-- ─── EXPORTS ────────────────────────────────────────────────────────────────
exports('disableTargeting', function(value)
    _disabled = value
    if value and combatBlocked then
        combatBlocked = false
        restoreCombatControls()
        closeTarget()
    end
end)

exports('isActive', function()
    return _running and not _disabled
end)