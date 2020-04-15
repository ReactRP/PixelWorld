name 'PixelWorld Notification System'
author 'PixelWorld Notification System'
version 'v1.0.1'

ui_page {
    'html/ui.html',
}

client_scripts {
    'client/main.lua'
}

files {
    'html/ui.html',
	'html/js/app.js', 
	'html/css/style.css',
}

exports {
    'SendAlert',
	'SendUniqueAlert',
	'PersistentAlert',
}

fx_version 'bodacious'
games { 'gta5' }