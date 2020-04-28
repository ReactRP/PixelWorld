Config = {}

Config.TrainStations = {
    ['Metro'] = {
        [1] = { ['name'] = 'Puerto del Sol Southbound', ['trainCoords'] = { ['x'] = -547.34, ['y'] = -1286.16, ['z'] = 25.9 }, ['platformCoords'] = { ['x'] = -544.18, ['y'] = -1287.49, ['z'] = 26.90, ['blip'] = true}},
        [2] = { ['name'] = 'LSIA Parking Southbound', ['trainCoords'] = { ['x'] = -892.51, ['y'] = -2322.65, ['z'] = -12.61 }, ['platformCoords'] = { ['x'] = -890.18, ['y'] = -2325.66, ['z'] = -11.73, ['blip'] = true }},
        [3] = { ['name'] = 'LSIA Terminal 4 Southbound', ['trainCoords'] = { ['x'] = -1100.13, ['y'] = -2724.01, ['z'] = -8.30 }, ['platformCoords'] = { ['x'] = -1097.32, ['y'] = -2725.70, ['z'] = -7.410, ['blip'] = true }},
        [4] = { ['name'] = 'LSIA Terminal 4 Northbound', ['trainCoords'] = { ['x'] = -1071.48, ['y'] = -2713.21, ['z'] = -8.29 }, ['platformCoords'] = { ['x'] = -1074.24, ['y'] = -2710.99, ['z'] = -7.410, ['blip'] = false }},
        [5] = { ['name'] = 'LSIA Parking Northbound', ['trainCoords'] = { ['x'] = -875.61, ['y'] = -2319.86, ['z'] = -12.62 }, ['platformCoords'] = { ['x'] = -879.184, ['y'] = -2316.61, ['z'] = -11.73, ['blip'] = false }},
        [6] = { ['name'] = 'Puerto del Sol Northbound', ['trainCoords'] = { ['x'] = -536.63, ['y'] = -1285.03, ['z'] = 25.90 }, ['platformCoords'] = { ['x'] = -538.93, ['y'] = -1284.08, ['z'] = 26.90, ['blip'] = false }},
        [7] = { ['name'] = 'Strawberry Northbound', ['trainCoords'] = { ['x'] = 270.08, ['y'] = -1209.91, ['z'] = 38.07 }, ['platformCoords'] = { ['x'] = 270.19, ['y'] = -1207.09, ['z'] = 38.90, ['blip'] = true }},
        [8] = { ['name'] = 'Burton Northbound', ['trainCoords'] = { ['x'] = -287.08, ['y'] = -327.46, ['z'] = 9.17 }, ['platformCoords'] = { ['x'] = -290.49, ['y'] = -320.78, ['z'] = 10.06, ['blip'] = true }},
        [9] = { ['name'] = 'Portola Drive Northbound', ['trainCoords'] = { ['x'] = -821.33, ['y'] = -132.45, ['z'] = 19.056 }, ['platformCoords'] = { ['x'] = -819.909, ['y'] = -135.81, ['z'] = 19.95, ['blip'] = true }},
        [10] = { ['name'] = 'Del Perro Northbound', ['trainCoords'] = { ['x'] = -1359.97, ['y'] = -465.32, ['z'] = 14.14 }, ['platformCoords'] = { ['x'] = -1356.27, ['y'] = -464.51, ['z'] = 15.04, ['blip'] = true }},
        [11] = { ['name'] = 'Little Seoul Northbound', ['trainCoords'] = { ['x'] = -498.95, ['y'] = -680.65, ['z'] = 10.91 }, ['platformCoords'] = { ['x'] = -496.44, ['y'] = -676.52, ['z'] = 11.80, ['blip'] = true }},
        [12] = { ['name'] = 'Pillbox South Northbound', ['trainCoords'] = { ['x'] = -217.96, ['y'] = -1032.15, ['z'] = 29.32 }, ['platformCoords'] = { ['x'] = -215.31, ['y'] = -1033.68, ['z'] = 30.14, ['blip'] = true }},
        [13] = { ['name'] = 'Davis Northbound', ['trainCoords'] = { ['x'] = 113.86, ['y'] = -1730.02, ['z'] = 29.05 }, ['platformCoords'] = { ['x'] = 116.028, ['y'] = -1728.66, ['z'] = 30.1, ['blip'] = false }},
        [14] = { ['name'] = 'Davis Southbound', ['trainCoords'] = { ['x'] = 117.32, ['y'] = -1721.93, ['z'] = 29.12 }, ['platformCoords'] = { ['x'] = 115.351, ['y'] = -1723.71, ['z'] = 30.11, ['blip'] = true }},
        [15] = { ['name'] = 'Pillbox South Southbound', ['trainCoords'] = { ['x'] = -209.85, ['y'] = -1037.12, ['z'] = 29.32 }, ['platformCoords'] = { ['x'] = -212.714, ['y'] = -1036.30, ['z'] = 30.13, ['blip'] = false }},
        [16] = { ['name'] = 'Little Seoul Southbound', ['trainCoords'] = { ['x'] = -497.80, ['y'] = -665.53, ['z'] = 10.92 }, ['platformCoords'] = { ['x'] = -498.549, ['y'] = -669.75, ['z'] = 11.80, ['blip'] = false }},
        [17] = { ['name'] = 'Del Perro Southbound', ['trainCoords'] = { ['x'] = -1344.45, ['y'] = -462.13, ['z'] = 14.15 }, ['platformCoords'] = { ['x'] = -1347.5, ['y'] = -463.99, ['z'] = 15.04, ['blip'] = false }},
        [18] = { ['name'] = 'Portola Drive Southbound', ['trainCoords'] = { ['x'] = -806.85, ['y'] = -141.420, ['z'] = 19.05 }, ['platformCoords'] = { ['x'] = -808.54, ['y'] = -138.51, ['z'] = 19.95, ['blip'] = false }},
        [19] = { ['name'] = 'Burton Southbound', ['trainCoords'] = { ['x'] = -302.22, ['y'] = -327.28, ['z'] = 9.17 }, ['platformCoords'] = { ['x'] = -298.83, ['y'] = -327.50, ['z'] = 10.06, ['blip'] = false }},
        [20] = { ['name'] = 'Strawberry Southbound', ['trainCoords'] = { ['x'] = 262.02, ['y'] = -1198.61, ['z'] = 38.07 }, ['platformCoords'] = { ['x'] = 262.12, ['y'] = -1201.20, ['z'] = 38.90, ['blip'] = false }},
    }
    --[[['OuterCity'] = {
        [1] = { ['name'] = 'City 1', ['trainCoords'] = { ['x'] = 664.73, ['y'] = -997.64, ['z'] = 22.26, ['h'] = 350.49 }, ['platformCoords'] = { ['x'] = 662.2, ['y'] = -997.55, ['z'] = 22.26, ['h'] = 97.99, ['blip'] = true }},
    }]]
}

