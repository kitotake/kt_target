-- client/framework/ox.lua
-- Adapteur OX (ox_core / kt_core) pour kt_target.
-- Chargé conditionnellement seulement si kt_core est présent et à jour.

local utils = require 'client.utils'

-- ✅ Guard : vérifie kt_core avant tout
if not lib.checkDependency('kt_core', '0.21.3', false) then
    -- Essaye ox_core comme fallback
    local oxOk = pcall(function()
        local _ = exports['ox_core']
    end)
    if not oxOk then return end
end

-- Essaye kt_core d'abord, puis ox_core
local Player
local ok

ok, Player = pcall(function()
    local Kt = require '@kt_core.lib.init'
    return Kt.GetPlayer()
end)

if not ok or not Player then
    ok, Player = pcall(function()
        return exports['ox_core']:GetPlayer()
    end)
end

if not ok or not Player then
    warn('[kt_target] Adapteur OX : impossible de récupérer le joueur.')
    return
end

-- ✅ Surcharge hasPlayerGotGroup pour OX/kt_core
---@diagnostic disable-next-line: duplicate-set-field
function utils.hasPlayerGotGroup(filter)
    if not filter then return true end
    local ok2, result = pcall(function()
        return Player.getGroup(filter)
    end)
    return ok2 and result or false
end

print('[kt_target] Adapteur OX/kt_core chargé.')