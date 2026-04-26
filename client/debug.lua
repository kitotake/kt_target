-- client/debug.lua

local debug = {}

function debug.print(msg)
    print('[kt_target DEBUG] ' .. tostring(msg))
end

return debug