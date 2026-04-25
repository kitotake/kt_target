-- client/framework/union.lua
-- Intégration Union Framework dans kt_target


local utils = require 'client.utils'

-- Cache local du personnage actif
local playerJob   = 'unemployed'
local playerGrade = 0
local playerGroup = 'user'  -- admin, moderator, founder, user

-- ─────────────────────────────────────────────────────────────
-- Initialisation au chargement (si le joueur est déjà spawné)
-- ─────────────────────────────────────────────────────────────
local function refreshFromCharacter()
    local ok, char = pcall(function()
        return exports['union']:GetCurrentCharacter()
    end)

    if not ok or not char then return end

    playerJob   = char.job       or 'unemployed'
    playerGrade = char.job_grade or 0
end

local function refreshPlayerGroup()
    local ok, player = pcall(function()
        return exports['union']:GetCurrentPlayer()
    end)

    if not ok or not player then return end

    playerGroup = player.group or 'user'
end

SetTimeout(500, function()
    refreshFromCharacter()
    refreshPlayerGroup()
end)

-- ─────────────────────────────────────────────────────────────
-- Mise à jour en live quand le job change
-- ─────────────────────────────────────────────────────────────
RegisterNetEvent('union:job:updated', function(job, grade)
    playerJob   = job   or 'unemployed'
    playerGrade = grade or 0
end)

-- ─────────────────────────────────────────────────────────────
-- Reset à la déconnexion / changement de personnage
-- ─────────────────────────────────────────────────────────────
RegisterNetEvent('union:character:deselected', function()
    playerJob   = 'unemployed'
    playerGrade = 0
    playerGroup = 'user'
end)

RegisterNetEvent('union:player:spawned', function()
    refreshFromCharacter()
    refreshPlayerGroup()
end)

-- ─────────────────────────────────────────────────────────────
-- hasPlayerGotGroup — utilisé par kt_target pour filtrer les options
--
-- Supporte les formats :
--   string           → "police"
--   array            → { "police", "ambulance" }
--   hash (grade min) → { police = 0, ambulance = 2 }
--
-- Note : le bypass admin/founder a été supprimé — il contournait
-- tous les filtres de job, ce qui causait des incohérences de gameplay.
-- Si tu veux le réactiver pour certaines options spécifiques, utilise
-- canInteract dans la définition de l'option.
-- ─────────────────────────────────────────────────────────────

---@diagnostic disable-next-line: duplicate-set-field
function utils.hasPlayerGotGroup(filter)
    if not filter then return true end

    local _type = type(filter)

    if _type == 'string' then
        return playerJob == filter

    elseif _type == 'table' then
        local tabletype = table.type(filter)

        if tabletype == 'hash' then
            -- { police = 0, ambulance = 2 } → job ET grade minimum requis
            for jobName, minGrade in pairs(filter) do
                if playerJob == jobName and playerGrade >= minGrade then
                    return true
                end
            end

        elseif tabletype == 'array' then
            -- { "police", "ambulance" } → n'importe lequel suffit
            for i = 1, #filter do
                if playerJob == filter[i] then
                    return true
                end
            end
        end
    end

    return false
end


print('[kt_target] Chargement du module framework/union.lua')