Config = {}

Config.BreakChance = 50
Config.NeededPolice = 0
Config.TimeToLockdown = 10 -- in minutes / Time between the first spot is broken until starting robbery cooldown
Config.Cooldown = 120 -- in minutes

Config.Spots = {
    [1]     = { ['coords'] = vector3(-626.5326, -238.3758, 38.05),  ['heading'] = 226.86,   ['robbed'] = false, ['caseProp'] = 'cab2' },
    [2]     = { ['coords'] = vector3(-625.6032, -237.5273, 38.05),  ['heading'] = 226.86,   ['robbed'] = false, ['caseProp'] = 'cab3' },
    [3]     = { ['coords'] = vector3(-626.9178, -235.5166, 38.05),  ['heading'] = 34.8,     ['robbed'] = false, ['caseProp'] = 'cab3' },
    [4]     = { ['coords'] = vector3(-625.6701, -234.6061, 38.05),  ['heading'] = 34.8,     ['robbed'] = false, ['caseProp'] = 'cab4' },
    [5]     = { ['coords'] = vector3(-626.8935, -233.0814, 38.05),  ['heading'] = 215.71,   ['robbed'] = false, ['caseProp'] = 'cab' },
    [6]     = { ['coords'] = vector3(-627.9514, -233.8582, 38.05),  ['heading'] = 215.71,   ['robbed'] = false, ['caseProp'] = 'cab' },
    [7]     = { ['coords'] = vector3(-624.5250, -231.0555, 38.05),  ['heading'] = 308.34,   ['robbed'] = false, ['caseProp'] = 'cab4' },
    [8]     = { ['coords'] = vector3(-623.0003, -233.0833, 38.05),  ['heading'] = 308.34,   ['robbed'] = false, ['caseProp'] = 'cab' },
    [9]     = { ['coords'] = vector3(-620.1098, -233.3672, 38.05),  ['heading'] = 28.56,    ['robbed'] = false, ['caseProp'] = 'cab4' },
    [10]    = { ['coords'] = vector3(-620.2979, -234.4196, 38.05),  ['heading'] = 211.21,   ['robbed'] = false, ['caseProp'] = 'cab' },
    [11]    = { ['coords'] = vector3(-619.0646, -233.5629, 38.05),  ['heading'] = 211.21,   ['robbed'] = false, ['caseProp'] = 'cab3' },
    [12]    = { ['coords'] = vector3(-617.4846, -230.6598, 38.05),  ['heading'] = 316.8,    ['robbed'] = false, ['caseProp'] = 'cab2' },
    [13]    = { ['coords'] = vector3(-618.3619, -229.4285, 38.05),  ['heading'] = 316.8,    ['robbed'] = false, ['caseProp'] = 'cab3' },
    [14]    = { ['coords'] = vector3(-619.6064, -230.5518, 38.05),  ['heading'] = 138.95,   ['robbed'] = false, ['caseProp'] = 'cab' },
    [15]    = { ['coords'] = vector3(-620.8951, -228.6519, 38.05),  ['heading'] = 138.95,   ['robbed'] = false, ['caseProp'] = 'cab3' },
    [16]    = { ['coords'] = vector3(-619.7905, -227.5623, 38.05),  ['heading'] = 316.8,    ['robbed'] = false, ['caseProp'] = 'cab2' },
    [17]    = { ['coords'] = vector3(-620.6110, -226.4467, 38.05),  ['heading'] = 316.8,    ['robbed'] = false, ['caseProp'] = 'cab' },
    [18]    = { ['coords'] = vector3(-623.9951, -228.1755, 38.05),  ['heading'] = 226.92,   ['robbed'] = false, ['caseProp'] = 'cab2' },
    [19]    = { ['coords'] = vector3(-624.8832, -227.8645, 38.05),  ['heading'] = 32.55,    ['robbed'] = false, ['caseProp'] = 'cab3' },
    [20]    = { ['coords'] = vector3(-623.6746, -227.0025, 38.05),  ['heading'] = 32.55,    ['robbed'] = false, ['caseProp'] = 'cab4' },
    [21]    = { ['coords'] = vector3(-619.89, -237.42, 38.06),      ['heading'] = 151.5,    ['robbed'] = false, ['type'] = 'necklaces' },
    [22]    = { ['coords'] = vector3(-618.63, -237.68, 38.06),      ['heading'] = 184.58,   ['robbed'] = false, ['type'] = 'necklaces' },
    [23]    = { ['coords'] = vector3(-617.38, -237.33, 38.06),      ['heading'] = 224.35,   ['robbed'] = false, ['type'] = 'necklaces' },
    [24]    = { ['coords'] = vector3(-616.54, -236.35, 38.06),      ['heading'] = 257.91,   ['robbed'] = false, ['type'] = 'necklaces' },
    [25]    = { ['coords'] = vector3(-616.47, -235.05, 38.06),      ['heading'] = 282.72,   ['robbed'] = false, ['type'] = 'necklaces' },
    [26]    = { ['coords'] = vector3(-624.25, -224.12, 38.06),      ['heading'] = 335.29,   ['robbed'] = false, ['type'] = 'necklaces' },
    [27]    = { ['coords'] = vector3(-625.52, -223.8, 38.06),       ['heading'] = 358.65,   ['robbed'] = false, ['type'] = 'necklaces' },
    [28]    = { ['coords'] = vector3(-626.76, -224.2, 38.06),       ['heading'] = 27.26,    ['robbed'] = false, ['type'] = 'necklaces' },
    [29]    = { ['coords'] = vector3(-627.6, -225.21, 38.06),       ['heading'] = 71.04,    ['robbed'] = false, ['type'] = 'necklaces' },
    [30]    = { ['coords'] = vector3(-627.75, -226.54, 38.06),      ['heading'] = 106.03,   ['robbed'] = false, ['type'] = 'necklaces' }
}

