-- server/main.lua
lib.versionCheck('kitotake/kt_target')

if not lib.checkDependency('kt_lib', '3.30.0', true) then return end

---@type table<number, number>  netId → entity handle
local entityStates = {}

-- ─── Utilitaire : vérifie le groupe Union côté serveur ───────────────────────

-- FIX: Guard complet si union n'est pas chargé (pcall sur l'export ET sur
-- l'accès au champ group).
local function isAdminPlayer(src)
    local ok, player = pcall(function()
        return exports['union']:GetPlayer(src)
    end)

    if not ok or not player then
        -- union absent ou le joueur n'existe pas → accès refusé par défaut
        return false
    end

    local groupOk, group = pcall(function()
        return player.group
    end)

    if not groupOk then return false end

    group = group or 'user'
    return group == 'admin' or group == 'founder' or group == 'moderator'
end

-- ─── Marque une entité ────────────────────────────────────────────────────────

RegisterNetEvent('kt_target:setEntityHasOptions', function(netId)
    -- FIX: Validation du type du netId pour éviter les injections
    if type(netId) ~= 'number' then return end

    local handle = NetworkGetEntityFromNetworkId(netId)
    if not DoesEntityExist(handle) then return end

    Entity(handle).state.hasTargetOptions = true
    entityStates[netId] = handle
end)

-- ─── Ouverture / fermeture de porte ──────────────────────────────────────────

RegisterNetEvent('kt_target:toggleEntityDoor', function(netId, door)
    if type(netId) ~= 'number' or type(door) ~= 'number' then return end
    if door < 0 or door > 5 then return end

    local entity = NetworkGetEntityFromNetworkId(netId)
    if not DoesEntityExist(entity) then return end

    local owner = NetworkGetEntityOwner(entity)
    TriggerClientEvent('kt_target:toggleEntityDoor', owner, netId, door)
end)

-- ─── Suppression d'objet (admin) ─────────────────────────────────────────────

RegisterNetEvent('admin:object:delete', function(netId)
    local src = source
    if type(netId) ~= 'number' then return end

    if not isAdminPlayer(src) then
        warn(('[kt_target] admin:object:delete — accès refusé pour le joueur %d'):format(src))
        return
    end

    local entity = NetworkGetEntityFromNetworkId(netId)
    if not DoesEntityExist(entity) then return end

    DeleteEntity(entity)
    entityStates[netId] = nil
    TriggerClientEvent('kt_target:removeEntity', -1, { netId })
end)

-- ─── Nettoyage périodique ─────────────────────────────────────────────────────

CreateThread(function()
    while true do
        Wait(10000)

        local toRemove = {}

        for netId, handle in pairs(entityStates) do
            if not DoesEntityExist(handle) then
                entityStates[netId] = nil
                toRemove[#toRemove + 1] = netId
            end
        end

        if #toRemove > 0 then
            TriggerClientEvent('kt_target:removeEntity', -1, toRemove)
        end
    end
end)

print('[kt_target] server/main.lua chargé')