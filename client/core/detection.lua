-- client/core/detection.lua
local detection = {}

local GetEntityType        = GetEntityType
local GetEntityModel       = GetEntityModel
local DoesEntityExist      = DoesEntityExist
local NetworkGetEntityIsNetworked = NetworkGetEntityIsNetworked

local VALID_TYPES = { [1] = true, [2] = true, [3] = true }

function detection.isValid(entity)
    if not entity or entity == 0 then return false end
    if not DoesEntityExist(entity) then return false end
    local etype = GetEntityType(entity)
    if not VALID_TYPES[etype] then return false end
    return true
end

function detection.getType(entity)
    if not entity or entity == 0 then return 0 end
    local ok, result = pcall(GetEntityType, entity)
    return ok and result or 0
end

function detection.getModel(entity)
    if not entity or entity == 0 then return false end
    local ok, result = pcall(GetEntityModel, entity)
    return ok and result or false
end

function detection.isNetworked(entity)
    return NetworkGetEntityIsNetworked(entity) == true
end

return detection