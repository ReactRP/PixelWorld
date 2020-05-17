description 'PixelWorld Fishing'
name 'PixelWorld pw_fishing'
author 'PixelWorldRP [Dr Nick] - https://pixelworldrp.com'
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
