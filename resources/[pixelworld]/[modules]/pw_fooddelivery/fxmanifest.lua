fx_version 'bodacious'
games {'gta5'}

description 'SynCity Food Delivery'
name 'SynCity pw_fooddelivery'
author 'SynCityRP [Dr Nick] - https://SynCityrp.com'
version 'v1.0.0'
url 'https://www.SynCityrp.com'

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
    'pw_drawtext',
    'pw_progbar',
    'pw_interact',
    --'pw_phone'
}


