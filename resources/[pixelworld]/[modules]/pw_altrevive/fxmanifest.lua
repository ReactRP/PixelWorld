fx_version 'bodacious'
games {'gta5'} 

description 'SynCity Alternate Revive (Grandma House)'
name 'SynCity: pw_altrevive'
author 'SynCityRP [Dr Nick] - https://SynCityrp.com'
version 'v1.0.0'
url 'https://www.SynCityrp.com'

server_scripts {
    'config.lua',
    'server/main.lua',
}

client_scripts {
    'config.lua',
    'client/main.lua',
}

dependencies {
    'pw_notify',
    'pw_progbar',
    'pw_core',
    'pw_interact',
    'pw_ems'
}