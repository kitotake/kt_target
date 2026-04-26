-- client/framework/union.lua
-- Intégration Union Framework dans kt_target

local utils = require 'client.utils'

-- Cache local du personnage actif
local playerJob   = 'unemployed'
local playerGrade = 0
local playerGroup = 'user'  -- admin, moderator, founder, user

-- ─────────────────────────────────────────────────────────────
-- Helpers d'accès aux exports Union (noms variables selon version)
-- ─────────────────────────────────────────────────────────────

local function getUnionCharacter()
    -- Tente plusieurs noms d'export selon la version de Union
    local ok, result

    ok, result = pcall(function() return exports['union']:GetCurrentCharacter() end)
    if ok and result then return result end

    ok, result = pcall(function() return exports['union']:getCharacter() end)
    if ok and result then return result end

    return nil
end

local function getUnionPlayer()
    local ok, result

    ok, result = pcall(function() return exports['union']:GetCurrentPlayer() end)
    if ok and result then return result end

    ok, result = pcall(function() return exports['union']:getPlayer() end)
    if ok and result then return result end

    return nil
end

-- ─────────────────────────────────────────────────────────────
-- Refresh depuis le personnage actif
-- ─────────────────────────────────────────────────────────────

local function refreshFromCharacter()
    local char = getUnionCharacter()
    if not char then return end

    playerJob   = char.job       or 'unemployed'
    playerGrade = char.job_grade or 0
end

local function refreshPlayerGroup()
    local player = getUnionPlayer()
    if not player then return end

    playerGroup = player.group or 'user'
end

-- Remplacer SetTimeout(500, ...) par :
AddEventHandler('onClientResourceStart', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    SetTimeout(1000, function()
        refreshFromCharacter()
        refreshPlayerGroup()
    end)
end)

-- ─────────────────────────────────────────────────────────────
-- Events Union
-- ─────────────────────────────────────────────────────────────

RegisterNetEvent('union:job:updated', function(job, grade)
    playerJob   = job   or 'unemployed'
    playerGrade = grade or 0
end)

RegisterNetEvent('union:character:deselected', function()
    playerJob   = 'unemployed'
    playerGrade = 0
    playerGroup = 'user'
end)

RegisterNetEvent('union:player:spawned', function()
    refreshFromCharacter()
    refreshPlayerGroup()
end)

-- Certaines versions de Union utilisent cet événement
RegisterNetEvent('union:character:selected', function()
    SetTimeout(200, function()
        refreshFromCharacter()
        refreshPlayerGroup()
    end)
end)

-- ─────────────────────────────────────────────────────────────
-- hasPlayerGotGroup
--
-- Supporte :
--   string           → "police"
--   array            → { "police", "ambulance" }
--   hash (grade min) → { police = 0, ambulance = 2 }
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
            for jobName, minGrade in pairs(filter) do
                if playerJob == jobName and playerGrade >= minGrade then
                    return true
                end
            end

        elseif tabletype == 'array' then
            for i = 1, #filter do
                if playerJob == filter[i] then
                    return true
                end
            end
        end
    end

    return false
end

print('[kt_target] Module framework/union.lua chargé — job:', playerJob, '| group:', playerGroup)