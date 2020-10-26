description 'SynCity Doors'
name 'SynCity pw_doors'
author 'SynCityRP [creaKtive] - https://SynCityrp.com'
version 'v1.0.0'

client_scripts {
    'config/main.lua',
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
    'pw_core' 
}

fx_version 'bodacious'
games {'gta5'}