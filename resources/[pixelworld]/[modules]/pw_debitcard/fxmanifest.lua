description 'SynCity Banking'
name 'SynCity: pw_banking'
author 'SynCityRP [Chris Rogers] - https://SynCityrp.com'
version 'v1.0.2'

server_scripts {
    '@pw_mysql/lib/MySQL.lua',
    'config/config.lua',
    'server/wrappers/buisness.lua',
    'server/main.lua'
}

client_scripts {
    'config/config.lua',
    'client/main.lua',
    'client/nui.lua'
}

ui_page 'nui/index.html'

files {
    'nui/images/logo.gif',
    'nui/images/logo.png',
    'nui/images/mastercard.png',
    'nui/images/visa.png',
    'nui/scripting/jquery-ui.css',
    'nui/scripting/external/jquery/jquery.js',
    'nui/scripting/jquery-ui.js',
    'nui/style.css',
    'nui/index.html',
    'nui/pw_debitcard.js',
}

fx_version 'bodacious'
games {'gta5'}