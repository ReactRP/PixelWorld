
fx_version 'bodacious'
games {'gta5'}

description 'SynCity Trucking Job'
name 'SynCity pw_trucking'
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
    'pw_progbar',
    'pw_interact',
    'pw_drawtext'
}
