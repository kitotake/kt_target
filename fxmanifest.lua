fx_version 'cerulean'

lua54 'yes'
game 'gta5'

name 'kt_target'
author 'kitotake'
version '1.18.0'
repository 'https://github.com/kitotake/kt_target'
description ''

ui_page 'web/dist/index.html'

shared_scripts {
    '@kt_lib/init.lua',
    'shared/constants.lua',
    'shared/config.lua',
    'shared/types.lua',
    'shared/utils.lua',
    'shared/validators.lua',
    'shared/middleware.lua',
}

client_scripts {
    'client/main.lua',
    -- Core
    'client/core/loop.lua',
    'client/core/raycast.lua',
    'client/core/detection.lua',
    'client/core/resolver.lua',
    'client/core/executor.lua',

    -- Registry (documentaire)
    'client/registry/entities.lua',
    'client/registry/globals.lua',
    'client/registry/models.lua',
    'client/registry/zones.lua',

    -- State
    'client/state/target.lua',

    -- NUI
    'client/nui/bridge.lua',
    'client/nui/focus.lua',
    'client/nui/messages.lua',

    -- Utils
    'client/utils/entity.lua',
    'client/utils/math.lua',
    'client/utils/table.lua',

    -- API
    'client/api/exports.lua',

    -- Framework adapters
    'client/framework/esx.lua',
    'client/framework/ox.lua',
    'client/framework/union.lua',

    -- Admin
    'client/admin/object_target.lua',

    -- Commands
    'client/commands/target.lua',

    -- Compat
    'client/compat/qtarget.lua',

    -- Debug
    'client/debug/debug.lua',
}

server_scripts {
    'server/main.lua',
}

files {
    'web/dist/index.html',
    'web/dist/assets/*.js',
    'web/dist/assets/*.css',
    'locales/*.json',

    -- Core
    'client/core/loop.lua',
    'client/core/raycast.lua',
    'client/core/detection.lua',
    'client/core/resolver.lua',
    'client/core/executor.lua',

    -- Registry (documentaire)
    'client/registry/entities.lua',
    'client/registry/globals.lua',
    'client/registry/models.lua',
    'client/registry/zones.lua',

    -- State
    'client/state/target.lua',

    -- NUI
    'client/nui/bridge.lua',
    'client/nui/focus.lua',
    'client/nui/messages.lua',

    -- Utils
    'client/utils/entity.lua',
    'client/utils/math.lua',
    'client/utils/table.lua',

    -- API
    'client/api/exports.lua',

    -- Framework adapters
    'client/framework/esx.lua',
    'client/framework/nd.lua',
    'client/framework/ox.lua',
    'client/framework/qbx.lua',
    'client/framework/union.lua',

    -- Admin
    'client/admin/object_target.lua',

    -- Commands
    'client/commands/target.lua',

    -- Compat
    'client/compat/qtarget.lua',

    -- Debug
    'client/debug/debug.lua',
}

provide 'qtarget'

dependency 'kt_lib'