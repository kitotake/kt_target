-- client/framework/esx.lua
-- Adapteur ESX pour kt_target.
-- Chargé conditionnellement seulement si es_extended est présent.

-- ✅ Guard : on vérifie que es_extended existe avant de tout charger
local ok, ESX = pcall(function()
    return exports['es_extended']:getSharedObject()
end)

if not ok or not ESX then
    return
end

local utils  = require 'client.utils'
local groups = { 'job', 'job2' }

local playerItems  = utils.getItems()
local playerGroups = {}

local usingktinventory = utils.hasExport('kt_inventory.Items')

-- FIX: table.wipe est une extension ox_lib/kt_lib non garantie.
-- On utilise une alternative compatible Lua 5.4 standard.
local function clearTable(t)
    for k in pairs(t) do
        t[k] = nil
    end
end

local function setPlayerData(playerData)
    clearTable(playerGroups)
    clearTable(playerItems)

    for i = 1, #groups do
        local group = groups[i]
        local data  = playerData[group]
        if data then
            playerGroups[group] = data
        end
    end

    if usingktinventory or not playerData.inventory then return end

    for _, v in pairs(playerData.inventory) do
        if v.count and v.count > 0 then
            playerItems[v.name] = v.count
        end
    end
end

if ESX.PlayerLoaded then
    setPlayerData(ESX.PlayerData)
end

AddEventHandler('esx:playerLoaded', function(data)
    setPlayerData(data)
end)

AddEventHandler('esx:setJob', function(job)
    playerGroups.job = job
end)

AddEventHandler('esx:setJob2', function(job)
    playerGroups.job2 = job
end)

AddEventHandler('esx:addInventoryItem', function(name, count)
    playerItems[name] = count
end)

AddEventHandler('esx:removeInventoryItem', function(name, count)
    playerItems[name] = count
end)

---@diagnostic disable-next-line: duplicate-set-field
function utils.hasPlayerGotGroup(filter)
    if not filter then return true end

    local _type = type(filter)

    for i = 1, #groups do
        local group = groups[i]
        local data  = playerGroups[group]
        if not data then goto continue end

        if _type == 'string' then
            if filter == data.name then return true end

        elseif _type == 'table' then
            -- FIX: table.type est une extension ox_lib. On utilise une
            -- détection manuelle compatible Lua 5.4 standard.
            local isHash = false
            for k in pairs(filter) do
                if type(k) ~= 'number' then
                    isHash = true
                    break
                end
            end

            if isHash then
                for name, grade in pairs(filter) do
                    if data.name == name and grade <= (data.grade or 0) then
                        return true
                    end
                end
            else
                for j = 1, #filter do
                    if data.name == filter[j] then return true end
                end
            end
        end

        ::continue::
    end

    return false
end

print('[kt_target] Adapteur ESX chargé.')