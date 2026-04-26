-- client/api.lua
-- Point d'entrée de l'API publique kt_target.
-- Charge le registre et enregistre tous les exports FiveM.

local registry = require 'client.registry'

-- ─── Enregistrement des exports publics ───────────────────────────────────────
-- Chaque exports(name, fn) rend la fonction disponible via
-- exports.kt_target:name(...)

-- Zones
exports('addPolyZone',   function(data)           return registry.addPolyZone(data)         end)
exports('addBoxZone',    function(data)           return registry.addBoxZone(data)           end)
exports('addSphereZone', function(data)           return registry.addSphereZone(data)        end)
exports('removeZone',    function(id, suppress)   registry.removeZone(id, suppress)          end)
exports('zoneExists',    function(id)             return registry.zoneExists(id)             end)

-- Globaux
exports('addGlobalPed',      function(opts)  registry.addGlobalPed(opts)      end)
exports('removeGlobalPed',   function(opts)  registry.removeGlobalPed(opts)   end)
exports('addGlobalVehicle',  function(opts)  registry.addGlobalVehicle(opts)  end)
exports('removeGlobalVehicle',function(opts) registry.removeGlobalVehicle(opts) end)
exports('addGlobalObject',   function(opts)  registry.addGlobalObject(opts)   end)
exports('removeGlobalObject',function(opts)  registry.removeGlobalObject(opts) end)
exports('addGlobalPlayer',   function(opts)  registry.addGlobalPlayer(opts)   end)
exports('removeGlobalPlayer',function(opts)  registry.removeGlobalPlayer(opts) end)
exports('addGlobalOption',   function(opts)  registry.addGlobalOption(opts)   end)
exports('removeGlobalOption',function(opts)  registry.removeGlobalOption(opts) end)

-- Modèles
exports('addModel',    function(arr, opts)   registry.addModel(arr, opts)    end)
exports('removeModel', function(arr, filter) registry.removeModel(arr, filter) end)

-- Entités réseau
exports('addEntity',    function(arr, opts)   registry.addEntity(arr, opts)    end)
exports('removeEntity', function(arr, filter) registry.removeEntity(arr, filter) end)

-- Entités locales
exports('addLocalEntity',    function(arr, opts)   registry.addLocalEntity(arr, opts)    end)
exports('removeLocalEntity', function(arr, filter) registry.removeLocalEntity(arr, filter) end)

-- Contrôle (disableTargeting / isActive → définis dans client/main.lua)
exports('clearAll', function() registry.clearAll() end)

-- Interne — utilisé par main.lua pour récupérer les options
exports('getTargetOptions', function(entity, etype, emodel)
    return registry.getTargetOptions(entity, etype, emodel)
end)

-- Rétrocompatibilité avec l'ancienne API objet (kt_target:method())
-- Certains scripts appellent `local kt = exports.kt_target` puis `kt:addGlobalObject(...)`
-- Le mécanisme __index ci-dessous redirige les appels de méthode vers le registre.
local _meta = {
    __index = function(_, key)
        return registry[key] and function(_, ...) return registry[key](...) end or nil
    end,
}
setmetatable(exports.kt_target or {}, _meta)

return registry