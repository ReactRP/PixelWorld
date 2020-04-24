fx_version 'bodacious'
games {'gta5'} 

description 'PixelWorld Newspaper Stands'
name 'PixelWorld: pw_newspapers'
author 'PixelWorldRP Dr Nick - https://pixelworldrp.com'
version 'v1.0.0'
url 'https://www.pixelworldrp.com'

client_scripts {
    'config.lua',
    'client/main.lua',
}

server_scripts { 
    'server/main.lua',
}

ui_page 'nui/index.html'

files {
    'nui/images/pw-newspaper1.png',
    'nui/images/pw-newspaper2.png',
    'nui/index.html',
    'nui/style.css',
    'nui/pw_newspapers.js'
}

dependencies {
    'pw_mysql',
    'pw_notify',
    'pw_progbar',
    'pw_core'
}

