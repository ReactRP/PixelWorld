Config = {}

Config.Marker = {
    ['markerType'] = 2,
    ['markerDraw']  = 5.0,
    ['markerSize']  = { ['x'] = 0.5, ['y'] = 0.5, ['z'] = 0.5 },
    ['markerColor'] = { ['r'] = 0, ['g'] = 255, ['b'] = 0 }
}

Config.Blips = {
    ['blipSprite'] = 50,
    ['blipScale'] = 1.0,
    ['color'] = { ['Public'] = 2, ['Impound'] = 3, ['Unit'] = 1, ['Business'] = 5 }
}

Config.PoliceImpoundCost = 100

Config.Insurance = {
    ['buildings'] = {
        {
            ['name'] = "Insurance Company",
            ['coords'] = { ['x'] = -265.85, ['y'] = -960.44, ['z'] = 31.22, ['h'] = 115 },
            ['blip'] = {
                ['sprite'] = 380,
                ['color'] = 46,
            },
        },
    },
    ['plans'] = {                                 -- in jerrycans
        { ['label'] = "Plan 1",     ['tows'] = 5,   ['fuel'] = 5,   ['dailyCost'] = 50  }, 
        { ['label'] = "Plan 2",     ['tows'] = 10,  ['fuel'] = 10,  ['dailyCost'] = 90  },
        { ['label'] = "Plan 3",     ['tows'] = -1,  ['fuel'] = 20,  ['dailyCost'] = 200 } -- -1 = unlimited
    },
    ['vehiclePercentage'] = 1, -- percentage based on vehicle cost to add to plans dailyCost
    ['fuelDeliveryVehicle'] = 'taxi',
    ['fuelDeliveryDriver'] = 'a_m_y_stlat_01', -- ped model
    ['fuelDeliveryJerrycanPicking'] = 15 -- delay for picking a jerrycan at gas station in seconds
}

Config.PumpModels = {
	[-2007231801] = true,
	[1339433404] = true,
	[1694452750] = true,
	[1933174915] = true,
	[-462817101] = true,
	[-469694731] = true,
	[-164877493] = true
}