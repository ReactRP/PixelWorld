description 'PixelWorld Audi Vehicles'
name 'PixelWorld audi'
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


client_script {
    'vehicle_names.lua'
}

fx_version 'adamant'
games {'gta5'}