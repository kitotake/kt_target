-- client/nui/bridge.lua
-- Pont entre le Lua et la NUI React.
-- Expose des fonctions haut niveau pour envoyer des messages NUI.

local bridge = {}

local SendNuiMessage = SendNuiMessage

---Envoie un message NUI encodé en JSON.
---@param payload table
function bridge.send(payload)
    SendNuiMessage(json.encode(payload, { sort_keys = true }))
end

---Affiche ou masque l'UI.
---@param value boolean
function bridge.setVisible(value)
    bridge.send({ event = 'visible', state = value })
end

---Notifie la NUI que l'entité ciblée a changé (reset).
function bridge.leftTarget()
    SendNuiMessage('{"event": "leftTarget"}')
end

---Envoie les options au React sous forme structurée.
---@param groups table   nuiGroups  (tableau sérialisé)
---@param zones  table   nuiZones   (tableau sérialisé)
function bridge.setTarget(groups, zones)
    bridge.send({
        event  = 'setTarget',
        groups = groups,
        zones  = zones,
    })
end

return bridge