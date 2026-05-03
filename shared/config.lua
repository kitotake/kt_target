-- shared/config.lua
Config = Config or {}

Config.maxDistance  = 7.0
Config.zoneDistance = 7.0
Config.requireLoS   = true
Config.dotThreshold = 0.92

Config.toggleHotkey = GetConvarInt('kt_target:toggleHotkey', 0) == 1
Config.mouseButton  = GetConvarInt('kt_target:leftClick', 1) == 1 and 24 or 25
Config.debug        = GetConvarInt('kt_target:debug', 0) == 1
Config.defaults     = GetConvarInt('kt_target:defaults', 1) == 1
Config.drawSprite   = GetConvarInt('kt_target:drawSprite', 24)