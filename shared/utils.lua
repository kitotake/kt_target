-- shared/utils.lua
local utils = {}

function utils.isString(v)
    return type(v) == 'string' and #v > 0
end

function utils.isPositiveNumber(v)
    return type(v) == 'number' and v > 0
end

function utils.toArray(v)
    if type(v) ~= 'table' then return { v } end
    return v
end

function utils.count(t)
    local n = 0
    for _ in pairs(t) do n = n + 1 end
    return n
end

return utils