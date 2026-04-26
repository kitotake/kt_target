-- client/state/target.lua
-- État interne du système de ciblage : entité courante, coords, distance.
-- Utilisé pour construire la réponse passée aux callbacks onSelect/event.

local targetState = {}

local _current = {
    entity   = 0,
    coords   = nil,
    distance = 0,
    zone     = nil,
}

---@return table
function targetState.get()
    return _current
end

---@param entity   number
---@param coords   vector3
---@param distance number
function targetState.set(entity, coords, distance)
    _current.entity   = entity
    _current.coords   = coords
    _current.distance = distance
    _current.zone     = nil
end

---@param zoneId number?
function targetState.setZone(zoneId)
    _current.zone = zoneId
end

function targetState.reset()
    _current.entity   = 0
    _current.coords   = nil
    _current.distance = 0
    _current.zone     = nil
end

return targetState