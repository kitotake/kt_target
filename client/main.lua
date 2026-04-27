-- client/main.lua
if not lib.checkDependency('kt_lib', '3.30.0', true) then return end

lib.locale()

-- ─── Modules ─────────────────────────────────────────────────────────────────
local utils = require 'client.utils'
local state = require 'client.state.target'
local bridge = require 'client.nui.bridge'
local focus = require 'client.nui.focus'
local raycast = require 'client.core.raycast'
local detect = require 'client.core.detection'
local resolve = require 'client.core.resolver'
local exec = require 'client.core.executor'
local api = require 'client.api'

require 'client.debug'
require 'client.defaults'
require 'client.compat.qtarget'

-- ─── État ────────────────────────────────────────────────────────────────────
local _running = false
local _disabled = false
local _altActive = false
local _lastGroupList = {}

-- ─── Constantes ──────────────────────────────────────────────────────────────
local HOTKEY = 19 -- INPUT_CHARACTER_WHEEL (ALT)
local DOT_THRESHOLD = Config.dotThreshold or 0.92

print('[kt_target] Client script loaded.')
print('dot threshold:', DOT_THRESHOLD)

-- ─── Helpers ─────────────────────────────────────────────────────────────────

--- Convertit une valeur en number de manière sécurisée
local function toNumber(value)
    if type(value) == 'number' then 
        return value 
    end
    if type(value) == 'string' then
        local n = tonumber(value)
        if n then return n end
    end
    return nil
end

--- Vérifie que le joueur regarde bien vers l'entité (dot product)
---@param entityCoords vector3
---@return boolean
local function isLookingAt(entityCoords)
    local camCoords = GetGameplayCamCoords()
    local camRot = GetGameplayCamRot(2)  -- renamed for clarity

    local x = math.rad(camRot.x)
    local z = math.rad(camRot.z)

    -- Direction vector from camera (forward)
    local dir = vector3(
        -math.sin(z) * math.abs(math.cos(x)),
        math.cos(z) * math.abs(math.cos(x)),
        math.sin(x)
    )

    local toEntity = entityCoords - camCoords
    local len = #toEntity
    if len < 0.001 then 
        return false 
    end

    -- Proper dot product (normalized)
    local normalized = toEntity / len
   local dot = normalized.x * dir.x + normalized.y * dir.y + normalized.z * dir.z
if not dot or dot ~= dot then  -- NaN check
    return false
end
return dot >= DOT_THRESHOLD
end

--- Ferme proprement le targeting
local function closeTarget()
    if focus.isFocused() then
        focus.set(false)
    end
    bridge.send({event = 'leftTarget'})
    bridge.setVisible(false)
    state.reset()
    _altActive = false
    _lastGroupList = {}
end

-- ─── Filtre de visibilité ────────────────────────────────────────────────────
local function shouldHide(opt, dist, endCoords, entityHit, entityType, entityModel)
    local maxDist = toNumber(opt.distance)
    
    if maxDist and dist > maxDist then
        return true
    end
    
    if opt.canInteract then
        local ok, result = pcall(opt.canInteract, entityHit, dist, endCoords, opt.name)
        if not ok or not result then
            return true
        end
    end
    
    if opt.groups and not utils.hasPlayerGotGroup(opt.groups) then
        return true
    end
    
    if opt.items and not utils.hasPlayerGotItem(opt.items, opt.anyItem) then
        return true
    end
    
    return false
end

--- Nettoie toutes les options (convertit distance en number)
local function sanitizeOptions(optionsGroups)
    for _, opts in pairs(optionsGroups or {}) do
        for _, opt in ipairs(opts) do
            if opt.distance then
                opt.distance = toNumber(opt.distance)
            end
        end
    end
end

