fx_version 'bodacious'
games {'gta5'}

description 'SynCity Car Wash'
name 'SynCity: pw_carwash'
author 'SynCityRP [Dr Nick] - https://SynCityrp.com'
version 'v1.0.0'

server_scripts {
    'config.lua',
    'server/main.lua',
}

client_scripts {
    'config.lua',
    'client/main.lua',
}

dependencies {
    'pw_notify',
    'pw_progbar',
    'pw_core'
}