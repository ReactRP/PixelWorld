fx_version 'bodacious'
games {'gta5'} -- 'gta5' for GTAv / 'rdr3' for Red Dead 2, 'gta5','rdr3' for both

description 'SynCity Stats - Food, Drink etc'
name 'SynCity: [pw_stats]'
author 'SynCityRP [Chris Rogers] - https://SynCityrp.com'
version 'v1.0.0'
url 'https://www.SynCityrp.com'

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
