-- client/debug/init.lua
-- Utilitaires de débogage avancés (outline, logs, overlays).
-- Chargé uniquement si kt_target:debug == 1.

if GetConvarInt('kt_target:debug', 0) ~= 1 then return end

local debug = {}

---Dessine un outline sur une entité.
---@param entity number
---@param enabled boolean
function debug.outline(entity, enabled)
    if DoesEntityExist(entity) then
        SetEntityDrawOutline(entity, enabled)
    end
end

---Log une entité ciblée avec ses métadonnées.
---@param entity number
---@param entityType number
---@param model number|false
function debug.logTarget(entity, entityType, model)
    local typeNames = { [1] = 'Ped', [2] = 'Vehicle', [3] = 'Object' }
    local typeName  = typeNames[entityType] or 'Unknown'

    print(('[kt_target:debug] Target → type=%s | model=%s | entity=%d'):format(
        typeName,
        model and GetEntityArchetypeName(entity) or 'N/A',
        entity
    ))
end

return debug