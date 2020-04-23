fx_version 'bodacious'
games {'gta5'} -- 'gta5' for GTAv / 'rdr3' for Red Dead 2, 'gta5','rdr3' for both

description 'PixelWorld Inventory'
name 'PixelWorld: [pw_inventory]'
author 'PixelWorldRP [Chris Rogers & AlzarTV (Mythic)]'
version 'v1.0.0'
url 'https://www.pixelworldrp.com'

server_scripts {
  '@pw_mysql/lib/MySQL.lua', -- Required for MySQL Support
  'config.lua',
	'server/*.lua',
}

client_scripts {
  'client/*.lua',
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
  'html/img/items/*.png',
}

dependencies {
    'pw_mysql',
    'pw_notify',
    'pw_progbar',
    'pw_core'
}