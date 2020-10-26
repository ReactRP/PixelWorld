fx_version 'bodacious'
games {'gta5'} -- 'gta5' for GTAv / 'rdr3' for Red Dead 2, 'gta5','rdr3' for both

description 'SynCity Inventory'
name 'SynCity: [pw_inventory]'
author 'SynCityRP [Chris Rogers & AlzarTV (Mythic)]'
version 'v1.0.0'
url 'https://www.SynCityrp.com'

server_scripts {
  '@pw_mysql/lib/MySQL.lua', -- Required for MySQL Support
  'config.lua',
  'server/startup.lua',
	'server/commands.lua',
  'server/database.lua',
  'server/main.lua',
  'server/drop.lua',
  'server/container.lua',
  'server/shops.lua',
}

client_scripts {
  'client/main.lua',
  'client/drop.lua',
  'client/container.lua',
  'client/shops.lua',
}

ui_page 'html/ui.html'

files {
  'html/*.html',
  'html/css/*.min.css',
  'html/js/*.js',

  'html/css/*.min.css',
  'html/js/*.min.js',
  
  -- IMAGES
  'html/img/*.png',
  'html/*.wav',
  -- ICONS
  'html/img/item/*.png',
}

dependencies {
    'pw_mysql',
    'pw_notify',
    'pw_progbar',
    'pw_core'
}