fx_version 'bodacious'
games {'gta5'}

description 'PixelWorld Mumble Voip'
name 'PixelWorld: pw_voip'
author 'PixelWorldRP Dr Nick - https://pixelworldrp.com'
version 'v1.0.0'

server_scripts {
	'config/main.lua',
	'server/main.lua',
}

client_scripts {
	'config/main.lua',
	'client/main.lua',
	'client/radio.lua'
}

ui_page 'nui/index.html' 

files { 
	'nui/index.html',
	'nui/mic_click_on.ogg',
	'nui/mic_click_off.ogg',
	'nui/radio_off.ogg',
	'nui/radio_on.ogg',
}

dependencies {
	'pw_notify',
	'pw_core'
}