-- client/utils/table.lua
-- Utilitaires de manipulation de tables pour kt_target.

local tbl = {}

---Copie superficielle d'une table.
---@param t table
---@return table
function tbl.shallowCopy(t)
    local copy = {}
    for k, v in pairs(t) do
        copy[k] = v
    end
    return copy
end

---Vérifie si une table est vide.
---@param t table
---@return boolean
function tbl.isEmpty(t)
    return next(t) == nil
end

---Trouve un élément par prédicat.
---@param t    table
---@param pred function
---@return any|nil
function tbl.find(t, pred)
    for i = 1, #t do
        if pred(t[i]) then return t[i] end
    end
    return nil
end

---Supprime les doublons d'un tableau (comparison par valeur).
---@param t table
---@return table
function tbl.unique(t)
    local seen   = {}
    local result = {}

    for i = 1, #t do
        local v = t[i]
        if not seen[v] then
            seen[v] = true
            result[#result + 1] = v
        end
    end

    return result
end

---Filtre un tableau selon un prédicat.
---@param t    table
---@param pred function
---@return table
function tbl.filter(t, pred)
    local result = {}
    for i = 1, #t do
        if pred(t[i]) then
            result[#result + 1] = t[i]
        end
    end
    return result
end

return tbl