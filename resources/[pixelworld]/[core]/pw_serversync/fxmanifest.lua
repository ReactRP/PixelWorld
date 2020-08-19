description 'SynCity Server Sync'
name 'SynCity: pw_serversync'
author 'SynCityRP [Chris Rogers]'
version 'v1.0.1'
url 'https://www.SynCityrp.com'

client_scripts {
    'ss_shared_functions.lua',
    'config/Keybinds.lua',
    'config/ServerSync.lua',
    'ss_cli_indicators.lua',
    'ss_cli_windows.lua',
    'ss_cli_traffic_crowd.lua',
    'ss_cli_weather.lua',
    'ss_cli_time.lua'
}

server_scripts {
    'ss_shared_functions.lua',
    'config/ServerSync.lua',
    'ss_srv_indicators.lua',
    'ss_srv_windows.lua',
    'ss_srv_weather.lua',
    'ss_srv_time.lua'
}

fx_version 'bodacious'
games { 'gta5' }