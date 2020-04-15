description 'PixelWorld Additional Maps'
name 'PixelWorld pw-maps'
author 'PixelWorldRP [Ultrunz] - https://pixelworldrp.com'

client_script "client.lua"

files {
    "interiorproxies.meta"
}

data_file 'INTERIOR_PROXY_ORDER_FILE' 'interiorproxies.meta'
data_file 'DLC_ITYP_REQUEST' 'stream/v_int_49.ytyp'
data_file 'DLC_ITYP_REQUEST' 'stream/int_services.ytyp'

this_is_a_map 'yes'

fx_version 'bodacious'
games {'gta5'}