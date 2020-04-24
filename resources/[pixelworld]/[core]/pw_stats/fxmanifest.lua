fx_version 'bodacious'
games {'gta5'} -- 'gta5' for GTAv / 'rdr3' for Red Dead 2, 'gta5','rdr3' for both

description 'PixelWorld Stats - Food, Drink etc'
name 'PixelWorld: [pw_stats]'
author 'PixelWorldRP [Chris Rogers] - https://pixelworldrp.com'
version 'v1.0.0'
url 'https://www.pixelworldrp.com'

server_scripts {
    'server/server.lua',
}

client_scripts {
    'client/main.lua',
}

dependencies {
    'pw_notify',
    'pw_progbar',
    'pw_core'
}
