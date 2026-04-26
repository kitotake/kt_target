-- client/registry/init.lua
-- Registre central : stocke toutes les options de ciblage.
-- Expose l'API publique (addEntity, addModel, addGlobalPed, etc.)
-- Retourné par client/api.lua via require 'client.registry'

local validators = require 'shared.validators'
local utils      = require 'client.utils'

-- ─── Stores ──────────────────────────────────────────────────────────────────

---@type table<number, KtTargetOption[]>   netId  → options
local entities    = {}
---@type table<number, KtTargetOption[]>   handle → options (entités locales)
local localEntities = {}
---@type table<number, KtTargetOption[]>   modelHash → options
local models      = {}
---@type KtTargetOption[]
local peds        = {}
---@type KtTargetOption[]
local vehicles    = {}
---@type KtTargetOption[]
local objects     = {}
---@type KtTargetOption[]
local players     = {}
---@type KtTargetOption[]
local globalOpts  = {}

-- ─── Helpers ─────────────────────────────────────────────────────────────────

local function currentResource()
    return GetCurrentResourceName()
end

---Normalise les options : accepte table ou tableau de tables.
---Injecte `resource` automatiquement.
---@param raw KtTargetOption | KtTargetOption[]
---@return KtTargetOption[]
local function normalise(raw)
    local list = (type(raw[1]) == 'table') and raw or { raw }
    local res  = currentResource()
    for _, opt in ipairs(list) do
        opt.resource = opt.resource or res
    end
    return list
end

