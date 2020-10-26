
------
-- InteractSound by Scott
-- Verstion: v0.0.1
------
-- Client Scripts
client_script 'client/main.lua'

-- Server Scripts
server_script 'server/main.lua'

-- NUI Default Page
ui_page('client/html/index.html')

-- Files needed for NUI
-- DON'T FORGET TO ADD THE SOUND FILES TO THIS!
files({
    'client/html/index.html',
    'client/html/js/app.js',
    'client/html/libs/howler.min.js',
    'client/html/sounds/*.ogg',
})

fx_version 'bodacious'
games { 'gta5' }