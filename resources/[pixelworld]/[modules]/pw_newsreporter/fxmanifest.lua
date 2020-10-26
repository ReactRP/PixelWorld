fx_version 'bodacious'
games {'gta5'}

description 'PixelWorld News Reporter'
name 'PixelWorld pw_newsreporter'
author 'PixelWorldRP [Dr Nick] - https://pixelworldrp.com'
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