-- ─── Sérialisation NUI ───────────────────────────────────────────────────────
local function buildNuiPayload(optionsGroups, nearbyZones)
    local groups = {}
    _lastGroupList = {}
    
    for key, opts in pairs(optionsGroups) do
        _lastGroupList[#_lastGroupList + 1] = {key = key, options = opts}
    end
    
    for _, grp in ipairs(_lastGroupList) do
        local serialized = {}
        for _, opt in ipairs(grp.options) do
            serialized[#serialized + 1] = {
                label = opt.label,
                icon = opt.icon or 'fa-solid fa-hand-pointer',
                iconColor = opt.iconColor,
                hide = opt.hide,
                cooldown = opt.cooldown,
                name = opt.name,
                openMenu = opt.openMenu,
                menuName = opt.menuName,
            }
        end
        if #serialized > 0 then
            groups[#groups + 1] = {key = grp.key, options = serialized}
        end
    end
    
    local zones = {}
    if nearbyZones then
        for i, zone in ipairs(nearbyZones) do
            local serialized = {}
            for _, opt in ipairs(zone.options or {}) do
                serialized[#serialized + 1] = {
                    label = opt.label,
                    icon = opt.icon or 'fa-solid fa-map-pin',
                    iconColor = opt.iconColor,
                    hide = opt.hide,
                    cooldown = opt.cooldown,
                    name = opt.name,
                }
            end
            if #serialized > 0 then
                zones[#zones + 1] = {zoneId = i, options = serialized}
            end
        end
    end
    
    return groups, zones
end

-- ─── Thread : gestion hotkey ─────────────────────────────────────────────────
CreateThread(function()
    while true do
        Wait(0)
        
        if not _disabled then
            if Config.toggleHotkey then
                if IsControlJustPressed(0, HOTKEY) then
                    if not _altActive then
                        _altActive = true
                        bridge.setVisible(true)
                    else
                        closeTarget()
                    end
                end
            else
                local pressed = IsControlPressed(0, HOTKEY)
                if pressed and not _altActive then
                    _altActive = true
                    bridge.setVisible(true)
                elseif not pressed and _altActive then
                    closeTarget()
                end
            end
        end
    end
end)

-- ─── Boucle principale ───────────────────────────────────────────────────────
CreateThread(function()
    _running = true
    
    local _lastEntityHit = 0
    local _lastVisible = false

    -- Sécurisation des configs au démarrage
    Config.maxDistance = toNumber(Config.maxDistance) or 5.0
    Config.zoneDistance = toNumber(Config.zoneDistance) or 10.0

    while _running do
        
        if not _disabled and _altActive then
            
            local ped = cache.ped
            local coords = GetEntityCoords(ped)
            
            local hit, entityHit, endCoords = raycast.fromCamera(
                RAYCAST_FLAG_ALL, ped, Config.maxDistance
            )
            
            local dist = hit and #(coords - endCoords) or Config.maxDistance
            dist = toNumber(dist) or Config.maxDistance

            -- Validation regard (dot product)
            local entityValid = false
            if hit and detect.isValid(entityHit) then
                local ec = GetEntityCoords(entityHit)
                entityValid = isLookingAt(ec)
            end
            
            -- Zones proches
            local nearbyZones = {}
            if lib.zones and lib.zones.getNearby then
                for _, zone in ipairs(lib.zones.getNearby(coords, Config.zoneDistance) or {}) do
                    if zone.options then
                        nearbyZones[#nearbyZones + 1] = zone
                    end
                end
            end
            
            local hasEntity = entityValid
            local hasZones = #nearbyZones > 0
            
            if hasEntity or hasZones then
                
                local entityType = hasEntity and detect.getType(entityHit) or 0
                local entityModel = hasEntity and detect.getModel(entityHit) or false
                
                if hasEntity then
                    state.set(entityHit, endCoords, dist)
                end
                
                local optionsGroups = hasEntity
                    and api.getTargetOptions(entityHit, entityType, entityModel)
                    or {}

                -- Nettoyage important des distances
                sanitizeOptions(optionsGroups)
                
                -- Mise à jour visibilité
                local changed = false
                local totalVisible = 0
                
                for _, opts in pairs(optionsGroups) do
                    if resolve.updateVisibility(
                        opts, dist, endCoords, shouldHide,
                        entityHit, entityType, entityModel
                    ) then 
                        changed = true 
                    end
                    
                    for _, opt in ipairs(opts) do
                        if not opt.hide then 
                            totalVisible = totalVisible + 1 
                        end
                    end
                end
                
                for _, zone in ipairs(nearbyZones) do
                    if resolve.updateVisibility(
                        zone.options, dist, endCoords, shouldHide,
                        0, 0, false
                    ) then 
                        changed = true 
                    end
                    
                    for _, opt in ipairs(zone.options or {}) do
                        if not opt.hide then 
                            totalVisible = totalVisible + 1 
                        end
                    end
                end
                
                -- Envoi NUI seulement si changement
                local entityChanged = entityHit ~= _lastEntityHit
                if changed or entityChanged or not _lastVisible then
                    local groups, zones = buildNuiPayload(optionsGroups, nearbyZones)
                    local hasAnyGroups = #groups > 0 or #zones > 0
                    
                    bridge.send({
                        event = 'setTarget',
                        groups = groups,
                        zones = zones,
                        noOptionsLabel = (hasAnyGroups and totalVisible == 0)
                            and locale('no_options')
                            or nil,
                    })
                    
                    _lastVisible = true
                end
                
                _lastEntityHit = entityHit
                
                if not focus.isFocused() then
                    focus.set(true, true)
                end
            
            else
                -- Aucune cible valide
                if _lastVisible then
                    if focus.isFocused() then focus.set(false) end
                    bridge.send({event = 'leftTarget'})
                    state.reset()
                    _lastEntityHit = 0
                    _lastVisible = false
                end
            end
            
            Wait(0)
        else
            _lastEntityHit = 0
            _lastVisible = false
            Wait(100)
        end
    end
end)

-- ─── NUI Callbacks ───────────────────────────────────────────────────────────
RegisterNUICallback('select', function(data, cb)
    local groupIndex = data[1]
    local optionIndex = data[2]
    local zoneId = data[3]
    local isZone = zoneId ~= nil and zoneId ~= 0
    
    local currentState = state.get()
    local option
    
    if isZone then
        local nearbyZones = {}
        if lib.zones and lib.zones.getNearby then
            nearbyZones = lib.zones.getNearby(
                GetEntityCoords(cache.ped), Config.zoneDistance
            ) or {}
        end
        local zone = nearbyZones[zoneId]
        if zone and zone.options then
            option = zone.options[optionIndex]
        end
        state.setZone(zoneId)
    else
        local group = _lastGroupList[groupIndex]
        if group then
            option = group.options[optionIndex]
        end
    end
    
    if not option then
        warn(('[kt_target] select : option introuvable (g=%s o=%s z=%s)'):format(
            tostring(groupIndex), tostring(optionIndex), tostring(zoneId)
        ))
        cb('error')
        return
    end
    
    exec.run(option, currentState)
    cb('ok')
end)

-- ─── Exports ─────────────────────────────────────────────────────────────────
exports('disableTargeting', function(value)
    _disabled = value
    if value then closeTarget() end
end)

exports('isActive', function()
    return _running and not _disabled
end)