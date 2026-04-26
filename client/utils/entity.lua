-- client/utils/entity.lua
-- Utilitaires liés aux entités GTA V.

local entity = {}

local GetEntityCoords       = GetEntityCoords
local GetEntityHeading      = GetEntityHeading
local GetEntityModel        = GetEntityModel
local GetEntityType         = GetEntityType
local GetEntityArchetypeName = GetEntityArchetypeName
local NetworkGetEntityIsNetworked    = NetworkGetEntityIsNetworked
local NetworkGetNetworkIdFromEntity  = NetworkGetNetworkIdFromEntity

---Retourne les coords d'une entité de manière sécurisée.
---@param entity number
---@return vector3|nil
function entity.getCoords(entity)
    if not DoesEntityExist(entity) then return nil end
    return GetEntityCoords(entity)
end

---Retourne le netId d'une entité réseau, ou nil.
---@param ent number
---@return number|nil
function entity.getNetId(ent)
    if NetworkGetEntityIsNetworked(ent) then
        return NetworkGetNetworkIdFromEntity(ent)
    end
    return nil
end

---Construit une table de debug pour une entité.
---@param ent number
---@return table
function entity.describe(ent)
    if not DoesEntityExist(ent) then
        return { exists = false }
    end

    return {
        exists   = true,
        type     = GetEntityType(ent),
        model    = GetEntityModel(ent),
        archetype = GetEntityArchetypeName(ent),
        coords   = GetEntityCoords(ent),
        heading  = GetEntityHeading(ent),
        networked = NetworkGetEntityIsNetworked(ent),
        netId    = NetworkGetEntityIsNetworked(ent)
                    and NetworkGetNetworkIdFromEntity(ent)
                    or nil,
    }
end

return entity