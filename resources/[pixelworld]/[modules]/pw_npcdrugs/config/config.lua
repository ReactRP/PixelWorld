Config = {}

Config.NPCChance = 100 -- Chance of getting a close NPC with an offer
Config.NPCCooldown = 300 -- Time in seconds that NPC gets blacklisted after being picked the first time
Config.NPCWait = 15 -- Time in seconds that NPC will wait for a decision
Config.FindCooldown = 10 -- Time in seconds between finding nearby peds

Config.MaxQty = {
    ['weed'] = 5,
    ['coke'] = 5
}

Config.Prices = { -- Price PER Bag
    ['weed'] = { ['min'] = 10, ['max'] = 50 },
    ['coke'] = { ['min'] = 10, ['max'] = 50 },
    ['meth'] = { ['min'] = 10, ['max'] = 50 },
}

Config.ItemName = {
    ['weed'] = 'bagofdope',
    ['coke'] = 'coke',
    ['meth'] = 'crack',
}

Config.MethRun = {
    ['location'] = { ['x'] = 434.45, ['y'] = -619.29, ['z'] = 28.5, ['h'] = 84.31 }, --{ ['x'] = -177.45, ['y'] = 6384.54, ['z'] = 31.5, ['h'] = 226.45 },
    ['clerk'] = { "s_m_m_migrant_01", "s_m_m_linecook", "s_m_m_strvend_01", "s_m_y_busboy_01", "mp_m_shopkeep_01", "s_f_y_sweatshop_01", "s_f_y_shop_low", "s_f_y_shop_mid" },
    ['cars'] = { 'r820', 'nismo20' },
    ['spawns'] = {
        { ['x'] = 419.84, ['y'] = -611.19, ['z'] = 27.66, ['h'] = 88.45 },
        { ['x'] = 428.17, ['y'] = -611.32, ['z'] = 27.66, ['h'] = 90.6 },
        { ['x'] = 420.47, ['y'] = -603.96, ['z'] = 27.66, ['h'] = 83.56 }
        --[[ { ['x'] = -154.66, ['y'] = 6389.93, ['z'] = 30.49, ['h'] = 134.22 },
        { ['x'] = -162.27, ['y'] = 6382.71, ['z'] = 30.49, ['h'] = 134.68 },
        { ['x'] = -169.69, ['y'] = 6375.4, ['z'] = 30.49, ['h'] = 135.21 } ]]
    },
    ['qty'] = 30,
    ['price'] = 100,
    ['dropoffs'] = {
        { ['x'] = 409.97, ['y'] = -623.03, ['z'] = 28.7, ['h'] = 186.12 },
        { ['x'] = 398.85, ['y'] = -625.57, ['z'] = 28.7, ['h'] = 243.75 },
        { ['x'] = 393.27, ['y'] = -637.22, ['z'] = 28.53, ['h'] = 188.91 },
        { ['x'] = 390.54, ['y'] = -647.67, ['z'] = 28.74, ['h'] = 291.24 },
        { ['x'] = 390.93, ['y'] = -662.32, ['z'] = 28.8, ['h'] = 339.14 },
        { ['x'] = 407.68, ['y'] = -662.59, ['z'] = 28.71, ['h'] = 349.18 },
        { ['x'] = 420.67, ['y'] = -663.9, ['z'] = 28.93, ['h'] = 1.8 }
        --[[ { ['x'] = -153.5, ['y'] = 6325.97, ['z'] = 31.59, ['h'] = 314.49 },
        { ['x'] = -116.58, ['y'] = 6285.84, ['z'] = 31.3, ['h'] = 276.95 },
        { ['x'] = -132.24, ['y'] = 6266.57, ['z'] = 31.1, ['h'] = 240.93 },
        { ['x'] = -142.43, ['y'] = 6256.66, ['z'] = 31.14, ['h'] = 227.23 } ]]
    },
    ['blips'] = {
        ['scale'] = 1.2,
        ['color'] = 11,
        ['type'] = 480
    },
    ['targets'] = --[[ TODO: change peds later ]] { "s_m_m_migrant_01", "s_m_m_linecook", "s_m_m_strvend_01", "s_m_y_busboy_01", "mp_m_shopkeep_01", "s_f_y_sweatshop_01", "s_f_y_shop_low", "s_f_y_shop_mid" },
    ['maxDuration'] = 10, -- Time in minutes to finish the meth run before it expires
    ['cooldown'] = 1, -- Time in minutes between runs
}