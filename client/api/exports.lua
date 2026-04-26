-- client/api/exports.lua
-- Point d'entrée des exports publics de kt_target.
-- Les exports sont déclarés via le mécanisme __newindex de client/api.lua
-- qui appelle automatiquement exports(name, value) à chaque assignation.
--
-- Ce fichier liste les exports disponibles à titre documentaire.
-- Ils sont tous effectivement enregistrés dans client/api.lua.

--[[
  Zones :
    exports.kt_target:addPolyZone(data)         → number (zone id)
    exports.kt_target:addBoxZone(data)           → number (zone id)
    exports.kt_target:addSphereZone(data)        → number (zone id)
    exports.kt_target:removeZone(id, suppress?)
    exports.kt_target:zoneExists(id)             → boolean

  Globaux :
    exports.kt_target:addGlobalPed(options)
    exports.kt_target:removeGlobalPed(options)
    exports.kt_target:addGlobalVehicle(options)
    exports.kt_target:removeGlobalVehicle(options)
    exports.kt_target:addGlobalObject(options)
    exports.kt_target:removeGlobalObject(options)
    exports.kt_target:addGlobalPlayer(options)
    exports.kt_target:removeGlobalPlayer(options)
    exports.kt_target:addGlobalOption(options)
    exports.kt_target:removeGlobalOption(options)

  Modèles :
    exports.kt_target:addModel(arr, options)
    exports.kt_target:removeModel(arr, options?)

  Entités réseau :
    exports.kt_target:addEntity(arr, options)
    exports.kt_target:removeEntity(arr, options?)

  Entités locales :
    exports.kt_target:addLocalEntity(arr, options)
    exports.kt_target:removeLocalEntity(arr, options?)

  Contrôle :
    exports.kt_target:disableTargeting(value)
    exports.kt_target:isActive()                 → boolean
    exports.kt_target:clearAll()

  Interne :
    exports.kt_target:getTargetOptions(entity?, type?, model?) → table
]]