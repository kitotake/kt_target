-- shared/validators.lua
local validators = {}

function validators.option(option)
    if type(option) ~= 'table' then
        return false, 'option must be a table'
    end

    if type(option.label) ~= 'string' or #option.label == 0 then
        return false, 'option.label must be a non-empty string'
    end

    local hasAction = option.onSelect
        or option.export
        or option.event
        or option.serverEvent
        or option.command
        or option.openMenu

    if not hasAction then
        return false, ('option "%s" has no action (onSelect/export/event/serverEvent/command/openMenu)'):format(
            option.name or option.label
        )
    end

    return true
end

function validators.zone(data)
    if type(data) ~= 'table' then
        return false, 'zone data must be a table'
    end

    if not data.options then
        return false, 'zone data must have an "options" field'
    end

    return true
end

function validators.resource(resource)
    return type(resource) == 'string' and #resource > 0
end

return validators