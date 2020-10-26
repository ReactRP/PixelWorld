description 'SynCity Keys System'
name 'SynCity pw_keys'
author 'SynCityRP [Chris Rogers] - https://SynCityrp.com'
version 'v1.0.0'

client_scripts {
	'client/main.lua'
}

server_scripts {
    '@pw_mysql/lib/MySQL.lua',
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