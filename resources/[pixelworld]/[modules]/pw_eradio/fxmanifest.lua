fx_version 'bodacious'
games {'gta5'} -- 'gta5' for GTAv / 'rdr3' for Red Dead 2, 'gta5','rdr3' for both

description 'SynCity Emergency Radio Script'
name 'SynCity: pw_eradio'
author 'SynCityRP [Chris Rogers] - https://www.SynCityrp.com'
version 'v1.0.0'

server_scripts {
    '@pw_mysql/lib/MySQL.lua', -- Required for MySQL Support
    'server/main.lua',
}

client_scripts {
    'client/main.lua',
}

dependencies {
    'pw_mysql',
    'pw_core'
}