-- client/state.lua
local state = {}

local isActive = false

---@return boolean
function state.isActive()
    return isActive
end

---@param value boolean
function state.setActive(value)
    isActive = value
    SendNuiMessage(json.encode({ event = 'visible', state = value }))

    -- ✅ Correction : quand on désactive le targeting (depuis n'importe où,
    -- y compris disableTargeting() ou une ressource externe), on libère
    -- toujours le focus NUI pour ne pas bloquer l'input du joueur.
    if not value then
        state.setNuiFocus(false)
    end
end

local nuiFocus = false

---@return boolean
function state.isNuiFocused()
    return nuiFocus
end

---@param value boolean
---@param cursor? boolean
function state.setNuiFocus(value, cursor)
    if value then SetCursorLocation(0.5, 0.5) end

    nuiFocus = value
    SetNuiFocus(value, cursor or false)
    SetNuiFocusKeepInput(value)
end

local isDisabled = false

---@return boolean
function state.isDisabled()
    return isDisabled
end

---@param value boolean
function state.setDisabled(value)
    isDisabled = value

    -- ✅ Correction : si on disable le targeting depuis l'extérieur
    -- (ex: moveObject dans object_target.lua), on s'assure de fermer
    -- proprement le menu et de libérer le focus.
    if value then
        state.setActive(false)
    end
end

return state