description 'SynCity Garage'
name 'SynCity pw_garage'
author 'SynCityRP [creaKtive] - https://SynCityrp.com'
version 'v1.0.0'

client_scripts {
    'config/config.lua',
    'client/fuel.lua',
    'client/main.lua'
}

server_scripts {
    '@pw_mysql/lib/MySQL.lua',
    'config/config.lua',
    'server/main.lua'
}

dependencies {
    'pw_mysql',
    'pw_notify',
    'pw_progbar',
    'pw_core' 
}

fx_version 'adamant'
games {'gta5'}