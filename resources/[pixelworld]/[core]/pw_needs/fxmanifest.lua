fx_version 'bodacious'
games {'gta5'} -- 'gta5' for GTAv / 'rdr3' for Red Dead 2, 'gta5','rdr3' for both

description 'PixelWorld Needs'
name 'PixelWorld: pw_needs'
author 'PixelWorldRP [Chris Rogers] - https://www.pixelworldrp.com'
version 'v1.0.1'

server_scripts {
    '@pw_mysql/lib/MySQL.lua', -- Required for MySQL Support
    'config/main.lua',
    'server/main.lua',
}

client_scripts {
    'config/main.lua',
    'client/main.lua',
}

dependencies {
    'pw_mysql',
    'pw_core',
    'pw_notify',
}