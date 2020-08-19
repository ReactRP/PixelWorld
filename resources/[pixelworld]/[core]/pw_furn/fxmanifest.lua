fx_version 'bodacious'
games {'gta5'} -- 'gta5' for GTAv / 'rdr3' for Red Dead 2, 'gta5','rdr3' for both

description 'SynCity [Script Full Name]'
name 'SynCity: [resourcefoldername]'
author 'SynCityRP [Author] - https://SynCityrp.com'
version 'v1.0.0'

server_scripts {
    '@pw_mysql/lib/MySQL.lua', -- Required for MySQL Support
}

client_scripts {
    'config/main.lua',
    'client/main.lua',
}

ui_page 'nui/index.html' -- Only Required if implementing a NUI

files { -- Any NUI Files also need to be loaded here.
    'nui/index.html',
    'nui/movement.js',
}

dependencies {
    'pw_mysql',
    'pw_core'
}