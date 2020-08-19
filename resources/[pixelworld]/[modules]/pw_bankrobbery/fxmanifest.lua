fx_version 'bodacious'
games {'gta5'}

description 'SynCity Banking'
name 'SynCity: pw_bankrobbery'
author 'SynCityRP [creaKtive & Chris Rogers] - https://SynCityrp.com'
version 'v1.0.0'

server_scripts {
    '@pw_mysql/lib/MySQL.lua',
    'config/config.lua',
    'server/main.lua'
}

client_scripts {
    'config/config.lua',
    'client/main.lua'
}

dependencies {
    'pw_mysql',
    'pw_notify',
    'pw_progbar',
    'pw_core'
}