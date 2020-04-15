description 'PixelWorld Karts Vehicles'
name 'PixelWorld karts'
author 'PixelWorldRP [Panda_builds] - https://pixelworldrp.com'

files {
    'vehicles.meta',
    'carvariations.meta',
    'carcols.meta',
    'handling.meta',
    'vehiclelayouts.meta',
}

data_file 'HANDLING_FILE' 'handling.meta'
data_file 'VEHICLE_METADATA_FILE' 'vehicles.meta'
data_file 'CARCOLS_FILE' 'carcols.meta'
data_file 'VEHICLE_VARIATION_FILE' 'carvariations.meta'
data_file 'VEHICLE_LAYOUTS_FILE' 'vehiclelayouts.meta'

-- SERVER SCRIPT ADDED BY CHRIS - LEAVE INTACT AS THIS TELLS THE BASE THE LAST RESOURCE HAS LOADED
server_script {
    'server.lua'
}

client_script {
    'vehicle_names.lua'
}

fx_version 'adamant'
games {'gta5'}