resource_manifest_version "44febabe-d386-4d18-afbe-5e627f4af937"

description 'Mythic Framework Inventory System'

version '1.0'

ui_page 'html/ui.html'

client_scripts {
  'client/main.lua',
  'client/drop.lua',
  'client/container.lua',
  'client/shops.lua',
}

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

files {
    'html/ui.html',
    'html/css/style.min.css',
    'html/js/inventory.js',
    'html/js/config.js',

    'html/css/*.min.css',
    'html/js/*.min.js',
    
    -- IMAGES
    'html/img/bullet.png',
    'html/img/cash.png',
    'html/img/bank.png',
    'html/success.wav',
    'html/fail.wav',
    -- ICONS
    
    'html/img/items/*.png',
}

dependencies {
  'pw_mysql',
  'pw_core',
}