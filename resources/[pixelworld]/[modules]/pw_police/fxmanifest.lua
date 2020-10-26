description 'SynCity Police'
name 'SynCity pw_police'
author 'SynCityRP [Chris Rogers] - https://SynCityrp.com'
version 'v1.0.0'

client_scripts {
    'config/main.lua',
    'client/cad.lua',
    'client/functions.lua',
    'client/main.lua'
}

server_scripts {
    '@pw_mysql/lib/MySQL.lua',
    'config/main.lua',
    'server/main.lua'
}

dependencies {
    'pw_mysql',
    'pw_notify',
    'pw_progbar',
    'pw_interact',
    'pw_core'
}

ui_page "nui/ui.html"

files {
    "nui/*"
}

fx_version 'bodacious'
games {'gta5'}