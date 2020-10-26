fx_version 'adamant'
games {'gta5'} -- 'gta5' for GTAv / 'rdr3' for Red Dead 2, 'gta5','rdr3' for both

description 'PixelWorld Gangs'
name 'PixelWorld: pw_gangs'
author 'PixelWorldRP creaKtive - https://pixelworldrp.com'
version 'v1.0.0'

server_scripts {
    '@pw_mysql/lib/MySQL.lua', -- Required for MySQL Support
    'config/config.lua',
    'server/main.lua',
}

client_scripts {
    '@PolyZone/client.lua',
    'config/config.lua',
    'client/main.lua',
}

dependencies {
    'pw_mysql',
    'pw_notify',
    'pw_progbar',
    'pw_core',
}