fx_version 'bodacious'
games {'gta5'} 

description 'PixelWorld Radial Menu'
name 'PixelWorld: pw_radialmenu'
author 'PixelWorldRP Dr Nick'
version 'v1.0.0'
url 'https://www.pixelworldrp.com'

client_scripts {
    'config.lua',
    'client/main.lua',
}

ui_page "nui/wheel.html"

files {
    'nui/wheel.html',
    'nui/pw_wheel.js',
	'nui/assets/raphael.min.js',
    'nui/assets/wheelnav.min.js',
}
