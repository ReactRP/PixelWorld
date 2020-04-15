fx_version 'bodacious'
games {'gta5'} -- 'gta5' for GTAv / 'rdr3' for Red Dead 2, 'gta5','rdr3' for both

description 'PixelWorld Framework'
name 'PixelWorld: pw_core'
author 'PixelWorldRP [Chris Rogers] - https://www.pixelworldrp.com'
version 'v1.0.0'

server_scripts {
    '@pw_mysql/lib/MySQL.lua', -- Required for MySQL Support
    '@pw_mysql2/lib/MySQL.lua', -- Required for MySQL Support
    'config/main.lua',
    'server/admin.lua',
    'server/functions.lua',
    'server/wrappers/character.lua',
    'server/wrappers/user.lua',
    'server/commands.lua',
    'server/initial.lua',
    'server/db_func.lua',
    'server/main.lua',
    'server/events.lua'
}

client_scripts {
    'config/main.lua',
    'client/enumerators.lua',
    'client/functions.lua',
    'client/initial.lua',
    'client/admin.lua',
    'client/nui.lua',
    'client/events.lua',
    'client/discord.lua'
}

loadscreen 'nui/loadscreen/index.html'

ui_page 'nui/characterselect/index.html'

files {
    'nui/characterselect/js/pixelworld.js',
    'nui/characterselect/index.html',
    'nui/characterselect/style.css',
    'nui/loadscreen/index.html',
    'nui/loadscreen/style.css',
    'nui/images/BigBanner.png',
    'nui/images/logo.png',
    'nui/images/96x96.png'
}

data_file 'WEAPONINFO_FILE_PATCH' 'weapons.meta'
data_file 'WEAPON_ANIMATIONS_FILE' 'weaponanimations.meta'

dependencies {
    'pw_mysql',
    'pw_mysql2',
    'pw_notify',
    'pw_progbar',
}