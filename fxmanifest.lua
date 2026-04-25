fx_version 'cerulean'

lua54 'yes'
game 'gta5'

name 'kt_target'
author 'kitotake'
version '1.17.3'
repository 'https://github.com/kitotake/kt_target'
description ''

ui_page 'web/index.html'

shared_scripts {
    '@kt_lib/init.lua',
}

client_scripts {
    'client/main.lua',
    'client/admin/object_target.lua',   -- ← AJOUT
}

server_scripts {
    'server/main.lua'
}

files {
    'web/build/index.html',
    'web/build/**/*',
    'locales/*.json',
    'client/api.lua',
    'client/utils.lua',
    'client/state.lua',
    'client/debug.lua',
    'client/defaults.lua',
    'client/framework/nd.lua',
    'client/framework/ox.lua',
    'client/framework/esx.lua',
    'client/framework/qbx.lua',
    'client/framework/union.lua',
    'client/compat/qtarget.lua',
    'client/admin/object_target.lua',   -- ← AJOUT
}

provide 'qtarget'

dependency 'kt_lib'