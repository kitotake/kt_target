-- shared/middleware.lua
local middleware = {}

---@type function[]
local stack = {}

function middleware.use(fn)
    stack[#stack + 1] = fn
end

function middleware.run(option)
    local index = 0

    local function next()
        index = index + 1
        local fn = stack[index]
        if fn then
            return fn(option, next)
        end
        return true
    end

    return next()
end

return middleware