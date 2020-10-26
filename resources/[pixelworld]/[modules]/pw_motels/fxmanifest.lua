fx_version 'bodacious'
games {'gta5'} -- 'gta5' for GTAv / 'rdr3' for Red Dead 2, 'gta5','rdr3' for both

description 'SynCity Motels'
name 'SynCity: [pw_motels]'
author 'SynCityRP [Chris Rogers]'
version 'v1.0.0'
url 'https://www.SynCityrp.com'

server_scripts {
    '@pw_mysql/lib/MySQL.lua', -- Required for MySQL Support
    'config/main.lua',
    'server/wrappers/motels.lua',
    'server/initalize.lua',
    'server/main.lua',
}

client_scripts {
    'config/main.lua',
    'client/main.lua',
}

-- ui_page 'nui/index.html' -- Only Required if implementing a NUI

-- files { -- Any NUI Files also need to be loaded here.
    -- 'file1.gif',
    -- 'file2.lua',
--}

dependencies {
    'pw_mysql',
    'pw_notify',
    'pw_progbar',
    'pw_core'
}