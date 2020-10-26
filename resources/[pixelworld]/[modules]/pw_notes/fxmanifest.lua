fx_version 'bodacious'
games {'gta5'} -- 'gta5' for GTAv / 'rdr3' for Red Dead 2, 'gta5','rdr3' for both

description 'SynCity Notes'
name 'SynCity: [pw_notes]'
author 'SynCityRP [Chris Rogers] - https://SynCityrp.com'
version 'v1.0.0'

server_scripts {
    '@pw_mysql/lib/MySQL.lua', -- Required for MySQL Support
    'config/main.lua',
    'server/main.lua',
}

client_scripts {
    'config/main.lua',
    'client/main.lua',
}

ui_page 'nui/index.html' -- Only Required if implementing a NUI

files { -- Any NUI Files also need to be loaded here.
    'nui/index.html',
    'nui/style.css',
    'nui/pw_notes.js',
    'nui/images/blank.png'
}

dependencies {
    'pw_mysql',
    'pw_notify',
    'pw_progbar',
    'pw_core'
}
