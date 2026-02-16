fx_version 'cerulean'
game 'gta5'

author 'SiiK'
description 'Safezone personal stash (new qb-inventory + oxmysql persistence)'
version '1.1.0'

shared_scripts { 'config.lua' }

client_scripts { 'client/main.lua' }

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua'
}

dependencies {
    'qb-core',
    'SiiK-bridge',
    'qb-target',
    'oxmysql'
}
