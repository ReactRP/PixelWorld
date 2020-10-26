
client_scripts {
    "config/main.lua",
    "client/main.lua",
    "client/notifications.lua",
    "client/nui.lua",
    "client/animations.lua"
}


server_scripts {
    "@pw_mysql/lib/MySQL.lua",
    "server/wrapper/simcard.lua",
    "server/main.lua"
}

ui_page 'nui/index.html'

files {
    'nui/images/phone.png',
    'nui/images/radio.png',
    'nui/index.html',
    'nui/style.css',
    'nui/pw_phone.js',
    'nui/sound/success.ogg',
    'nui/sound/error.ogg'
}

dependencies {
    'pw_mysql',
    'pw_core'
}

fx_version 'bodacious'
games {'gta5'}