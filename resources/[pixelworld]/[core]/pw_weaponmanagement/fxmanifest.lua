fx_version 'bodacious'
games {'gta5'} -- 'gta5' for GTAv / 'rdr3' for Red Dead 2, 'gta5','rdr3' for both

description 'SynCity Weapon Management'
name 'SynCity: [pw_weapons]'
author 'SynCityRP [Chris Rogers]'
version 'v1.0.1'
url 'https://www.SynCityrp.com'

server_scripts {
    '@pw_mysql/lib/MySQL.lua', -- Required for MySQL Support
    'config/main.lua',
    'config/weapons.lua',
    'server/functions/*.lua',
    'server/*.lua',
}

client_scripts {
    'config/main.lua',
    'config/weapons.lua',
    'client/*.lua',
}

dependencies {
    'pw_mysql',
    'pw_notify',
    'pw_progbar',
    'pw_core'
}