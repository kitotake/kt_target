-- client/registry/init.lua
-- Registre central : stocke toutes les options de ciblage.

local validators = require 'shared.validators'
local utils      = require 'client.utils'

-- ─── Stores ──────────────────────────────────────────────────────────────────

local entities      = {}
local localEntities = {}
local models        = {}
local peds          = {}
local vehicles      = {}
local objects       = {}
local players       = {}
local globalOpts    = {}

-- ─── Helpers ─────────────────────────────────────────────────────────────────

local function currentResource()
    return GetCurrentResourceName()
end

-- 🔥 FIX : normalise ULTRA SAFE
local function normalise(raw)
    local list = {}

    if type(raw) ~= "table" then
        return {}
    end

    for _, v in pairs(raw) do
        if type(v) == "table" then
            list[#list + 1] = v
        end
    end

    local res = currentResource()

    for _, opt in ipairs(list) do
        opt.resource = opt.resource or res
    end

    return list
end

-- 🔥 FIX : validation stricte (PLUS DE "?")
local function validateAll(list)
    local valid = {}

    for i, opt in ipairs(list) do
        local ok, reason = validators.option(opt)

        local labelOk = type(opt.label) == "string" and opt.label ~= ""

        if ok and labelOk then
            valid[#valid + 1] = opt
        else
            warn(('[kt_target:registry] Option ignorée index=%s reason=%s'):format(
                tostring(i),
                reason or "invalid option"
            ))
        end
    end

    return valid
end

-- 🔥 FIX : suppression safe
local function removeFromStore(store, filter)
    if not filter then
        local res = currentResource()
        for i = #store, 1, -1 do
            if store[i].resource == res then
                table.remove(store, i)
            end
        end
        return
    end

    local set = {}
    if type(filter) == 'string' then
        set[filter] = true
    else
        for _, v in ipairs(filter) do set[v] = true end
    end

    for i = #store, 1, -1 do
        local opt = store[i]
        if set[opt.name] or set[opt.label] then
            table.remove(store, i)
        end
    end
end

-- ─── SAFE NET ID ─────────────────────────────────────────────────────────────

local function safeGetNetId(entity)
    if not entity or entity == 0 then return nil end
    if not DoesEntityExist(entity) then return nil end
    if not NetworkGetEntityIsNetworked(entity) then return nil end
    return NetworkGetNetworkIdFromEntity(entity)
end

-- ─── API ─────────────────────────────────────────────────────────────────────

local api = {}

-- ── Zones ────────────────────────────────────────────────────────────────────

function api.addPolyZone(data)
    data.resource = data.resource or currentResource()

    local opts = normalise(data.options)
    data.options = validateAll(opts)

    return lib.zones.poly({
        points    = data.points,
        thickness = data.thickness or 4.0,
        name      = data.name,
        debug     = data.debug,
        onEnter   = function(self) self.options = data.options end,
        onExit    = function(self) self.options = nil end,
    }).id
end

function api.addBoxZone(data)
    data.resource = data.resource or currentResource()

    local opts = normalise(data.options)
    data.options = validateAll(opts)

    return lib.zones.box({
        coords   = data.coords,
        size     = data.size,
        rotation = data.rotation or 0,
        name     = data.name,
        debug    = data.debug,
        onEnter  = function(self) self.options = data.options end,
        onExit   = function(self) self.options = nil end,
    }).id
end

function api.addSphereZone(data)
    data.resource = data.resource or currentResource()

    local opts = normalise(data.options)
    data.options = validateAll(opts)

    return lib.zones.sphere({
        coords  = data.coords,
        radius  = data.radius or 1.0,
        name    = data.name,
        debug   = data.debug,
        onEnter = function(self) self.options = data.options end,
        onExit  = function(self) self.options = nil end,
    }).id
end

function api.removeZone(id, suppress)
    local zone = lib.zones.getZone(id)
    if zone then
        zone:remove()
    elseif not suppress then
        warn(('[kt_target] removeZone id=%d introuvable'):format(id))
    end
end

function api.zoneExists(id)
    return lib.zones.getZone(id) ~= nil
end

-- ── ENTITIES ────────────────────────────────────────────────────────────────

function api.addEntity(arr, options)
    local list = utils.toArray(arr)
    local opts = validateAll(normalise(options))

    for _, netId in ipairs(list) do
        if not entities[netId] then entities[netId] = {} end

        for _, opt in ipairs(opts) do
            entities[netId][#entities[netId] + 1] = opt
        end

        TriggerServerEvent('kt_target:setEntityHasOptions', netId)
    end
end

function api.removeEntity(arr, filter)
    local list = utils.toArray(arr)

    for _, netId in ipairs(list) do
        if entities[netId] then
            if not filter then
                entities[netId] = nil
            else
                removeFromStore(entities[netId], filter)
                if #entities[netId] == 0 then entities[netId] = nil end
            end
        end
    end
end

-- ── LOCAL ENTITIES ───────────────────────────────────────────────────────────

function api.addLocalEntity(arr, options)
    local list = utils.toArray(arr)
    local opts = validateAll(normalise(options))

    for _, handle in ipairs(list) do
        if not localEntities[handle] then localEntities[handle] = {} end

        for _, opt in ipairs(opts) do
            localEntities[handle][#localEntities[handle] + 1] = opt
        end
    end
end

function api.removeLocalEntity(arr, filter)
    local list = utils.toArray(arr)

    for _, handle in ipairs(list) do
        if localEntities[handle] then
            if not filter then
                localEntities[handle] = nil
            else
                removeFromStore(localEntities[handle], filter)
                if #localEntities[handle] == 0 then localEntities[handle] = nil end
            end
        end
    end
end

-- ── MODELS ──────────────────────────────────────────────────────────────────

function api.addModel(arr, options)
    local list = utils.toArray(arr)
    local opts = validateAll(normalise(options))

    for _, model in ipairs(list) do
        local hash = type(model) == 'string' and joaat(model) or model

        if not models[hash] then models[hash] = {} end

        for _, opt in ipairs(opts) do
            models[hash][#models[hash] + 1] = opt
        end
    end
end

function api.removeModel(arr, filter)
    local list = utils.toArray(arr)

    for _, model in ipairs(list) do
        local hash = type(model) == 'string' and joaat(model) or model

        if models[hash] then
            if not filter then
                models[hash] = nil
            else
                removeFromStore(models[hash], filter)
                if #models[hash] == 0 then models[hash] = nil end
            end
        end
    end
end

-- ── GLOBALS ────────────────────────────────────────────────────────────────

local function addToStore(store, raw)
    local opts = validateAll(normalise(raw))

    for _, opt in ipairs(opts) do
        store[#store + 1] = opt
    end
end

function api.addGlobalPed(options)     addToStore(peds, options) end
function api.addGlobalVehicle(options) addToStore(vehicles, options) end
function api.addGlobalObject(options)  addToStore(objects, options) end
function api.addGlobalPlayer(options)  addToStore(players, options) end
function api.addGlobalOption(options)  addToStore(globalOpts, options) end

function api.removeGlobalPed(filter)     removeFromStore(peds, filter) end
function api.removeGlobalVehicle(filter) removeFromStore(vehicles, filter) end
function api.removeGlobalObject(filter)  removeFromStore(objects, filter) end
function api.removeGlobalPlayer(filter)  removeFromStore(players, filter) end
function api.removeGlobalOption(filter)  removeFromStore(globalOpts, filter) end

-- ── GET OPTIONS ─────────────────────────────────────────────────────────────

function api.getTargetOptions(entity, etype, emodel)
    local result = {}

    local function merge(key, store)
        if store and #store > 0 then
            result[key] = result[key] or {}

            for _, opt in ipairs(store) do
                result[key][#result[key] + 1] = opt
            end
        end
    end

    merge('__global', globalOpts)

    if etype == ENTITY_TYPE_PED then
        merge('globalPlayer', players)
        merge('globalPed', peds)

    elseif etype == ENTITY_TYPE_VEHICLE then
        merge('globalVehicle', vehicles)

    elseif etype == ENTITY_TYPE_OBJECT then
        merge('globalObject', objects)
    end

    if emodel and models[emodel] then
        merge('model_' .. emodel, models[emodel])
    end

    local netId = safeGetNetId(entity)
    if netId and entities[netId] then
        merge('entity_' .. netId, entities[netId])
    end

    if localEntities[entity] then
        merge('local_' .. entity, localEntities[entity])
    end

    return result
end

-- ── CLEAR ───────────────────────────────────────────────────────────────────

function api.clearAll()
    entities      = {}
    localEntities = {}
    models        = {}
    peds          = {}
    vehicles      = {}
    objects       = {}
    players       = {}
    globalOpts    = {}
end

return api