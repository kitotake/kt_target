-- client/utils/math.lua
-- Utilitaires mathématiques pour kt_target.

local math_utils = {}

---Calcule la distance 2D entre deux vecteurs (ignore Z).
---@param a vector3
---@param b vector3
---@return number
function math_utils.dist2D(a, b)
    local dx = a.x - b.x
    local dy = a.y - b.y
    return math.sqrt(dx * dx + dy * dy)
end

---Calcule la distance 3D entre deux vecteurs.
---@param a vector3
---@param b vector3
---@return number
function math_utils.dist3D(a, b)
    return #(a - b)
end

---Clamp une valeur entre min et max.
---@param value number
---@param min   number
---@param max   number
---@return number
function math_utils.clamp(value, min, max)
    if value < min then return min end
    if value > max then return max end
    return value
end

---Interpolation linéaire.
---@param a number
---@param b number
---@param t number  (0.0 → 1.0)
---@return number
function math_utils.lerp(a, b, t)
    return a + (b - a) * math_utils.clamp(t, 0.0, 1.0)
end

return math_utils