Config.Blips = {
    ['Metro'] = {
        ['blipScale'] = 0.6,
        ['blipSprite'] = 570,
        ['blipColor'] = 66,
        ['blipName'] = "Metro Train Station"
    },
    ['OuterCity'] = {
        ['blipScale'] = 0.6,
        ['blipSprite'] = 570,
        ['blipColor'] = 58,
        ['blipName'] = "Outer City Train Station"
    }
}

Config.Speeds = { -- NOT IN MPH BTW
    ['metro'] = 25.0,
    ['outer'] = 50.0,
}

Config.WaitTimes = { -- In MS
    ['initial'] = {
        ['metro'] = 30000,
        ['outer'] = 30000,
    },
    ['eachStation'] = {
        ['metro'] = 20000,
        ['outer'] = 30000,
    },
}

--[[
    Outer City Trains for Future Reference
---------------------------------------------------------
    2072.4086914063,1569.0856933594,76.712524414063
    664.93090820313,-997.59942626953,22.261747360229
    190.62687683105,-1956.8131103516,19.520135879517
    2611.0278320313,1675.3806152344,26.578210830688
    2615.3901367188,2934.8666992188,39.312232971191
    2885.5346679688,4862.0146484375,62.551517486572
    47.061096191406,6280.8969726563,31.580261230469
    2002.3624267578,3619.8029785156,38.568252563477
    2609.7016601563,2937.11328125,39.418235778809
    
]]