Config.Safes = {
    { ['safe'] = { ['coords'] = vector3(-616.69, -233.14, 38.52),   ['heading'] = 271.0},   ['frame'] = { ['coords'] = vector3(-617.03, -233.14, 37.84), ['heading'] = 270.97,  ['model'] = "v_ret_mirror" } },
    { ['safe'] = { ['coords'] = vector3(-622.67, -224.84, 38.49),   ['heading'] = 341.08},  ['frame'] = { ['coords'] = vector3(-622.75, -225.14, 37.95), ['heading'] = 340.89,  ['model'] = "v_ilev_trev_pictureframe" } },
    { ['safe'] = { ['coords'] = vector3(-627.5299, -228.4, 38.55),  ['heading'] = 92.08},   ['frame'] = { ['coords'] = vector3(-627.19, -228.37, 37.89), ['heading'] = 90.59,   ['model'] = "v_ret_mirror" } },
    { ['safe'] = { ['coords'] = vector3(-621.47, -236.6299, 38.52), ['heading'] = 161.08},  ['frame'] = { ['coords'] = vector3(-621.37, -236.31, 37.91), ['heading'] = 160.65,  ['model'] = "v_ilev_trev_pictureframe" } },
}

Config.Award = {
    { ['item'] = 'ring',       ['min'] = 1, ['max'] = 5 },
    { ['item'] = 'earring',    ['min'] = 1, ['max'] = 5 },
    { ['item'] = 'watch',      ['min'] = 1, ['max'] = 3 },
    { ['item'] = 'necklace',   ['min'] = 1, ['max'] = 3 }, -- necklaces in the necklace spots (Spots #21-30 will only award 1 necklace)
    { ['item'] = 'bracelet',   ['min'] = 1, ['max'] = 5 },
    { ['item'] = 'diamond',    ['min'] = 1, ['max'] = 3 }
}

Config.SafeAward = { ['min'] = 1, ['max'] = 10 } -- Value goods to award ofter safe cracking

Config.WeaponsAllowed = { -- 0 = won't break, 1 = Chance of breaking, 2 = always breaks
    ['banned'] = 0,
    ['explosive'] = 0,
    ['knife'] = 1,
    ['hand'] = 1,
    ['automatic'] = 2,
    ['rifle'] = 2,
    ['sniper'] = 2,
    ['shotgun'] = 2,
    ['normal'] = 2
}