description 'PixelWorld Alternate Pillbox'
name 'PixelWorld pw-alternatepillbox'
author 'PixelWorldRP [Ultrunz] - https://pixelworldrp.com'

files {
    "interiorproxies.meta",
    "gabz_timecycle_mods_1.xml"
}

data_file 'INTERIOR_PROXY_ORDER_FILE' 'interiorproxies.meta'
data_file 'TIMECYCLEMOD_FILE' 'gabz_timecycle_mods_1.xml'

client_script {
    "main.lua"
}

this_is_a_map 'yes'

fx_version 'bodacious'
games {'gta5'}