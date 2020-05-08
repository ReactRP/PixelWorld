fx_version 'adamant'
games { 'gta5' }

client_scripts {
	"config/config.lua",
	"client/timers.lua",
	"client/events.lua",
}

server_scripts {
	"server/main.lua"
}

ui_page "html/index.html"

files {
	"html/index.html",
	
	"html/scripts/config.js",
	"html/scripts/listener.js",
	"html/scripts/SoundPlayer.js",
	"html/scripts/functions.js",
}

export{
	"Distance",
	"PlayUrl",
	"PlayUrlPos",
	"PlayPos",
	"Play",
	"Position",
	"Stop",
	"Resume",
	"Pause",
	"setVolume",
	"getVolume",
	"getInfo",
	"setVolumeMax",
}