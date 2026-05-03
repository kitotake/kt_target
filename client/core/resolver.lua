-- client/core/resolver.lua
local resolver = {}

function resolver.countVisible(options)
    local n = 0
    for i = 1, #options do
        if not options[i].hide then n = n + 1 end
    end
    return n
end

function resolver.updateVisibility(options, dist, endCoords, shouldHideFn,
                                    entityHit, entityType, entityModel)
    local changed = false
    for i = 1, #options do
        local opt = options[i]
        local hide = shouldHideFn(opt, dist, endCoords, entityHit, entityType, entityModel)
        if opt.hide ~= hide then
            opt.hide = hide
            changed = true
        end
    end
    return changed
end

return resolver