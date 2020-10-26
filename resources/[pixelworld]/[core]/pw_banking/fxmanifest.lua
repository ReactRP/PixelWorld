fx_version 'bodacious'
games {'gta5'} -- 'gta5' for GTAv / 'rdr3' for Red Dead 2, 'gta5','rdr3' for both

description 'PixelWorld Banking'
name 'PixelWorld: pw_banking'
author 'PixelWorldRP [Chris Rogers] - https://www.pixelworldrp.com'
version 'v1.0.1'

server_scripts {
    '@pw_mysql/lib/MySQL.lua', -- Required for MySQL Support
    'config/main.lua',
    'server/buisnessBanking.lua',
    'server/offlineAccount.lua',
    'server/main.lua',
}

client_scripts {
    'config/main.lua',
    'client/nui.lua',
    'client/main.lua',
}

ui_page 'nui/pw_index.html' -- Only Required if implementing a NUI

files { -- Any NUI Files also need to be loaded here.
    'nui/*',
}

dependencies {
    'pw_mysql',
    'pw_core',
    'pw_notify',
    'pw_progbar',
}