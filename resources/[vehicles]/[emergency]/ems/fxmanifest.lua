description 'PixelWorld EMS Vehicles'
name 'PixelWorld: ems'
author 'PixelWorldRP [Dr Nick] - https://pixelworldrp.com'

files {
    'handling.meta',
    'vehicles.meta',
    'carcols.meta',
    'carvariations.meta'
}

data_file 'HANDLING_FILE' 'handling.meta'
data_file 'VEHICLE_METADATA_FILE' 'vehicles.meta'
data_file 'CARCOLS_FILE' 'carcols.meta'
data_file 'VEHICLE_VARIATION_FILE' 'carvariations.meta'

client_script {
    'vehicle_names.lua'
}

fx_version 'adamant'
games {'gta5'} 