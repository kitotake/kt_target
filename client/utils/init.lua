-- client/utils/init.lua
-- Point d'entrée des utilitaires client.
-- Retourné par client/utils.lua via require 'client.utils'
--
-- Contient aussi les stubs hasPlayerGotGroup / hasPlayerGotItem
-- que les adapteurs framework viendront surcharger.

local entity_utils = require 'client.utils.entity'
local math_utils   = require 'client.utils.math'
local table_utils  = require 'client.utils.table'

-- ─── Shared utils (réexportés depuis shared/) ─────────────────────────────────
local shared_utils = require 'shared.utils'

-- ─── Items (inventaire) ───────────────────────────────────────────────────────
-- Table locale, peuplée par les adapteurs framework.
local _items = {}

---Retourne la référence interne à la table d'items.
---Utilisé par les adapteurs pour la remplir.
---@return table
local function getItems()
    return _items
end

-- ─── API publique ─────────────────────────────────────────────────────────────

local utils = {}

-- Ré-exporte entity / math / table
utils.getCoords   = entity_utils.getCoords
utils.getNetId    = entity_utils.getNetId
utils.describe    = entity_utils.describe
utils.dist2D      = math_utils.dist2D
utils.dist3D      = math_utils.dist3D
utils.clamp       = math_utils.clamp
utils.lerp        = math_utils.lerp
utils.shallowCopy = table_utils.shallowCopy
utils.isEmpty     = table_utils.isEmpty
utils.find        = table_utils.find
utils.unique      = table_utils.unique
utils.filter      = table_utils.filter

-- Ré-exporte shared utils
utils.isString        = shared_utils.isString
utils.isPositiveNumber = shared_utils.isPositiveNumber
utils.toArray         = shared_utils.toArray
utils.count           = shared_utils.count

-- Items
utils.getItems = getItems

-- ─── Vérification export (pour compat) ───────────────────────────────────────

---Vérifie si un export est disponible sur une resource.
---@param exportPath string  "resource.exportName"
---@return boolean
function utils.hasExport(exportPath)
    local sep  = exportPath:find('%.')
    if not sep then return false end
    local res  = exportPath:sub(1, sep - 1)
    local name = exportPath:sub(sep + 1)
    local ok   = pcall(function()
        local _ = exports[res][name]
    end)
    return ok
end

-- ─── Stubs framework (surchargés par les adapteurs) ──────────────────────────

---Vérifie si le joueur possède le groupe / job requis.
---Surcharge par client/framework/*.lua au chargement.
---@param filter string|string[]|table<string,number>|nil
---@return boolean
function utils.hasPlayerGotGroup(filter)
    -- Stub par défaut : pas de framework chargé → toujours autorisé.
    -- Les adapteurs (esx.lua, union.lua, …) surchargent cette fonction.
    return true
end

---Vérifie si le joueur possède l'item requis.
---Surcharge par client/framework/*.lua au chargement.
---@param filter string|string[]|table<string,number>|nil
---@param anyItem? boolean
---@return boolean
function utils.hasPlayerGotItem(filter, anyItem)
    if not filter then return true end

    local _type = type(filter)

    if _type == 'string' then
        return (_items[filter] or 0) > 0

    elseif _type == 'table' then
        local tabletype = table.type(filter)

        if tabletype == 'hash' then
            -- { itemName = minCount }
            for itemName, minCount in pairs(filter) do
                local count = _items[itemName] or 0
                if anyItem then
                    if count >= minCount then return true end
                else
                    if count < minCount then return false end
                end
            end
            return not anyItem

        elseif tabletype == 'array' then
            -- { 'item1', 'item2' }
            for _, itemName in ipairs(filter) do
                local has = (_items[itemName] or 0) > 0
                if anyItem then
                    if has then return true end
                else
                    if not has then return false end
                end
            end
            return not anyItem
        end
    end

    return false
end

return utils