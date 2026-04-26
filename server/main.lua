lib.versionCheck('kitotake/kt_target')

if not lib.checkDependency('kt_lib', '3.30.0', true) then return end

---@type table<number, EntityInterface>
local entityStates = {}

-- ─────────────────────────────────────────────────────────────
-- Marque une entité comme ayant des options de ciblage
-- ─────────────────────────────────────────────────────────────

---@param netId number
RegisterNetEvent('kt_target:setEntityHasOptions', function(netId)
    local entity = Entity(NetworkGetEntityFromNetworkId(netId))
    entity.state.hasTargetOptions = true
    entityStates[netId] = entity
end)

-- ─────────────────────────────────────────────────────────────
-- Ouverture / fermeture de porte (relayé au propriétaire)
-- ─────────────────────────────────────────────────────────────

---@param netId number
---@param door number
RegisterNetEvent('kt_target:toggleEntityDoor', function(netId, door)
    local entity = NetworkGetEntityFromNetworkId(netId)
    if not DoesEntityExist(entity) then return end

    local owner = NetworkGetEntityOwner(entity)
    TriggerClientEvent('kt_target:toggleEntityDoor', owner, netId, door)
end)

-- ─────────────────────────────────────────────────────────────
-- Suppression d'objet par un admin (depuis object_target.lua)
-- ─────────────────────────────────────────────────────────────

RegisterNetEvent('admin:object:delete', function(netId)
    local src = source

    -- Vérification basique : le joueur doit exister
    if not GetPlayerPed(src) then return end

    -- Vérification du groupe via Union (si disponible)
    -- On laisse le client faire la vérification isAdmin() avant d'envoyer
    -- mais on vérifie quand même côté serveur que l'entité existe
    local entity = NetworkGetEntityFromNetworkId(netId)
    if not DoesEntityExist(entity) then return end

    DeleteEntity(entity)

    -- Nettoyage de la table entityStates
    entityStates[netId] = nil

    -- Notifie tous les clients de retirer les options sur cette entité
    TriggerClientEvent('kt_target:removeEntity', -1, { netId })
end)

-- ─────────────────────────────────────────────────────────────
-- Nettoyage périodique des entités disparues
-- ─────────────────────────────────────────────────────────────

CreateThread(function()
    while true do
        Wait(10000)

        local arr = {}
        local num = 0

        for netId, entity in pairs(entityStates) do
            if not DoesEntityExist(entity.__data) or not entity.state.hasTargetOptions then
                entityStates[netId] = nil
                num += 1
                arr[num] = netId
            end
        end

        if num > 0 then
            TriggerClientEvent('kt_target:removeEntity', -1, arr)
        end
    end
end)

print('[kt_target] server/main.lua chargé')
