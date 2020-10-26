
fx_version 'bodacious'
games {'gta5'} 

description 'SynCity Job Center'
name 'SynCity: pw_jobcenter'
author 'SynCityRP [Dr Nick] - https://SynCityrp.com'
version 'v1.0.0'
url 'https://www.SynCityrp.com'


server_scripts {
    '@pw_mysql/lib/MySQL.lua',
    'server/main.lua',
}

client_scripts {
    'config.lua',
    'client/main.lua',
}

dependencies {
    'pw_notify',
    'pw_interact',
    'pw_core',
    'pw_mysql'
}
