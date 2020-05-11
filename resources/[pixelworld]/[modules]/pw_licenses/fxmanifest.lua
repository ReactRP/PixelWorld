fx_version 'bodacious'
games {'gta5'} 

description 'PixelWorld Licensing System'
name 'PixelWorld: pw_licenses'
author 'PixelWorldRP Dr Nick - https://pixelworldrp.com'
version 'v1.0.0'

server_scripts {
    '@pw_mysql/lib/MySQL.lua', 
    'config.lua',
    'server/main.lua',
}

client_scripts {
    'config.lua',
    'client/main.lua',
}

dependencies {
    'pw_mysql',
    'pw_notify',
    'pw_interact',
    'pw_core'
}
