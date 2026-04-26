if not lib.checkDependency('kt_core', '0.21.3', true) then return end

local Kt = require '@kt_core.lib.init' --[[@as KtClient]]
local utils = require 'client.utils'
local player = Kt.GetPlayer()

---@diagnostic disable-next-line: duplicate-set-field
function utils.hasPlayerGotGroup(filter)
    return player.getGroup(filter)
end