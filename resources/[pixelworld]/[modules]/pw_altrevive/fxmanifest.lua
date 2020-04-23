fx_version 'bodacious'
games {'gta5'} 

description 'PixelWorld Alternate Revive (Grandma House)'
name 'PixelWorld: pw_altrevive'
author 'PixelWorldRP [Dr Nick] - https://pixelworldrp.com'
version 'v1.0.0'
url 'https://www.pixelworldrp.com'

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
    'pw_core',
    'pw_interact',
    'pw_ems'
}