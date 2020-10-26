description 'SynCity Fishing'
name 'SynCity pw_fishing'
author 'SynCityRP [Dr Nick] - https://SynCityrp.com'
version 'v1.0.0'

client_scripts {
    'config.lua',
    'client/main.lua'
}

server_scripts {
    'config.lua',
    'server/main.lua'
}

dependencies {
    'pw_core',
    'pw_notify',
    'pw_interact',
    'pw_drawtext'
}

fx_version 'bodacious'
games {'gta5'}
