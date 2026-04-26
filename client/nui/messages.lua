-- client/nui/messages.lua
-- Définition des types de messages NUI échangés avec React.
-- Ce fichier sert de référence documentaire et expose
-- des constantes pour éviter les magic strings.

local messages = {}

messages.VISIBLE     = 'visible'
messages.LEFT_TARGET = 'leftTarget'
messages.SET_TARGET  = 'setTarget'

return messages