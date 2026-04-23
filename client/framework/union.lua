-- client/framework/union.lua
-- Intégration Union Framework dans kt_target
-- Ce fichier est chargé automatiquement si exports('union.getPlayer') existe

if not lib.checkDependency then return end

local utils = require 'client.utils'

---@diagnostic disable-next-line: duplicate-set-field
function utils.hasPlayerGotGroup(filter)
    local player = exports['union']:GetCurrentCharacter()
    if not player then return false end

    local job   = player.job        or 'unemployed'
    local grade = player.job_grade  or 0

    local _type = type(filter)

    if _type == 'string' then
        return job == filter
    elseif _type == 'table' then
        local tabletype = table.type(filter)

        if tabletype == 'hash' then
            for name, minGrade in pairs(filter) do
                if job == name and grade >= minGrade then
                    return true
                end
            end
        elseif tabletype == 'array' then
            for i = 1, #filter do
                if job == filter[i] then
                    return true
                end
            end
        end
    end

    return false
end