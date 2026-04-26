-- server/main.lua
lib.versionCheck('kitotake/kt_target')

if not lib.checkDependency('kt_lib', '3.30.0', true) then return end

---@type table<number, number>  netId → entity handle
local entityStates = {}

-- ─── Utilitaire : vérifie le groupe Union côté serveur ───────────────────────

local function isAdminPlayer(src)
    -- Adapter selon votre implémentation Union server-side
    -- Exemple avec un export Union côté serveur :
    local ok, player = pcall(function()
        return exports['union']:GetPlayer(src)
    end)
    if not ok or not player then return false end
    local group = player.group or 'user'
    return group == 'admin' or group == 'founder' or group == 'moderator'
end

-- ─── Marque une entité ────────────────────────────────────────────────────────

RegisterNetEvent('kt_target:setEntityHasOptions', function(netId)
    local src    = source
    local handle = NetworkGetEntityFromNetworkId(netId)
    if not DoesEntityExist(handle) then return end

    Entity(handle).state.hasTargetOptions = true
    entityStates[netId] = handle
end)

-- ─── Ouverture / fermeture de porte ──────────────────────────────────────────

RegisterNetEvent('kt_target:toggleEntityDoor', function(netId, door)
    if type(netId) ~= 'number' or type(door) ~= 'number' then return end
    if door < 0 or door > 5 then return end  -- validation

    local entity = NetworkGetEntityFromNetworkId(netId)
    if not DoesEntityExist(entity) then return end

    local owner = NetworkGetEntityOwner(entity)
    TriggerClientEvent('kt_target:toggleEntityDoor', owner, netId, door)
end)

-- ─── Suppression d'objet (admin) ─────────────────────────────────────────────

RegisterNetEvent('admin:object:delete', function(netId)
    local src = source
    if type(netId) ~= 'number' then return end

    -- ✅ Vérification côté serveur — jamais faire confiance au client
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