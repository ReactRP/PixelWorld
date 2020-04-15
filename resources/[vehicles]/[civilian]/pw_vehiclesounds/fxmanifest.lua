fx_version 'adamant'
games {'gta5'}

description 'PixelWorld [Addon Vehicle Sounds]'
name 'PixelWorld: [pw_vehiclesounds]'
author 'PixelWorldRP [Dr Nick] - https://pixelworldrp.com'
version 'v1.0.0'

files {
    'audio/elegyx_game.dat151',-- ElegyX
    'audio/elegyx_game.dat151.nametable',
    'audio/elegyx_game.dat151.rel',
    'audio/elegyx_sounds.dat54',
    'audio/elegyx_sounds.dat54.nametable',
    'audio/elegyx_sounds.dat54.rel',
    'audio/sfx/dlc_elegyx/elegyx.awc',
    'audio/sfx/dlc_elegyx/elegyx_npc.awc' -- ElegyX END
}

-- ElegyX (R35 Nismo Sounds)
data_file 'AUDIO_SYNTHDATA' 'audio/elegyx_amp.dat'
data_file 'AUDIO_GAMEDATA' 'audio/elegyx_game.dat'
data_file 'AUDIO_SOUNDDATA' 'audio/elegyx_sounds.dat'
data_file 'AUDIO_WAVEPACK' 'audio/sfx/dlc_elegyx'
-- 
