-- shared/middleware.lua
-- Pipeline de middleware appliqué aux options avant affichage.
-- Permet d'injecter des vérifications transversales (logs, ACL, throttle…).

local middleware = {}

---@type function[]
local stack = {}

---Ajoute un middleware au pipeline.
---Un middleware reçoit (option, next) et doit appeler next() pour continuer.
---@param fn function
function middleware.use(fn)
    stack[#stack + 1] = fn
end

---Exécute le pipeline sur une option.
---Retourne true si l'option est autorisée, false sinon.
---@param option KtTargetOption
---@return boolean
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