-- shared/utils.lua
-- Utilitaires légers partagés entre client et serveur.

local utils = {}

---Retourne true si la valeur est une string non vide.
---@param v any
---@return boolean
function utils.isString(v)
    return type(v) == 'string' and #v > 0
end

---Retourne true si la valeur est un nombre positif.
---@param v any
---@return boolean
function utils.isPositiveNumber(v)
    return type(v) == 'number' and v > 0
end

---Convertit une valeur scalaire ou un tableau en tableau.
---@param v any
---@return table
function utils.toArray(v)
    if type(v) ~= 'table' then return { v } end
    return v
end

---Retourne le nombre d'éléments d'une table (paires + indices).
---@param t table
---@return number
function utils.count(t)
    local n = 0
    for _ in pairs(t) do n = n + 1 end
    return n
end

return utils