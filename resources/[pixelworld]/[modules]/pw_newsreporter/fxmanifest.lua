fx_version 'bodacious'
games {'gta5'}

description 'SynCity News Reporter'
name 'SynCity pw_newsreporter'
author 'SynCityRP [Dr Nick] - https://SynCityrp.com'
version 'v1.0.0'


server_scripts {
    'config.lua',
    'server/main.lua'
}

client_scripts {
    'config.lua',
    'client/main.lua'
}

dependencies {
    'pw_core',
    'pw_notify',
    'pw_drawtext'
}
