fx_version 'cerulean'

lua54 'yes'
game 'gta5'

name 'kt_target'
author 'kitotake'
version '1.17.3'
repository 'https://github.com/kitotake/kt_target'
description ''

ui_page 'web/build/index.html'

shared_scripts {
    '@kt_lib/init.lua',
}

client_scripts {
    'client/main.lua',
    'client/framework/union.lua',
    'client/admin/object_target.lua',
    
}

server_scripts {
    'server/main.lua'
}

files {
    'web/dist/index.html',
    'web/dist/assets/*.js',
    'web/dist/assets/*.css',
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
}

provide 'qtarget'

dependency 'kt_lib'