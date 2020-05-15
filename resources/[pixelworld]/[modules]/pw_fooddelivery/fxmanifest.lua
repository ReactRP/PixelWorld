fx_version 'bodacious'
games {'gta5'}

description 'PixelWorld Food Delivery'
name 'PixelWorld pw_fooddelivery'
author 'PixelWorldRP [Dr Nick] - https://pixelworldrp.com'
version 'v1.0.0'
url 'https://www.pixelworldrp.com'

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


