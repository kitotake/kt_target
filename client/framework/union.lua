-- client/framework/union.lua
-- Adapteur Union Framework pour kt_target.
-- Chargé conditionnellement si union est disponible.

-- ✅ Guard
local unionOk = pcall(function() local _ = exports['union'] end)
if not unionOk then return end

local utils = require 'client.utils'

local playerJob   = 'unemployed'
local playerGrade = 0
local playerGroup = 'user'  -- 'admin' | 'moderator' | 'founder' | 'user'

-- ─── Helpers ─────────────────────────────────────────────────────────────────

local function getUnionCharacter()
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

-- ─── Événements ──────────────────────────────────────────────────────────────

AddEventHandler('onClientResourceStart', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    SetTimeout(1000, function()
        refreshFromCharacter()
        refreshPlayerGroup()
    end)
end)

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

RegisterNetEvent('union:character:selected', function()
    SetTimeout(200, function()
        refreshFromCharacter()
        refreshPlayerGroup()
    end)
end)

-- ─── Surcharge hasPlayerGotGroup ─────────────────────────────────────────────

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
                if playerJob == filter[i] then return true end
            end
        end
    end

    return false
end

print('[kt_target] Adapteur Union chargé '.. (unionOk and 'avec succès.' or 'mais union semble indisponible.'))