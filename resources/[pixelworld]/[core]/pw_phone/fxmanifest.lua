fx_version 'bodacious'
games {'gta5'} -- 'gta5' for GTAv / 'rdr3' for Red Dead 2, 'gta5','rdr3' for both

description 'PixelWorld Phone'
name 'PixelWorld: [pw_phone]'
author 'PixelWorldRP [Chris Rogers]'
version 'v1.0.0'
url 'https://www.pixelworldrp.com'

server_scripts {
    '@pw_mysql/lib/MySQL.lua', -- Required for MySQL Support
    'config/main.lua',
    'server/main.lua',
    'server/apps/*.lua'
}

client_scripts {
    'config/main.lua',
    'client/nuiactions.lua',
    'client/animations.lua',
    'client/main.lua',
    'client/apps/*.lua'
}

ui_page 'html/index.html' -- Only Required if implementing a NUI

files {
	'html/index.html',
	'html/html/apps/*.html',
    
    'html/js/build.js',

    'html/libs/webfonts/*.woff',
    'html/libs/webfonts/*.woff2',
    'html/libs/webfonts/*.ttf',
    'html/libs/webfonts/*.eot',
    'html/libs/webfonts/*.svg',

    'html/libs/*.min.css',
    'html/libs/*.min.js',

    'html/imgs/*.png',
}

dependencies {
    'pw_mysql',
    'pw_notify',
    'pw_progbar',
    'pw_core'
}