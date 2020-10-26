fx_version 'bodacious'
games {'gta5'}

description 'PixelWorld Emotes'
name 'PixelWorld: pw_emotes'
author 'PixelWorldRP [Dr Nick]'
version 'v1.0.0'
url 'https://www.pixelworldrp.com'

server_scripts {
	'@pw_mysql/lib/MySQL.lua', -- Required for MySQL Support
	'config.lua',
	'server/main.lua'
}

client_scripts {
	'config.lua',
	'client/animationList.lua',
	'client/main.lua',
}

dependencies {
	'pw_mysql',
	'pw_notify',
	'pw_interact',
	'pw_core',
}
