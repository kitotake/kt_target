-- client/core/loop.lua
local loop = {}

local _running  = false
local _disabled = false

function loop.isRunning()  return _running  end
function loop.isDisabled() return _disabled end
function loop.setRunning(v)  _running  = v end
function loop.setDisabled(v) _disabled = v end

return loop