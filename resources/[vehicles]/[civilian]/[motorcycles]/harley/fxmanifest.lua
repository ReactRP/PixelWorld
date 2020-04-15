description 'PixelWorld Harley Vehicles'
name 'PixelWorld harley'
author 'PixelWorldRP [Panda_builds] - https://pixelworldrp.com'

files {
    'vehicles.meta',
    'carvariations.meta',
    'handling.meta',
}

data_file 'HANDLING_FILE' 'handling.meta'
data_file 'VEHICLE_METADATA_FILE' 'vehicles.meta'
data_file 'VEHICLE_VARIATION_FILE' 'carvariations.meta'


client_script {
    'vehicle_names.lua'
}

fx_version 'adamant'
games {'gta5'}