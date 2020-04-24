client_script('client.lua')

server_script {
	'@pw_mysql/lib/MySQL.lua',
}

ui_page('html/index.html')

files({
    'html/index.html',
    'html/howler.core.min.js',
    'html/pw_lockpick2.js',
    'html/style.css',
})

fx_version 'bodacious'
games { 'gta5' }