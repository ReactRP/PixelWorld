fx_version 'bodacious'
games {'gta5'} 

description 'SynCity Licensing System'
name 'SynCity: pw_licenses'
author 'SynCityRP Dr Nick - https://SynCityrp.com'
version 'v1.0.0'

server_scripts {
    '@pw_mysql/lib/MySQL.lua', 
    'config.lua',
    'server/main.lua',
}

client_scripts {
    'config.lua',
    'client/main.lua',
}

dependencies {
    'pw_mysql',
    'pw_notify',
    'pw_interact',
    'pw_core'
}
