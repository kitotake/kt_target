-- client/core/executor.lua
-- Exécute l'action associée à une option sélectionnée.

local executor = {}

---@param option KtTargetOption
---@param response table   données enrichies (entity, coords, distance, zone…)
function executor.run(option, response)
    if option.onSelect then
        local ok, err = pcall(option.onSelect,
            option.qtarget and response.entity or response)
        if not ok then
            warn(('[kt_target] executor.run — onSelect error: %s'):format(err))
        end

    elseif option.export then
        local resource = option.resource
        local ok, err = pcall(function()
            exports[resource][option.export](nil, response)
        end)
        if not ok then
            warn(('[kt_target] executor.run — export error: %s'):format(err))
        end

    elseif option.event then
        TriggerEvent(option.event, response)

    elseif option.serverEvent then
        -- Convertit l'entity en netId pour le serveur
        local serverResponse = table.clone(response)
        serverResponse.entity = response.entity ~= 0
            and NetworkGetEntityIsNetworked(response.entity)
            and NetworkGetNetworkIdFromEntity(response.entity)
            or 0
        TriggerServerEvent(option.serverEvent, serverResponse)

    elseif option.command then
        ExecuteCommand(option.command)
    end
end

return executor