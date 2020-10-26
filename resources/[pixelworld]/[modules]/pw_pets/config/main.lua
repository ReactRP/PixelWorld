Config = {}

Config.GuardHouseMaxDistance = 100.0
Config.KeyTrigger = 2.0 -- Distance to trigger key press

Config.Locations = {
    ['shop'] = vector3(-662.37, -935.49, 21.83)
}

Config.Blips = {
    ['shop'] = {
        ['blipSprite'] = 442,
        ['blipScale'] = 1.0,
        ['blipColor'] = 46,
        ['text'] = "Pet Shop"
    }
}

Config.Markers = {
    ['shop'] = {
        ['markerType'] = 31,
        ['markerDraw'] = 10.0,
        ['markerSize'] = { ['x'] = 1.0, ['y'] = 1.0, ['z'] = 1.0},
        ['markerColor'] = { ['r'] = 0, ['g'] = 255, ['b'] = 0 },
    }
}

Config.PetTickRates = {
    ['change'] = {  
        ['hunger'] = 1500,
        ['thirst'] = 1000,
        ['excercise'] = 700
    },
    ['maxValue'] = {  
        ['hunger'] = 1000000,
        ['thirst'] = 1000000,
        ['excercise'] = 1000000
    }, 

}

Config.Pets = {
    ['Rottweiler']  = { ['hash'] = 351016938,   ['price'] = 100, ['actions'] = { ['sit'] = true,    ['lay'] = true,     ['beg'] = true,     ['paw'] = true } },
    ['Westie']      = { ['hash'] = -1384627013, ['price'] = 100, ['actions'] = { ['sit'] = false,   ['lay'] = false,    ['beg'] = false,    ['paw'] = false } },
    ['Shepherd']    = { ['hash'] = 1126154828,  ['price'] = 100, ['actions'] = { ['sit'] = true,    ['lay'] = true,     ['beg'] = true,     ['paw'] = true } },
    ['Retriever']   = { ['hash'] = 882848737,   ['price'] = 100, ['actions'] = { ['sit'] = true,    ['lay'] = true,     ['beg'] = true,     ['paw'] = true } },
    ['Pug']         = { ['hash'] = 1832265812,  ['price'] = 100, ['actions'] = { ['sit'] = true,    ['lay'] = true,     ['beg'] = false,    ['paw'] = false } },
    ['Poodle']      = { ['hash'] = 1125994524,  ['price'] = 100, ['actions'] = { ['sit'] = false,   ['lay'] = false,    ['beg'] = false,    ['paw'] = false } },
    ['Husky']       = { ['hash'] = 1318032802,  ['price'] = 100, ['actions'] = { ['sit'] = true,    ['lay'] = true,     ['beg'] = true,     ['paw'] = true } },
}

Config.WestieColors = {
    { ['label'] = "White",  ['id'] = 0 },
    { ['label'] = "Brown",  ['id'] = 1 },
    { ['label'] = "Black",  ['id'] = 2 }
}

Config.PugColors = {
    { ['label'] = "Cream",  ['id'] = 0 },
    { ['label'] = "Gray",   ['id'] = 1 },
    { ['label'] = "Brown" , ['id'] = 2 },
    { ['label'] = "Black",  ['id'] = 3 }
}
-- westie 3
-- pug 4


Config.Needs = {
    ['water']           = { ['label'] = 'Bottled Water',    ['price'] = 100, ['addNeed'] = 50000,   ['hide'] = true },
    ['dogbowl']         = { ['label'] = 'Empty Bowl',       ['price'] = 100 },
    ['cheapdogfood']    = { ['label'] = 'Cheap Dog Food',   ['price'] = 100, ['addNeed'] = 50000    },
    ['premiumdogfood']  = { ['label'] = 'Premium Dog Food', ['price'] = 100, ['addNeed'] = 100000   },
    ['chip']            = { ['label'] = 'Pet Tracker',      ['price'] = 100 }
}