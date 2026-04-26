-- client/core/detection.lua
-- Filtre les entités candidates détectées par le raycast.
-- Détermine si une entité est valide pour le ciblage.

local detection = {}

local GetEntityType        = GetEntityType
local GetEntityModel       = GetEntityModel
local DoesEntityExist      = DoesEntityExist
local IsEntityDead         = IsEntityDead
local NetworkGetEntityIsNetworked = NetworkGetEntityIsNetworked

-- Types d'entités valides
local VALID_TYPES = { [1] = true, [2] = true, [3] = true }

---Vérifie si une entité est une cible valide.
---@param entity number
---@return boolean
function detection.isValid(entity)
    if not entity or entity == 0 then return false end
    if not DoesEntityExist(entity) then return false end

    local etype = GetEntityType(entity)
    if not VALID_TYPES[etype] then return false end

    return true
end

---Retourne le type d'entité de manière sécurisée.
---@param entity number
---@return number type (1=ped, 2=vehicle, 3=object, 0=inconnu)
function detection.getType(entity)
    if not entity or entity == 0 then return 0 end
    local ok, result = pcall(GetEntityType, entity)
    return ok and result or 0
end

---Retourne le modèle de manière sécurisée.
---@param entity number
---@return number|false
function detection.getModel(entity)
    if not entity or entity == 0 then return false end
    local ok, result = pcall(GetEntityModel, entity)
    return ok and result or false
end

---Vérifie si l'entité est en réseau.
---@param entity number
---@return boolean
function detection.isNetworked(entity)
    return NetworkGetEntityIsNetworked(entity) == true
end

return detection