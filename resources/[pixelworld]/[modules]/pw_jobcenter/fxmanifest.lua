
fx_version 'bodacious'
games {'gta5'} 

description 'PixelWorld Job Center'
name 'PixelWorld: pw_jobcenter'
author 'PixelWorldRP [Dr Nick] - https://pixelworldrp.com'
version 'v1.0.0'
url 'https://www.pixelworldrp.com'


server_scripts {
    '@pw_mysql/lib/MySQL.lua',
    'server/main.lua',
}

client_scripts {
    'config.lua',
    'client/main.lua',
}

dependencies {
    'pw_notify',
    'pw_interact',
    'pw_core',
    'pw_mysql'
}
