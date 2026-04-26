fx_version 'cerulean'

lua54 'yes'
game 'gta5'

name 'kt_target'
author 'kitotake'
version '1.17.3'
repository 'https://github.com/kitotake/kt_target'
description ''

ui_page 'web/dist/index.html'

shared_scripts {
    '@kt_lib/init.lua',
}

client_scripts {
    'client/main.lua',
}

server_scripts {
    'server/main.lua'
}

files {
    'web/dist/index.html',
    'web/dist/assets/*.js',
    'web/dist/assets/*.css',
    'locales/*.json',
 
    'client/core/loop.lua',
    'client/core/raycast.lua',
    'client/core/detection.lua',
    'client/core/resolver.lua',
    'client/core/executor.lua',
    'client/registry/entities.lua',
    'client/registry/globals.lua',
    'client/registry/models.lua',
    'client/registry/zones.lua',

}

provide 'qtarget'

dependency 'kt_lib'