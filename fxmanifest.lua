fx_version 'cerulean'

lua54 'yes'
game 'gta5'

name        'kt_target'
author      'kitotake'
version     '1.18.1'
repository  'https://github.com/kitotake/kt_target'
description 'A performant and flexible standalone targeting resource for FiveM.'

ui_page 'web/dist/index.html'

-- ─── Shared (client + serveur) ────────────────────────────────────────────────
shared_scripts {
    '@kt_lib/init.lua',
    'shared/constants.lua',
    'shared/config.lua',
    'shared/types.lua',
    'shared/utils.lua',
    'shared/validators.lua',
    'shared/middleware.lua',
}

-- ─── Client ──────────────────────────────────────────────────────────────────
client_scripts {
    'client/main.lua',

    -- Core (requireables)
    'client/core/loop.lua',
    'client/core/raycast.lua',
    'client/core/detection.lua',
    'client/core/resolver.lua',
    'client/core/executor.lua',

    -- State (requireable)
    'client/state/target.lua',
    'client/state.lua',

    -- NUI (requireables)
    'client/nui/bridge.lua',
    'client/nui/focus.lua',
    'client/nui/messages.lua',

    -- Utils (requireables)
    'client/utils/init.lua',
    'client/utils/entity.lua',
    'client/utils/math.lua',
    'client/utils/table.lua',
    'client/utils.lua',

    -- Registry (requireable — contient la logique réelle)
    'client/registry/init.lua',

    -- API (requireable — enregistre les exports)
    'client/api.lua',

    -- Framework adapters (chargés conditionnellement)
    'client/framework/esx.lua',
    'client/framework/union.lua',

    -- Admin
  --  'client/admin/object_target.lua',

    -- Defaults (interactions véhicules par défaut)
    'client/defaults.lua',

    -- Compat qtarget
    'client/compat/qtarget.lua',

    -- Commands (guard interne par convar kt_target:debug)
    'client/commands/target.lua',

    -- Debug (guard interne par convar kt_target:debug)
    'client/debug.lua',
    'client/debug/init.lua',
}

-- ─── Exports client ───────────────────────────────────────────────────────────
-- Zones
client_exports {
    -- Zones
    'addPolyZone',
    'addBoxZone',
    'addSphereZone',
    'removeZone',
    'zoneExists',

    -- Globaux par type d'entité
    'addGlobalPed',
    'removeGlobalPed',
    'addGlobalVehicle',
    'removeGlobalVehicle',
    'addGlobalObject',
    'removeGlobalObject',
    'addGlobalPlayer',
    'removeGlobalPlayer',
    'addGlobalOption',
    'removeGlobalOption',

    -- Modèles
    'addModel',
    'removeModel',

    -- Entités réseau
    'addEntity',
    'removeEntity',

    -- Entités locales
    'addLocalEntity',
    'removeLocalEntity',

    -- Contrôle
    'disableTargeting',
    'isActive',
    'clearAll',

    -- Interne
    'getTargetOptions',
    'disableTargeting',
}

-- ─── Serveur ─────────────────────────────────────────────────────────────────
server_scripts {
    'server/main.lua',
}

-- ─── Exports serveur ──────────────────────────────────────────────────────────
-- (aucun export serveur public pour le moment)
server_exports {}

-- ─── Fichiers statiques (NUI + locales) ──────────────────────────────────────
files {
    'web/dist/index.html',
    'web/dist/assets/*.js',
    'web/dist/assets/*.css',
    'locales/*.json',
}

-- ─── Méta ────────────────────────────────────────────────────────────────────
provide   'qtarget'
dependency 'kt_lib'