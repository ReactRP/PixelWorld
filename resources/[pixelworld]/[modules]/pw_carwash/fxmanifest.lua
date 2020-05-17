fx_version 'bodacious'
games {'gta5'}

description 'PixelWorld Car Wash'
name 'PixelWorld: pw_carwash'
author 'PixelWorldRP [Dr Nick] - https://pixelworldrp.com'
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