fx_version 'cerulean'
game 'gta5'

author 'SiiK'
description 'Safezone personal stash (qb-inventory v2 / qs-inventory)'
version '1.1.0'

shared_scripts { 'config.lua' }

client_scripts { 'client/main.lua' }

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua'
}

dependencies {
    'qb-core',
    'qb-target',
    'oxmysql'
}

optional_dependency 'qb-inventory'
optional_dependency 'qs-inventory'
