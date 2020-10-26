fx_version 'bodacious'
games {'gta5'} -- 'gta5' for GTAv / 'rdr3' for Red Dead 2, 'gta5','rdr3' for both

description 'SynCity [Store Robbery]'
name 'SynCity: [pw_storerobbery]'
author 'SynCityRP [creaKtive] - https://SynCityrp.com'
version 'v1.0.0'

server_scripts {
    '@pw_mysql/lib/MySQL.lua', -- Required for MySQL Support
    'config/config.lua',
    'server/main.lua',
}

client_scripts {
    'config/config.lua',
    'client/main.lua',
}

dependencies {
    'pw_mysql',
    'pw_notify',
    'pw_progbar',
    'pw_core'
}