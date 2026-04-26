-- client/core/raycast.lua
-- Couche d'abstraction bas niveau pour les raycasts caméra.
-- Utilisé par loop.lua pour détecter les entités ciblées.

local raycast = {}

local GetWorldCoordFromScreenCoord = GetWorldCoordFromScreenCoord
local StartShapeTestLosProbe       = StartShapeTestLosProbe
local GetShapeTestResult           = GetShapeTestResult

---@param flag number       Flags de collision (511 = tout, 26 = map uniquement)
---@param ignore number     Entité à ignorer (cache.ped)
---@param distance number   Distance max du raycast
---@return boolean hit
---@return number entityHit
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

    repeat
        Wait(0)
        retval, hit, endCoords, _, entityHit = GetShapeTestResult(handle)
    until retval ~= 1

    if not hit or hit == 0 then
        endCoords = dest
        entityHit = 0
    end

    return hit == 1, entityHit, endCoords
end

---@param from vector3
---@param to   vector3
---@param flag number
---@param ignore number
---@return boolean hit
---@return number entityHit
---@return vector3 endCoords
function raycast.fromTo(from, to, flag, ignore)
    local handle = StartShapeTestLosProbe(
        from.x, from.y, from.z,
        to.x,   to.y,   to.z,
        flag, ignore, 4
    )

    local retval, hit, endCoords, _, entityHit

    repeat
        Wait(0)
        retval, hit, endCoords, _, entityHit = GetShapeTestResult(handle)
    until retval ~= 1

    if not hit or hit == 0 then
        endCoords = to
        entityHit = 0
    end

    return hit == 1, entityHit, endCoords
end

return raycast