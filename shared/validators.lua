-- shared/validators.lua
-- Validateurs d'entrée pour les options et les zones.

local validators = {}

---Valide qu'une option possède les champs minimaux requis.
---@param option table
---@return boolean ok
---@return string? reason
function validators.option(option)
    if type(option) ~= 'table' then
        return false, 'option must be a table'
    end

    if type(option.label) ~= 'string' or #option.label == 0 then
        return false, 'option.label must be a non-empty string'
    end

    -- Au moins une action doit être définie
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

---Valide les données d'une zone.
---@param data table
---@return boolean ok
---@return string? reason
function validators.zone(data)
    if type(data) ~= 'table' then
        return false, 'zone data must be a table'
    end

    if not data.options then
        return false, 'zone data must have an "options" field'
    end

    return true
end

---Valide un identifiant de ressource FiveM.
---@param resource string
---@return boolean
function validators.resource(resource)
    return type(resource) == 'string' and #resource > 0
end

return validators