---Valide chaque option et affiche un warning si invalide.
---@param list KtTargetOption[]
---@return KtTargetOption[]
local function validateAll(list)
    local valid = {}
    for _, opt in ipairs(list) do
        local ok, reason = validators.option(opt)
        if ok then
            valid[#valid + 1] = opt
        else
            warn(('[kt_target:registry] Option "%s" ignorée : %s'):format(
                opt.name or opt.label or '?', reason))
        end
    end
    return valid
end

---Supprime les options d'un tableau selon leur `name` ou leur `label`.
---@param store KtTargetOption[]
---@param filter string|string[]|nil
local function removeFromStore(store, filter)
    if not filter then
        -- Supprime tout ce qui vient de la resource courante
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

-- ─── API publique ─────────────────────────────────────────────────────────────

local api = {}

-- ── Zones ─────────────────────────────────────────────────────────────────────

---@param data KtTargetPolyZone
---@return number id
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

---@param data KtTargetBoxZone
---@return number id
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

---@param data KtTargetSphereZone
---@return number id
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

---@param id number
---@param suppress? boolean
function api.removeZone(id, suppress)
    local zone = lib.zones.getZone(id)
    if zone then
        zone:remove()
    elseif not suppress then
        warn(('[kt_target] removeZone : zone id=%d introuvable'):format(id))
    end
end

---@param id number
---@return boolean
function api.zoneExists(id)
    return lib.zones.getZone(id) ~= nil
end

-- ── Entités réseau ────────────────────────────────────────────────────────────

---@param arr number|number[]
---@param options KtTargetOption|KtTargetOption[]
function api.addEntity(arr, options)
    local list = utils.toArray(arr)
    local opts = validateAll(normalise(options))
    for _, netId in ipairs(list) do
        if not entities[netId] then entities[netId] = {} end
        for _, opt in ipairs(opts) do
            entities[netId][#entities[netId] + 1] = opt
        end
        -- Notifier le serveur pour le state bag
        TriggerServerEvent('kt_target:setEntityHasOptions', netId)
    end
end

---@param arr number|number[]
---@param filter? string|string[]
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

-- ── Entités locales ───────────────────────────────────────────────────────────

---@param arr number|number[]
---@param options KtTargetOption|KtTargetOption[]
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

---@param arr number|number[]
---@param filter? string|string[]
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

-- ── Modèles ───────────────────────────────────────────────────────────────────

---@param arr number|string|(number|string)[]
---@param options KtTargetOption|KtTargetOption[]
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

---@param arr number|string|(number|string)[]
---@param filter? string|string[]
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

-- ── Globaux ───────────────────────────────────────────────────────────────────

local function addToStore(store, raw)
    local opts = validateAll(normalise(raw))
    for _, opt in ipairs(opts) do
        store[#store + 1] = opt
    end
end

function api.addGlobalPed(options)     addToStore(peds, options)    end
function api.addGlobalVehicle(options) addToStore(vehicles, options) end
function api.addGlobalObject(options)  addToStore(objects, options)  end
function api.addGlobalPlayer(options)  addToStore(players, options)  end
function api.addGlobalOption(options)  addToStore(globalOpts, options) end

function api.removeGlobalPed(filter)     removeFromStore(peds, filter)     end
function api.removeGlobalVehicle(filter) removeFromStore(vehicles, filter) end
function api.removeGlobalObject(filter)  removeFromStore(objects, filter)  end
function api.removeGlobalPlayer(filter)  removeFromStore(players, filter)  end
function api.removeGlobalOption(filter)  removeFromStore(globalOpts, filter) end

-- ── Agrégation des options pour une entité ────────────────────────────────────

---Retourne toutes les options applicables à l'entité détectée.
---Résultat : table<string, KtTargetOption[]> (clé = nom de groupe)
---@param entity  number
---@param etype   number  (1=ped, 2=vehicle, 3=object)
---@param emodel  number|false
---@return table<string, KtTargetOption[]>
function api.getTargetOptions(entity, etype, emodel)
    local result = {}

    local function merge(key, store)
        if store and #store > 0 then
            if not result[key] then result[key] = {} end
            for _, opt in ipairs(store) do
                result[key][#result[key] + 1] = opt
            end
        end
    end

    -- Globaux (toutes entités)
    merge('__global', globalOpts)

    -- Par type d'entité
    if etype == ENTITY_TYPE_PED then
        local isPlyPed = entity == GetPlayerPed(-1) or
                         (NetworkGetEntityIsNetworked(entity) and
                          GetPlayerFromServerId(NetworkGetNetworkIdFromEntity(entity)) ~= -1)
        if isPlyPed then
            merge('globalPlayer', players)
        else
            merge('globalPed', peds)
        end
    elseif etype == ENTITY_TYPE_VEHICLE then
        merge('globalVehicle', vehicles)
    elseif etype == ENTITY_TYPE_OBJECT then
        merge('globalObject', objects)
    end

    -- Par modèle
    if emodel and models[emodel] then
        merge('model_' .. emodel, models[emodel])
    end

    -- Par netId
    if NetworkGetEntityIsNetworked(entity) then
        local netId = NetworkGetNetworkIdFromEntity(entity)
        if entities[netId] then
            merge('entity_' .. netId, entities[netId])
        end
    end

    -- Entité locale
    if localEntities[entity] then
        merge('local_' .. entity, localEntities[entity])
    end

    return result
end

-- ── Contrôle ─────────────────────────────────────────────────────────────────

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

-- ── Nettoyage à l'arrêt de la resource ───────────────────────────────────────

AddEventHandler('onClientResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        api.clearAll()
        return
    end
    -- Nettoie les options enregistrées par une resource tierce qui s'arrête
    local function cleanStore(store)
        for i = #store, 1, -1 do
            if store[i].resource == resourceName then
                table.remove(store, i)
            end
        end
    end
    cleanStore(peds)
    cleanStore(vehicles)
    cleanStore(objects)
    cleanStore(players)
    cleanStore(globalOpts)
    for _, store in pairs(entities) do cleanStore(store) end
    for _, store in pairs(localEntities) do cleanStore(store) end
    for _, store in pairs(models) do cleanStore(store) end
end)

-- ── Réception des suppressions serveur ───────────────────────────────────────

RegisterNetEvent('kt_target:removeEntity', function(netIds)
    for _, netId in ipairs(netIds) do
        entities[netId] = nil
    end
end)

return api