Config = {}

characterCreatorLocations = {
    [1] = { ['inuse'] = false, ['user'] = 0, ['coords'] = {['x'] = 408.78, ['y'] = -998.57, ['z'] = -99.00, ['h'] = 271.38} },
    [2] = { ['inuse'] = false, ['user'] = 0, ['coords'] = {['x'] = 408.78, ['y'] = -998.57, ['z'] = -104.00, ['h'] = 271.38} },
    [3] = { ['inuse'] = false, ['user'] = 0, ['coords'] = {['x'] = 408.78, ['y'] = -998.57, ['z'] = -109.00, ['h'] = 271.38} },
    [4] = { ['inuse'] = false, ['user'] = 0, ['coords'] = {['x'] = 408.78, ['y'] = -998.57, ['z'] = -114.00, ['h'] = 271.38} },
    [5] = { ['inuse'] = false, ['user'] = 0, ['coords'] = {['x'] = 408.78, ['y'] = -998.57, ['z'] = -119.00, ['h'] = 271.38} },
    [6] = { ['inuse'] = false, ['user'] = 0, ['coords'] = {['x'] = 431.09, ['y'] = -998.57, ['z'] = -99.00, ['h'] = 271.38} }, -- Second Row
    [7] = { ['inuse'] = false, ['user'] = 0, ['coords'] = {['x'] = 431.09, ['y'] = -998.57, ['z'] = -104.00, ['h'] = 271.38} },
    [8] = { ['inuse'] = false, ['user'] = 0, ['coords'] = {['x'] = 431.09, ['y'] = -998.57, ['z'] = -109.00, ['h'] = 271.38} },
    [9] = { ['inuse'] = false, ['user'] = 0, ['coords'] = {['x'] = 431.09, ['y'] = -998.57, ['z'] = -114.00, ['h'] = 271.38} },
    [10] = { ['inuse'] = false, ['user'] = 0, ['coords'] = {['x'] = 431.09, ['y'] = -998.57, ['z'] = -119.00, ['h'] = 271.38} },
}

Config.NewCharacters = {
    ['startCash'] = 1000,
    ['startBank'] = 10000,
    ['dailyWithdraw'] = 5000,
    ['needs'] = { ['hunger'] = 100, ['thirst'] = 100, ['armour'] = 0, ['drugs'] = { ['weed'] = 0, ['coke'] = 0, ['meth'] = 0, ['crack'] = 0 }, ['stress'] = 0, ['drunk'] = 0 },
    ['health'] = 200,
    ['job'] = { ['name'] = "unemployed", ['grade'] = "unemployed", ['workplace'] = 0, ['salery'] = 10, ['duty'] = false, ['grade_level'] = 0, ['label'] = "Unemployed", ['grade_label'] = "Unemployed", ['callSign'] = 0},
    ['playtime'] = 0,
}

Config.DecorRegisters = {
    { ['type'] = 3, ['name'] = "player_hunger"},
    { ['type'] = 3, ['name'] = "player_thirst"},
    { ['type'] = 2, ['name'] = "player_owned_veh"},
    { ['type'] = 3, ['name'] = "vehicle_id"},
    { ['type'] = 3, ['name'] = "vehicle_fuel"},
    { ['type'] = 2, ['name'] = "vehicle_fakeplate"},
    { ['type'] = 2, ['name'] = "player_cop"},
    { ['type'] = 2, ['name'] = "player_ems"},
    { ['type'] = 2, ['name'] = "player_admin"},
    { ['type'] = 2, ['name'] = "pw_veh_chopShop"}
}

Config.Discord = {}
Config.Discord.AppID        = 601704277961998346
Config.Discord.AssetLg      = 'pwlarge'
Config.Discord.AssetSm      = 'pwsmall'
Config.Discord.SmallTxt     = 'Signup @ pixelworldrp.com'
Config.Discord.LargeTxt     = 'PixelWorld Roleplay'