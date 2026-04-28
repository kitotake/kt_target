fx_version 'cerulean'

lua54 'yes'
game 'gta5'

name        'kt_target'
author      'kitotake'
version     '1.18.0'
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
 -- ─── Client ─────────────────────────────────────────────────────────────────
client_scripts {
    'client/main.lua',

    'client/test.lua',
    
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

    -- Framework adapters (requireables depuis main.lua)
    'client/framework/esx.lua',
    'client/framework/union.lua',

    
    -- Admin (requireable)
    'client/admin/object_target.lua',

    -- Defaults (requireable)
    'client/defaults.lua',

    -- Compat (requireable)
    'client/compat/qtarget.lua',

    -- Commands (top-level, guard interne par convar)
    'client/commands/target.lua',

   -- Debug (top-level, guard interne par convar)
    'client/debug.lua',
    'client/debug/init.lua',
}

-- ─── Serveur ─────────────────────────────────────────────────────────────────
server_scripts {
    'server/main.lua',
}

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