-- client/core/resolver.lua
-- Agrège et trie les options de ciblage selon la priorité.
-- Filtre les options cachées et calcule lesquelles sont visibles.

local resolver = {}

---Compte les options visibles dans une liste.
---@param options KtTargetOption[]
---@return number
function resolver.countVisible(options)
    local n = 0
    for i = 1, #options do
        if not options[i].hide then
            n = n + 1
        end
    end
    return n
end

---Vérifie si une liste d'options a changé de visibilité depuis le dernier frame.
---@param options KtTargetOption[]
---@param dist    number
---@param endCoords vector3
---@param shouldHideFn function
---@param entityHit? number
---@param entityType? number
---@param entityModel? number|false
---@return boolean changed
function resolver.updateVisibility(options, dist, endCoords, shouldHideFn,
                                    entityHit, entityType, entityModel)
    local changed = false

    for i = 1, #options do
        local opt = options[i]
        local hide = shouldHideFn(opt, dist, endCoords, entityHit, entityType, entityModel)

        if opt.hide ~= hide then
            opt.hide = hide
            changed = true
        end
    end

    return changed
end

return resolver