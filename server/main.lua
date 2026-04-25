lib.versionCheck('kitotake/kt_target')

if not lib.checkDependency('kt_lib', '3.30.0', true) then return end

---@type table<number, EntityInterface>
local entityStates = {}

---@param netId number
RegisterNetEvent('kt_target:setEntityHasOptions', function(netId)
    local entity = Entity(NetworkGetEntityFromNetworkId(netId))
    entity.state.hasTargetOptions = true
    entityStates[netId] = entity
end)

---@param netId number
---@param door number
RegisterNetEvent('kt_target:toggleEntityDoor', function(netId, door)
    local entity = NetworkGetEntityFromNetworkId(netId)
    if not DoesEntityExist(entity) then return end

    local owner = NetworkGetEntityOwner(entity)
    TriggerClientEvent('kt_target:toggleEntityDoor', owner, netId, door)
end)

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

print('[kt_target] Chargement du module server/main.lua terminé')