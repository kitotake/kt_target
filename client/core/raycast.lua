-- client/core/raycast.lua
local raycast = {}

local GetWorldCoordFromScreenCoord = GetWorldCoordFromScreenCoord
local StartShapeTestLosProbe       = StartShapeTestLosProbe
local GetShapeTestResult           = GetShapeTestResult

---Lance un raycast et attend le résultat (max 10 frames).
---@param flag    number
---@param ignore  number
---@param distance number
---@return boolean hit
---@return number  entityHit
---@return vector3 endCoords
function raycast.fromCamera(flag, ignore, distance)
    local coords, dir = GetWorldCoordFromScreenCoord(0.5, 0.5)
    local dest = coords + dir * distance

    local handle = StartShapeTestLosProbe(
        coords.x, coords.y, coords.z,
        dest.x,   dest.y,   dest.z,
        flag, ignore, 4
    )

    local retval, hit, endCoords, _, entityHit
    local attempts = 0

    repeat
        Wait(0)
        retval, hit, endCoords, _, entityHit = GetShapeTestResult(handle)
        attempts = attempts + 1
    until retval ~= 1 or attempts > 10

    if retval ~= 2 then
        return false, 0, dest
    end

    if not hit or hit == 0 then
        return false, 0, dest
    end

    return true, entityHit, endCoords
end

---@param from   vector3
---@param to     vector3
---@param flag   number
---@param ignore number
---@return boolean hit
---@return number  entityHit
---@return vector3 endCoords
function raycast.fromTo(from, to, flag, ignore)
    local handle = StartShapeTestLosProbe(
        from.x, from.y, from.z,
        to.x,   to.y,   to.z,
        flag, ignore, 4
    )

    local retval, hit, endCoords, _, entityHit
    local attempts = 0

    repeat
        Wait(0)
        retval, hit, endCoords, _, entityHit = GetShapeTestResult(handle)
        attempts = attempts + 1
    until retval ~= 1 or attempts > 10

    if retval ~= 2 then
        return false, 0, to
    end

    if not hit or hit == 0 then
        return false, 0, to
    end

    return true, entityHit, endCoords
end

return raycast