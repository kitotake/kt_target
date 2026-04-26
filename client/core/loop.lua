-- client/core/loop.lua
-- Boucle principale du système de ciblage.
-- Orchestre : raycast → detection → resolver → state → nui.
-- NOTE : la logique principale est dans client/main.lua.
-- Ce module expose des helpers pour contrôler la boucle depuis l'extérieur.

local loop = {}

local _running = false

---@return boolean
function loop.isRunning()
    return _running
end

---@param value boolean
function loop.setRunning(value)
    _running = value
end

return loop