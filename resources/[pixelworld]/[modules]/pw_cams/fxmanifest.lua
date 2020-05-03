fx_version 'bodacious'
games {'gta5'} -- 'gta5' for GTAv / 'rdr3' for Red Dead 2, 'gta5','rdr3' for both

description 'PixelWorld [Script Full Name]'
name 'PixelWorld: [resourcefoldername]'
author 'PixelWorldRP [Author]'
version 'v1.0.0'
url 'https://www.pixelworldrp.com'

client_scripts {
    'config/config.lua',
    'client/client.lua',
}

ui_page 'ui/index.html' -- Only Required if implementing a NUI

files { -- Any NUI Files also need to be loaded here.
    "ui/index.html",
    "ui/vue.min.js",
    "ui/script.js",
    "ui/cam.png"
}

dependencies {
    'pw_mysql',
    'pw_notify',
    'pw_progbar',
    'pw_core'
}