-- client/core/executor.lua
local executor = {}

local function shallowClone(t)
    local copy = {}
    for k, v in pairs(t) do copy[k] = v end
    return copy
end

---@param option KtTargetOption
---@param response table
function executor.run(option, response)
    if option.onSelect then
        local ok, err = pcall(option.onSelect,
            option.qtarget and response.entity or response)
        if not ok then
            warn(('[kt_target] executor.run — onSelect error: %s'):format(err))
        end

    elseif option.export then
        local ok, err = pcall(function()
            exports[option.resource][option.export](nil, response)
        end)
        if not ok then
            warn(('[kt_target] executor.run — export error: %s'):format(err))
        end

    elseif option.event then
        TriggerEvent(option.event, response)

    elseif option.serverEvent then
        local serverResponse = shallowClone(response)
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